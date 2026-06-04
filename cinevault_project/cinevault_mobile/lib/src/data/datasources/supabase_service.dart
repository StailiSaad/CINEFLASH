import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;
  final AppDatabase _database = AppDatabase();

  SupabaseService() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (session != null && (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession)) {
        print('SUPABASE AUTH STATE: Signed In / Initial Session loaded. Triggering syncLocalToCloud...');
        await syncLocalToCloud();
      }
    });
  }

  String? _parseReleaseDate(String? date) {
    if (date == null || date.trim().isEmpty) return null;
    try {
      DateTime.parse(date);
      return date;
    } catch (_) {
      if (RegExp(r'^\d{4}$').hasMatch(date.trim())) {
        return '${date.trim()}-01-01';
      }
      return null;
    }
  }

  // --- Authentication Methods ---

  Future<Result<AuthResponse>> signUpWithEmail(String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);
      
      // Auto-insert user into public.users table if it exists
      if (res.user != null) {
        await _syncUserProfile(res.user!.id, email);
      }
      
      return Result.success(res);
    } catch (e) {
      return Result.failure(Exception(e.toString()));
    }
  }

  Future<Result<AuthResponse>> signInWithEmail(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(email: email, password: password);
      
      if (res.user != null) {
        await _syncUserProfile(res.user!.id, email);
      }
      
      return Result.success(res);
    } catch (e) {
      return Result.failure(Exception(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Clear user data on logout
      await _database.clearWatchlistAndWatched();
    } catch (e) {
      print('SUPABASE SERVICE ERROR (Sign out): $e');
    }
  }

  Future<void> _syncUserProfile(String userId, String email) async {
    try {
      // Upsert into users table if table exists
      await _supabase.from('users').upsert({
        'id': userId,
        'email': email,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('SUPABASE SERVICE ERROR (User Profile Sync): $e');
    }
  }

  // --- Watchlist Sync Methods ---

  Future<void> uploadWatchlistItem(WatchlistMovy movie) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      // Ensure user profile is synced first to satisfy foreign key constraint
      await _syncUserProfile(user.id, user.email ?? '');

      // Check if item already exists to prevent duplicate insertion
      final existing = await _supabase
          .from('watchlist_items')
          .select('id')
          .match({
            'user_id': user.id,
            'tmdb_id': movie.tmdbId,
            'media_type': movie.mediaType,
          });

      final parsedDate = _parseReleaseDate(movie.releaseDate);

      if (existing.isNotEmpty) {
        final existingId = existing.first['id'];
        await _supabase.from('watchlist_items').update({
          'title': movie.title,
          'poster_path': movie.posterPath,
          'overview': movie.overview,
          'release_date': parsedDate,
          'vote_average': movie.voteAverage,
          'added_at': movie.addedAt.toIso8601String(),
        }).eq('id', existingId);
      } else {
        await _supabase.from('watchlist_items').insert({
          'user_id': user.id,
          'tmdb_id': movie.tmdbId,
          'media_type': movie.mediaType,
          'title': movie.title,
          'poster_path': movie.posterPath,
          'overview': movie.overview,
          'release_date': parsedDate,
          'vote_average': movie.voteAverage,
          'added_at': movie.addedAt.toIso8601String(),
        });
      }

      // Mark as synced locally
      final db = await _database.database;
      await db.update(
        'watchlist_movies',
        {'isSynced': 1},
        where: 'tmdbId = ? AND mediaType = ?',
        whereArgs: [movie.tmdbId, movie.mediaType],
      );
    } catch (e) {
      print('SUPABASE SYNC ERROR (Watchlist upload): $e');
    }
  }

  Future<void> removeWatchlistItem(int tmdbId, String mediaType) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _supabase
          .from('watchlist_items')
          .delete()
          .match({
            'user_id': user.id,
            'tmdb_id': tmdbId,
            'media_type': mediaType,
          });
    } catch (e) {
      print('SUPABASE SYNC ERROR (Watchlist delete): $e');
    }
  }

  // --- Watched Sync Methods ---

  Future<void> uploadWatchedItem(WatchedMovy movie) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      // Ensure user profile is synced first to satisfy foreign key constraint
      await _syncUserProfile(user.id, user.email ?? '');

      // Check if item already exists to prevent duplicate insertion
      final existing = await _supabase
          .from('watched_items')
          .select('id')
          .match({
            'user_id': user.id,
            'tmdb_id': movie.tmdbId,
            'media_type': movie.mediaType,
          });

      if (existing.isNotEmpty) {
        final existingId = existing.first['id'];
        await _supabase.from('watched_items').update({
          'title': movie.title,
          'poster_path': movie.posterPath,
          'vote_average': movie.rating,
          'watched_at': movie.watchedAt.toIso8601String(),
        }).eq('id', existingId);
      } else {
        await _supabase.from('watched_items').insert({
          'user_id': user.id,
          'tmdb_id': movie.tmdbId,
          'media_type': movie.mediaType,
          'title': movie.title,
          'poster_path': movie.posterPath,
          'vote_average': movie.rating,
          'watched_at': movie.watchedAt.toIso8601String(),
        });
      }

      // Mark as synced locally
      final db = await _database.database;
      await db.update(
        'watched_movies',
        {'isSynced': 1},
        where: 'tmdbId = ? AND mediaType = ?',
        whereArgs: [movie.tmdbId, movie.mediaType],
      );
    } catch (e) {
      print('SUPABASE SYNC ERROR (Watched upload): $e');
    }
  }

  Future<void> removeWatchedItem(int tmdbId, String mediaType) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _supabase
          .from('watched_items')
          .delete()
          .match({
            'user_id': user.id,
            'tmdb_id': tmdbId,
            'media_type': mediaType,
          });
    } catch (e) {
      print('SUPABASE SYNC ERROR (Watched delete): $e');
    }
  }

  // --- Bulk Local database Sync on startup/login ---

  Future<void> syncLocalToCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final db = await _database.database;
      
      // Sync Watchlist
      final watchlistMaps = await db.query('watchlist_movies', where: 'isSynced = ?', whereArgs: [0]);
      final watchlistItems = watchlistMaps.map((e) => WatchlistMovy.fromMap(e)).toList();
      for (final item in watchlistItems) {
        await uploadWatchlistItem(item);
      }

      // Sync Watched
      final watchedMaps = await db.query('watched_movies', where: 'isSynced = ?', whereArgs: [0]);
      final watchedItems = watchedMaps.map((e) => WatchedMovy.fromMap(e)).toList();
      for (final item in watchedItems) {
        await uploadWatchedItem(item);
      }
    } catch (e) {
      print('SUPABASE SYNC ERROR (Sync local to cloud): $e');
    }
  }

  // --- Data Restoration Engine (Cloud to Local) ---

  Future<void> restoreDataFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Wipe local tables
      await _database.clearWatchlistAndWatched();

      // 2. Fetch Watchlist from cloud
      final List<dynamic> watchlistData = await _supabase
          .from('watchlist_items')
          .select()
          .eq('user_id', user.id);

      // 3. Fetch Watched from cloud
      List<dynamic> watchedData = [];
      try {
        watchedData = await _supabase
            .from('watched_items')
            .select()
            .eq('user_id', user.id);
      } catch (e) {
        print('SUPABASE RESTORE WARNING (Could not fetch watched_items - table might not exist yet): $e');
      }

      final db = await _database.database;

      // 4. Save Watchlist locally
      await db.transaction((txn) async {
        for (final row in watchlistData) {
          final movie = WatchlistMovy(
            tmdbId: row['tmdb_id'],
            mediaType: row['media_type'],
            title: row['title'],
            posterPath: row['poster_path'],
            overview: row['overview'],
            releaseDate: row['release_date'],
            voteAverage: (row['vote_average'] as num?)?.toDouble(),
            isSynced: true,
            addedAt: row['added_at'] != null ? DateTime.parse(row['added_at']) : DateTime.now(),
          );
          await txn.insert(
            'watchlist_movies',
            movie.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      // 5. Save Watched locally
      if (watchedData.isNotEmpty) {
        await db.transaction((txn) async {
          for (final row in watchedData) {
            final movie = WatchedMovy(
              tmdbId: row['tmdb_id'],
              mediaType: row['media_type'],
              title: row['title'],
              posterPath: row['poster_path'],
              rating: (row['vote_average'] as num?)?.toDouble(),
              isSynced: true,
              watchedAt: row['watched_at'] != null ? DateTime.parse(row['watched_at']) : DateTime.now(),
            );
            await txn.insert(
              'watched_movies',
              movie.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        });
      }
      
      print('SUPABASE RESTORE SUCCESS: Restored ${watchlistData.length} watchlist items and ${watchedData.length} watched items.');
    } catch (e) {
      print('SUPABASE RESTORE ERROR: $e');
    }
  }
}
