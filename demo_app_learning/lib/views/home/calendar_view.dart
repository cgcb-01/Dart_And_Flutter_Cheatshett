import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/class_model.dart';
import '../../models/exam_model.dart';
import '../../models/holiday_model.dart';
import '../../models/vacation_model.dart';
import '../../services/local_storage.dart';
import '../../utils/app_colors.dart';
import '../../utils/app-styles.dart';

class CalendarView extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) onDateSelected;

  const CalendarView({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentMonth;
  late List<DateTime> _daysInMonth;
  late List<Holiday> _holidays;
  late List<Vacation> _vacations;
  late List<Exam> _exams;
  late List<ClassModel> _classes;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.startDate.year, widget.startDate.month, 1);
    _loadData();
  }

  void _loadData() {
    _holidays = LocalStorage.getHolidays();
    _vacations = LocalStorage.getVacations();
    _exams = LocalStorage.getExams();
    _classes = LocalStorage.getClasses();
    _updateDaysInMonth();
  }

  void _updateDaysInMonth() {
    final firstDay = _currentMonth;
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    _daysInMonth = [];
    DateTime currentDay = firstDay;
    while (currentDay.isBefore(lastDay) || currentDay.day == lastDay.day) {
      _daysInMonth.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 1));
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _updateDaysInMonth();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _updateDaysInMonth();
    });
  }

  bool _isHoliday(DateTime date) {
    return _holidays.any((h) => _isSameDay(h.date, date));
  }

  bool _isVacation(DateTime date) {
    return _vacations.any(
      (v) => date.isAfter(v.startDate) && date.isBefore(v.endDate),
    );
  }

  bool _isExam(DateTime date) {
    return _exams.any(
      (e) => date.isAfter(e.startDate) && date.isBefore(e.endDate),
    );
  }

  bool _hasClasses(DateTime date) {
    return _classes.any((c) => _isSameDay(c.date, date));
  }

  bool _isAbsent(DateTime date) {
    return _classes.any((c) => _isSameDay(c.date, date) && !c.isPresent);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getDateColor(DateTime date) {
    if (date.isAfter(DateTime.now())) return Colors.grey;
    if (_isHoliday(date)) return AppColors.holidayColor;
    if (_isVacation(date)) return AppColors.vacationColor;
    if (_isExam(date)) return AppColors.examColor;
    if (_isAbsent(date)) return AppColors.absentColor;
    if (_hasClasses(date)) return AppColors.presentColor;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  _currentMonth.month > widget.startDate.month ||
                      _currentMonth.year > widget.startDate.year
                  ? _previousMonth
                  : null,
            ),
            Text(
              DateFormat('MMMM yyyy').format(_currentMonth),
              style: AppStyles.subHeadingStyle,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  _currentMonth.month < widget.endDate.month ||
                      _currentMonth.year < widget.endDate.year
                  ? _nextMonth
                  : null,
            ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: _daysInMonth.length,
          itemBuilder: (context, index) {
            final date = _daysInMonth[index];
            final isInRange =
                !date.isBefore(widget.startDate) &&
                !date.isAfter(widget.endDate);
            final isWeekend =
                date.weekday == DateTime.saturday ||
                date.weekday == DateTime.sunday;

            return GestureDetector(
              onTap: isInRange ? () => widget.onDateSelected(date) : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isInRange ? _getDateColor(date) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: _isSameDay(date, DateTime.now())
                      ? Border.all(color: AppColors.primaryColor, width: 2)
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isInRange
                              ? isWeekend
                                    ? Colors.red
                                    : Colors.black
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_hasClasses(date) && isInRange)
                        const Icon(Icons.school, size: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
