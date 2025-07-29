import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MaterialApp(home: FormPage()));
}

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  DateTime? startDate;
  DateTime? endDate;

  PlatformFile? routineFile;
  PlatformFile? holidaysFile;
  PlatformFile? optionalFile;

  final _formKey = GlobalKey<FormState>();

  Future<void> pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> pickFile(Function(PlatformFile) onFilePicked) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      onFilePicked(result.files.first);
    }
  }

  void submitForm() {
    if (startDate == null ||
        endDate == null ||
        routineFile == null ||
        holidaysFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // Process the data here
    print("Start Date: $startDate");
    print("End Date: $endDate");
    print("Routine File: ${routineFile!.name}");
    print("Holidays File: ${holidaysFile!.name}");
    if (optionalFile != null) {
      print("Optional File: ${optionalFile!.name}");
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Form Submitted")));
  }

  Widget buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
        ),
        child: Text(
          date != null ? "${date.toLocal()}".split(' ')[0] : "Select $label",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget buildFilePicker(
    String label,
    PlatformFile? file,
    VoidCallback onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        ElevatedButton.icon(
          onPressed: onPick,
          icon: Icon(Icons.attach_file),
          label: Text(file != null ? file.name : "Choose File"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Routine Form")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildDatePicker(
                "Start Date",
                startDate,
                () => pickDate(isStart: true),
              ),
              SizedBox(height: 16),
              buildDatePicker(
                "End Date",
                endDate,
                () => pickDate(isStart: false),
              ),
              SizedBox(height: 24),
              buildFilePicker("Routine File *", routineFile, () {
                pickFile((file) => setState(() => routineFile = file));
              }),
              SizedBox(height: 16),
              buildFilePicker("Holidays File *", holidaysFile, () {
                pickFile((file) => setState(() => holidaysFile = file));
              }),
              SizedBox(height: 16),
              buildFilePicker("Optional File", optionalFile, () {
                pickFile((file) => setState(() => optionalFile = file));
              }),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
