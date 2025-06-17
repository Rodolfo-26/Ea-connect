import 'package:flutter/material.dart';

class ArchitectAccountScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const ArchitectAccountScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Cuenta del arquitecto'),
    );
  }
}
