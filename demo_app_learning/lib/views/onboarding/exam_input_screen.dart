import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/local_storage.dart';
import '../../utils/app-styles.dart';
import '../widgets/custom_button.dart';
import '../home/home_screen.dart';
import '../../models/exam_model.dart';
import '../../services/attendance_calculator.dart';

class ExamInputScreen extends StatefulWidget {
  const ExamInputScreen({super.key});

  @override
  State<ExamInputScreen> createState() => _ExamInputScreenState();
}

class _ExamInputScreenState extends State<ExamInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examNameController = TextEditingController();
  DateTime? _examStartDate;
  DateTime? _examEndDate;
  bool _affectsAttendance = false;
  List<Exam> _exams = [];

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = DateTime.now();
    final firstDate = LocalStorage.getSemesterStartDate() ?? DateTime.now();
    final lastDate = LocalStorage.getSemesterEndDate() ?? DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _examStartDate = pickedDate;
          if (_examEndDate != null && _examEndDate!.isBefore(_examStartDate!)) {
            _examEndDate = null;
          }
        } else {
          _examEndDate = pickedDate;
        }
      });
    }
  }

  void _addExam() {
    if (_examNameController.text.isEmpty ||
        _examStartDate == null ||
        _examEndDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_examStartDate!.isAfter(_examEndDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }

    setState(() {
      _exams.add(
        Exam(
          name: _examNameController.text,
          startDate: _examStartDate!,
          endDate: _examEndDate!,
          affectsAttendance: _affectsAttendance,
        ),
      );
      _examNameController.clear();
      _examStartDate = null;
      _examEndDate = null;
      _affectsAttendance = false;
    });
  }

  void _removeExam(int index) {
    setState(() {
      _exams.removeAt(index);
    });
  }

  Future<void> _completeSetup() async {
    await LocalStorage.saveExams(_exams);
    await LocalStorage.setFirstLaunchComplete();
    await AttendanceCalculator.initializeAttendanceData();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Schedule'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add your exam schedule', style: AppStyles.headingStyle),
              const SizedBox(height: 10),
              Text(
                'Add any exams during your semester. '
                'Mark whether attendance is calculated during these exams.',
                style: AppStyles.bodyStyle,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _examNameController,
                decoration: const InputDecoration(
                  labelText: 'Exam Name',
                  hintText: 'e.g., Midterm Exams',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _examStartDate != null
                                  ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(_examStartDate!)
                                  : 'Select date',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _examEndDate != null
                                  ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(_examEndDate!)
                                  : 'Select date',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Attendance is calculated during this exam'),
                value: _affectsAttendance,
                onChanged: (value) {
                  setState(() => _affectsAttendance = value);
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _addExam,
                  child: const Text('Add Exam'),
                ),
              ),
              const SizedBox(height: 20),
              if (_exams.isNotEmpty) ...[
                Text('Your Exams', style: AppStyles.subHeadingStyle),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _exams.length,
                    itemBuilder: (context, index) {
                      final exam = _exams[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(exam.name),
                          subtitle: Text(
                            '${DateFormat('dd MMM yyyy').format(exam.startDate)} - '
                            '${DateFormat('dd MMM yyyy').format(exam.endDate)}\n'
                            'Attendance: ${exam.affectsAttendance ? "Calculated" : "Not Calculated"}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeExam(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              CustomButton(text: 'Complete Setup', onPressed: _completeSetup),
            ],
          ),
        ),
      ),
    );
  }
}
