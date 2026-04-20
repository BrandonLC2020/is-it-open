import 'package:equatable/equatable.dart';

enum CalendarViewType { singleDay, threeDay, week }

class CalendarUiState extends Equatable {
  final CalendarViewType currentView;
  final DateTime baseDate;
  final bool isCalendarExpanded;
  final bool isCalendarMinimized;

  const CalendarUiState({
    required this.currentView,
    required this.baseDate,
    required this.isCalendarExpanded,
    required this.isCalendarMinimized,
  });

  CalendarUiState copyWith({
    CalendarViewType? currentView,
    DateTime? baseDate,
    bool? isCalendarExpanded,
    bool? isCalendarMinimized,
  }) {
    return CalendarUiState(
      currentView: currentView ?? this.currentView,
      baseDate: baseDate ?? this.baseDate,
      isCalendarExpanded: isCalendarExpanded ?? this.isCalendarExpanded,
      isCalendarMinimized: isCalendarMinimized ?? this.isCalendarMinimized,
    );
  }

  @override
  List<Object?> get props => [currentView, baseDate, isCalendarExpanded, isCalendarMinimized];
}
