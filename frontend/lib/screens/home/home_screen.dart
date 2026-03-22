import 'package:flutter/material.dart';
import 'package:frontend/screens/search/search_screen.dart';
import 'package:frontend/screens/map/map_screen.dart';
import 'package:frontend/screens/places/my_places_screen.dart';
import 'package:frontend/screens/calendar/calendar_screen.dart';
import '../../components/shared/side_menu.dart';
import 'package:frontend/screens/profile/me_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MyPlacesScreen(),
    CalendarScreen(),
    MapScreen(),
    SearchScreen(),
    MeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A237E).withValues(alpha: 0.1), // Deep Blue
                      const Color(0xFF0D47A1).withValues(alpha: 0.1), // Blue
                      const Color(0xFF880E4F).withValues(alpha: 0.1), // Pink/Purple accent
                    ],
                  ),
                ),
              ),
              if (isMobile)
                _widgetOptions.elementAt(_selectedIndex)
              else
                Row(
                  children: [
                    SideMenu(
                      selectedIndex: _selectedIndex,
                      onIndexChanged: _onItemTapped,
                    ),
                    Expanded(
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: _widgetOptions.elementAt(_selectedIndex),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  currentIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 8,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Places'),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
                    BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                  ],
                )
              : null,
        );
      },
    );
  }
}
