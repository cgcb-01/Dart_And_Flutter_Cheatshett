import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // the header part and the body part of the calendar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Tracker',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      //Including the calendar
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              // You can now fetch class info or modify attendance for selectedDay
              print("Clicked date: $_selectedDay");
            },
            calendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
          ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Selected Date: ${_selectedDay!.toLocal()}",
                style: TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
