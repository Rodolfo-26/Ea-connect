import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login/login_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/architect/architect_main.dart';
import 'screens/user/cliente_main.dart';
import 'screens/user/guest_main.dart';

import 'notification_service.dart';  // Importa tu servicio de notificaciones

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();  // Inicializa las notificaciones

  runApp(const EAConnectApp());
}

class EAConnectApp extends StatefulWidget {
  const EAConnectApp({super.key});

  @override
  State<EAConnectApp> createState() => _EAConnectAppState();
}

class _EAConnectAppState extends State<EAConnectApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<Widget> _determineStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isGuest = prefs.getBool('isGuest') ?? false;
    final role = prefs.getString('role');

    if (isLoggedIn) {
      if (role == 'arquitecto') {
        return ArchitectMainScreen(onToggleTheme: _toggleTheme);
      }
      if (role == 'cliente') {
        return ClienteMainScreen(
          isGuest: false,
          onToggleTheme: _toggleTheme,
        );
      }
    }

    if (isGuest) {
      return GuestMainScreen(onToggleTheme: _toggleTheme);
    }

    return WelcomeScreen(onToggleTheme: _toggleTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EA Connect',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: FutureBuilder<Widget>(
        future: _determineStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
      routes: {
        '/feed': (context) => GuestMainScreen(onToggleTheme: _toggleTheme),
        '/login': (context) => LoginScreen(onToggleTheme: _toggleTheme),
        '/welcome': (context) => WelcomeScreen(onToggleTheme: _toggleTheme),
      },
    );
  }
}
