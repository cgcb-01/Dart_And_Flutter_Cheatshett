import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'home_page.dart';
import 'models.dart';
import 'package:intl/intl.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final DataManager _dataManager = DataManager();
  final _formKey = GlobalKey<FormState>();

  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _routineController = TextEditingController();
  final List<Subject> _routine = [];
  final List<Holiday> _holidays = [];
  final List<Vacation> _vacations = [];
  final List<Exam> _exams = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New User Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'The more accurate data you give, the more accurate a result we can show.\n'
                'You can always manually edit any changes that you want to make.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Type "understood" to proceed',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.toLowerCase() != 'understood' &&
                          value.toLowerCase() != 'ok') {
                    return 'Please type "understood" or "ok"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildDateInput(
                'Start of Class Date',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
              _buildDateInput(
                'End of Class Date',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showRoutineInput,
                child: const Text('Manually Insert Routine'),
              ),
              const SizedBox(height: 20),
              _buildHolidayVacationInput(),
              const SizedBox(height: 20),
              _buildExamInput(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (date != null) {
            onDateSelected(date);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Text(
            selectedDate != null
                ? DateFormat('dd-MM-yyyy').format(selectedDate)
                : 'Select Date',
          ),
        ),
      ),
    );
  }

  Widget _buildHolidayVacationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Holiday and Vacation List',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          "You can always mark a date as a holiday later if you don't have a list. For vacations, only insert the start and end dates.",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        ElevatedButton(
          onPressed: () => _addHoliday(),
          child: const Text('Add Holiday Date'),
        ),
        ElevatedButton(
          onPressed: () => _addVacation(),
          child: const Text('Add Vacation Period'),
        ),
        ..._holidays
            .map(
              (h) =>
                  Text('Holiday: ${DateFormat('dd-MM-yyyy').format(h.date)}'),
            )
            .toList(),
        ..._vacations
            .map(
              (v) => Text(
                'Vacation: ${DateFormat('dd-MM-yyyy').format(v.startDate)} to ${DateFormat('dd-MM-yyyy').format(v.endDate)}',
              ),
            )
            .toList(),
      ],
    );
  }

  void _addHoliday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _holidays.add(Holiday(date: date));
      });
    }
  }

  void _addVacation() async {
    DateTime? startDate;
    DateTime? endDate;

    startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (startDate != null) {
      endDate = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime(2030),
      );
    }
    if (startDate != null && endDate != null) {
      setState(() {
        _vacations.add(Vacation(startDate: startDate!, endDate: endDate!));
      });
    }
  }

  Widget _buildExamInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exam Dates',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () => _addExam(),
          child: const Text('Add Exam Period'),
        ),
        ..._exams
            .map(
              (e) => Text(
                'Exam: ${DateFormat('dd-MM-yyyy').format(e.startDate)} to ${DateFormat('dd-MM-yyyy').format(e.endDate)}',
              ),
            )
            .toList(),
      ],
    );
  }

  void _addExam() async {
    DateTime? startDate;
    DateTime? endDate;

    startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (startDate != null) {
      endDate = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime(2030),
      );
    }
    if (startDate != null && endDate != null) {
      setState(() {
        _exams.add(Exam(startDate: startDate!, endDate: endDate!));
      });
    }
  }

  void _showRoutineInput() async {
    final newRoutine = await showDialog<Routine>(
      context: context,
      builder: (_) => const RoutineInputPage(),
    );
    if (newRoutine != null) {
      _dataManager.saveRoutine(newRoutine);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Routine saved!')));
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      await _dataManager.saveClassDates(
        ClassDates(start: _startDate!, end: _endDate!),
      );
      await _dataManager.saveHolidays(_holidays);
      await _dataManager.saveVacations(_vacations);
      await _dataManager.saveExams(_exams);

      // Initialize attendance for all past classes as present
      final routine = await _dataManager.getRoutine();
      if (routine != null) {
        final attendance = Attendance(subjects: {});
        for (var day in routine.schedule.keys) {
          for (var subject in routine.schedule[day]!) {
            if (!attendance.subjects.containsKey(subject.name)) {
              attendance.subjects[subject.name] = SubjectAttendance();
            }
          }
        }
        await _dataManager.saveAttendance(attendance);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}

class RoutineInputPage extends StatefulWidget {
  const RoutineInputPage({Key? key}) : super(key: key);

  @override
  _RoutineInputPageState createState() => _RoutineInputPageState();
}

class _RoutineInputPageState extends State<RoutineInputPage> {
  final Map<String, List<Subject>> _schedule = {};
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    for (var day in _days) {
      _schedule[day] = [];
    }
  }

  void _addSubject(String day) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController subjectNameController =
            TextEditingController();
        final TextEditingController teacherNameController =
            TextEditingController();
        final TextEditingController classTimeController =
            TextEditingController();

        return AlertDialog(
          title: Text('Add Subject for $day'),
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
                if (subjectNameController.text.isNotEmpty &&
                    classTimeController.text.isNotEmpty) {
                  setState(() {
                    _schedule[day]!.add(
                      Subject(
                        name: subjectNameController.text,
                        teacher: teacherNameController.text,
                        classTime: classTimeController.text,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(Routine(schedule: _schedule));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          return ExpansionTile(
            title: Text(day),
            children: [
              ..._schedule[day]!.map(
                (subject) => ListTile(
                  title: Text(subject.name),
                  subtitle: Text('${subject.teacher} - ${subject.classTime}'),
                ),
              ),
              ElevatedButton(
                onPressed: () => _addSubject(day),
                child: const Text('Add Class'),
              ),
            ],
          );
        },
      ),
    );
  }
}
