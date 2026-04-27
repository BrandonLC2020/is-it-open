import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BusinessHours extends Equatable {
  final int dayOfWeek;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const BusinessHours({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
  });

  @override
  List<Object?> get props => [dayOfWeek, openTime, closeTime];

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    return BusinessHours(
      dayOfWeek: json['day_of_week'],
      openTime: _parseTime(json['open_time']),
      closeTime: _parseTime(json['close_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'open_time':
          '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}',
      'close_time':
          '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}',
    };
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
