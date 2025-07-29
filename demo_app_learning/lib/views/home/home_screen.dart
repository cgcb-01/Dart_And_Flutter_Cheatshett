import 'package:flutter/material.dart';
import '../../utils/app-styles.dart';
import '../../models/subject_model.dart';
import '../../services/attendance_calculator.dart';
import '../../services/local_storage.dart';
import '../../services/notification_service.dart';
import './calendar_view.dart';
import './subject_stats.dart';
import '../widgets/pie_chart_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Subject> _subjects;
  late DateTime _semesterStartDate;
  late DateTime _semesterEndDate;

  @override
  void initState() {
    super.initState();
    _loadData();
    NotificationService.init();
    _checkAttendanceThresholds();
  }

  Future<void> _loadData() async {
    await AttendanceCalculator.initializeAttendanceData();
    setState(() {
      _subjects = LocalStorage.getSubjects();
      _semesterStartDate = LocalStorage.getSemesterStartDate()!;
      _semesterEndDate = LocalStorage.getSemesterEndDate()!;
    });
  }

  void _checkAttendanceThresholds() {
    for (final subject in _subjects) {
      if (subject.attendancePercentage < 75) {
        NotificationService.showNotification(
          title: 'Attendance Alert',
          body: '${subject.name} attendance is below 75%!',
        );
      } else if (subject.attendancePercentage < 80) {
        NotificationService.showNotification(
          title: 'Attendance Warning',
          body: '${subject.name} attendance is below 80%',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Bunk Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance Overview', style: AppStyles.headingStyle),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 16),
                      child: PieChartWidget(
                        percentage: subject.attendancePercentage,
                        subjectName: subject.name,
                        attended: subject.attendedClasses,
                        total: subject.totalClasses,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text('Upcoming Classes', style: AppStyles.headingStyle),
              const SizedBox(height: 16),
              CalendarView(
                startDate: _semesterStartDate,
                endDate: _semesterEndDate,
                onDateSelected: (date) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubjectStats(
                        date: date,
                        onAttendanceUpdated: _loadData,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
