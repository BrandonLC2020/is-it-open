import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'my_places_screen.dart';
import '../components/shared/side_menu.dart';
import 'me_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    SearchScreen(),
    MapScreen(),
    MyPlacesScreen(),
    MeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            selectedIndex: _selectedIndex,
            onIndexChanged: _onItemTapped,
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: const Text('Is It Open')),
              body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
            ),
          ),
        ],
      ),
    );
  }
}
