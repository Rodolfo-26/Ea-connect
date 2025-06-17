import 'package:flutter/material.dart';
import '../feed/feed_screen.dart';
import '../login/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const WelcomeScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Center(
                child: Text(
                  'EA CONNECT',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Cambiar tema'),
              onTap: () {
                Navigator.pop(context);
                onToggleTheme();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Bienvenido'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Logo.png', height: 120),
            const SizedBox(height: 30),
            Text(
              'Bienvenido a EA Connect',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Explora proyectos arquitectónicos o inicia sesión para acceder a más funciones.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeedScreen(isLoggedIn: false),
                    ),
                  );
                },
                child: const Text('Continuar como invitado'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(onToggleTheme: onToggleTheme),
                  ),
                );
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
