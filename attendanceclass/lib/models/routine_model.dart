class RoutineDay {
  final String day;
  final List<ClassSlot> classes;

  RoutineDay({required this.day, required this.classes});

  Map<String, dynamic> toMap() {
    return {'day': day, 'classes': classes.map((e) => e.toMap()).toList()};
  }

  factory RoutineDay.fromMap(Map<String, dynamic> map) {
    return RoutineDay(
      day: map['day'],
      classes: (map['classes'] as List)
          .map((e) => ClassSlot.fromMap(e))
          .toList(),
    );
  }

  RoutineDay copyWith({String? day, List<ClassSlot>? classes}) {
    return RoutineDay(day: day ?? this.day, classes: classes ?? this.classes);
  }
}

class ClassSlot {
  final String subjectId;
  final String startTime;
  final String endTime;

  ClassSlot({
    required this.subjectId,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {'subjectId': subjectId, 'startTime': startTime, 'endTime': endTime};
  }

  factory ClassSlot.fromMap(Map<String, dynamic> map) {
    return ClassSlot(
      subjectId: map['subjectId'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }

  // Add this missing copyWith method
  ClassSlot copyWith({String? subjectId, String? startTime, String? endTime}) {
    return ClassSlot(
      subjectId: subjectId ?? this.subjectId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
