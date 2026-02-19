class PlantTask {
  final String id;
  final String plantName;
  final String plantImage;
  final int taskCount;
  final List<TaskItem> tasks;
  final String borderColor;
  final String? careInstructions;

  PlantTask({
    required this.id,
    required this.plantName,
    required this.plantImage,
    required this.taskCount,
    required this.tasks,
    this.borderColor = 'green',
    this.careInstructions,
  });

  PlantTask copyWith({
    String? id,
    String? plantName,
    String? plantImage,
    int? taskCount,
    List<TaskItem>? tasks,
    String? borderColor,
    String? careInstructions,
  }) {
    return PlantTask(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      plantImage: plantImage ?? this.plantImage,
      taskCount: taskCount ?? this.taskCount,
      tasks: tasks ?? this.tasks,
      borderColor: borderColor ?? this.borderColor,
      careInstructions: careInstructions ?? this.careInstructions,
    );
  }
}

class TaskItem {
  final String name;
  final String value;
  final String icon;
  final String? reminderId;
  final bool isCompleted;

  TaskItem({
    required this.name,
    required this.value,
    required this.icon,
    this.reminderId,
    this.isCompleted = false,
  });

  TaskItem copyWith({
    String? name,
    String? value,
    String? icon,
    String? reminderId,
    bool? isCompleted,
  }) {
    return TaskItem(
      name: name ?? this.name,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      reminderId: reminderId ?? this.reminderId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
