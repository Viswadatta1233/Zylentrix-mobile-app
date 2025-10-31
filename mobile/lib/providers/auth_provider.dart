/**
 * Auth Provider
 * 
 * Manages authentication state throughout the app.
 * Handles login, signup, logout, and user persistence.
 */

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  // Initialize auth state from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        print('[AUTH] Token found, fetching user data...');
        // Try to fetch current user
        _user = await _apiService.getCurrentUser();
        await _storage.saveUser(_user!);
        print('[AUTH] User data loaded: ${_user?.name}');
      } else {
        print('[AUTH] No token found');
      }
    } catch (e) {
      print('[AUTH] Error loading user: $e');
      // If fetch fails, clear storage
      await _storage.clearAuth();
      _user = null;
    }
    
    // 🕒 Force a short splash delay so the splash animation is visible
    print('[AUTH] Waiting 2 seconds for splash...');
    await Future.delayed(const Duration(seconds: 2));
    
    _isLoading = false;
    notifyListeners();
    print('[AUTH] Initialization complete. Authenticated: ${_user != null}');
  }
  
  // Signup
  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final token = await _apiService.signup(name, email, password);
      await _storage.saveToken(token);
      
      // Fetch user data
      _user = await _apiService.getCurrentUser();
      await _storage.saveUser(_user!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final token = await _apiService.login(email, password);
      await _storage.saveToken(token);
      
      // Fetch user data
      _user = await _apiService.getCurrentUser();
      await _storage.saveUser(_user!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    // Cancel all notifications when user logs out
    await NotificationService.cancelAll();
    
    _user = null;
    _error = null;
    await _storage.clearAuth();
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

