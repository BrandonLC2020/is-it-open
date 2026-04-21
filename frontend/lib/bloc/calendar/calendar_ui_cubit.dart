import 'package:flutter_bloc/flutter_bloc.dart';
import 'calendar_ui_state.dart';

class CalendarUiCubit extends Cubit<CalendarUiState> {
  CalendarUiCubit({DateTime? initialDate})
    : super(
        CalendarUiState(
          currentView: CalendarViewType.week,
          baseDate: initialDate ?? DateTime.now(),
          isCalendarExpanded: false,
          isCalendarMinimized: false,
          showBusinessHours: true,
          showPersonalEvents: true,
        ),
      );

  void changeViewType(CalendarViewType type) {
    emit(state.copyWith(currentView: type));
  }

  void navigateDate(DateTime newDate) {
    emit(state.copyWith(baseDate: newDate));
  }

  void toggleExpanded() {
    emit(
      state.copyWith(
        isCalendarExpanded: !state.isCalendarExpanded,
        isCalendarMinimized: false,
      ),
    );
  }

  void toggleMinimized() {
    emit(
      state.copyWith(
        isCalendarMinimized: !state.isCalendarMinimized,
        isCalendarExpanded: false,
      ),
    );
  }

  void toggleBusinessHours() {
    emit(state.copyWith(showBusinessHours: !state.showBusinessHours));
  }

  void togglePersonalEvents() {
    emit(state.copyWith(showPersonalEvents: !state.showPersonalEvents));
  }
}
