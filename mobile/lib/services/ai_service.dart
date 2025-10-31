/**
 * AI Service
 * 
 * Handles AI-powered task insights using Google Gemini API.
 * Analyzes user task data and generates productivity recommendations.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class AIService {
  static const String _geminiApiKey = 'AIzaSyB38iiitB0SPujfTggC5UFEgG-jXLd7UOE';
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$_geminiApiKey';

  /**
   * Generate AI-powered productivity insights based on task data
   * 
   * @param tasks - Array of task objects to analyze
   * @returns Map containing success status, insights text, and statistics
   */
  static Future<Map<String, dynamic>> generateTaskInsights(List<Task> tasks) async {
    try {
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.completed).length;
      final pendingTasks = tasks.where((t) => !t.completed).length;
      final overdueTasks = tasks.where((t) => t.isOverdue).length;

      final upcomingDeadlines = tasks
          .where((t) => t.deadline != null && !t.completed)
          .toList()
            ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
      final topDeadlines = upcomingDeadlines.take(3).map((t) {
        final daysLeft = t.deadline!.difference(DateTime.now()).inDays;
        return {'title': t.title, 'daysLeft': daysLeft};
      }).toList();

      final prompt = _buildPrompt(totalTasks, completedTasks, pendingTasks, overdueTasks, topDeadlines, tasks);

      final response = await http.post(
        Uri.parse(_geminiApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

        return {
          'success': true,
          'insights': text,
          'stats': {
            'totalTasks': totalTasks,
            'completedTasks': completedTasks,
            'pendingTasks': pendingTasks,
            'overdueTasks': overdueTasks,
            'completionRate': totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0,
          }
        };
      } else {
        throw Exception('Failed to generate insights');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static String _buildPrompt(
    int totalTasks,
    int completedTasks,
    int pendingTasks,
    int overdueTasks,
    List<Map<String, dynamic>> upcomingDeadlines,
    List<Task> tasks,
  ) {
    final deadlinesText = upcomingDeadlines.isEmpty
        ? 'No upcoming deadlines'
        : upcomingDeadlines.map((t) => '- "${t['title']}" in ${t['daysLeft']} day(s)').join('\n');

    final tasksText = tasks
        .take(20)
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final i = entry.key;
          final t = entry.value;
          return '${i + 1}. ${t.title} - ${t.completed ? 'Completed' : 'Pending'} ${t.deadline != null ? '(Due: ${_formatDate(t.deadline!)})' : ''}';
        })
        .join('\n');

    return '''You are a productivity coach providing task management insights. Based on the following user's task data, provide 3-4 specific, actionable insights to help them improve productivity:

Task Statistics:
- Total Tasks: $totalTasks
- Completed: $completedTasks
- Pending: $pendingTasks
- Overdue: $overdueTasks

$deadlinesText

Tasks List:
$tasksText

Please provide:
1. Specific productivity suggestions based on their current task load
2. Tips to handle overdue tasks if any
3. Deadlines management recommendations
4. General task organization advice

Keep the response concise, friendly, and actionable. Format each insight as a bullet point.''';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

