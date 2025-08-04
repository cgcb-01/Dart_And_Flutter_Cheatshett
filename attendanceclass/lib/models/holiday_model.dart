class Holiday {
  final DateTime date;
  final String name;

  Holiday({required this.date, required this.name});

  Map<String, dynamic> toMap() {
    return {'date': date.toIso8601String(), 'name': name};
  }

  factory Holiday.fromMap(Map<String, dynamic> map) {
    return Holiday(date: DateTime.parse(map['date']), name: map['name']);
  }
}
