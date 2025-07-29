class Vacation {
  final DateTime startDate;
  final DateTime endDate;
  final String name;

  Vacation({
    required this.startDate,
    required this.endDate,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'name': name,
    };
  }

  factory Vacation.fromMap(Map<String, dynamic> map) {
    return Vacation(
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      name: map['name'],
    );
  }
}
