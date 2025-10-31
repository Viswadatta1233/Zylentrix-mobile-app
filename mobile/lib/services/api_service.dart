/**
 * API Service
 * 
 * Handles all HTTP requests to the backend API.
 * Manages authentication headers and error handling.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class ApiService {
  final StorageService _storage = StorageService();
  
  // Get authorization headers with token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (includeAuth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('[HEADERS] Authorization header added (token length: ${token.length})');
      } else {
        print('[HEADERS] No token available for Authorization');
      }
    }
    
    return headers;
  }
  
  // Authentication APIs
  
  Future<String> signup(String name, String email, String password) async {
    final url = ApiConfig.buildUrl(ApiConfig.signup);
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(includeAuth: false),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']?['token'] ?? data['token'];
      return token;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Signup failed');
    }
  }
  
  Future<String> login(String email, String password) async {
    final url = ApiConfig.buildUrl(ApiConfig.login);
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']?['token'] ?? data['token'];
      return token;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }
  
  Future<User> getCurrentUser() async {
    try {
      final url = ApiConfig.buildUrl(ApiConfig.me);
      print('[GET_CURRENT_USER] Fetching from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('[GET_CURRENT_USER] Status: ${response.statusCode}');
      print('[GET_CURRENT_USER] Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'] ?? data;
        return User.fromJson(userData);
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      print('[GET_CURRENT_USER] Error: $e');
      rethrow;
    }
  }
  
  // Task APIs
  
  Future<List<Task>> getTasks() async {
    try {
      final url = ApiConfig.buildUrl(ApiConfig.tasks);
      final headers = await _getHeaders();
      
      print('========== GET_TASKS START ==========');
      print('[GET_TASKS] URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('[GET_TASKS] Status code: ${response.statusCode}');
      print('[GET_TASKS] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[GET_TASKS] Parsed data: $data');
        final tasksData = data['data'] ?? data;
        print('[GET_TASKS] Tasks data: $tasksData');
        if (tasksData is List) {
          print('[GET_TASKS] Converting ${tasksData.length} tasks');
          return tasksData.map((json) => Task.fromJson(json)).toList();
        }
        print('[GET_TASKS] No tasks data or not a list');
        return [];
      } else if (response.statusCode == 401) {
        // Unauthorized - clear token and throw
        await _storage.clearToken();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to fetch tasks');
      }
    } catch (e) {
      print('[GET_TASKS] Exception caught: $e');
      rethrow;
    }
  }
  
  Future<Task> createTask(Task task) async {
    try {
      final url = ApiConfig.buildUrl(ApiConfig.tasks);
      final jsonBody = task.toJson();
      final headers = await _getHeaders();
      
      print('========== CREATE_TASK START ==========');
      print('[CREATE_TASK] URL: $url');
      print('[CREATE_TASK] Headers: $headers');
      print('[CREATE_TASK] Request body (raw): $jsonBody');
      print('[CREATE_TASK] Request body (JSON): ${jsonEncode(jsonBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(jsonBody),
      );
      
      print('[CREATE_TASK] Status code: ${response.statusCode}');
      print('[CREATE_TASK] Response headers: ${response.headers}');
      print('[CREATE_TASK] Response body: ${response.body}');
      print('========== CREATE_TASK END ==========');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[CREATE_TASK] Parsed data: $data');
        final taskData = data['data'] ?? data;
        return Task.fromJson(taskData);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Failed to create task';
        print('[CREATE_TASK] Error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('[CREATE_TASK] Exception caught: $e');
      rethrow;
    }
  }
  
  Future<Task> updateTask(Task task) async {
    try {
      final url = ApiConfig.taskById(task.id);
      final jsonBody = task.toJson();
      final headers = await _getHeaders();
      
      print('========== UPDATE_TASK START ==========');
      print('[UPDATE_TASK] URL: $url');
      print('[UPDATE_TASK] Headers: $headers');
      print('[UPDATE_TASK] Request body (raw): $jsonBody');
      print('[UPDATE_TASK] Request body (JSON): ${jsonEncode(jsonBody)}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(jsonBody),
      );
      
      print('[UPDATE_TASK] Status code: ${response.statusCode}');
      print('[UPDATE_TASK] Response headers: ${response.headers}');
      print('[UPDATE_TASK] Response body: ${response.body}');
      print('========== UPDATE_TASK END ==========');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[UPDATE_TASK] Parsed data: $data');
        final taskData = data['data'] ?? data;
        return Task.fromJson(taskData);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Failed to update task';
        print('[UPDATE_TASK] Error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('[UPDATE_TASK] Exception caught: $e');
      rethrow;
    }
  }
  
  Future<void> deleteTask(String id) async {
    final url = ApiConfig.taskById(id);
    final response = await http.delete(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}

