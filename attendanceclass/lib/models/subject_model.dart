class Subject {
  final String id;
  final String name;
  final String code;
  final String teacher;
  final int totalClasses;
  final int attendedClasses;
  final int extraClasses;
  final List<DateTime> absentDates;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.teacher,
    this.totalClasses = 0,
    this.attendedClasses = 0,
    this.extraClasses = 0,
    this.absentDates = const [],
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 0.0;
    return (attendedClasses / totalClasses) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'teacher': teacher,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'extraClasses': extraClasses,
      'absentDates': absentDates.map((e) => e.toIso8601String()).toList(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      teacher: map['teacher'],
      totalClasses: map['totalClasses'],
      attendedClasses: map['attendedClasses'],
      extraClasses: map['extraClasses'],
      absentDates: (map['absentDates'] as List)
          .map((e) => DateTime.parse(e))
          .toList(),
    );
  }

  // Add this copyWith method
  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? teacher,
    int? totalClasses,
    int? attendedClasses,
    int? extraClasses,
    List<DateTime>? absentDates,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacher: teacher ?? this.teacher,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      extraClasses: extraClasses ?? this.extraClasses,
      absentDates: absentDates ?? this.absentDates,
    );
  }
}
