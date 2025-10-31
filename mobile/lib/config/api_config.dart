/**
 * API Configuration
 * 
 * Contains backend API base URL and endpoint constants.
 * All API endpoints are defined here for consistency.
 */

class ApiConfig {
  // Backend API base URL
  static const String baseUrl = 'https://zylentrix-backend.onrender.com';
  
  // Authentication endpoints
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  
  // Task endpoints
  static const String tasks = '/api/tasks';
  
  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Helper method to build task URL with ID
  static String taskById(String id) {
    return '$baseUrl$tasks/$id';
  }
}

