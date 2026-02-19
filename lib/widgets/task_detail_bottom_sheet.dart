import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant_task.dart';
import '../services/reminder_service.dart';
import '../config/app_theme.dart';

class TaskDetailBottomSheet extends StatefulWidget {
  final PlantTask task;
  final VoidCallback? onTaskCompleted;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    this.onTaskCompleted,
  });

  @override
  State<TaskDetailBottomSheet> createState() => _TaskDetailBottomSheetState();
}

class _TaskDetailBottomSheetState extends State<TaskDetailBottomSheet> {
  final ReminderService _reminderService = ReminderService();
  late List<TaskItem> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.task.tasks);
  }

  Future<void> _toggleTaskComplete(int index) async {
    final task = _tasks[index];
    if (task.reminderId == null) return;

    await _reminderService.toggleReminderComplete(task.reminderId!);

    setState(() {
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
    });

    widget.onTaskCompleted?.call();

    // Check if all tasks are now completed
    final allDone = _tasks.every((t) => t.isCompleted);
    if (allDone) {
      _showCompletionAndClose();
    }
  }

  Future<void> _markAllComplete() async {
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.reminderId != null && !task.isCompleted) {
        await _reminderService.toggleReminderComplete(task.reminderId!);
        setState(() {
          _tasks[i] = task.copyWith(isCompleted: true);
        });
      }
    }
    widget.onTaskCompleted?.call();
    _showCompletionAndClose();
  }

  void _showCompletionAndClose() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${widget.task.plantName} tasks completed!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.task.borderColor == 'orange'
        ? Colors.orange.shade400
        : Colors.green.shade400;

    final allCompleted = _tasks.every((t) => t.isCompleted);
    final pendingCount = _tasks.where((t) => !t.isCompleted).length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: borderColor.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with plant info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Plant image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: widget.task.plantImage.isNotEmpty &&
                            File(widget.task.plantImage).existsSync()
                        ? Image.file(
                            File(widget.task.plantImage),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade800,
                                child: Icon(
                                  Icons.local_florist,
                                  color: borderColor,
                                  size: 32,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade800,
                            child: Icon(
                              Icons.local_florist,
                              color: borderColor,
                              size: 32,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Plant name and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.plantName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: borderColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          allCompleted
                              ? 'All done!'
                              : '$pendingCount task${pendingCount > 1 ? 's' : ''} pending',
                          style: TextStyle(
                            color: borderColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  borderColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Tasks section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Task items
                ..._tasks.asMap().entries.map((entry) {
                  return _buildTaskItem(entry.key, entry.value, borderColor);
                }),
              ],
            ),
          ),

          // Care tips if available
          if (widget.task.careInstructions != null &&
              widget.task.careInstructions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.task.careInstructions!,
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Mark all complete button
          if (!allCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _markAllComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Mark All Complete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildTaskItem(int index, TaskItem task, Color accentColor) {
    IconData icon;
    switch (task.icon) {
      case 'water':
        icon = Icons.water_drop;
        break;
      case 'fertilizer':
        icon = Icons.eco;
        break;
      default:
        icon = Icons.check_circle_outline;
    }

    final isCompleted = task.isCompleted;
    final canToggle = task.reminderId != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: canToggle ? () => _toggleTaskComplete(index) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.3)
                  : accentColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isCompleted ? Colors.green : accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Task name
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    color: isCompleted ? Colors.grey : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),

              // Task value
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.15)
                      : accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.value,
                  style: TextStyle(
                    color: isCompleted ? Colors.green : accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (canToggle) ...[
                const SizedBox(width: 12),
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green
                          : Colors.grey.shade600,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Show the task detail bottom sheet
void showTaskDetailBottomSheet(
  BuildContext context, {
  required PlantTask task,
  VoidCallback? onTaskCompleted,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => TaskDetailBottomSheet(
      task: task,
      onTaskCompleted: onTaskCompleted,
    ),
  );
}
