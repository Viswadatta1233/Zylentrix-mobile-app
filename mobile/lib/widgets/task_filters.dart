/**
 * Task Filters Widget
 * 
 * Provides filtering and sorting options for tasks.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../config/app_colors.dart';

class TaskFiltersWidget extends StatelessWidget {
  const TaskFiltersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: taskProvider.filterStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.filter_list),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkCardBackground : Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      taskProvider.setFilterStatus(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Sort button
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => _showSortDialog(context, taskProvider),
                tooltip: 'Sort',
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showSortDialog(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Date Created'),
              value: 'createdAt',
              groupValue: taskProvider.sortBy,
              onChanged: (value) {
                if (value != null) taskProvider.setSortBy(value);
              },
            ),
            RadioListTile<String>(
              title: const Text('Deadline'),
              value: 'deadline',
              groupValue: taskProvider.sortBy,
              onChanged: (value) {
                if (value != null) taskProvider.setSortBy(value);
              },
            ),
            RadioListTile<String>(
              title: const Text('Title'),
              value: 'title',
              groupValue: taskProvider.sortBy,
              onChanged: (value) {
                if (value != null) taskProvider.setSortBy(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskProvider.toggleSortDirection();
            },
            child: Text(taskProvider.sortDesc ? 'Descending ▼' : 'Ascending ▲'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

