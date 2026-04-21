import 'package:equatable/equatable.dart';

enum CalendarViewType { singleDay, threeDay, week }

class CalendarUiState extends Equatable {
  final CalendarViewType currentView;
  final DateTime baseDate;
  final bool isCalendarExpanded;
  final bool isCalendarMinimized;
  final bool showBusinessHours;
  final bool showPersonalEvents;

  const CalendarUiState({
    required this.currentView,
    required this.baseDate,
    required this.isCalendarExpanded,
    required this.isCalendarMinimized,
    this.showBusinessHours = true,
    this.showPersonalEvents = true,
  });

  CalendarUiState copyWith({
    CalendarViewType? currentView,
    DateTime? baseDate,
    bool? isCalendarExpanded,
    bool? isCalendarMinimized,
    bool? showBusinessHours,
    bool? showPersonalEvents,
  }) {
    return CalendarUiState(
      currentView: currentView ?? this.currentView,
      baseDate: baseDate ?? this.baseDate,
      isCalendarExpanded: isCalendarExpanded ?? this.isCalendarExpanded,
      isCalendarMinimized: isCalendarMinimized ?? this.isCalendarMinimized,
      showBusinessHours: showBusinessHours ?? this.showBusinessHours,
      showPersonalEvents: showPersonalEvents ?? this.showPersonalEvents,
    );
  }

  @override
  List<Object?> get props => [
    currentView,
    baseDate,
    isCalendarExpanded,
    isCalendarMinimized,
    showBusinessHours,
    showPersonalEvents,
  ];
}
