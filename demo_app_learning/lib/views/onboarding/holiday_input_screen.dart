import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/ai_parser_service.dart';
import '../../services/local_storage.dart';

import '../../utils/app-styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import './exam_input_screen.dart';
import '../../models/holiday_model.dart';
import '../../models/vacation_model.dart';

class HolidayInputScreen extends StatefulWidget {
  const HolidayInputScreen({super.key});

  @override
  State<HolidayInputScreen> createState() => _HolidayInputScreenState();
}

class _HolidayInputScreenState extends State<HolidayInputScreen> {
  final _fileController = TextEditingController();
  final _holidayNameController = TextEditingController();
  final _vacationNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Holiday> _holidays = [];
  List<Vacation> _vacations = [];
  bool _isLoading = false;
  DateTime? _selectedHolidayDate;
  DateTime? _selectedVacationStart;
  DateTime? _selectedVacationEnd;

  Future<void> _parseHolidayFile() async {
    if (_fileController.text.isEmpty) return;

    final startDate = LocalStorage.getSemesterStartDate();
    final endDate = LocalStorage.getSemesterEndDate();
    if (startDate == null || endDate == null) return;

    setState(() => _isLoading = true);
    try {
      final parsedHolidays = await AIParserService.parseHolidayFile(
        _fileController.text,
        startDate,
        endDate,
      );
      setState(() => _holidays = parsedHolidays);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error parsing file: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addHoliday() {
    if (_selectedHolidayDate == null || _holidayNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _holidays.add(
        Holiday(date: _selectedHolidayDate!, name: _holidayNameController.text),
      );
      _holidayNameController.clear();
      _selectedHolidayDate = null;
    });
  }

  void _addVacation() {
    if (_selectedVacationStart == null ||
        _selectedVacationEnd == null ||
        _vacationNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_selectedVacationStart!.isAfter(_selectedVacationEnd!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }

    setState(() {
      _vacations.add(
        Vacation(
          startDate: _selectedVacationStart!,
          endDate: _selectedVacationEnd!,
          name: _vacationNameController.text,
        ),
      );
      _vacationNameController.clear();
      _selectedVacationStart = null;
      _selectedVacationEnd = null;
    });
  }

  void _removeHoliday(int index) {
    setState(() {
      _holidays.removeAt(index);
    });
  }

  void _removeVacation(int index) {
    setState(() {
      _vacations.removeAt(index);
    });
  }

  void _navigateToExamInput() {
    LocalStorage.saveHolidays(_holidays);
    LocalStorage.saveVacations(_vacations);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExamInputScreen()),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isStart,
    bool isVacation,
  ) async {
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
        if (isVacation) {
          if (isStart) {
            _selectedVacationStart = pickedDate;
            if (_selectedVacationEnd != null &&
                _selectedVacationEnd!.isBefore(_selectedVacationStart!)) {
              _selectedVacationEnd = null;
            }
          } else {
            _selectedVacationEnd = pickedDate;
          }
        } else {
          _selectedHolidayDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holidays & Vacations'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload your holiday list',
                      style: AppStyles.headingStyle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We will parse your holiday list file to extract dates. '
                      'You can also add holidays and vacations manually below.',
                      style: AppStyles.bodyStyle,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _fileController,
                      hintText: 'Paste file content here',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Parse File',
                      onPressed: _parseHolidayFile,
                      padding: 12,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Add Single Holiday',
                      style: AppStyles.subHeadingStyle,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _holidayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Holiday Name',
                              hintText: 'e.g., Independence Day',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedHolidayDate != null
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_selectedHolidayDate!)
                                        : 'Select date',
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addHoliday,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Add Vacation Period',
                      style: AppStyles.subHeadingStyle,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _vacationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Vacation Name',
                        hintText: 'e.g., Winter Break',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedVacationStart != null
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_selectedVacationStart!)
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
                            onTap: () => _selectDate(context, false, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedVacationEnd != null
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_selectedVacationEnd!)
                                        : 'Select date',
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addVacation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_holidays.isNotEmpty) ...[
                      Text('Holidays', style: AppStyles.subHeadingStyle),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _holidays.length,
                          itemBuilder: (context, index) {
                            final holiday = _holidays[index];
                            return ListTile(
                              title: Text(holiday.name),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy').format(holiday.date),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeHoliday(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (_vacations.isNotEmpty) ...[
                      Text('Vacations', style: AppStyles.subHeadingStyle),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _vacations.length,
                          itemBuilder: (context, index) {
                            final vacation = _vacations[index];
                            return ListTile(
                              title: Text(vacation.name),
                              subtitle: Text(
                                '${DateFormat('dd MMM yyyy').format(vacation.startDate)} - '
                                '${DateFormat('dd MMM yyyy').format(vacation.endDate)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeVacation(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Continue',
                      onPressed: _navigateToExamInput,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
