class ClassModel {
  final DateTime date;
  final String subjectId;
  final bool isPresent;
  final bool isExtraClass;

  ClassModel({
    required this.date,
    required this.subjectId,
    this.isPresent = true,
    this.isExtraClass = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'subjectId': subjectId,
      'isPresent': isPresent,
      'isExtraClass': isExtraClass,
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      date: DateTime.parse(map['date']),
      subjectId: map['subjectId'],
      isPresent: map['isPresent'],
      isExtraClass: map['isExtraClass'],
    );
  }
  ClassModel copyWith({
    DateTime? date,
    String? subjectId,
    bool? isPresent,
    bool? isExtraClass,
  }) {
    return ClassModel(
      date: date ?? this.date,
      subjectId: subjectId ?? this.subjectId,
      isPresent: isPresent ?? this.isPresent,
      isExtraClass: isExtraClass ?? this.isExtraClass,
    );
  }
}
