import 'package:equatable/equatable.dart';

sealed class CalendarDataEvent extends Equatable {
  const CalendarDataEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedPlaces extends CalendarDataEvent {}

class TogglePlaceFilter extends CalendarDataEvent {
  final String tomtomId;
  const TogglePlaceFilter(this.tomtomId);

  @override
  List<Object?> get props => [tomtomId];
}

class InitDeviceCalendar extends CalendarDataEvent {
  final bool fromButton;
  const InitDeviceCalendar({this.fromButton = false});

  @override
  List<Object?> get props => [fromButton];
}

class ToggleDeviceCalendar extends CalendarDataEvent {
  final String calendarId;
  const ToggleDeviceCalendar(this.calendarId);

  @override
  List<Object?> get props => [calendarId];
}

class ImportIcalFile extends CalendarDataEvent {
  final String icsString;
  const ImportIcalFile(this.icsString);

  @override
  List<Object?> get props => [icsString];
}

class ClearImportedEvents extends CalendarDataEvent {}

class LoadRemoteEvents extends CalendarDataEvent {
  final String url;
  const LoadRemoteEvents(this.url);

  @override
  List<Object?> get props => [url];
}

class LoadPersistedImportedEvents extends CalendarDataEvent {}
