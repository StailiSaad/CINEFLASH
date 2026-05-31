import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../data/database/app_database.dart';
import '../../data/datasources/movie_api_service.dart';
import 'package:cineflash/src/data/repositories/movie_repository.dart';
import 'package:cineflash/src/presentation/blocs/app/app_bloc.dart';
import 'package:cineflash/src/presentation/blocs/movies/movies_bloc.dart';

import '../../data/datasources/supabase_service.dart';


final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Manual registrations
  
  // Database
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);
  
  // Supabase
  getIt.registerSingleton<SupabaseService>(SupabaseService());
  
  // Network
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print('[NETWORK] REQUEST[${options.method}] => PATH: ${options.path}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('[NETWORK] RESPONSE[${response.statusCode}]');
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      print('[NETWORK] ERROR[${e.response?.statusCode}] => ${e.type}: ${e.message}');
      return handler.next(e);
    },
  ));
  getIt.registerSingleton<Dio>(dio);
  
  // API Service
  final apiService = MovieApiService(dio);
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
