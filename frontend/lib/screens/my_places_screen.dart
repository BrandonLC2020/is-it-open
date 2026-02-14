import 'package:flutter/material.dart';

class MyPlacesScreen extends StatelessWidget {
  const MyPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: const SafeArea(
        child: Center(
          child: Text(
            'My Saved Places will appear here',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
