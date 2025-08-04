import '../models/class_model.dart';
import '../models/routine_model.dart';
import '../models/subject_model.dart';
import '../services/local_storage.dart';

class AttendanceCalculator {
  static Future<void> initializeAttendanceData() async {
    final startDate = LocalStorage.getSemesterStartDate();
    final endDate = LocalStorage.getSemesterEndDate();
    if (startDate == null || endDate == null) return;

    final routine = LocalStorage.getRoutine();
    final holidays = LocalStorage.getHolidays();
    final vacations = LocalStorage.getVacations();
    final exams = LocalStorage.getExams();
    final existingClasses = LocalStorage.getClasses();

    // If already initialized, don't recalculate
    if (existingClasses.isNotEmpty) return;

    final classes = <ClassModel>[];
    final updatedSubjects = <Subject>[];

    // Calculate all class dates
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      // Skip weekends
      if (currentDate.weekday == DateTime.saturday ||
          currentDate.weekday == DateTime.sunday) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      // Skip holidays
      if (holidays.any((h) => _isSameDay(h.date, currentDate))) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      // Skip vacations
      bool shouldSkip = false;
      DateTime? newDate;

      for (final v in vacations) {
        if (currentDate.isAfter(v.startDate) &&
            currentDate.isBefore(v.endDate)) {
          shouldSkip = true;
          newDate = v.endDate.add(const Duration(days: 1));
          break;
        }
      }

      if (shouldSkip) {
        currentDate = newDate!;
        continue;
      }

      // Skip exams that affect attendance
      // Solution using any() while maintaining your exact logic flow
      shouldSkip = false;
      newDate;

      for (final e in exams) {
        if (!e.affectsAttendance &&
            currentDate.isAfter(e.startDate) &&
            currentDate.isBefore(e.endDate)) {
          shouldSkip = true;
          newDate = e.endDate.add(const Duration(days: 1));
          break;
        }
      }

      if (shouldSkip) {
        currentDate = newDate!;
        continue;
      }

      // Get day name (Monday, Tuesday, etc.)
      final dayName = _getDayName(currentDate.weekday);
      final dayRoutine = routine.firstWhere(
        (r) => r.day.toLowerCase() == dayName.toLowerCase(),
        orElse: () => RoutineDay(day: dayName, classes: []),
      );

      // Create classes for each slot
      for (final classSlot in dayRoutine.classes) {
        classes.add(
          ClassModel(
            date: currentDate,
            subjectId: classSlot.subjectId,
            isPresent: currentDate.isBefore(DateTime.now()),
            isExtraClass: false,
          ),
        );

        // Update subject totals
        final subjectIndex = updatedSubjects.indexWhere(
          (s) => s.id == classSlot.subjectId,
        );
        if (subjectIndex != -1) {
          final subject = updatedSubjects[subjectIndex];
          updatedSubjects[subjectIndex] = subject.copyWith(
            totalClasses: subject.totalClasses + 1,
            attendedClasses:
                subject.attendedClasses +
                (currentDate.isBefore(DateTime.now()) ? 1 : 0),
          );
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Save all data
    await LocalStorage.saveClasses(classes);
    await LocalStorage.saveSubjects(updatedSubjects);
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
