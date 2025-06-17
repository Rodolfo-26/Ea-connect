import 'package:flutter/material.dart';
import '../feed/feed_screen.dart';
import 'cliente_mensajes.dart';
import 'cliente_progress.dart';
import 'cliente_perfil.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClienteMainScreen extends StatefulWidget {
  final bool isGuest;
  final VoidCallback? onToggleTheme;

  const ClienteMainScreen({
    super.key,
    this.isGuest = false,
    this.onToggleTheme,
  });

  @override
  State<ClienteMainScreen> createState() => _ClienteMainScreenState();
}

class _ClienteMainScreenState extends State<ClienteMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  final List<String> _titles = [
    '',
    'Chat de Mensajes',
    'Progreso',
    'Cuenta',
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      FeedScreen(isLoggedIn: true, onToggleTheme: widget.onToggleTheme),
      const ClienteMensajesScreen(),
      const ClienteProgressScreen(),
      const ClientePerfilScreen(),
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

  void _confirmLogout(BuildContext context) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!context.mounted) return;

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
              elevation: 1,
              iconTheme: theme.iconTheme,
              automaticallyImplyLeading: true,
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
                widget.onToggleTheme?.call();
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => _confirmLogout(context),
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
