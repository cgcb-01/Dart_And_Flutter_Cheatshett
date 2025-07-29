import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/class_model.dart';
import '../../models/holiday_model.dart';
import '../../models/routine_model.dart';
import '../../models/subject_model.dart';
import '../../services/local_storage.dart';
import '../../utils/app_colors.dart';
import '../../utils/app-styles.dart';
import '../widgets/custom_button.dart';

class SubjectStats extends StatefulWidget {
  final DateTime date;
  final Function() onAttendanceUpdated;

  const SubjectStats({
    super.key,
    required this.date,
    required this.onAttendanceUpdated,
  });

  @override
  State<SubjectStats> createState() => _SubjectStatsState();
}

class _SubjectStatsState extends State<SubjectStats> {
  late List<Subject> _subjects;
  late List<ClassModel> _classes;
  late List<RoutineDay> _routine;
  late String _dayName;

  @override
  void initState() {
    super.initState();
    _loadData();
    _dayName = _getDayName(widget.date.weekday);
  }

  void _loadData() {
    _subjects = LocalStorage.getSubjects();
    _classes = LocalStorage.getClasses();
    _routine = LocalStorage.getRoutine();
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  List<ClassSlot> _getDayRoutine() {
    try {
      return _routine
          .firstWhere((r) => r.day.toLowerCase() == _dayName.toLowerCase())
          .classes;
    } catch (e) {
      return [];
    }
  }

  List<ClassModel> _getExtraClasses() {
    return _classes
        .where((c) => _isSameDay(c.date, widget.date) && c.isExtraClass)
        .toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _markAttendance(String subjectId, bool isPresent) async {
    setState(() {
      // Update existing class if found
      final index = _classes.indexWhere(
        (c) => _isSameDay(c.date, widget.date) && c.subjectId == subjectId,
      );

      if (index != -1) {
        _classes[index] = _classes[index].copyWith(isPresent: isPresent);
      } else {
        // Add new class if not found (extra class)
        _classes.add(
          ClassModel(
            date: widget.date,
            subjectId: subjectId,
            isPresent: isPresent,
            isExtraClass: true,
          ),
        );
      }
    });

    // Update subjects
    final subjectIndex = _subjects.indexWhere((s) => s.id == subjectId);
    if (subjectIndex != -1) {
      final subject = _subjects[subjectIndex];
      var attended = subject.attendedClasses;
      var total = subject.totalClasses;
      var extra = subject.extraClasses;
      var absentDates = List<DateTime>.from(subject.absentDates);

      if (isPresent) {
        attended++;
        extra++;
        total++;
        absentDates.removeWhere((d) => _isSameDay(d, widget.date));
      } else {
        if (attended > 0) attended--;
        absentDates.add(widget.date);
      }

      _subjects[subjectIndex] = subject.copyWith(
        attendedClasses: attended,
        totalClasses: total,
        extraClasses: extra,
        absentDates: absentDates,
      );
    }

    // Save data
    await LocalStorage.saveClasses(_classes);
    await LocalStorage.saveSubjects(_subjects);
    widget.onAttendanceUpdated();
  }

  Future<void> _markDayAsHoliday() async {
    final holidayName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Mark as Holiday'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Holiday Name',
              hintText: 'e.g., College Festival',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (holidayName != null && holidayName.isNotEmpty) {
      final holidays = LocalStorage.getHolidays();
      holidays.add(Holiday(date: widget.date, name: holidayName));
      await LocalStorage.saveHolidays(holidays);

      // Update attendance for all subjects that had classes this day
      final classesOnDay = _classes
          .where((c) => _isSameDay(c.date, widget.date))
          .toList();

      for (final classModel in classesOnDay) {
        final subjectIndex = _subjects.indexWhere(
          (s) => s.id == classModel.subjectId,
        );
        if (subjectIndex != -1) {
          final subject = _subjects[subjectIndex];
          _subjects[subjectIndex] = subject.copyWith(
            totalClasses: subject.totalClasses - 1,
            attendedClasses: classModel.isPresent
                ? subject.attendedClasses - 1
                : subject.attendedClasses,
          );
        }
      }

      await LocalStorage.saveSubjects(_subjects);
      widget.onAttendanceUpdated();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayRoutine = _getDayRoutine();
    final extraClasses = _getExtraClasses();
    final isPastDate = widget.date.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd MMM yyyy').format(widget.date)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dayRoutine.isEmpty && extraClasses.isEmpty)
              const Center(child: Text('No classes scheduled for this day'))
            else
              Expanded(
                child: ListView(
                  children: [
                    if (dayRoutine.isNotEmpty)
                      Text(
                        'Scheduled Classes',
                        style: AppStyles.subHeadingStyle,
                      ),
                    if (dayRoutine.isNotEmpty) const SizedBox(height: 8),
                    ...dayRoutine.map((slot) {
                      final subject = _subjects.firstWhere(
                        (s) => s.id == slot.subjectId,
                        orElse: () => Subject(
                          id: '',
                          name: 'Unknown Subject',
                          code: '',
                          teacher: '',
                        ),
                      );
                      final classModel = _classes.firstWhere(
                        (c) =>
                            _isSameDay(c.date, widget.date) &&
                            c.subjectId == slot.subjectId,
                        orElse: () => ClassModel(
                          date: widget.date,
                          subjectId: slot.subjectId,
                          isPresent: !isPastDate,
                        ),
                      );

                      return _ClassItem(
                        subject: subject,
                        startTime: slot.startTime,
                        endTime: slot.endTime,
                        isPresent: classModel.isPresent,
                        onChanged: isPastDate
                            ? (value) => _markAttendance(
                                slot.subjectId,
                                value ?? false,
                              )
                            : null,
                      );
                    }).toList(),
                    if (extraClasses.isNotEmpty) const SizedBox(height: 16),
                    if (extraClasses.isNotEmpty)
                      Text('Extra Classes', style: AppStyles.subHeadingStyle),
                    if (extraClasses.isNotEmpty) const SizedBox(height: 8),
                    ...extraClasses.map((classModel) {
                      final subject = _subjects.firstWhere(
                        (s) => s.id == classModel.subjectId,
                        orElse: () => Subject(
                          id: '',
                          name: 'Unknown Subject',
                          code: '',
                          teacher: '',
                        ),
                      );

                      return _ClassItem(
                        subject: subject,
                        isExtra: true,
                        isPresent: classModel.isPresent,
                        onChanged: isPastDate
                            ? (value) => _markAttendance(
                                classModel.subjectId,
                                value ?? false,
                              )
                            : null,
                      );
                    }).toList(),
                  ],
                ),
              ),
            if (isPastDate)
              Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'Mark Day as Holiday',
                    onPressed: _markDayAsHoliday,
                    backgroundColor: AppColors.holidayColor,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassItem extends StatelessWidget {
  final Subject subject;
  final String? startTime;
  final String? endTime;
  final bool isPresent;
  final bool isExtra;
  final Function(bool?)? onChanged;

  const _ClassItem({
    required this.subject,
    this.startTime,
    this.endTime,
    required this.isPresent,
    this.isExtra = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (onChanged != null)
              Checkbox(
                value: isPresent,
                onChanged: onChanged,
                activeColor: AppColors.primaryColor,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: AppStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (startTime != null && endTime != null)
                    Text('$startTime - $endTime', style: AppStyles.smallStyle),
                  if (isExtra)
                    Text(
                      'Extra Class',
                      style: AppStyles.smallStyle.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
