import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class DataManager {
  static const String _routineKey = 'routine';
  static const String _holidaysKey = 'holidays';
  static const String _vacationsKey = 'vacations';
  static const String _examsKey = 'exams';
  static const String _classDatesKey = 'classDates';
  static const String _attendanceKey = 'attendance';

  Future<void> saveRoutine(Routine routine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_routineKey, jsonEncode(routine.toJson()));
  }

  Future<Routine?> getRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final routineJson = prefs.getString(_routineKey);
    if (routineJson != null) {
      return Routine.fromJson(jsonDecode(routineJson));
    }
    return null;
  }

  Future<void> saveHolidays(List<Holiday> holidays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _holidaysKey,
      jsonEncode(holidays.map((h) => h.toJson()).toList()),
    );
  }

  Future<List<Holiday>> getHolidays() async {
    final prefs = await SharedPreferences.getInstance();
    final holidaysJson = prefs.getString(_holidaysKey);
    if (holidaysJson != null) {
      final List<dynamic> list = jsonDecode(holidaysJson);
      return list.map((item) => Holiday.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveVacations(List<Vacation> vacations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _vacationsKey,
      jsonEncode(vacations.map((v) => v.toJson()).toList()),
    );
  }

  Future<List<Vacation>> getVacations() async {
    final prefs = await SharedPreferences.getInstance();
    final vacationsJson = prefs.getString(_vacationsKey);
    if (vacationsJson != null) {
      final List<dynamic> list = jsonDecode(vacationsJson);
      return list.map((item) => Vacation.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveExams(List<Exam> exams) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _examsKey,
      jsonEncode(exams.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<Exam>> getExams() async {
    final prefs = await SharedPreferences.getInstance();
    final examsJson = prefs.getString(_examsKey);
    if (examsJson != null) {
      final List<dynamic> list = jsonDecode(examsJson);
      return list.map((item) => Exam.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveClassDates(ClassDates dates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_classDatesKey, jsonEncode(dates.toJson()));
  }

  Future<ClassDates?> getClassDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesJson = prefs.getString(_classDatesKey);
    if (datesJson != null) {
      return ClassDates.fromJson(jsonDecode(datesJson));
    }
    return null;
  }

  Future<void> saveAttendance(Attendance attendance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_attendanceKey, jsonEncode(attendance.toJson()));
  }

  Future<Attendance?> getAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString(_attendanceKey);
    if (attendanceJson != null) {
      return Attendance.fromJson(jsonDecode(attendanceJson));
    }
    return null;
  }
}
