import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedScreen extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;
  final VoidCallback? onToggleTheme;

  const FeedScreen({
    super.key,
    this.isLoggedIn = false,
    this.role,
    this.onToggleTheme,
  });

  void _confirmExit(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('isGuest', true);
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/feed', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = !isLoggedIn;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EA CONNECT',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 1,
        iconTheme: theme.iconTheme,
        actions: isGuest
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Iniciar Sesión'),
                  ),
                ),
              ]
            : null,
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
                onToggleTheme?.call();
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
                  applicationLegalese: '©2025 Espacio Arquitectura Estudio SA de CV ',
                );
              },
            ),
            if (!isGuest)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () => _confirmExit(context),
              ),
          ],
        ),
      ),

      // 🔁 AQUÍ VIENE EL CAMBIO PARA MOSTRAR TARJETAS DINÁMICAS
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feeds')
            .orderBy('createdAt', descending: true)
            
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay publicaciones aún.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Column(
                children: [
                  ProjectCard(
                    imageUrl: data['imageUrl'] ?? '',
                    title: data['name'] ?? '',
                    location: data['location'] ?? '',
                    description: data['description'] ?? '',
                    date: data['date'] ?? '',
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ProjectCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String description;
  final String date;

  const ProjectCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.description,
    required this.date,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool isLiked = false;
  
  int likeCount = 15;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(widget.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 15, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(widget.location, style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.date, style: theme.textTheme.bodySmall),
                    Row(
                      children: [
                        IconButton(
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : theme.iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked;
                              likeCount += isLiked ? 1 : -1;
                            });
                          },
                        ),
                        Text('$likeCount', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
