import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_screen.dart';
import '../user/guest_main.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const WelcomeScreen({super.key, required this.onToggleTheme});

  Future<void> _continuarComoInvitado(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GuestMainScreen(onToggleTheme: onToggleTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> servicios = [
      {'icon': Icons.architecture, 'texto': 'Diseño arquitectónico personalizado'},
      {'icon': Icons.design_services, 'texto': 'Supervisión y gestión de obra'},
      {'icon': Icons.camera, 'texto': 'Renderizados y presentación 3D'},
      {'icon': Icons.home_repair_service, 'texto': 'Remodelación de espacios'},
      {'icon': Icons.engineering, 'texto': 'Consultoría técnica profesional'},
    ];

    return Scaffold(
      // 🔴 Eliminamos el AppBar para evitar la franja superior
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/Logo.png', height: 120),
              const SizedBox(height: 30),

              Text(
                'Bienvenido a EA Connect',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: servicios.map((servicio) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(servicio['icon'], color: Colors.amber, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            servicio['texto'],
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

           
              const SizedBox(height: 40),

              // ⬜ Botón blanco
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _continuarComoInvitado(context),
                  child: const Text('Continuar como invitado'),
                ),
              ),

              const SizedBox(height: 16),

              // 🟡 Botón amarillo
              SizedBox(
                width: double.infinity,
                height: 50,
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
                        builder: (_) => LoginScreen(onToggleTheme: onToggleTheme),
                      ),
                    );
                  },
                  child: const Text('Iniciar Sesión'),
                ),
              ),
            ],
          ),
          
        ),
      ),
    );
  }
}