import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_ui_state.dart';

class MapUiCubit extends Cubit<MapUiState> {
  MapUiCubit() : super(const MapUiState());

  void toggleSidebar() {
    emit(state.copyWith(isSidebarCollapsed: !state.isSidebarCollapsed));
  }
}
