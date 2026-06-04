import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AppEvent extends Equatable {
  const AppEvent();
  
  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {}
class ToggleTheme extends AppEvent {}
class SetOfflineMode extends AppEvent {
  final bool isOffline;
  const SetOfflineMode(this.isOffline);
}

// States
abstract class AppState extends Equatable {
  const AppState();
  
  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {}

class AppReady extends AppState {
  final bool isDarkMode;
  final bool isOffline;
  final bool isAuthenticated;
  
  const AppReady({
    this.isDarkMode = false,
    this.isOffline = false,
    this.isAuthenticated = false,
  });
  
  AppReady copyWith({
    bool? isDarkMode,
    bool? isOffline,
    bool? isAuthenticated,
  }) {
    return AppReady(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isOffline: isOffline ?? this.isOffline,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
  
  @override
  List<Object?> get props => [isDarkMode, isOffline, isAuthenticated];
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<ToggleTheme>(_onToggleTheme);
    on<SetOfflineMode>(_onSetOfflineMode);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    // Initialize app state
    emit(const AppReady());
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<AppState> emit) async {
    if (state is AppReady) {
      final current = state as AppReady;
      emit(current.copyWith(isDarkMode: !current.isDarkMode));
    }
  }

  Future<void> _onSetOfflineMode(SetOfflineMode event, Emitter<AppState> emit) async {
    if (state is AppReady) {
      final current = state as AppReady;
      emit(current.copyWith(isOffline: event.isOffline));
    }
  }
}