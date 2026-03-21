import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState {
  final bool use24HourFormat;

  const PreferencesState({
    required this.use24HourFormat,
  });

  PreferencesState copyWith({
    bool? use24HourFormat,
  }) {
    return PreferencesState(
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
    );
  }
}

class PreferencesCubit extends Cubit<PreferencesState> {
  static const String _timeFormatKey = 'use_24_hour_format';

  PreferencesCubit() : super(const PreferencesState(use24HourFormat: false)) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final use24HourFormat = prefs.getBool(_timeFormatKey) ?? false;
    emit(state.copyWith(use24HourFormat: use24HourFormat));
  }

  Future<void> toggle24HourFormat(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_timeFormatKey, value);
    emit(state.copyWith(use24HourFormat: value));
  }
}
