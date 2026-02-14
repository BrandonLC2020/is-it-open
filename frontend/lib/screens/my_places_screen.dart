import 'package:flutter/material.dart';

class MyPlacesScreen extends StatelessWidget {
  const MyPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Places')),
      body: const Center(child: Text('My Saved Places will appear here')),
    );
  }
}
