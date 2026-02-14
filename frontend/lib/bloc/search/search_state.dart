import 'package:equatable/equatable.dart';
import '../../models/place.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<Place> places;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.places = const [],
    this.error,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Place>? places,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      places: places ?? this.places,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, places, error];
}
