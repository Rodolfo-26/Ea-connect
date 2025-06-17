import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/image_full_screen.dart';

class ChatConversacionScreen extends StatefulWidget {
  final String chatId;
  final String proyectoId;
  final Map<String, dynamic> proyecto;

  const ChatConversacionScreen({
    super.key,
    required this.chatId,
    required this.proyectoId,
    required this.proyecto,
  });

  @override
  State<ChatConversacionScreen> createState() =>
      _ChatConversacionScreenState();
}

class _ChatConversacionScreenState extends State<ChatConversacionScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'texto': texto,
      'imageUrl': '',
      'remitenteId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _mensajeController.clear();
  }

  Future<void> _enviarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images/${widget.chatId}/$fileName.jpg');

    await ref.putFile(file);
    final imageUrl = await ref.getDownloadURL();

    if (!mounted) return;
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'texto': '',
      'imageUrl': imageUrl,
      'remitenteId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _mostrarIntegrantes() async {
    final chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    final List<dynamic> uids = chatDoc['participantes'];
    List<Map<String, String>> integrantes = [];

    for (String uid in uids) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        integrantes.add({
          'nombre': data['nombre'] ?? 'Usuario',
          'rol': data['rol'] ?? '',
        });
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Integrantes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: integrantes
              .map((i) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(i['nombre']!),
                    subtitle: Text(i['rol']!),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nombreProyecto = widget.proyecto['name'] ?? 'Proyecto';
    final String imageUrl = widget.proyecto['imageURL'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nombreProyecto,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.group, color: Colors.black),
              onPressed: _mostrarIntegrantes,
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mensajes = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final msg =
                        mensajes[index].data() as Map<String, dynamic>;
                    final isMe = msg['remitenteId'] == currentUserId;

                    if (msg['imageUrl'] != null &&
                        msg['imageUrl'].toString().isNotEmpty) {
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImageFullScreen(
                                    imageUrl: msg['imageUrl']),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.network(msg['imageUrl'], width: 200),
                          ),
                        ),
                      );
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['texto'] ?? '',
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _enviarImagen,
                ),
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
