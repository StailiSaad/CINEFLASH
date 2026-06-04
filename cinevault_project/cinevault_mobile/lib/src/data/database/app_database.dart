import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// --- Data Models ---

class LocalMovy {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final String mediaType;
  final bool isTrending;
  final bool isPopular;
  final bool isTopRated;
  final DateTime cachedAt;

  LocalMovy({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    required this.mediaType,
    this.isTrending = false,
    this.isPopular = false,
    this.isTopRated = false,
    required this.cachedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'mediaType': mediaType,
      'isTrending': isTrending ? 1 : 0,
      'isPopular': isPopular ? 1 : 0,
      'isTopRated': isTopRated ? 1 : 0,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  factory LocalMovy.fromMap(Map<String, dynamic> map) {
    return LocalMovy(
      id: map['id'],
      title: map['title'],
      overview: map['overview'],
      posterPath: map['posterPath'],
      backdropPath: map['backdropPath'],
      releaseDate: map['releaseDate'],
      voteAverage: map['voteAverage']?.toDouble(),
      mediaType: map['mediaType'],
      isTrending: map['isTrending'] == 1,
      isPopular: map['isPopular'] == 1,
      isTopRated: map['isTopRated'] == 1,
      cachedAt: DateTime.parse(map['cachedAt']),
    );
  }
}

class WatchlistMovy {
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final bool isSynced;
  final DateTime addedAt;

  WatchlistMovy({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    this.isSynced = false,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tmdbId': tmdbId,
      'mediaType': mediaType,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'isSynced': isSynced ? 1 : 0,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WatchlistMovy.fromMap(Map<String, dynamic> map) {
    return WatchlistMovy(
      tmdbId: map['tmdbId'],
      mediaType: map['mediaType'],
      title: map['title'],
      posterPath: map['posterPath'],
      overview: map['overview'],
      releaseDate: map['releaseDate'],
      voteAverage: map['voteAverage']?.toDouble(),
      isSynced: map['isSynced'] == 1,
      addedAt: DateTime.parse(map['addedAt']),
    );
  }
}

class WatchedMovy {
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final double? rating;
  final bool isSynced;
  final DateTime watchedAt;

  WatchedMovy({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.rating,
    this.isSynced = false,
    required this.watchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tmdbId': tmdbId,
      'mediaType': mediaType,
      'title': title,
      'posterPath': posterPath,
      'rating': rating,
      'isSynced': isSynced ? 1 : 0,
      'watchedAt': watchedAt.toIso8601String(),
    };
  }

  factory WatchedMovy.fromMap(Map<String, dynamic> map) {
    return WatchedMovy(
      tmdbId: map['tmdbId'],
      mediaType: map['mediaType'],
      title: map['title'],
      posterPath: map['posterPath'],
      rating: map['rating']?.toDouble(),
      isSynced: map['isSynced'] == 1,
      watchedAt: DateTime.parse(map['watchedAt']),
    );
  }
}

// --- AppDatabase ---

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'cineflash_db.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_movies (
        id INTEGER NOT NULL,
        mediaType TEXT NOT NULL,
        title TEXT NOT NULL,
        overview TEXT,
        posterPath TEXT,
        backdropPath TEXT,
        releaseDate TEXT,
        voteAverage REAL,
        isTrending INTEGER NOT NULL DEFAULT 0,
        isPopular INTEGER NOT NULL DEFAULT 0,
        isTopRated INTEGER NOT NULL DEFAULT 0,
        cachedAt TEXT NOT NULL,
        PRIMARY KEY (id, mediaType)
      )
    ''');

    await db.execute('''
      CREATE TABLE watchlist_movies (
        tmdbId INTEGER NOT NULL,
        mediaType TEXT NOT NULL,
        title TEXT NOT NULL,
        posterPath TEXT,
        overview TEXT,
        releaseDate TEXT,
        voteAverage REAL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        addedAt TEXT NOT NULL,
        PRIMARY KEY (tmdbId, mediaType)
      )
    ''');

    await db.execute('''
      CREATE TABLE watched_movies (
        tmdbId INTEGER NOT NULL,
        mediaType TEXT NOT NULL,
        title TEXT NOT NULL,
        posterPath TEXT,
        rating REAL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        watchedAt TEXT NOT NULL,
        PRIMARY KEY (tmdbId, mediaType)
      )
    ''');
  }

  // --- Local Movies Queries ---

  Future<List<LocalMovy>> getTrendingMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_movies',
      where: 'isTrending = ? AND mediaType = ?',
      whereArgs: [1, 'movie'],
    );
    return maps.map((e) => LocalMovy.fromMap(e)).toList();
  }

  Future<List<LocalMovy>> getTrendingTv() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_movies',
      where: 'isTrending = ? AND mediaType = ?',
      whereArgs: [1, 'tv'],
    );
    return maps.map((e) => LocalMovy.fromMap(e)).toList();
  }

  Future<List<LocalMovy>> getPopularMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_movies',
      where: 'isPopular = ? AND mediaType = ?',
      whereArgs: [1, 'movie'],
    );
    return maps.map((e) => LocalMovy.fromMap(e)).toList();
  }

  Future<List<LocalMovy>> getTopRatedMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_movies',
      where: 'isTopRated = ? AND mediaType = ?',
      whereArgs: [1, 'movie'],
    );
    return maps.map((e) => LocalMovy.fromMap(e)).toList();
  }

  Future<void> cacheMovies(List<LocalMovy> movies, {bool trending = false, bool popular = false, bool topRated = false}) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final movie in movies) {
        final existingMaps = await txn.query('local_movies', where: 'id = ? AND mediaType = ?', whereArgs: [movie.id, movie.mediaType]);
        
        bool isT = trending;
        bool isP = popular;
        bool isTr = topRated;
        
        if (existingMaps.isNotEmpty) {
           final existing = LocalMovy.fromMap(existingMaps.first);
           isT = trending || existing.isTrending;
           isP = popular || existing.isPopular;
           isTr = topRated || existing.isTopRated;
        }
        
        final updatedMovie = LocalMovy(
          id: movie.id,
          title: movie.title,
          overview: movie.overview,
          posterPath: movie.posterPath,
          backdropPath: movie.backdropPath,
          releaseDate: movie.releaseDate,
          voteAverage: movie.voteAverage,
          mediaType: movie.mediaType,
          isTrending: isT,
          isPopular: isP,
          isTopRated: isTr,
          cachedAt: DateTime.now()
        );
        
        await txn.insert(
          'local_movies',
          updatedMovie.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> clearWatchlistAndWatched() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('watchlist_movies');
      await txn.delete('watched_movies');
    });
  }

  // --- Watchlist Queries ---

  Future<List<WatchlistMovy>> getWatchlist() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('watchlist_movies');
    return maps.map((e) => WatchlistMovy.fromMap(e)).toList();
  }

  Future<void> addToWatchlist(WatchlistMovy movie) async {
    final db = await database;
    await db.insert(
      'watchlist_movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromWatchlist(int tmdbId, String mediaType) async {
    final db = await database;
    await db.delete(
      'watchlist_movies',
      where: 'tmdbId = ? AND mediaType = ?',
      whereArgs: [tmdbId, mediaType],
    );
  }

  Future<bool> isInWatchlist(int tmdbId, String mediaType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watchlist_movies',
      where: 'tmdbId = ? AND mediaType = ?',
      whereArgs: [tmdbId, mediaType],
    );
    return maps.isNotEmpty;
  }

  // --- Watched Queries ---

  Future<List<WatchedMovy>> getWatchedMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('watched_movies');
    return maps.map((e) => WatchedMovy.fromMap(e)).toList();
  }

  Future<void> markAsWatched(WatchedMovy movie) async {
    final db = await database;
    await db.insert(
      'watched_movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromWatched(int tmdbId, String mediaType) async {
    final db = await database;
    await db.delete(
      'watched_movies',
      where: 'tmdbId = ? AND mediaType = ?',
      whereArgs: [tmdbId, mediaType],
    );
  }

  Future<bool> isWatched(int tmdbId, String mediaType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watched_movies',
      where: 'tmdbId = ? AND mediaType = ?',
      whereArgs: [tmdbId, mediaType],
    );
    return maps.isNotEmpty;
  }
}