import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data_manager.dart';
import 'models.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataManager _dataManager = DataManager();
  Attendance? _attendance;
  ClassDates? _classDates;
  Routine? _routine;
  List<Holiday> _holidays = [];
  List<Vacation> _vacations = [];
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final attendance = await _dataManager.getAttendance();
    final classDates = await _dataManager.getClassDates();
    final routine = await _dataManager.getRoutine();
    final holidays = await _dataManager.getHolidays();
    final vacations = await _dataManager.getVacations();
    final exams = await _dataManager.getExams();

    if (classDates != null && routine != null && attendance != null) {
      await _handleInitialAttendance(classDates, routine, attendance);
    }

    setState(() {
      _attendance = attendance;
      _classDates = classDates;
      _routine = routine;
      _holidays = holidays;
      _vacations = vacations;
      _exams = exams;
    });
  }

  Future<void> _handleInitialAttendance(
    ClassDates classDates,
    Routine routine,
    Attendance attendance,
  ) async {
    final now = DateTime.now();
    DateTime currentDate = classDates.start;
    bool needsUpdate = false;

    while (currentDate.isBefore(now)) {
      final dayOfWeek = DateFormat('EEEE').format(currentDate);
      final subjectsForDay = routine.schedule[dayOfWeek];

      if (subjectsForDay != null) {
        for (var subject in subjectsForDay) {
          if (!attendance.subjects[subject.name]!.absentDates.any(
            (d) =>
                d.year == currentDate.year &&
                d.month == currentDate.month &&
                d.day == currentDate.day,
          )) {
            // Check if it's not a holiday, vacation, or exam day
            if (!_isHoliday(currentDate) &&
                !_isVacation(currentDate) &&
                !_isExam(currentDate)) {
              if (attendance.subjects[subject.name]!.total <
                  _calculateTotalClasses(
                    classDates.start,
                    currentDate,
                    routine,
                    subject.name,
                  )) {
                attendance.subjects[subject.name]!.attended++;
                attendance.subjects[subject.name]!.total++;
                needsUpdate = true;
              }
            }
          }
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    if (needsUpdate) {
      await _dataManager.saveAttendance(attendance);
    }
  }

  int _calculateTotalClasses(
    DateTime start,
    DateTime end,
    Routine routine,
    String subjectName,
  ) {
    int total = 0;
    DateTime currentDate = start;
    while (currentDate.isBefore(end)) {
      final dayOfWeek = DateFormat('EEEE').format(currentDate);
      if (routine.schedule[dayOfWeek] != null) {
        if (routine.schedule[dayOfWeek]!.any((s) => s.name == subjectName)) {
          if (!_isHoliday(currentDate) &&
              !_isVacation(currentDate) &&
              !_isExam(currentDate)) {
            total++;
          }
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return total;
  }

  bool _isHoliday(DateTime date) {
    return _holidays.any(
      (h) =>
          h.date.year == date.year &&
          h.date.month == date.month &&
          h.date.day == date.day,
    );
  }

  bool _isVacation(DateTime date) {
    return _vacations.any(
      (v) =>
          (date.isAfter(v.startDate) || date.isAtSameMomentAs(v.startDate)) &&
          (date.isBefore(v.endDate) || date.isAtSameMomentAs(v.endDate)),
    );
  }

  bool _isExam(DateTime date) {
    return _exams.any(
      (e) =>
          (date.isAfter(e.startDate) || date.isAtSameMomentAs(e.startDate)) &&
          (date.isBefore(e.endDate) || date.isAtSameMomentAs(e.endDate)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_attendance == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Home')),
      body: SingleChildScrollView(
        child: Column(children: [_buildAttendanceSummary(), _buildCalendar()]),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    if (_attendance == null || _attendance!.subjects.isEmpty) {
      return const Center(child: Text('No attendance data available.'));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _attendance!.subjects.length,
        itemBuilder: (context, index) {
          final subjectName = _attendance!.subjects.keys.elementAt(index);
          final subjectData = _attendance!.subjects[subjectName]!;

          final percentage = subjectData.total > 0
              ? (subjectData.attended / subjectData.total) * 100
              : 0.0;

          final double presentValue = percentage.clamp(0.0, 100.0);
          final double absentValue = (100.0 - presentValue).clamp(0.0, 100.0);

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: presentValue,
                            title: '${presentValue.toStringAsFixed(1)}%',
                            radius: 20,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: absentValue,
                            title: '',
                            radius: 10,
                          ),
                        ],
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Extra Classes: ${subjectData.extraClasses}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    if (_classDates == null) return Container();

    final classStart = _classDates!.start;
    final classEnd = _classDates!.end;
    final firstMonth = DateTime(classStart.year, classStart.month);
    final lastMonth = DateTime(classEnd.year, classEnd.month);

    final months = _generateMonths(firstMonth, lastMonth);

    return Column(
      children: months.map((month) {
        return _buildMonthView(month);
      }).toList(),
    );
  }

  List<DateTime> _generateMonths(DateTime start, DateTime end) {
    List<DateTime> months = [];
    DateTime current = start;
    while (current.isBefore(end) ||
        (current.year == end.year && current.month == end.month)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return months;
  }

  Widget _buildMonthView(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = _daysInMonth(firstDayOfMonth);
    final firstDayOfWeek = firstDayOfMonth.weekday - 1; // 0=Mon, 6=Sun

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              DateFormat('MMMM yyyy').format(month),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: daysInMonth + firstDayOfWeek,
              itemBuilder: (context, index) {
                if (index < firstDayOfWeek) {
                  return Container();
                }
                final day = index - firstDayOfWeek + 1;
                final date = DateTime(month.year, month.month, day);
                return _buildDayCell(date);
              },
            ),
          ],
        ),
      ),
    );
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  Widget _buildDayCell(DateTime date) {
    bool isHoliday = _isHoliday(date);
    bool isVacation = _isVacation(date);
    bool isExam = _isExam(date);
    bool isAbsent = _isAbsent(date);
    bool isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    Color backgroundColor = Colors.white;
    if (isToday) backgroundColor = Colors.blue.withOpacity(0.3);

    if (isAbsent) backgroundColor = Colors.red.withOpacity(0.5);
    if (!isAbsent &&
        _routine != null &&
        _routine!.schedule[DateFormat('EEEE').format(date)]?.isNotEmpty ==
            true) {
      backgroundColor = Colors.green.withOpacity(0.5);
    }

    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DayDetailsPage(
              date: date,
              routine: _routine!,
              holidays: _holidays,
              attendance: _attendance!,
            ),
          ),
        );
        _loadData();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isHoliday || isVacation
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(height: 2, color: Colors.black54),
                    ),
                  ),
                ],
              )
            : Text('${date.day}'),
      ),
    );
  }

  bool _isAbsent(DateTime date) {
    if (_attendance == null) return false;
    for (var subject in _attendance!.subjects.values) {
      if (subject.absentDates.any(
        (absentDate) =>
            absentDate.year == date.year &&
            absentDate.month == date.month &&
            absentDate.day == date.day,
      )) {
        return true;
      }
    }
    return false;
  }
}

class DayDetailsPage extends StatefulWidget {
  final DateTime date;
  final Routine routine;
  final List<Holiday> holidays;
  final Attendance attendance;

  const DayDetailsPage({
    Key? key,
    required this.date,
    required this.routine,
    required this.holidays,
    required this.attendance,
  }) : super(key: key);

  @override
  _DayDetailsPageState createState() => _DayDetailsPageState();
}

class _DayDetailsPageState extends State<DayDetailsPage> {
  final DataManager _dataManager = DataManager();

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat('EEEE').format(widget.date);
    final subjectsForDay = widget.routine.schedule[dayOfWeek] ?? [];
    bool isHoliday = widget.holidays.any((h) => h.date == widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd MMMM yyyy').format(widget.date)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            isHoliday
                ? const Text(
                    'This day is a holiday.',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  )
                : Column(
                    children: subjectsForDay.map((subject) {
                      final isAbsent =
                          widget.attendance.subjects[subject.name]?.absentDates
                              .any((d) => d.day == widget.date.day) ??
                          false;
                      return ListTile(
                        title: Text(subject.name),
                        subtitle: Text(subject.classTime),
                        trailing: Checkbox(
                          value: !isAbsent,
                          onChanged: (bool? isPresent) {
                            _updateAttendance(subject.name, isPresent!);
                          },
                        ),
                        tileColor: isAbsent
                            ? Colors.red.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _markDayAsHoliday(),
              child: const Text('Mark Day as Holiday'),
            ),
            ElevatedButton(
              onPressed: () => _addExtraClass(),
              child: const Text('Add an Extra Class'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAttendance(String subjectName, bool isPresent) async {
    final attendance = await _dataManager.getAttendance();
    if (attendance != null) {
      final subjectData = attendance.subjects[subjectName];
      if (subjectData != null) {
        if (isPresent) {
          subjectData.attended++;
          subjectData.absentDates.removeWhere((d) => d.day == widget.date.day);
        } else {
          if (!subjectData.absentDates.any((d) => d.day == widget.date.day)) {
            subjectData.absentDates.add(widget.date);
            subjectData.attended--;
          }
        }
        await _dataManager.saveAttendance(attendance);
        setState(() {});
      }
    }
  }

  Future<void> _markDayAsHoliday() async {
    final attendance = await _dataManager.getAttendance();
    final holidays = await _dataManager.getHolidays();

    if (attendance != null) {
      final dayOfWeek = DateFormat('EEEE').format(widget.date);
      final subjectsForDay = widget.routine.schedule[dayOfWeek] ?? [];

      for (var subject in subjectsForDay) {
        final subjectData = attendance.subjects[subject.name];
        if (subjectData != null) {
          subjectData.total--;
          if (subjectData.absentDates.any((d) => d.day == widget.date.day)) {
            subjectData.absentDates.removeWhere(
              (d) => d.day == widget.date.day,
            );
          } else {
            subjectData.attended--;
          }
        }
      }

      holidays.add(Holiday(date: widget.date));
      await _dataManager.saveAttendance(attendance);
      await _dataManager.saveHolidays(holidays);
      Navigator.of(context).pop();
    }
  }

  Future<void> _addExtraClass() async {
    final newSubject = await showDialog<Subject?>(
      context: context,
      builder: (_) => const ExtraClassInputPage(),
    );
    if (newSubject != null) {
      bool isPresent =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Was attendance taken?'),
              content: Text('Mark ${newSubject.name} as present or absent?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Absent'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Present'),
                ),
              ],
            ),
          ) ??
          false;

      final attendance = await _dataManager.getAttendance();
      if (attendance != null) {
        final subjectData = attendance.subjects[newSubject.name];
        if (subjectData != null) {
          subjectData.total++;
          subjectData.extraClasses++;
          if (isPresent) {
            subjectData.attended++;
          } else {
            subjectData.absentDates.add(widget.date);
          }
          await _dataManager.saveAttendance(attendance);
          setState(() {});
        }
      }
    }
  }
}

class ExtraClassInputPage extends StatelessWidget {
  const ExtraClassInputPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController subjectNameController = TextEditingController();
    final TextEditingController teacherNameController = TextEditingController();
    final TextEditingController classTimeController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Extra Class'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: subjectNameController,
            decoration: const InputDecoration(labelText: 'Subject Name'),
          ),
          TextField(
            controller: teacherNameController,
            decoration: const InputDecoration(
              labelText: 'Teacher Name (Optional)',
            ),
          ),
          TextField(
            controller: classTimeController,
            decoration: const InputDecoration(
              labelText: 'Class Time (e.g., 9:00 AM)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (subjectNameController.text.isNotEmpty) {
              Navigator.of(context).pop(
                Subject(
                  name: subjectNameController.text,
                  teacher: teacherNameController.text,
                  classTime: classTimeController.text,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
