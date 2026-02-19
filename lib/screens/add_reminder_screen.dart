import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/reminder.dart';
import '../models/plant.dart';
import '../widgets/app_background.dart';
import '../services/garden_service.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final GardenService _gardenService = GardenService();

  List<Plant> _plants = [];
  Plant? _selectedPlant;
  bool _isLoading = true;

  String _remindMeAbout = 'Watering';
  ReminderRepeat _repeat = ReminderRepeat.weekly;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  DateTime? _previousWatering;

  ReminderType _selectedType = ReminderType.watering;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final plants = await _gardenService.getAllPlants();
      setState(() {
        _plants = plants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading plants: $e');
      setState(() {
        _plants = [];
        _isLoading = false;
      });
    }
  }

  void _selectPlant() {
    if (_plants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No plants in your garden. Scan a plant first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a plant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _plants.length,
                    itemBuilder: (context, index) {
                      final plant = _plants[index];
                      final isSelected = _selectedPlant?.id == plant.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlant = plant;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF90EE90)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: plant.imagePath.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(plant.imagePath),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.local_florist,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.local_florist,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plant.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      plant.scientificName,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF90EE90),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectReminderType() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the type of reminder you want to create',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _buildTypeOption(
                'Watering',
                'remind to water you plants regularly',
                Icons.water_drop,
                ReminderType.watering,
              ),
              const SizedBox(height: 12),
              _buildTypeOption(
                'Fertilizing',
                'remind you to fertilize you plant',
                Icons.grass,
                ReminderType.fertilizing,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeOption(
    String title,
    String subtitle,
    IconData icon,
    ReminderType type,
  ) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _remindMeAbout = title;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF90EE90) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF90EE90),
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF90EE90),
              ),
          ],
        ),
      ),
    );
  }

  void _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF90EE90),
              onPrimary: Colors.black,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF90EE90),
              onPrimary: Colors.black,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectRepeat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Repeat frequency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...ReminderRepeat.values.map((repeat) {
                final isSelected = _repeat == repeat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _repeat = repeat;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF90EE90)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getRepeatLabel(repeat),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF90EE90),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getRepeatLabel(ReminderRepeat repeat) {
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

  void _saveReminder() {
    if (_selectedPlant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plant'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantId: _selectedPlant!.id,
      plantName: _selectedPlant!.name,
      plantImageUrl: _selectedPlant!.imagePath,
      type: _selectedType,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      repeat: _repeat,
      remindMeAbout: _remindMeAbout,
      previousWatering: _previousWatering,
    );

    Navigator.pop(context, reminder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Add reminder',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF90EE90),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Plant Selection
                            _buildFormItem(
                              'Plant',
                              _selectedPlant?.name ?? 'Select plant',
                              Icons.chevron_right,
                              _selectPlant,
                            ),

                            const SizedBox(height: 16),

                            // Remind me about
                            _buildFormItem(
                              'Remind me about',
                              _remindMeAbout,
                              Icons.chevron_right,
                              _selectReminderType,
                            ),

                            const SizedBox(height: 16),

                            // Repeat
                            _buildFormItem(
                              'Repeat',
                              _getRepeatLabel(_repeat),
                              Icons.chevron_right,
                              _selectRepeat,
                            ),

                            const SizedBox(height: 16),

                            // Date
                            _buildFormItem(
                              'Date',
                              DateFormat('MMM d, yyyy').format(_selectedDate),
                              Icons.chevron_right,
                              _selectDate,
                            ),

                            const SizedBox(height: 16),

                            // Time
                            _buildFormItem(
                              'Time',
                              DateFormat('h:mm a').format(
                                DateTime(2024, 1, 1, _selectedTime.hour,
                                    _selectedTime.minute),
                              ),
                              null,
                              _selectTime,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormat('h:mm a').format(
                                    DateTime(2024, 1, 1, _selectedTime.hour,
                                        _selectedTime.minute),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
              ),

              // Set Reminder Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90EE90),
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shadowColor: const Color(0xFF90EE90).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Set reminder',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormItem(
    String label,
    String value,
    IconData? icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailing != null)
                    trailing
                  else
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: Colors.grey[500],
                      size: 22,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
