import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../feed/feed_screen.dart';
import 'architect_chat.dart';
import 'architect_progress.dart';
import 'architect_account.dart';

class ArchitectMainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ArchitectMainScreen({super.key, required this.onToggleTheme});

  @override
  State<ArchitectMainScreen> createState() => _ArchitectMainScreenState();
}

class _ArchitectMainScreenState extends State<ArchitectMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  final List<String> _titles = [
    '',
    'MENSAJES',
    'PROGRESO',
    'CUENTA',
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      FeedScreen(isLoggedIn: true, onToggleTheme: widget.onToggleTheme),
      ArchitectChatScreen(onToggleTheme: widget.onToggleTheme),
      ArchitectProgressScreen(onToggleTheme: widget.onToggleTheme),
      ArchitectAccountScreen(onToggleTheme: widget.onToggleTheme),
    ];
  }

  void _confirmExitApp(BuildContext context) {
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
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Text(
                _titles[_currentIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              iconTheme: theme.iconTheme,
              elevation: 1,
            ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Center(
                child: Text(
                  'EA CONNECT',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Cambiar tema'),
              onTap: () {
                Navigator.pop(context);
                widget.onToggleTheme();
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Política de privacidad'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'EA Connect',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 TuEmpresa',
                );
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 4) {
            _confirmExitApp(context);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progreso'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cuenta'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Salir'),
        ],
      ),
    );
  }
}