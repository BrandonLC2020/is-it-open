import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/api_client.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiClient apiClient;

  SearchBloc({required this.apiClient}) : super(const SearchState()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial, places: []));
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading));

    try {
      final places = await apiClient.searchPlaces(event.query);
      emit(state.copyWith(status: SearchStatus.success, places: places));
    } catch (e) {
      emit(state.copyWith(status: SearchStatus.failure, error: e.toString()));
    }
  }
}
