
import 'package:equatable/equatable.dart';

import '../model/calendar_model.dart';

class CalendarState extends Equatable {
  final CalendarModel calendar;
  final DateTime currentDate;
  final DateTime selectedDate;
  final double blur;

  const CalendarState({
    required this.calendar,
    required this.currentDate,
    required this.selectedDate,
    this.blur = 0.0,
  });

  CalendarState copyWith({
    final CalendarModel? calendar,
    final DateTime? currentDate,
    final DateTime? selectedDate,
    final double? blur,
  }) {
    return CalendarState(
      calendar: calendar ?? this.calendar,
      currentDate: currentDate ?? this.currentDate,
      selectedDate: selectedDate ?? this.selectedDate,
      blur: blur ?? this.blur,
    );
  }

  @override
  List<Object?> get props => [calendar, selectedDate, currentDate, blur];
}
