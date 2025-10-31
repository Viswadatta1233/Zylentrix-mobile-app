/**
 * User Model
 * 
 * Represents a user in the application.
 * Maps to the backend User model.
 */

class User {
  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });
  
  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }
  
  // Convert User to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
  
  // Get user's initial (first letter of name)
  String get initial {
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return 'U';
  }
}

