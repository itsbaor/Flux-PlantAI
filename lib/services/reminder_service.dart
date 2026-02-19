import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

/// Service to manage plant reminders
class ReminderService {
  static const String _remindersKey = 'plant_reminders';
  static final ReminderService _instance = ReminderService._internal();

  factory ReminderService() {
    return _instance;
  }

  ReminderService._internal();

  /// Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(_remindersKey);

      if (remindersJson == null || remindersJson.isEmpty) {
        return [];
      }

      final List<dynamic> remindersList = jsonDecode(remindersJson);
      return remindersList.map((json) => Reminder.fromJson(json)).toList();
    } catch (e) {
      print('Error loading reminders: $e');
      return [];
    }
  }

  /// Get reminders for a specific day
  Future<List<Reminder>> getRemindersForDay(DateTime day) async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) {
      // Check if reminder matches the day
      if (reminder.dateTime.year == day.year &&
          reminder.dateTime.month == day.month &&
          reminder.dateTime.day == day.day) {
        return true;
      }

      // Check repeating reminders
      switch (reminder.repeat) {
        case ReminderRepeat.daily:
          return true;
        case ReminderRepeat.weekly:
          return reminder.dateTime.weekday == day.weekday;
        case ReminderRepeat.monthly:
          return reminder.dateTime.day == day.day;
        case ReminderRepeat.once:
          return false;
      }
    }).toList();
  }

  /// Get reminders for a specific plant
  Future<List<Reminder>> getRemindersForPlant(String plantId) async {
    final reminders = await getAllReminders();
    return reminders.where((r) => r.plantId == plantId).toList();
  }

  /// Add a reminder
  Future<bool> addReminder(Reminder reminder) async {
    try {
      final reminders = await getAllReminders();
      reminders.add(reminder);
      return await _saveReminders(reminders);
    } catch (e) {
      print('Error adding reminder: $e');
      return false;
    }
  }

  /// Update a reminder
  Future<bool> updateReminder(Reminder updatedReminder) async {
    try {
      final reminders = await getAllReminders();
      final index = reminders.indexWhere((r) => r.id == updatedReminder.id);

      if (index == -1) {
        return false;
      }

      reminders[index] = updatedReminder;
      return await _saveReminders(reminders);
    } catch (e) {
      print('Error updating reminder: $e');
      return false;
    }
  }

  /// Toggle reminder completion status
  Future<bool> toggleReminderComplete(String reminderId) async {
    try {
      final reminders = await getAllReminders();
      final index = reminders.indexWhere((r) => r.id == reminderId);

      if (index == -1) {
        return false;
      }

      reminders[index] = reminders[index].copyWith(
        isCompleted: !reminders[index].isCompleted,
      );
      return await _saveReminders(reminders);
    } catch (e) {
      print('Error toggling reminder: $e');
      return false;
    }
  }

  /// Remove a reminder
  Future<bool> removeReminder(String reminderId) async {
    try {
      final reminders = await getAllReminders();
      reminders.removeWhere((r) => r.id == reminderId);
      return await _saveReminders(reminders);
    } catch (e) {
      print('Error removing reminder: $e');
      return false;
    }
  }

  /// Remove all reminders for a plant
  Future<bool> removeRemindersForPlant(String plantId) async {
    try {
      final reminders = await getAllReminders();
      reminders.removeWhere((r) => r.plantId == plantId);
      return await _saveReminders(reminders);
    } catch (e) {
      print('Error removing reminders for plant: $e');
      return false;
    }
  }

  /// Clear all reminders
  Future<bool> clearAllReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_remindersKey);
    } catch (e) {
      print('Error clearing reminders: $e');
      return false;
    }
  }

  /// Save reminders to storage
  Future<bool> _saveReminders(List<Reminder> reminders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = jsonEncode(reminders.map((r) => r.toJson()).toList());
      return await prefs.setString(_remindersKey, remindersJson);
    } catch (e) {
      print('Error saving reminders: $e');
      return false;
    }
  }

  /// Get today's pending reminders count
  Future<int> getTodayPendingCount() async {
    final todayReminders = await getRemindersForDay(DateTime.now());
    return todayReminders.where((r) => !r.isCompleted).length;
  }
}
