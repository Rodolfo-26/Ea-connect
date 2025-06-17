import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../architect/architect_main.dart';
import '../user/cliente_main.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? errorText;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final prefs = await SharedPreferences.getInstance();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final firestore = FirebaseFirestore.instance;

      final clienteDoc = await firestore.collection('clientes').doc(uid).get();
      final arqDoc = await firestore.collection('users').doc(uid).get();

      if (clienteDoc.exists) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGuest', false);
        await prefs.setString('role', 'cliente');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClienteMainScreen(
              isGuest: false,
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      } else if (arqDoc.exists) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGuest', false);
        await prefs.setString('role', 'arquitecto');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ArchitectMainScreen(
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      } else {
        setState(() {
          errorText = 'Este usuario no tiene un rol asignado en la base de datos.';
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'Credenciales inválidas o usuario no existe';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
          top: screenHeight * 0.15,
          bottom: 30,
        ),
        child: Column(
          children: [
            Image.asset('assets/iconoLogin.png', height: 130),
            const SizedBox(height: 20),
            const Text(
              'Ingresa los datos asignados',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Campo Usuario
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  border: InputBorder.none,
                  hintText: 'Usuario',
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campo Contraseña
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock),
                  border: InputBorder.none,
                  hintText: 'Contraseña',
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            if (errorText != null)
              Text(
                errorText!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
