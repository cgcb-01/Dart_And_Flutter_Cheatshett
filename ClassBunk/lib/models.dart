class Subject {
  String name;
  String teacher;
  String classTime;

  Subject({required this.name, required this.teacher, required this.classTime});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      teacher: json['teacher'],
      classTime: json['classTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'teacher': teacher, 'classTime': classTime};
  }
}

class Routine {
  Map<String, List<Subject>> schedule;

  Routine({required this.schedule});

  factory Routine.fromJson(Map<String, dynamic> json) {
    Map<String, List<Subject>> schedule = {};
    json.forEach((day, subjects) {
      schedule[day] = (subjects as List)
          .map((s) => Subject.fromJson(s))
          .toList();
    });
    return Routine(schedule: schedule);
  }

  Map<String, dynamic> toJson() {
    return schedule.map(
      (day, subjects) =>
          MapEntry(day, subjects.map((s) => s.toJson()).toList()),
    );
  }
}

class Holiday {
  DateTime date;

  Holiday({required this.date});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(date: DateTime.parse(json['date']));
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String()};
  }
}

class Vacation {
  DateTime startDate;
  DateTime endDate;

  Vacation({required this.startDate, required this.endDate});

  factory Vacation.fromJson(Map<String, dynamic> json) {
    return Vacation(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

class Exam {
  DateTime startDate;
  DateTime endDate;

  Exam({required this.startDate, required this.endDate});

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

class ClassDates {
  DateTime start;
  DateTime end;

  ClassDates({required this.start, required this.end});

  factory ClassDates.fromJson(Map<String, dynamic> json) {
    return ClassDates(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'start': start.toIso8601String(), 'end': end.toIso8601String()};
  }
}

class Attendance {
  Map<String, SubjectAttendance> subjects;

  Attendance({required this.subjects});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    Map<String, SubjectAttendance> subjects = {};
    json.forEach((key, value) {
      subjects[key] = SubjectAttendance.fromJson(value);
    });
    return Attendance(subjects: subjects);
  }

  Map<String, dynamic> toJson() {
    return subjects.map((key, value) => MapEntry(key, value.toJson()));
  }
}

class SubjectAttendance {
  int attended;
  int total;
  int extraClasses;
  List<DateTime> absentDates;

  SubjectAttendance({
    this.attended = 0,
    this.total = 0,
    this.extraClasses = 0,
    List<DateTime>? absentDates,
  }) : absentDates = absentDates ?? [];

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    return SubjectAttendance(
      attended: json['attended'],
      total: json['total'],
      extraClasses: json['extraClasses'],
      absentDates: (json['absentDates'] as List)
          .map((date) => DateTime.parse(date))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attended': attended,
      'total': total,
      'extraClasses': extraClasses,
      'absentDates': absentDates.map((date) => date.toIso8601String()).toList(),
    };
  }
}
