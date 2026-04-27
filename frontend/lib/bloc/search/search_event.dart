import 'package:equatable/equatable.dart';
import '../../models/place.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class LoadSearchSuggestions extends SearchEvent {
  final double? lat;
  final double? lng;

  const LoadSearchSuggestions({this.lat, this.lng});

  @override
  List<Object> get props => [lat ?? 0.0, lng ?? 0.0];
}

class AddRecentPlace extends SearchEvent {
  final Place place;

  const AddRecentPlace(this.place);

  @override
  List<Object> get props => [place];
}
