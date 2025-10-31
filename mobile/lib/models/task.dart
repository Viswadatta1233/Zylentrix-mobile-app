/**
 * Task Model
 * 
 * Represents a task in the application.
 * Maps to the backend Task model with field conversions.
 */

class Task {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String status; // 'Pending' or 'Done' for backend
  final DateTime? deadline;
  final DateTime? createdAt;
  
  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.completed,
    required this.status,
    this.deadline,
    this.createdAt,
  });
  
  // Factory constructor to create Task from JSON (backend format)
  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime? deadline;
    if (json['deadline'] != null) {
      try {
        deadline = DateTime.parse(json['deadline']);
        print('[TASK.fromJson] Parsed deadline: ${json['deadline']} -> $deadline');
      } catch (e) {
        print('[TASK.fromJson] Failed to parse deadline: ${json['deadline']} - $e');
        deadline = null;
      }
    }
    
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt']);
      } catch (e) {
        print('[TASK.fromJson] Failed to parse createdAt: ${json['createdAt']} - $e');
        createdAt = null;
      }
    }
    
    return Task(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Convert backend status string to boolean
      completed: json['status'] == 'Done' || json['completed'] == true,
      status: json['status'] ?? 'Pending',
      deadline: deadline,
      createdAt: createdAt,
    );
  }
  
  // Convert Task to JSON for backend (backend format)
  Map<String, dynamic> toJson() {
    final deadlineStr = deadline != null ? deadline!.toUtc().toIso8601String() : null;
    print('[TASK.toJson] Converting deadline to ISO: $deadline -> $deadlineStr');
    return {
      'title': title,
      'description': description,
      'status': status, // Backend uses 'Done' or 'Pending'
      'deadline': deadlineStr,
    };
  }
  
  // Convert Task to JSON for backend update
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> json = {};
    if (title.isNotEmpty) json['title'] = title;
    if (description.isNotEmpty) json['description'] = description;
    json['status'] = status;
    if (deadline != null) {
      final deadlineStr = deadline!.toUtc().toIso8601String();
      print('[TASK.toUpdateJson] Converting deadline to ISO: $deadline -> $deadlineStr');
      json['deadline'] = deadlineStr;
    }
    return json;
  }
  
  // Copy with method for immutable updates
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    String? status,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Check if task is overdue
  bool get isOverdue {
    if (deadline == null || completed) return false;
    // Convert deadline to UTC for comparison (handles both UTC and local DateTime)
    final deadlineUtc = deadline!.isUtc ? deadline! : deadline!.toUtc();
    return deadlineUtc.isBefore(DateTime.now().toUtc());
  }
}

