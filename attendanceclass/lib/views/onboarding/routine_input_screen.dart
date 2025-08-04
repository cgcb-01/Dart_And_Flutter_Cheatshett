import 'package:flutter/material.dart';
import '../../services/ai_parser_service.dart';
import '../../services/local_storage.dart';
import '../../utils/app_colors.dart';
import '../../utils/app-styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import './holiday_input_screen.dart';
import '../../models/routine_model.dart';

class RoutineInputScreen extends StatefulWidget {
  const RoutineInputScreen({super.key});

  @override
  State<RoutineInputScreen> createState() => _RoutineInputScreenState();
}

class _RoutineInputScreenState extends State<RoutineInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fileController = TextEditingController();
  List<RoutineDay> _routine = [];
  bool _isLoading = false;
  bool _showManualOption = false;

  Future<void> _parseRoutineFile() async {
    if (_fileController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final parsedRoutine = await AIParserService.parseRoutineFile(
        _fileController.text,
      );
      setState(() => _routine = parsedRoutine);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error parsing file: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHolidayInput() {
    if (_routine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one class')),
      );
      return;
    }

    LocalStorage.saveRoutine(_routine);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HolidayInputScreen()),
    );
  }

  void _addManualRoutineDay() {
    setState(() {
      _routine.add(RoutineDay(day: '', classes: []));
    });
  }

  void _updateRoutineDay(int index, RoutineDay updatedDay) {
    setState(() {
      _routine[index] = updatedDay;
    });
  }

  void _removeRoutineDay(int index) {
    setState(() {
      _routine.removeAt(index);
    });
  }

  void _addClassToDay(int dayIndex) {
    setState(() {
      _routine[dayIndex].classes.add(
        ClassSlot(subjectId: '', startTime: '', endTime: ''),
      );
    });
  }

  void _updateClassSlot(int dayIndex, int slotIndex, ClassSlot updatedSlot) {
    setState(() {
      _routine[dayIndex].classes[slotIndex] = updatedSlot;
    });
  }

  void _removeClassSlot(int dayIndex, int slotIndex) {
    setState(() {
      _routine[dayIndex].classes.removeAt(slotIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Routine'), centerTitle: true),
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
                      'Upload your routine file',
                      style: AppStyles.headingStyle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We will parse your routine file to extract class schedule. '
                      'Supported formats: PDF, DOCX, TXT',
                      style: AppStyles.bodyStyle,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _fileController,
                      hintText: 'Paste file content here',
                      maxLines: 5,
                      validator: (value) {
                        if (_routine.isEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'Please either upload a file or add manually';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CustomButton(
                          text: 'Parse File',
                          onPressed: _parseRoutineFile,
                          padding: 12,
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            setState(
                              () => _showManualOption = !_showManualOption,
                            );
                          },
                          child: Text(
                            _showManualOption ? 'Hide Manual' : 'Add Manually',
                            style: AppStyles.bodyStyle.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showManualOption) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Manual Routine Entry',
                            style: AppStyles.subHeadingStyle,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addManualRoutineDay,
                          ),
                        ],
                      ),
                    ],
                    Expanded(
                      child: ListView.builder(
                        itemCount: _routine.length,
                        itemBuilder: (context, dayIndex) {
                          final day = _routine[dayIndex];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: day.day,
                                          decoration: const InputDecoration(
                                            labelText: 'Day',
                                            hintText: 'e.g., Monday',
                                          ),
                                          onChanged: (value) {
                                            _updateRoutineDay(
                                              dayIndex,
                                              day.copyWith(day: value),
                                            );
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _removeRoutineDay(dayIndex),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Classes',
                                    style: AppStyles.bodyStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...day.classes.asMap().entries.map((entry) {
                                    final slotIndex = entry.key;
                                    final slot = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  initialValue: slot.subjectId,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'Subject ID',
                                                        hintText:
                                                            'e.g., MATH101',
                                                      ),
                                                  onChanged: (value) {
                                                    _updateClassSlot(
                                                      dayIndex,
                                                      slotIndex,
                                                      slot.copyWith(
                                                        subjectId: value,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                TextFormField(
                                                  initialValue: slot.startTime,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'Start Time',
                                                        hintText: 'e.g., 09:00',
                                                      ),
                                                  onChanged: (value) {
                                                    _updateClassSlot(
                                                      dayIndex,
                                                      slotIndex,
                                                      slot.copyWith(
                                                        startTime: value,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                TextFormField(
                                                  initialValue: slot.endTime,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'End Time',
                                                        hintText: 'e.g., 10:30',
                                                      ),
                                                  onChanged: (value) {
                                                    _updateClassSlot(
                                                      dayIndex,
                                                      slotIndex,
                                                      slot.copyWith(
                                                        endTime: value,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _removeClassSlot(
                                              dayIndex,
                                              slotIndex,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _addClassToDay(dayIndex),
                                      child: const Text('Add Class'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    CustomButton(
                      text: 'Continue',
                      onPressed: _navigateToHolidayInput,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
