import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calendar_view/calendar_view.dart';

import '../../components/calendar/calendar_header.dart';
import '../../components/calendar/calendar_view_stack.dart';
import '../../components/calendar/calendar_sidebar.dart';
import '../../models/saved_place.dart';
import '../../bloc/preferences/preferences_cubit.dart';

import '../../bloc/calendar/calendar_ui_cubit.dart';
import '../../bloc/calendar/calendar_ui_state.dart';
import '../../bloc/calendar/calendar_data_bloc.dart';
import '../../bloc/calendar/calendar_data_state.dart';
import '../../utils/availability_calculator.dart';
import '../../utils/places_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalendarUiCubit>(
      create: (context) => CalendarUiCubit(),
      child: const _CalendarScreenView(),
    );
  }
}

class _CalendarScreenView extends StatelessWidget {
  const _CalendarScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarDataBloc, CalendarDataState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: const _CalendarScreenContent(),
    );
  }
}

class _CalendarScreenContent extends StatelessWidget {
  const _CalendarScreenContent();

  // A curated "Pocket Field Guide" palette for POIs
  static const List<Color> _defaultPalette = [
    Color(0xFFB14E27), // Anchor
    Color(0xFFD99B52), // Ochre
    Color(0xFF8F7A6A), // Taupe
    Color(0xFF6B5344), // Chestnut
    Color(0xFFB57D65), // Dusty Rose
    Color(0xFF9E8B7E), // Mushroom
  ];

  static const Map<String, IconData> _availableIcons = {
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'local_bar': Icons.local_bar,
    'store': Icons.store,
    'shopping_cart': Icons.shopping_cart,
    'fitness_center': Icons.fitness_center,
    'local_hospital': Icons.local_hospital,
    'park': Icons.park,
    'star': Icons.star,
    'home': Icons.home,
    'work': Icons.work,
  };

  Color _colorForPlace(SavedPlace sp, int index) {
    if (sp.color != null && sp.color!.isNotEmpty) {
      try {
        return Color(int.parse(sp.color!, radix: 16));
      } catch (_) {}
    }
    return _defaultPalette[index % _defaultPalette.length];
  }

  EventController<Object?> _buildEventController(
    CalendarDataState dataState,
    CalendarUiState uiState,
    Color personalEventColor,
  ) {
    final controller = EventController<Object?>();
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    List<CalendarEventData<Object?>> businessBlocks = [];

    if (uiState.showBusinessHours) {
      int colorIndex = 0;
      for (final sp in dataState.savedPlaces) {
        if (!dataState.checkedPlaceIds.contains(sp.place.tomtomId)) {
          colorIndex++;
          continue;
        }

        final color = _colorForPlace(sp, colorIndex).withValues(alpha: 1.0);
        final label = displayName(sp);

        for (int weekOffset = -4; weekOffset <= 12; weekOffset++) {
          final weekStart = startOfWeek.add(Duration(days: weekOffset * 7));

          for (final hours in sp.place.hours) {
            final baseDate = weekStart.add(Duration(days: hours.dayOfWeek));
            final startTime = DateTime(
              baseDate.year,
              baseDate.month,
              baseDate.day,
              hours.openTime.hour,
              hours.openTime.minute,
            );
            var endTime = DateTime(
              baseDate.year,
              baseDate.month,
              baseDate.day,
              hours.closeTime.hour,
              hours.closeTime.minute,
            );
            if (endTime.isBefore(startTime)) {
              endTime = endTime.add(const Duration(days: 1));
            }

            businessBlocks.add(
              CalendarEventData(
                title: label,
                date: baseDate,
                startTime: startTime,
                endTime: endTime,
                color: color,
              ),
            );
          }
        }
        colorIndex++;
      }
    }

    final allPersonalEvents = [
      ...dataState.deviceEvents.map(
        (e) => _recolorEvent(e, personalEventColor),
      ),
      ...dataState.importedEvents.map(
        (e) => _recolorEvent(e, personalEventColor),
      ),
      ...dataState.remoteEvents.map(
        (e) => _recolorEvent(e, personalEventColor),
      ),
    ];

    final timedPersonalEvents = allPersonalEvents
        .where((e) => e.startTime != null && e.endTime != null)
        .toList();

    if (uiState.showBusinessHours && uiState.showPersonalEvents) {
      final availableWindows = AvailabilityCalculator.calculateAvailableWindows(
        businessBlocks,
        timedPersonalEvents,
      );
      controller.addAll(availableWindows);
    } else if (uiState.showBusinessHours) {
      controller.addAll(businessBlocks);
    }

    if (uiState.showPersonalEvents) {
      controller.addAll(allPersonalEvents);
    }

    return controller;
  }

  CalendarEventData<Object?> _recolorEvent(
    CalendarEventData<Object?> event,
    Color color,
  ) {
    return CalendarEventData(
      title: event.title,
      description: event.description,
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
      color: color,
      event: event.event,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.places;
    final use24HourFormat = context
        .watch<PreferencesCubit>()
        .state
        .use24HourFormat;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return BlocBuilder<CalendarUiCubit, CalendarUiState>(
      builder: (context, uiState) {
        return BlocBuilder<CalendarDataBloc, CalendarDataState>(
          builder: (context, dataState) {
            final controller = _buildEventController(
              dataState,
              uiState,
              theme.inkMuted,
            );

            Widget sidebarContent = CalendarSidebarWidget(
              dataState: dataState,
              colorForPlace: _colorForPlace,
              availableIcons: _availableIcons,
              isCollapsed: uiState.isSidebarCollapsed,
            );

            Widget calendarContent = CalendarViewStackWidget(
              uiState: uiState,
              controller: controller,
              checkedPlacesCount: dataState.checkedPlaceIds.length,
              textColor: theme.ink,
              textSmallColor: theme.inkMuted,
              use24HourFormat: use24HourFormat,
            );

            return Scaffold(
              backgroundColor: theme.paper,
              appBar: AppBar(
                title: Text('Plan', style: PlacesType.headline(theme.ink)),
                backgroundColor: theme.paper,
                elevation: 0,
                scrolledUnderElevation: 0,
                iconTheme: IconThemeData(color: theme.ink),
                actions: [
                  _buildToggleAction(
                    context: context,
                    isActive: uiState.showBusinessHours,
                    icon: Icons.business_center,
                    label: 'Places',
                    activeColor: theme.anchor,
                    onTap: () =>
                        context.read<CalendarUiCubit>().toggleBusinessHours(),
                  ),
                  const SizedBox(width: 8),
                  _buildToggleAction(
                    context: context,
                    isActive: uiState.showPersonalEvents,
                    icon: Icons.person,
                    label: 'Personal',
                    activeColor: theme.inkMuted,
                    onTap: () =>
                        context.read<CalendarUiCubit>().togglePersonalEvents(),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        uiState.isSidebarCollapsed
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: theme.ink,
                      ),
                      tooltip: uiState.isSidebarCollapsed
                          ? 'Expand Sidebar'
                          : 'Collapse Sidebar',
                      onPressed: () {
                        context.read<CalendarUiCubit>().toggleSidebar();
                      },
                    ),
                  ],
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CalendarHeaderWidget(
                      currentView: uiState.currentView,
                    ),
                  ),
                  if (isMobile)
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: Icon(Icons.filter_list, color: theme.ink),
                        onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                      ),
                    ),
                ],
              ),
              endDrawer: isMobile
                  ? Drawer(
                      backgroundColor: theme.paper,
                      child: SafeArea(child: sidebarContent),
                    )
                  : null,
              body: isMobile
                  ? calendarContent
                  : Row(
                      children: [
                        Expanded(child: calendarContent),
                        VerticalDivider(width: 1, color: theme.ashSoft),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: uiState.isSidebarCollapsed ? 64 : 320,
                          color: theme.paperRaised,
                          child: sidebarContent,
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggleAction({
    required BuildContext context,
    required bool isActive,
    required IconData icon,
    required String label,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final theme = context.places;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(PlacesRadius.lg),
          border: Border.all(
            color: isActive ? activeColor.withValues(alpha: 0.3) : theme.ash,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeColor : theme.inkMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: PlacesType.label(isActive ? activeColor : theme.inkMuted)
                  .copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
