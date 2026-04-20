import 'package:equatable/equatable.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:device_calendar/device_calendar.dart';
import '../../models/saved_place.dart';

enum CalendarDataStatus { initial, loading, loaded, error }

class CalendarDataState extends Equatable {
  final CalendarDataStatus status;
  final List<SavedPlace> savedPlaces;
  final Set<String> checkedPlaceIds;
  final List<Calendar> deviceCalendars;
  final List<CalendarEventData<Object?>> deviceEvents;
  final Set<String> checkedCalendarIds;
  final bool hasCalendarPermission;
  final List<CalendarEventData<Object?>> importedEvents;
  final List<CalendarEventData<Object?>> remoteEvents;
  final String? errorMessage;
  final bool isLoadingRemote;

  const CalendarDataState({
    this.status = CalendarDataStatus.initial,
    this.savedPlaces = const [],
    this.checkedPlaceIds = const {},
    this.deviceCalendars = const [],
    this.deviceEvents = const [],
    this.checkedCalendarIds = const {},
    this.hasCalendarPermission = false,
    this.importedEvents = const [],
    this.remoteEvents = const [],
    this.errorMessage,
    this.isLoadingRemote = false,
  });

  CalendarDataState copyWith({
    CalendarDataStatus? status,
    List<SavedPlace>? savedPlaces,
    Set<String>? checkedPlaceIds,
    List<Calendar>? deviceCalendars,
    List<CalendarEventData<Object?>>? deviceEvents,
    Set<String>? checkedCalendarIds,
    bool? hasCalendarPermission,
    List<CalendarEventData<Object?>>? importedEvents,
    List<CalendarEventData<Object?>>? remoteEvents,
    String? errorMessage,
    bool? isLoadingRemote,
  }) {
    return CalendarDataState(
      status: status ?? this.status,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      checkedPlaceIds: checkedPlaceIds ?? this.checkedPlaceIds,
      deviceCalendars: deviceCalendars ?? this.deviceCalendars,
      deviceEvents: deviceEvents ?? this.deviceEvents,
      checkedCalendarIds: checkedCalendarIds ?? this.checkedCalendarIds,
      hasCalendarPermission:
          hasCalendarPermission ?? this.hasCalendarPermission,
      importedEvents: importedEvents ?? this.importedEvents,
      remoteEvents: remoteEvents ?? this.remoteEvents,
      errorMessage: errorMessage,
      isLoadingRemote: isLoadingRemote ?? this.isLoadingRemote,
    );
  }

  // Helper to clear error message
  CalendarDataState clearError() {
    return CalendarDataState(
      status: status,
      savedPlaces: savedPlaces,
      checkedPlaceIds: checkedPlaceIds,
      deviceCalendars: deviceCalendars,
      deviceEvents: deviceEvents,
      checkedCalendarIds: checkedCalendarIds,
      hasCalendarPermission: hasCalendarPermission,
      importedEvents: importedEvents,
      remoteEvents: remoteEvents,
      errorMessage: null,
      isLoadingRemote: isLoadingRemote,
    );
  }

  @override
  List<Object?> get props => [
    status,
    savedPlaces,
    checkedPlaceIds,
    deviceCalendars,
    deviceEvents,
    checkedCalendarIds,
    hasCalendarPermission,
    importedEvents,
    remoteEvents,
    errorMessage,
    isLoadingRemote,
  ];
}
