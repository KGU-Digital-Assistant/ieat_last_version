import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CalendarEvent extends Equatable {}

class CalendarStartEvent extends CalendarEvent {
  final DateTime? datTime;

  CalendarStartEvent({
    this.datTime,
  });
  @override
  List<Object?> get props => [];
}

class CalendarChangeEvent extends CalendarEvent {
  final bool isNext;
  CalendarChangeEvent({required this.isNext});
  @override
  List<Object?> get props => [];
}

class CalendarUpdateBlurEvent extends CalendarEvent {
  final DragUpdateDetails updateDetails;

  CalendarUpdateBlurEvent({required this.updateDetails});
  @override
  List<Object?> get props => [];
}

class CalendarEndBlurEvent extends CalendarEvent {
  final DragEndDetails endDetails;

  CalendarEndBlurEvent({required this.endDetails});

  @override
  List<Object?> get props => [];
}

class CalendarClickEvent extends CalendarEvent {
  final DateTime selectedDate;

  CalendarClickEvent({required this.selectedDate});

  @override
  List<Object?> get props => [];
}
