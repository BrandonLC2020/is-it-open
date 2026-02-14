import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/api_client.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/search/search_event.dart';
import '../../blocs/search/search_state.dart';

import 'place_detail_screen.dart'; // Will be created next

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(BuildContext context) {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    }
  }

  void _clearSearch(BuildContext context) {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchQueryChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(apiClient: ApiClient()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Search Places')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(
                builder: (context) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for a place...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _clearSearch(context),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _performSearch(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _performSearch(context),
                        child: const Text('Search'),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == SearchStatus.failure) {
                    return Center(child: Text('Error: ${state.error}'));
                  } else if (state.status == SearchStatus.success) {
                    if (state.places.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }
                    return ListView.builder(
                      itemCount: state.places.length,
                      itemBuilder: (context, index) {
                        final place = state.places[index];
                        return ListTile(
                          title: Text(place.name),
                          subtitle: Text(place.address),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlaceDetailScreen(place: place),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('Enter a query and press Search'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
