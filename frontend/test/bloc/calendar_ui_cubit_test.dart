import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/bloc/calendar/calendar_ui_state.dart';
import 'package:frontend/bloc/calendar/calendar_ui_cubit.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  test('CalendarUiState default toggles are true', () {
    final state = CalendarUiState(
      baseDate: DateTime.now(),
      currentView: CalendarViewType.week,
      isCalendarExpanded: false,
      isCalendarMinimized: false,
    );
    expect(state.showBusinessHours, true);
    expect(state.showPersonalEvents, true);
  });

  test('CalendarUiCubit toggles state correctly', () {
    final cubit = CalendarUiCubit();
    cubit.toggleBusinessHours();
    expect(cubit.state.showBusinessHours, false);
    cubit.togglePersonalEvents();
    expect(cubit.state.showPersonalEvents, false);
    cubit.toggleSidebar();
    expect(cubit.state.isSidebarCollapsed, true);
    cubit.toggleSidebar();
    expect(cubit.state.isSidebarCollapsed, false);
  });
}
