import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/presentation/blocs/app/app_bloc.dart';
import 'src/presentation/blocs/movies/movies_bloc.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/di/injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/constants/api_constants.dart';
import 'src/data/datasources/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );
  // Initialize dependencies
  await configureDependencies();
  
  // Trigger background sync for unsynced local data
  getIt<SupabaseService>().syncLocalToCloud();
  
  runApp(const CineFlashApp());
}

class CineFlashApp extends StatelessWidget {
  const CineFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AppBloc>()..add(AppStarted()),
        ),
        BlocProvider(
          create: (_) => getIt<MoviesBloc>(),
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final isDark = state is AppReady ? state.isDarkMode : false;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'CineFlash',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}