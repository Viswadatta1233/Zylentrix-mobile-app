/**
 * AI Insights Widget
 * 
 * Displays AI-powered productivity recommendations using Google Gemini.
 * Parses and displays insights in a structured, colorful format.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/ai_service.dart';
import '../config/app_colors.dart';

class AIInsightsWidget extends StatefulWidget {
  const AIInsightsWidget({super.key});

  @override
  State<AIInsightsWidget> createState() => _AIInsightsWidgetState();
}

class _AIInsightsWidgetState extends State<AIInsightsWidget> {
  Map<String, dynamic>? _insights;
  bool _loading = false;
  String? _error;
  bool _isExpanded = false;

  Future<void> _handleGetInsights() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasks = taskProvider.tasks;

    if (tasks.isEmpty) {
      setState(() {
        _error = 'Please add some tasks first to get AI insights.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AIService.generateTaskInsights(tasks);
      setState(() {
        _loading = false;
        if (result['success'] == true) {
          _insights = result;
          _isExpanded = true; // Auto-expand when insights are loaded
        } else {
          _error = result['error'] ?? 'Failed to generate insights';
        }
      });
    } catch (err) {
      setState(() {
        _loading = false;
        _error = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  List<Map<String, dynamic>> _parseInsights(String text) {
    final insightsArray = <Map<String, dynamic>>[];
    final bulletPoints = text.split(RegExp(r'\n(?=\*)')).where((line) => line.trim().isNotEmpty);

    for (final point in bulletPoints) {
      final trimmed = point.trim();
      if (trimmed.isEmpty ||
          trimmed.startsWith('Okay') ||
          trimmed.toLowerCase().contains('here are some insights')) {
        continue;
      }

      final match = RegExp(r'\*\s*\*\*(.*?)\*\*\s*:?\s*(.*)').firstMatch(trimmed);
      if (match != null) {
        final title = match.group(1)?.trim().replaceAll(RegExp(r'^\d+\.\s*'), '') ?? '';
        var content = match.group(2)?.trim().replaceAll(RegExp(r'\*\*'), '').replaceAll('*', '') ?? '';

        if (title.isNotEmpty && content.isNotEmpty) {
          insightsArray.add({'title': title, 'content': content});
        }
      }
    }

    return insightsArray;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF9333EA).withOpacity(0.3)
                  : const Color(0xFF9333EA).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9333EA), Color(0xFFDB2777)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Insights',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Get personalized recommendations',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_insights != null && !_isExpanded)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = true;
                            });
                          },
                          icon: const Icon(Icons.expand_more),
                          color: const Color(0xFF9333EA),
                        ),
                      ElevatedButton.icon(
                        onPressed: _loading || taskProvider.tasks.isEmpty ? null : _handleGetInsights,
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_loading ? 'Analyzing...' : 'Get Insights'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9333EA),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF9333EA).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
                  ),
                ),
              ],

              if (_insights != null && _isExpanded) ...[
                const SizedBox(height: 16),
                _buildInsightsContent(_insights!, isDark),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Close Insights'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsContent(Map<String, dynamic> insights, bool isDark) {
    // Stats summary
    final stats = insights['stats'] as Map<String, dynamic>?;
    final parsedInsights = _parseInsights(insights['insights'] as String? ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stats != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF374151)]
                    : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', stats['totalTasks'], AppColors.primaryBlue, isDark),
                _buildStatItem('Done', stats['completedTasks'], AppColors.successGreen, isDark),
                _buildStatItem('Pending', stats['pendingTasks'], AppColors.warningOrange, isDark),
                _buildStatItem('Overdue', stats['overdueTasks'], AppColors.errorRed, isDark),
                _buildStatItem('Rate', '${stats['completionRate']}%', AppColors.primaryPurple, isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Recommendations header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF9333EA) : const Color(0xFFE9D5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: isDark ? Colors.white : const Color(0xFF9333EA),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Personalized Recommendations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Insights cards
        if (parsedInsights.isNotEmpty)
          ...parsedInsights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            final colors = _getColors(index);
            return _buildInsightCard(insight, colors, isDark);
          }),
      ],
    );
  }

  Widget _buildStatItem(String label, dynamic value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight, Map<String, dynamic> colors, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colors['border'].withOpacity(0.5), width: 3)),
        boxShadow: [
          BoxShadow(
            color: (colors['border'] as Color).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors['gradient'] as List<Color>),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['content'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getColors(int index) {
    final colorSchemes = [
      {
        'gradient': [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
        'border': const Color(0xFF2563EB),
      },
      {
        'gradient': [const Color(0xFF9333EA), const Color(0xFFA855F7)],
        'border': const Color(0xFF9333EA),
      },
      {
        'gradient': [const Color(0xFFDB2777), const Color(0xFFEC4899)],
        'border': const Color(0xFFDB2777),
      },
      {
        'gradient': [const Color(0xFF16A34A), const Color(0xFF22C55E)],
        'border': const Color(0xFF16A34A),
      },
      {
        'gradient': [const Color(0xFFEA580C), const Color(0xFFF97316)],
        'border': const Color(0xFFEA580C),
      },
    ];
    return colorSchemes[index % colorSchemes.length];
  }
}

