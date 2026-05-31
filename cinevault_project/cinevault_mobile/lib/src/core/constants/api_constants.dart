class ApiConstants {
  // API Base URL - Updated for Hugging Face Space
  static const String baseUrl = 'https://sdawgxxx-cineflash.hf.space';

  // Local development
  static const String localBaseUrl = 'http://localhost:8080';

  // TMDB Image URLs
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';

  // API Endpoints
  static const String moviesTrending = '/api/v1/movies/trending';
  static const String moviesTopRated = '/api/v1/movies/top-rated';
  static const String moviesPopular = '/api/v1/movies/popular';
  static const String moviesSearch = '/api/v1/movies/search';
  static const String tvSearch = '/api/v1/tv/search';
  static const String multiSearch = '$tmdbBaseUrl/search/multi';
  
  // TV endpoints
  static const String tvTrending = '/api/v1/tv/trending';
  static const String tvPopular = '/api/v1/tv/popular';
  static const String movieDetails = '/api/v1/movies';
  static const String authLogin = '/api/v1/auth/login';
  static const String authMe = '/api/v1/auth/me';
  static const String watchlist = '/api/v1/watchlist';
  static const String watched = '/api/v1/watched';
  static const String aiSentiment = '/api/v1/ai/sentiment';
  static const String aiRecommendations = '/api/v1/ai/recommendations';

  // TMDB Direct API (Fallback)
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbApiKey = 'e9c68f17bb0613ed4dc60ce2b3ac7e62';

  // Supabase Configuration
  static const String supabaseUrl = 'https://eomiilauphxypqlefejg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvbWlpbGF1cGh4eXBxbGVmZWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyMzQ4MzksImV4cCI6MjA5MzgxMDgzOX0.k29rJW7SXXBSEv5uWGkUo1qMbP_XOt6PKlKB6g_iML0';
}
