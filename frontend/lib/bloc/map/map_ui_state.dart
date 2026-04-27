import 'package:equatable/equatable.dart';

class MapUiState extends Equatable {
  final bool isSidebarCollapsed;

  const MapUiState({this.isSidebarCollapsed = false});

  MapUiState copyWith({bool? isSidebarCollapsed}) {
    return MapUiState(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
    );
  }

  @override
  List<Object?> get props => [isSidebarCollapsed];
}
