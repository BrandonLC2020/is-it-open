import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/api_service.dart';
import '../../../models/saved_place.dart';
import '../../../components/places/saved_place_list_card.dart';
import '../../../components/places/saved_place_grid_card.dart';

class MyPlacesScreen extends StatefulWidget {
  const MyPlacesScreen({super.key});

  @override
  State<MyPlacesScreen> createState() => _MyPlacesScreenState();
}

class _MyPlacesScreenState extends State<MyPlacesScreen> {
  late Future<List<SavedPlace>> _bookmarksFuture;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _bookmarksFuture = context.read<ApiService>().getBookmarks();
  }

  Future<void> _refreshBookmarks() async {
    setState(() {
      _bookmarksFuture = context.read<ApiService>().getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Saved Places'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBookmarks,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<SavedPlace>>(
          future: _bookmarksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: _refreshBookmarks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No saved places yet',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
              );
            }

            final places = snapshot.data!;
            final pinnedPlaces = places.where((p) => p.isPinned).toList();
            final unpinnedPlaces = places.where((p) => !p.isPinned).toList();

            return RefreshIndicator(
              onRefresh: _refreshBookmarks,
              child: CustomScrollView(
                slivers: [
                  if (pinnedPlaces.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Pinned',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _isGridView
                        ? SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 300,
                                    mainAxisExtent: 140,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return SavedPlaceGridCard(
                                  savedPlace: pinnedPlaces[index],
                                  onRefresh: _refreshBookmarks,
                                );
                              }, childCount: pinnedPlaces.length),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return SavedPlaceListCard(
                                savedPlace: pinnedPlaces[index],
                                onRefresh: _refreshBookmarks,
                              );
                            }, childCount: pinnedPlaces.length),
                          ),
                  ],
                  if (unpinnedPlaces.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Saved Places',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _isGridView
                        ? SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 300,
                                    mainAxisExtent: 140,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return SavedPlaceGridCard(
                                  savedPlace: unpinnedPlaces[index],
                                  onRefresh: _refreshBookmarks,
                                );
                              }, childCount: unpinnedPlaces.length),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return SavedPlaceListCard(
                                savedPlace: unpinnedPlaces[index],
                                onRefresh: _refreshBookmarks,
                              );
                            }, childCount: unpinnedPlaces.length),
                          ),
                  ],
                  // Added bottom padding
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
