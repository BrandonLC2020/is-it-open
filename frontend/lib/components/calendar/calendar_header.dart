import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/calendar/calendar_ui_state.dart';
import '../../bloc/calendar/calendar_ui_cubit.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final CalendarViewType currentView;

  const CalendarHeaderWidget({super.key, required this.currentView});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CalendarViewType>(
      segments: const [
        ButtonSegment(value: CalendarViewType.singleDay, label: Text('1 Day')),
        ButtonSegment(value: CalendarViewType.threeDay, label: Text('3 Days')),
        ButtonSegment(value: CalendarViewType.week, label: Text('Week')),
      ],
      selected: <CalendarViewType>{currentView},
      onSelectionChanged: (Set<CalendarViewType> selection) {
        context.read<CalendarUiCubit>().changeViewType(selection.first);
      },
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}

String _formatHeaderDate(DateTime date) {
  return DateFormat('MMM d').format(date);
}

String buildCalendarHeaderText(
  CalendarViewType currentView,
  DateTime baseDate,
) {
  if (currentView == CalendarViewType.singleDay) {
    return DateFormat('EEEE, MMM d, yyyy').format(baseDate);
  } else if (currentView == CalendarViewType.threeDay) {
    final endDate = baseDate.add(const Duration(days: 2));
    if (baseDate.month == endDate.month) {
      return '${_formatHeaderDate(baseDate)} – ${endDate.day}, ${DateFormat('yyyy').format(endDate)}';
    }
    return '${_formatHeaderDate(baseDate)} – ${_formatHeaderDate(endDate)}, ${DateFormat('yyyy').format(endDate)}';
  } else {
    final weekStart = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekStart.month == weekEnd.month) {
      return '${_formatHeaderDate(weekStart)} – ${weekEnd.day}, ${DateFormat('yyyy').format(weekEnd)}';
    }
    return '${_formatHeaderDate(weekStart)} – ${_formatHeaderDate(weekEnd)}, ${DateFormat('yyyy').format(weekEnd)}';
  }
}
