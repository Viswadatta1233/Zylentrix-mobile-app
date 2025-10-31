/**
 * Task Provider
 * 
 * Manages task state throughout the app.
 * Handles CRUD operations and filtering.
 */

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all'; // 'all', 'completed', 'pending'
  String _sortBy = 'createdAt'; // 'createdAt', 'deadline', 'title'
  bool _sortDesc = true; // true for descending, false for ascending
  
  final ApiService _apiService = ApiService();
  
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  String get sortBy => _sortBy;
  bool get sortDesc => _sortDesc;
  
  // Get filtered and sorted tasks
  List<Task> get filteredTasks {
    var filtered = List<Task>.from(_tasks);
    
    // Apply status filter
    if (_filterStatus == 'completed') {
      filtered = filtered.where((t) => t.completed).toList();
    } else if (_filterStatus == 'pending') {
      filtered = filtered.where((t) => !t.completed).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      
      if (_sortBy == 'createdAt') {
        final aDate = a.createdAt ?? DateTime(0);
        final bDate = b.createdAt ?? DateTime(0);
        comparison = aDate.compareTo(bDate);
      } else if (_sortBy == 'deadline') {
        final aDate = a.deadline ?? DateTime.now().add(Duration(days: 365));
        final bDate = b.deadline ?? DateTime.now().add(Duration(days: 365));
        comparison = aDate.compareTo(bDate);
      } else if (_sortBy == 'title') {
        comparison = a.title.compareTo(b.title);
      }
      
      return _sortDesc ? -comparison : comparison;
    });
    
    return filtered;
  }
  
  // Get statistics
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.completed).length;
  int get pendingTasks => _tasks.where((t) => !t.completed).length;
  
  // Fetch all tasks
  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _tasks = await _apiService.getTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Create task
  Future<bool> createTask(Task task) async {
    try {
      final created = await _apiService.createTask(task);
      _tasks.insert(0, created);
      
      // Schedule notifications if task has a deadline
      if (created.deadline != null && !created.completed) {
        await NotificationService.scheduleTaskNotifications(
          taskId: created.id,
          taskTitle: created.title,
          deadline: created.deadline!,
          isCompleted: created.completed,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      // Get old task state to check if completion status changed
      final oldTask = _tasks.firstWhere(
        (t) => t.id == task.id,
        orElse: () => task,
      );
      
      final updated = await _apiService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _tasks[index] = updated;
        
        // Handle notifications
        if (updated.completed && !oldTask.completed) {
          // Task was marked as completed - cancel notifications
          await NotificationService.cancelTaskNotifications(updated.id);
        } else if (!updated.completed && updated.deadline != null) {
          // Task is pending and has a deadline - reschedule notifications
          await NotificationService.cancelTaskNotifications(updated.id);
          await NotificationService.scheduleTaskNotifications(
            taskId: updated.id,
            taskTitle: updated.title,
            deadline: updated.deadline!,
            isCompleted: updated.completed,
          );
        }
        
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Delete task
  Future<bool> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      
      // Cancel notifications for deleted task
      await NotificationService.cancelTaskNotifications(id);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Set filter status
  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }
  
  // Set sort options
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }
  
  // Toggle sort direction
  void toggleSortDirection() {
    _sortDesc = !_sortDesc;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

