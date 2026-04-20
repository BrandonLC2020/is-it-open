import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:calendar_view/calendar_view.dart';

import '../../bloc/calendar/calendar_ui_state.dart';
import '../../bloc/calendar/calendar_ui_cubit.dart';
import 'calendar_event_tile.dart';
import 'calendar_header.dart';

String _weekDayShortName(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[weekday - 1];
}

Widget _buildTimeLineLabel(
  DateTime date,
  bool use24HourFormat,
  Color labelColor,
) {
  final timeString = use24HourFormat
      ? "${date.hour.toString().padLeft(2, '0')}:00"
      : DateFormat(
          'h a',
        ).format(DateTime(date.year, date.month, date.day, date.hour));
  final label = Center(
    child: Text(timeString, style: TextStyle(color: labelColor, fontSize: 12)),
  );

  if (date.hour == 1) {
    final midnightString = use24HourFormat ? '00:00' : '12 AM';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        label,
        Positioned(
          top: -60,
          height: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              midnightString,
              style: TextStyle(color: labelColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
  return label;
}

class CalendarViewStackWidget extends StatelessWidget {
  final CalendarUiState uiState;
  final EventController<Object?> controller;
  final int checkedPlacesCount;
  final Color textColor;
  final Color textSmallColor;
  final bool use24HourFormat;

  const CalendarViewStackWidget({
    super.key,
    required this.uiState,
    required this.controller,
    required this.checkedPlacesCount,
    required this.textColor,
    required this.textSmallColor,
    required this.use24HourFormat,
  });

  @override
  Widget build(BuildContext context) {
    List<WeekDays> weekDays = WeekDays.values;
    int daysToAdvance = 0;

    if (uiState.currentView == CalendarViewType.threeDay) {
      daysToAdvance = 3;
      weekDays = [
        WeekDays.values[uiState.baseDate.weekday - 1],
        WeekDays.values[uiState.baseDate.add(const Duration(days: 1)).weekday -
            1],
        WeekDays.values[uiState.baseDate.add(const Duration(days: 2)).weekday -
            1],
      ];
    } else if (uiState.currentView == CalendarViewType.singleDay) {
      daysToAdvance = 1;
    } else {
      daysToAdvance = 7;
    }

    final now = DateTime.now();
    final initialScrollOffset = (now.hour * 60.0 + now.minute) * 1.0;
    final isShowingToday =
        DateUtils.isSameDay(uiState.baseDate, now) ||
        (uiState.currentView == CalendarViewType.week &&
            uiState.baseDate
                .subtract(Duration(days: uiState.baseDate.weekday - 1))
                .isBefore(now) &&
            uiState.baseDate
                .subtract(Duration(days: uiState.baseDate.weekday - 1))
                .add(const Duration(days: 7))
                .isAfter(now));

    Widget calendarWidget;
    if (uiState.currentView == CalendarViewType.singleDay) {
      calendarWidget = DayView(
        key: ValueKey('day_${uiState.baseDate}_$checkedPlacesCount'),
        controller: controller,
        initialDay: uiState.baseDate,
        scrollOffset: initialScrollOffset,
        minDay: uiState.baseDate.subtract(const Duration(days: 28)),
        maxDay: uiState.baseDate.add(const Duration(days: 84)),
        heightPerMinute: 1,
        scrollPhysics: const ClampingScrollPhysics(),
        pageViewPhysics: const NeverScrollableScrollPhysics(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        headerStyle: HeaderStyle(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        eventArranger: const StackEventArranger(),
        eventTileBuilder:
            (date, events, boundary, startDuration, endDuration) =>
                CalendarEventTileWidget(
                  date: date,
                  events: events,
                  boundary: boundary,
                  startDuration: startDuration,
                  endDuration: endDuration,
                ),
        fullDayEventBuilder: (events, date) =>
            FullDayEventWidget(events: events, date: date),
        showLiveTimeLineInAllDays: true,
        dayTitleBuilder: (date) => const SizedBox.shrink(),
        hourIndicatorSettings: HourIndicatorSettings(
          color: Theme.of(context).dividerColor,
        ),
        liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
          color: Theme.of(context).colorScheme.primary,
        ),
        timeLineBuilder: (date) => _buildTimeLineLabel(
          date,
          use24HourFormat,
          Theme.of(context).textTheme.bodySmall?.color ?? textSmallColor,
        ),
      );
    } else {
      calendarWidget = WeekView(
        key: ValueKey(
          'week_${uiState.baseDate}_${uiState.currentView}_$checkedPlacesCount',
        ),
        controller: controller,
        minDay: uiState.baseDate.subtract(const Duration(days: 28)),
        maxDay: uiState.baseDate.add(const Duration(days: 84)),
        initialDay: uiState.baseDate,
        scrollOffset: initialScrollOffset,
        startDay: uiState.currentView == CalendarViewType.threeDay
            ? WeekDays.values[uiState.baseDate.weekday - 1]
            : WeekDays.monday,
        weekDays: weekDays,
        heightPerMinute: 1,
        scrollPhysics: const ClampingScrollPhysics(),
        pageViewPhysics: const NeverScrollableScrollPhysics(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        headerStyle: HeaderStyle(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        weekTitleBackgroundColor: const Color(0xFF1565C0),
        eventArranger: const StackEventArranger(),
        eventTileBuilder:
            (date, events, boundary, startDuration, endDuration) =>
                CalendarEventTileWidget(
                  date: date,
                  events: events,
                  boundary: boundary,
                  startDuration: startDuration,
                  endDuration: endDuration,
                ),
        fullDayEventBuilder: (events, date) =>
            FullDayEventWidget(events: events, date: date),
        showLiveTimeLineInAllDays: true,
        weekPageHeaderBuilder: (start, end) => const SizedBox.shrink(),
        weekNumberBuilder: (date) => const SizedBox.shrink(),
        hourIndicatorSettings: HourIndicatorSettings(
          color: Theme.of(context).dividerColor,
        ),
        liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
          color: Theme.of(context).colorScheme.primary,
          showBullet: false,
        ),
        timeLineBuilder: (date) => _buildTimeLineLabel(
          date,
          use24HourFormat,
          Theme.of(context).textTheme.bodySmall?.color ?? textSmallColor,
        ),
        weekDayBuilder: (date) {
          final isToday = DateUtils.isSameDay(date, DateTime.now());
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: isToday
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _weekDayShortName(date.weekday),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  context.read<CalendarUiCubit>().navigateDate(
                    uiState.baseDate.subtract(Duration(days: daysToAdvance)),
                  );
                },
              ),
              Expanded(
                child: Text(
                  buildCalendarHeaderText(
                    uiState.currentView,
                    uiState.baseDate,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  context.read<CalendarUiCubit>().navigateDate(
                    uiState.baseDate.add(Duration(days: daysToAdvance)),
                  );
                },
              ),
              if (!isShowingToday)
                TextButton.icon(
                  onPressed: () => context.read<CalendarUiCubit>().navigateDate(
                    DateTime.now(),
                  ),
                  icon: const Icon(Icons.today, size: 18),
                  label: const Text('Today'),
                ),
            ],
          ),
        ),
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                secondaryContainer: Theme.of(context).scaffoldBackgroundColor,
                primaryContainer: Theme.of(context).scaffoldBackgroundColor,
                surface: Theme.of(context).scaffoldBackgroundColor,
                error: Colors.transparent,
              ),
              canvasColor: Theme.of(context).scaffoldBackgroundColor,
              cardColor: Theme.of(context).scaffoldBackgroundColor,
              secondaryHeaderColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: calendarWidget,
          ),
        ),
      ],
    );
  }
}
