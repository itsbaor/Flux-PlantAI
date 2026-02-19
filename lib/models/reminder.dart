enum ReminderType {
  watering,
  fertilizing,
}

enum ReminderRepeat {
  once,
  daily,
  weekly,
  monthly,
}

class Reminder {
  final String id;
  final String plantId;
  final String plantName;
  final String plantImageUrl;
  final ReminderType type;
  final DateTime dateTime;
  final ReminderRepeat repeat;
  final String? remindMeAbout;
  final DateTime? previousWatering;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.plantImageUrl,
    required this.type,
    required this.dateTime,
    this.repeat = ReminderRepeat.once,
    this.remindMeAbout,
    this.previousWatering,
    this.isCompleted = false,
  });

  Reminder copyWith({
    String? id,
    String? plantId,
    String? plantName,
    String? plantImageUrl,
    ReminderType? type,
    DateTime? dateTime,
    ReminderRepeat? repeat,
    String? remindMeAbout,
    DateTime? previousWatering,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      plantImageUrl: plantImageUrl ?? this.plantImageUrl,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      repeat: repeat ?? this.repeat,
      remindMeAbout: remindMeAbout ?? this.remindMeAbout,
      previousWatering: previousWatering ?? this.previousWatering,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      plantName: json['plantName'] as String,
      plantImageUrl: json['plantImageUrl'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ReminderType.watering,
      ),
      dateTime: DateTime.parse(json['dateTime'] as String),
      repeat: ReminderRepeat.values.firstWhere(
        (e) => e.toString() == json['repeat'],
        orElse: () => ReminderRepeat.once,
      ),
      remindMeAbout: json['remindMeAbout'] as String?,
      previousWatering: json['previousWatering'] != null
          ? DateTime.parse(json['previousWatering'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'plantName': plantName,
      'plantImageUrl': plantImageUrl,
      'type': type.toString(),
      'dateTime': dateTime.toIso8601String(),
      'repeat': repeat.toString(),
      'remindMeAbout': remindMeAbout,
      'previousWatering': previousWatering?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  String get typeLabel {
    switch (type) {
      case ReminderType.watering:
        return 'Watering';
      case ReminderType.fertilizing:
        return 'Fertilizing';
    }
  }

  String get repeatLabel {
    switch (repeat) {
      case ReminderRepeat.once:
        return 'Once';
      case ReminderRepeat.daily:
        return 'Daily';
      case ReminderRepeat.weekly:
        return 'Weekly';
      case ReminderRepeat.monthly:
        return 'Monthly';
    }
  }
}
