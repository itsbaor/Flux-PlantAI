import 'package:flutter/material.dart';
import '../models/plant_task.dart';
import '../models/care_guide.dart';
import '../widgets/scan_card.dart';
import '../widgets/plant_task_card.dart';
import '../widgets/care_guide_card.dart';
import '../widgets/app_background.dart';
import '../services/garden_service.dart';
import '../services/reminder_service.dart';
import '../models/reminder.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GardenService _gardenService = GardenService();
  final ReminderService _reminderService = ReminderService();

  final List<String> categories = [
    'All',
    'Watering',
    'Light',
    'Maintenance',
    'Health',
  ];

  int selectedCategory = 0;
  List<PlantTask> tasks = [];
  bool _isLoading = true;

  // Get care guides from data
  final List<CareGuide> careGuides = CareGuidesData.getAllGuides();

  List<CareGuide> get filteredCareGuides {
    if (selectedCategory == 0) {
      return careGuides; // All
    }
    final categoryMap = {
      1: 'Watering', // Watering
      2: 'Light', // Light
      3: 'Maintenance', // Maintenance
      4: 'Health', // Health
    };
    final selectedCategoryName = categoryMap[selectedCategory];
    if (selectedCategoryName == null) return careGuides;
    return careGuides.where((g) => g.category == selectedCategoryName).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final plants = await _gardenService.getAllPlants();
      final todayReminders = await _reminderService.getRemindersForDay(DateTime.now());

      final List<PlantTask> plantTasks = [];

      for (final plant in plants) {
        // Get reminders for this plant
        final plantReminders = todayReminders.where((r) => r.plantId == plant.id).toList();

        // Create task items from reminders or default care tasks
        List<TaskItem> taskItems = [];

        if (plantReminders.isNotEmpty) {
          for (final reminder in plantReminders) {
            taskItems.add(TaskItem(
              name: reminder.typeLabel,
              value: reminder.type == ReminderType.watering
                  ? '${plant.waterMl ?? 250} ml'
                  : '100 g',
              icon: reminder.type == ReminderType.watering ? 'water' : 'fertilizer',
              reminderId: reminder.id,
              isCompleted: reminder.isCompleted,
            ));
          }
        } else {
          // Default tasks based on plant care info
          taskItems = [
            TaskItem(
              name: 'Watering',
              value: '${plant.waterMl ?? 250} ml',
              icon: 'water',
            ),
          ];
        }

        // Only show tasks if there are pending items
        final pendingTasks = taskItems.where((t) => !t.isCompleted).toList();
        if (pendingTasks.isNotEmpty) {
          plantTasks.add(PlantTask(
            id: plant.id,
            plantName: plant.name,
            plantImage: plant.imagePath,
            taskCount: pendingTasks.length,
            borderColor: plant.healthStatus == 'excellent' || plant.healthStatus == 'good'
                ? 'green'
                : 'orange',
            tasks: taskItems,
            careInstructions: plant.careInstructions?.isNotEmpty == true
                ? plant.careInstructions!.first
                : null,
          ));
        }
      }

      setState(() {
        tasks = plantTasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        tasks = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(left: 20, top: 60),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(-20 * (1 - value), 0),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.green.shade200,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'Welcome,',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ScanCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Your tasks for today 👋',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF90EE90),
                      ),
                    ),
                  )
                else if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_florist_outlined,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No plants in your garden yet',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scan a plant to add it to your garden',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...tasks.asMap().entries.map((entry) {
                    return PlantTaskCard(
                      task: entry.value,
                      index: entry.key,
                      onTaskCompleted: _loadTasks,
                    );
                  }),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Care guide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedCategory == index;
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value.clamp(0.0, 1.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            Colors.green.shade400,
                                            Colors.green.shade500,
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green.shade400
                                        : Colors.green.shade700.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.green.shade400
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    categories[index],
                                    style: TextStyle(
                                      color:
                                          isSelected ? Colors.black : Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (filteredCareGuides.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CareGuideCard(
                      guide: filteredCareGuides[0],
                      isLarge: true,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (filteredCareGuides.length > 1)
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredCareGuides.length - 1,
                        itemBuilder: (context, index) {
                          return CareGuideCard(
                            guide: filteredCareGuides[index + 1],
                          );
                        },
                      ),
                    ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            color: Colors.grey[500],
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No guides in this category',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
