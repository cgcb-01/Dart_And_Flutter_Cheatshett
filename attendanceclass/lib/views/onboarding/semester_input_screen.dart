import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/local_storage.dart';
import '../../utils/app_colors.dart';
import '../../utils/app-styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'routine_input_screen.dart';

class SemesterInputScreen extends StatefulWidget {
  const SemesterInputScreen({super.key});

  @override
  State<SemesterInputScreen> createState() => _SemesterInputScreenState();
}

class _SemesterInputScreenState extends State<SemesterInputScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? DateTime.now()
        : _startDate ?? DateTime.now();
    final firstDate = isStartDate
        ? DateTime.now()
        : _startDate ?? DateTime.now();
    final lastDate = isStartDate ? DateTime(2100) : DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _navigateToRoutineInput() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both dates')),
        );
        return;
      }

      LocalStorage.setSemesterStartDate(_startDate!);
      LocalStorage.setSemesterEndDate(_endDate!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoutineInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semester Dates'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter your semester dates', style: AppStyles.headingStyle),
              const SizedBox(height: 20),
              Text('Start Date', style: AppStyles.labelStyle),
              const SizedBox(height: 8),
              CustomTextField(
                readOnly: true,
                controller: TextEditingController(
                  text: _startDate != null
                      ? DateFormat('dd MMM yyyy').format(_startDate!)
                      : '',
                ),
                hintText: 'Select start date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                ),
                validator: (value) {
                  if (_startDate == null) {
                    return 'Please select start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('End Date', style: AppStyles.labelStyle),
              const SizedBox(height: 8),
              CustomTextField(
                readOnly: true,
                controller: TextEditingController(
                  text: _endDate != null
                      ? DateFormat('dd MMM yyyy').format(_endDate!)
                      : '',
                ),
                hintText: 'Select end date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                ),
                validator: (value) {
                  if (_endDate == null) {
                    return 'Please select end date';
                  }
                  if (_endDate!.isBefore(_startDate!)) {
                    return 'End date must be after start date';
                  }
                  return null;
                },
              ),
              const Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: _navigateToRoutineInput,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
