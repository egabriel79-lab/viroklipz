import 'dart:io';
import 'dart:typed_data';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as p;
import '../config/env_config.dart';

class R2UploadService {
  late final Minio _minio;

  R2UploadService() {
    _minio = Minio(
      endPoint: EnvConfig.r2Endpoint,
      accessKey: EnvConfig.r2AccessKey,
      secretKey: EnvConfig.r2SecretKey,
      useSSL: true,
      region: 'auto',
    );
  }

  /// Sube el archivo de video a Cloudflare R2 y retorna su URL pública HTTPS.
  Future<String> uploadVideo({
    required File videoFile,
    required String userId,
    void Function(double progress)? onProgress,
  }) async {
    final int totalBytes = await videoFile.length();
    final String extension = p.extension(videoFile.path).isNotEmpty
        ? p.extension(videoFile.path)
        : '.mp4';
    final String objectKey =
        'videos/$userId/${DateTime.now().millisecondsSinceEpoch}$extension';

    try {
      int uploadedBytes = 0;

      final Stream<Uint8List> stream = videoFile.openRead().map((chunk) {
        uploadedBytes += chunk.length;
        if (onProgress != null && totalBytes > 0) {
          onProgress((uploadedBytes / totalBytes).clamp(0.0, 1.0));
        }
        return Uint8List.fromList(chunk);
      });

      await _minio.putObject(
        EnvConfig.r2BucketName,
        objectKey,
        stream,
        size: totalBytes,
        metadata: {
          'content-type': 'video/mp4',
        },
      );

      final String baseUrl = EnvConfig.r2PublicBaseUrl.endsWith('/')
          ? EnvConfig.r2PublicBaseUrl.substring(0, EnvConfig.r2PublicBaseUrl.length - 1)
          : EnvConfig.r2PublicBaseUrl;

      return '$baseUrl/$objectKey';
    } on SocketException {
      throw Exception('Sin conexión durante la subida a Cloudflare R2.');
    } catch (e) {
      throw Exception('Fallo al subir el video a R2: $e');
    }
  }
}