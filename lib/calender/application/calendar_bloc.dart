
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../model/calendar_model.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc()
      : super(CalendarState(
          calendar: CalendarModel.empty(),
          selectedDate: DateTime.now(),
          currentDate: DateTime.now(),
        )) {
    on<CalendarStartEvent>(_start);
    on<CalendarChangeEvent>(_change);
    on<CalendarUpdateBlurEvent>(_updateBlur);
    on<CalendarEndBlurEvent>(_endBlur);
    on<CalendarClickEvent>(_clicked);
    add(CalendarStartEvent());
  }

  Future<void> _endBlur(
      CalendarEndBlurEvent event, Emitter<CalendarState> emit) async {
    bool isNext = event.endDetails.primaryVelocity! < 0;
    emit(state.copyWith(blur: 0.0));
    add(CalendarChangeEvent(isNext: isNext));
  }

  Future<void> _updateBlur(
      CalendarUpdateBlurEvent event, Emitter<CalendarState> emit) async {
    double blur = state.blur;
    double dx = 0.0;
    if (event.updateDetails.delta.dx > 0) {
      dx = event.updateDetails.delta.dx / 70;
    } else {
      dx = -(event.updateDetails.delta.dx) / 70;
    }
    blur = dx + blur > 0.5 ? 0.5 : dx + blur;
    emit(state.copyWith(blur: blur));
  }

  Future<void> _change(
      CalendarChangeEvent event, Emitter<CalendarState> emit) async {
    int index = event.isNext ? 1 : -1;
    DateTime dateTime =
        DateTime(state.currentDate.year, state.currentDate.month + index);
    List<int> day = _days(dateTime);
    emit(state.copyWith(
        currentDate: dateTime,
        calendar: state.calendar
            .copyWith(year: dateTime.year, month: dateTime.month, days: day)));
  }

  Future<void> _start(
      CalendarStartEvent event, Emitter<CalendarState> emit) async {
    DateTime dateTime = event.datTime ?? DateTime.now();
    List<int> day = _days(dateTime);
    emit(state.copyWith(
        calendar: state.calendar
            .copyWith(year: dateTime.year, month: dateTime.month, days: day)));
  }

  List<int> _days(DateTime dateTime) {
    int dayLenght = _daysLengthChecked(dateTime);
    int frontSpaces = _spaceDays(
        type: DateFormat('EEEE')
            .format(DateTime(dateTime.year, dateTime.month, 1)));
    int rearSpaces = _spaceDays(
        type: DateFormat('EEEE')
            .format(DateTime(dateTime.year, dateTime.month, dayLenght)),
        isLast: true);

    List<int> days = [
      ...List.generate(frontSpaces, (_) => 0),
      ...List.generate(dayLenght, (index) => index + 1),
      ...List.generate(rearSpaces, (_) => 0),
    ];
    return days;
  }

  int _spaceDays({
    required String type,
    bool isLast = false,
  }) {
    int spaceLength = 0;
    switch (type) {
      case "Monday":
        spaceLength = isLast ? 5 : 1;
        break;
      case "Tuesday":
        spaceLength = isLast ? 4 : 2;
        break;
      case "Wednesday":
        spaceLength = isLast ? 3 : 3;
        break;
      case "Thursday":
        spaceLength = isLast ? 2 : 4;
        break;
      case "Friday":
        spaceLength = isLast ? 1 : 5;
        break;
      case "Saturday":
        spaceLength = isLast ? 0 : 6;
        break;
      case "Sunday":
        spaceLength = isLast ? 6 : 0;
        break;
      default:
    }
    return spaceLength;
  }

  int _daysLengthChecked(DateTime dateTime) {
    int dayLength = 0;
    List thiryFirst = [1, 3, 5, 7, 8, 10, 12];

    if (dateTime.month == 2) {
      if (((dateTime.year % 4 == 0) && (dateTime.year % 100 != 0)) ||
          (dateTime.year % 400 == 0)) {
        dayLength = 29;
      } else {
        dayLength = 28;
      }
    } else {
      dayLength = thiryFirst.contains(dateTime.month) ? 31 : 30;
    }
    return dayLength;
  }

  Future<void> _clicked(
      CalendarClickEvent event, Emitter<CalendarState> emit) async {
    DateTime selectedDateTime = DateTime(state.currentDate.year,
        state.currentDate.month, event.selectedDate.day);
    emit(state.copyWith(
      selectedDate: selectedDateTime,
    ));
  }

  @override
  void onChange(Change<CalendarState> change) {
    super.onChange(change);
  }
}
