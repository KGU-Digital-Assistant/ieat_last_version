class CalendarModel {
  final int year;
  final int month;
  final List<int> days;
  const CalendarModel({
    required this.year,
    required this.month,
    required this.days,
  });

  CalendarModel copyWith({
    final int? year,
    final int? month,
    final List<int>? days,
  }) {
    return CalendarModel(
      year: year ?? this.year,
      month: month ?? this.month,
      days: days ?? this.days,
    );
  }

  factory CalendarModel.empty() =>
      const CalendarModel(year: 0, month: 0, days: []);
}
