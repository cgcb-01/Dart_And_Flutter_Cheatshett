class Exam {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool affectsAttendance;

  Exam({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.affectsAttendance = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'affectsAttendance': affectsAttendance,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      affectsAttendance: map['affectsAttendance'],
    );
  }
}
