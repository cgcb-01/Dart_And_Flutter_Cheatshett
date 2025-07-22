import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AttendanceHomePage(),
    );
  }
}

class AttendanceHomePage extends StatefulWidget {
  @override
  _AttendanceHomePageState createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<String, String>> attendance =
      {}; // date -> subject -> status
  List<String> subjects = ["Math", "Physics", "Chemistry"];
  Map<String, int> presentCount = {};
  Map<String, int> totalCount = {};

  @override
  void initState() {
    super.initState();
    for (var subject in subjects) {
      presentCount[subject] = 0;
      totalCount[subject] = 0;
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showDayOptions(selectedDay);
  }

  void _showDayOptions(DateTime day) async {
    Map<String, String> subjectStatus = attendance[day] ?? {};
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Update Attendance for ${day.toLocal().toString().split(' ')[0]}",
          ),
          content: SingleChildScrollView(
            child: Column(
              children: subjects.map((subject) {
                String status = subjectStatus[subject] ?? "None";
                return ListTile(
                  title: Text(subject),
                  subtitle: Text("Status: $status"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        subjectStatus[subject] = value;
                        if (!attendance.containsKey(day)) attendance[day] = {};
                        attendance[day]![subject] = value;
                      });
                      Navigator.pop(context);
                      _showDayOptions(day);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "Present",
                        child: Text("Mark Present"),
                      ),
                      PopupMenuItem(
                        value: "Absent",
                        child: Text("Mark Absent"),
                      ),
                      PopupMenuItem(
                        value: "Medical",
                        child: Text("Medical Leave"),
                      ),
                      PopupMenuItem(value: "None", child: Text("Remove")),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Done"),
            ),
          ],
        );
      },
    );
  }

  Color _getDateColor(DateTime day) {
    if (!attendance.containsKey(day)) return Colors.transparent;
    bool hasAbsent = attendance[day]!.containsValue("Absent");
    bool hasPresent = attendance[day]!.containsValue("Present");
    if (hasAbsent) return Colors.red.shade300;
    if (hasPresent) return Colors.blue.shade300;
    return Colors.green.shade300;
  }

  Map<String, double> _calculatePercentages() {
    Map<String, int> total = {};
    Map<String, int> present = {};
    for (var subject in subjects) {
      total[subject] = 0;
      present[subject] = 0;
    }
    attendance.forEach((date, subjectMap) {
      subjectMap.forEach((subject, status) {
        total[subject] = (total[subject] ?? 0) + 1;
        if (status == "Present") {
          present[subject] = (present[subject] ?? 0) + 1;
        }
      });
    });
    Map<String, double> percentages = {};
    subjects.forEach((subject) {
      int p = present[subject] ?? 0;
      int t = total[subject] ?? 1;
      percentages[subject] = (p / t) * 100;
    });
    return percentages;
  }

  @override
  Widget build(BuildContext context) {
    final percentages = _calculatePercentages();

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Tracker")),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subjects.map((subject) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "$subject: ${percentages[subject]!.toStringAsFixed(1)}%",
                  ),
                );
              }).toList(),
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                    color: _getDateColor(day),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text('${day.day}'),
                );
              },
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Upload new semester logic
              },
              child: Text("Upload New Semester"),
            ),
          ),
        ],
      ),
    );
  }
}
