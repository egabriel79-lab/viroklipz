import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_model.dart';

class SupabaseVideoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<VideoModel>> fetchFeedVideos() async {
    try {
      final List<dynamic> rows = await _client
          .from('videos')
          .select('id, user_id, username, video_url, description, audio_name, likes_count')
          .order('created_at', ascending: false)
          .limit(30);

      return rows
          .map((row) => VideoModel.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error en Supabase: ${e.message}');
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu red.');
    } catch (_) {
      throw Exception('No se pudieron cargar los videos.');
    }
  }

  Future<void> createVideoRecord({
    required String videoUrl,
    required String description,
    required String audioName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para publicar un video.');
    }

    final String username =
        (user.userMetadata?['username'] as String?)?.trim().isNotEmpty == true
            ? user.userMetadata!['username'] as String
            : (user.email?.split('@').first ?? 'usuario');

    try {
      await _client.from('videos').insert({
        'user_id': user.id,
        'username': username,
        'video_url': videoUrl,
        'description': description,
        'audio_name': audioName.isEmpty ? 'Sonido original — $username' : audioName,
        'likes_count': 0,
      });
    } on PostgrestException catch (e) {
      throw Exception('Error al guardar en base de datos: ${e.message}');
    } on SocketException {
      throw Exception('Se perdió la conexión al guardar el registro.');
    }
  }
}