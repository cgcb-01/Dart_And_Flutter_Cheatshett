import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/class_model.dart';
import '../models/exam_model.dart';
import '../models/holiday_model.dart';
import '../models/routine_model.dart';
import '../models/subject_model.dart';
import '../models/vacation_model.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> isFirstLaunch() async {
    return _prefs.getBool('isFirstLaunch') ?? true;
  }

  static Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool('isFirstLaunch', false);
  }

  // Subjects
  static List<Subject> getSubjects() {
    final subjectsJson = _prefs.getStringList('subjects') ?? [];
    return subjectsJson.map((e) => Subject.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveSubjects(List<Subject> subjects) async {
    final subjectsJson = subjects.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('subjects', subjectsJson);
  }

  // Routine
  static List<RoutineDay> getRoutine() {
    final routineJson = _prefs.getStringList('routine') ?? [];
    return routineJson.map((e) => RoutineDay.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveRoutine(List<RoutineDay> routine) async {
    final routineJson = routine.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('routine', routineJson);
  }

  // Holidays
  static List<Holiday> getHolidays() {
    final holidaysJson = _prefs.getStringList('holidays') ?? [];
    return holidaysJson.map((e) => Holiday.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveHolidays(List<Holiday> holidays) async {
    final holidaysJson = holidays.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('holidays', holidaysJson);
  }

  // Vacations
  static List<Vacation> getVacations() {
    final vacationsJson = _prefs.getStringList('vacations') ?? [];
    return vacationsJson.map((e) => Vacation.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveVacations(List<Vacation> vacations) async {
    final vacationsJson = vacations.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('vacations', vacationsJson);
  }

  // Exams
  static List<Exam> getExams() {
    final examsJson = _prefs.getStringList('exams') ?? [];
    return examsJson.map((e) => Exam.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveExams(List<Exam> exams) async {
    final examsJson = exams.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('exams', examsJson);
  }

  // Classes
  static List<ClassModel> getClasses() {
    final classesJson = _prefs.getStringList('classes') ?? [];
    return classesJson.map((e) => ClassModel.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveClasses(List<ClassModel> classes) async {
    final classesJson = classes.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('classes', classesJson);
  }

  // Semester Dates
  static DateTime? getSemesterStartDate() {
    final dateStr = _prefs.getString('semesterStartDate');
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  static Future<void> setSemesterStartDate(DateTime date) async {
    await _prefs.setString('semesterStartDate', date.toIso8601String());
  }

  static DateTime? getSemesterEndDate() {
    final dateStr = _prefs.getString('semesterEndDate');
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  static Future<void> setSemesterEndDate(DateTime date) async {
    await _prefs.setString('semesterEndDate', date.toIso8601String());
  }
}
