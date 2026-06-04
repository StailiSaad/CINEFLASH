import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart';
import 'package:cineflash/src/data/repositories/movie_repository.dart';
import 'package:cineflash/src/presentation/blocs/app/app_bloc.dart';
import 'package:cineflash/src/presentation/blocs/movies/movies_bloc.dart';
import '../../data/database/app_database.dart';
import '../../data/datasources/movie_api_service.dart';
import '../../data/datasources/supabase_service.dart';


final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Database
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);
  
  // Supabase
  getIt.registerSingleton<SupabaseService>(SupabaseService());
  
  // Network
  final client = Client();
  getIt.registerSingleton<Client>(client);
  
  // API Service
  final apiService = MovieApiService(client);
  getIt.registerSingleton<MovieApiService>(apiService);
  
  // Repository
  getIt.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(getIt<MovieApiService>(), getIt<AppDatabase>()),
  );
  
  // Blocs
  getIt.registerFactory<AppBloc>(() => AppBloc());
  getIt.registerFactory<MoviesBloc>(
    () => MoviesBloc(movieRepository: getIt<MovieRepository>()),
  );
}
