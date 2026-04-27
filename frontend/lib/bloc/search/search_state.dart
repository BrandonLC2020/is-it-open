import 'package:equatable/equatable.dart';
import '../../models/place.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<Place> places;
  final List<Place> suggestions;
  final List<Place> recentPlaces;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.places = const [],
    this.suggestions = const [],
    this.recentPlaces = const [],
    this.error,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Place>? places,
    List<Place>? suggestions,
    List<Place>? recentPlaces,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      places: places ?? this.places,
      suggestions: suggestions ?? this.suggestions,
      recentPlaces: recentPlaces ?? this.recentPlaces,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, places, suggestions, recentPlaces, error];
}
