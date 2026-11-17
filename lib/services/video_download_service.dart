import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoDownloadService {
  final Dio _dio = Dio();

  /// Verifica y solicita permisos de almacenamiento según plataforma y versión.
  Future<bool> requestGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      if (status.isGranted || status.isLimited) return true;
      final fallback = await Permission.photos.request();
      return fallback.isGranted || fallback.isLimited;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final int sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+): permisos granulares de media
        final statuses = await [
          Permission.videos,
          Permission.photos,
        ].request();

        final bool videosGranted = statuses[Permission.videos]?.isGranted ?? false;
        final bool photosGranted = statuses[Permission.photos]?.isGranted ?? false;
        return videosGranted || photosGranted;
      } else {
        // Android 12 e inferiores (API <= 32)
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }

    return false;
  }

  /// Descarga el video desde [videoUrl] (Firebase / R2 / HTTP) y lo guarda en la galería.
  Future<void> downloadAndSaveToGallery({
    required String videoUrl,
    void Function(double progress)? onProgress,
  }) async {
    final bool hasPermission = await requestGalleryPermission();
    if (!hasPermission) {
      throw Exception(
        'Permiso de galería denegado. Habilítalo en los ajustes de la app.',
      );
    }

    // Si es un archivo local (ej. recién grabado en modo MVP), guárdalo directo
    if (!videoUrl.startsWith('http')) {
      await Gal.putVideo(videoUrl, album: 'Viroklipz');
      return;
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String filePath =
        '${tempDir.path}/viroklipz_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      await _dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total > 0) {
            onProgress((received / total).clamp(0.0, 1.0));
          }
        },
      );

      await Gal.putVideo(filePath, album: 'Viroklipz');
    } on DioException catch (e) {
      throw Exception('Error de descarga: ${e.message ?? "Verifica tu conexión"}');
    } on GalException catch (e) {
      throw Exception('No se pudo guardar en galería: ${e.type.message}');
    } finally {
      final tempFile = File(filePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}