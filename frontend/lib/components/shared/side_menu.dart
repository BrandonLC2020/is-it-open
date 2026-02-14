import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_cubit.dart';
import 'glass_container.dart';

class SideMenu extends StatelessWidget {
  final Function(int) onIndexChanged;
  final int selectedIndex;

  const SideMenu({
    super.key,
    required this.onIndexChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Access the current theme mode to determine switch state
    final themeMode = context.watch<ThemeCubit>().state;
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return GlassContainer(
      width: 250,
      blur: 15,
      opacity: 0.1,
      border: Border(
        right: BorderSide(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Text(
                'Is It Open',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(context, 0, 'Search', Icons.search),
                _buildNavItem(context, 1, 'Map', Icons.map),
                _buildNavItem(context, 2, 'My Places', Icons.star),
                _buildNavItem(context, 3, 'Me', Icons.person),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.2)),
          ListTile(
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            title: const Text(
              'Dark Mode',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<ThemeCubit>().toggleTheme();
              },
              activeThumbColor: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String title,
    IconData icon,
  ) {
    final isSelected = selectedIndex == index;
    return Container(
      color: isSelected
          ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          onIndexChanged(index);
        },
      ),
    );
  }
}
