import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../feed/feed_screen.dart';

class GuestMainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const GuestMainScreen({super.key, required this.onToggleTheme});

  @override
  State<GuestMainScreen> createState() => _GuestMainScreenState();
}

class _GuestMainScreenState extends State<GuestMainScreen> {
  int _selectedIndex = 0;

  void _confirmExitApp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Salir de la aplicación?'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // Cierra la app
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      FeedScreen(isLoggedIn: false, onToggleTheme: widget.onToggleTheme),
      const SizedBox.shrink(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            _confirmExitApp();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
        ],
      ),
    );
  }
}
