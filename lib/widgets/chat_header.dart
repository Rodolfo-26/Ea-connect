import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHeader extends StatelessWidget {
  final String imageUrl;
  final String projectName;
  final String clienteUID;
  final List<String> arquitectos;

  const ChatHeader({
    super.key,
    required this.imageUrl,
    required this.projectName,
    required this.clienteUID,
    required this.arquitectos,
  });

  Future<List<Map<String, String>>> _cargarIntegrantes() async {
    List<Map<String, String>> integrantes = [];
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Cliente
    final clienteDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(clienteUID)
        .get();
    final clienteData = clienteDoc.data();
    if (clienteData != null) {
      integrantes.add({
        'nombre': clienteData['nombre'] ?? 'Cliente',
        'rol': clienteUID == currentUserId ? 'Tú' : clienteData['rol'] ?? 'Cliente',
      });
    }

    // Arquitectos
    for (String uid in arquitectos) {
      final arqDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final arqData = arqDoc.data();
      if (arqData != null) {
        integrantes.add({
          'nombre': arqData['nombre'] ?? 'Arquitecto',
          'rol': uid == currentUserId ? 'Tú' : arqData['rol'] ?? 'Arquitecto',
        });
      }
    }

    return integrantes;
  }

  void _mostrarFoto(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text('Foto de perfil', style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarIntegrantes(BuildContext context) async {
    final integrantes = await _cargarIntegrantes();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text('Integrantes', style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: integrantes.map((i) {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(i['nombre'] ?? ''),
                    subtitle: Text(i['rol'] ?? ''),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _mostrarFoto(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, width: 40, height: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              projectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => _mostrarIntegrantes(context),
          ),
        ],
      ),
    );
  }
}
