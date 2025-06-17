import 'package:flutter/material.dart';

class ArchitectProgressScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const ArchitectProgressScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Progreso del arquitecto'),
    );
  }
}
