import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImageFullScreen extends StatefulWidget {
  final String imageUrl;

  const ImageFullScreen({super.key, required this.imageUrl});

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  bool _isDownloading = false;
  int _sdkInt = 0;

  @override
  void initState() {
    super.initState();
    _obtenerVersionSDK();
  }

  Future<void> _obtenerVersionSDK() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      setState(() {
        _sdkInt = info.version.sdkInt;
      });
    }
  }

  Future<void> _solicitarPermisos() async {
    if (Platform.isAndroid) {
      if (_sdkInt >= 33) {
        var permiso = await Permission.photos.request();
        if (!permiso.isGranted) {
          throw Exception("Permiso de galería denegado");
        }
      } else {
        var permiso = await Permission.storage.request();
        if (!permiso.isGranted) {
          throw Exception("Permiso de almacenamiento denegado");
        }
      }
    }
  }

  Future<void> _descargarImagen() async {
    setState(() => _isDownloading = true);

    try {
      await _solicitarPermisos();

      final response = await http.get(Uri.parse(widget.imageUrl));
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.bodyBytes),
        name: "imagen_${DateTime.now().millisecondsSinceEpoch}",
        isReturnImagePathOfIOS: true,
      );

      if (!mounted) return;

      if ((result['isSuccess'] == true) || (result['filePath'] != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Imagen guardada en la galería')),
        );
      } else {
        throw Exception("No se pudo guardar la imagen");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download, color: Colors.white),
            onPressed: _isDownloading ? null : _descargarImagen,
          )
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(widget.imageUrl),
        ),
      ),
    );
  }
}
