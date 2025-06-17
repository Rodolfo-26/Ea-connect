import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('¿Cerrar sesión?'),
      content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            await prefs.setBool('isGuest', true);

            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/feed', (route) => false);
          },
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
}
