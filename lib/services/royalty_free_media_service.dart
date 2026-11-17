import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class MissingApiKeyException implements Exception {
  final String providerName;
  MissingApiKeyException(this.providerName);

  @override
  String toString() =>
      'Falta configurar la API Key de $providerName en EnvConfig (--dart-define).';
}

class RoyaltyFreeSound {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final int durationSeconds;
  final String category; // 'music' | 'sfx'

  const RoyaltyFreeSound({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.durationSeconds,
    required this.category,
  });
}

class VideoEffectOverlay {
  final String id;
  final String name;
  final String tag;
  final String thumbnailUrl;
  final String videoUrl;

  const VideoEffectOverlay({
    required this.id,
    required this.name,
    required this.tag,
    required this.thumbnailUrl,
    required this.videoUrl,
  });
}

class RoyaltyFreeMediaService {
  static bool get hasJamendoKey =>
      EnvConfig.jamendoClientId.isNotEmpty &&
      !EnvConfig.jamendoClientId.startsWith('TU_');

  static bool get hasFreesoundKey =>
      EnvConfig.freesoundApiKey.isNotEmpty &&
      !EnvConfig.freesoundApiKey.startsWith('TU_');

  /// Consulta música libre de derechos usando la API oficial de Jamendo v3.0
  Future<List<RoyaltyFreeSound>> fetchJamendoMusic({String query = ''}) async {
    if (!hasJamendoKey) {
      throw MissingApiKeyException('Jamendo');
    }

    final Uri uri = Uri.https('api.jamendo.com', '/v3.0/tracks/', {
      'client_id': EnvConfig.jamendoClientId,
      'format': 'json',
      'limit': '20',
      'audioformat': 'mp32',
      if (query.trim().isNotEmpty) 'search': query.trim(),
    });

    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error Jamendo HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> results =
        (decoded['results'] as List<dynamic>?) ?? <dynamic>[];

    return results
        .map((dynamic item) {
          final map = item as Map<String, dynamic>;
          return RoyaltyFreeSound(
            id: (map['id'] ?? '').toString(),
            title: (map['name'] ?? 'Pista sin título').toString(),
            artist: (map['artist_name'] ?? 'Artista Jamendo').toString(),
            audioUrl: (map['audio'] ?? '').toString(),
            durationSeconds:
                int.tryParse((map['duration'] ?? '0').toString()) ?? 0,
            category: 'music',
          );
        })
        .where((s) => s.audioUrl.isNotEmpty)
        .toList();
  }

  /// Consulta efectos de sonido usando la API oficial de Freesound v2
  Future<List<RoyaltyFreeSound>> fetchFreesoundEffects({
    String query = 'whoosh',
  }) async {
    if (!hasFreesoundKey) {
      throw MissingApiKeyException('Freesound');
    }

    final String effectiveQuery =
        query.trim().isEmpty ? 'cinematic impact' : query.trim();

    final Uri uri = Uri.https('freesound.org', '/apiv2/search/text/', {
      'query': effectiveQuery,
      'fields': 'id,name,username,previews,duration',
      'page_size': '20',
      'token': EnvConfig.freesoundApiKey,
    });

    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error Freesound HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> results =
        (decoded['results'] as List<dynamic>?) ?? <dynamic>[];

    return results
        .map((dynamic item) {
          final map = item as Map<String, dynamic>;
          final previews =
              (map['previews'] as Map<String, dynamic>?) ?? <String, dynamic>{};
          final String url = (previews['preview-hq-mp3'] ??
                  previews['preview-lq-mp3'] ??
                  '')
              .toString();
          final double rawDuration =
              double.tryParse((map['duration'] ?? '0').toString()) ?? 0;

          return RoyaltyFreeSound(
            id: (map['id'] ?? '').toString(),
            title: (map['name'] ?? 'Efecto').toString(),
            artist: '@${(map['username'] ?? 'freesound').toString()}',
            audioUrl: url,
            durationSeconds: rawDuration.round(),
            category: 'sfx',
          );
        })
        .where((s) => s.audioUrl.isNotEmpty)
        .toList();
  }

  /// Pistas de demostración libres de derechos cuando aún no se configura la API Key
  static const List<RoyaltyFreeSound> sampleMusicFallback = [
    RoyaltyFreeSound(
      id: 'demo_m1',
      title: 'Neon Horizon (Synth)',
      artist: 'Viroklipz Royalty-Free',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      durationSeconds: 32,
      category: 'music',
    ),
    RoyaltyFreeSound(
      id: 'demo_m2',
      title: 'Midnight Pulse',
      artist: 'Creative Commons Audio',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      durationSeconds: 45,
      category: 'music',
    ),
    RoyaltyFreeSound(
      id: 'demo_m3',
      title: 'Urban Drift Lo-Fi',
      artist: 'Studio Libre',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      durationSeconds: 28,
      category: 'music',
    ),
  ];

  static const List<RoyaltyFreeSound> sampleEffectsFallback = [
    RoyaltyFreeSound(
      id: 'demo_e1',
      title: 'Transición Whoosh Cine',
      artist: 'SFX Pack CC0',
      audioUrl:
          'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3',
      durationSeconds: 2,
      category: 'sfx',
    ),
    RoyaltyFreeSound(
      id: 'demo_e2',
      title: 'Destello Mágico',
      artist: 'SFX Pack CC0',
      audioUrl:
          'https://assets.mixkit.co/active_storage/sfx/2019/2019-preview.mp3',
      durationSeconds: 3,
      category: 'sfx',
    ),
    RoyaltyFreeSound(
      id: 'demo_e3',
      title: 'Impacto Bass Drop',
      artist: 'SFX Pack CC0',
      audioUrl:
          'https://assets.mixkit.co/active_storage/sfx/2571/2571-preview.mp3',
      durationSeconds: 2,
      category: 'sfx',
    ),
  ];

  /// Galería de overlays visuales MP4 (Mixkit / Pexels libre de derechos)
  static const List<VideoEffectOverlay> effectOverlays = [
    VideoEffectOverlay(
      id: 'light_leaks',
      name: 'Destellos Cálidos',
      tag: 'Light Leak',
      thumbnailUrl:
          'https://images.pexels.com/photos/3377405/pexels-photo-3377405.jpeg?auto=compress&cs=tinysrgb&w=400',
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-warm-light-leaks-overlay-34597-large.mp4',
    ),
    VideoEffectOverlay(
      id: 'neon_particles',
      name: 'Partículas Neón',
      tag: 'Neón',
      thumbnailUrl:
          'https://images.pexels.com/photos/2156881/pexels-photo-2156881.jpeg?auto=compress&cs=tinysrgb&w=400',
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-glittering-golden-particles-background-41213-large.mp4',
    ),
    VideoEffectOverlay(
      id: 'bokeh_nights',
      name: 'Bokeh Nocturno',
      tag: 'Bokeh',
      thumbnailUrl:
          'https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=400',
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-colorful-bokeh-lights-blurred-background-41214-large.mp4',
    ),
    VideoEffectOverlay(
      id: 'vhs_retro',
      name: 'Estática Retro',
      tag: 'VHS',
      thumbnailUrl:
          'https://images.pexels.com/photos/2510428/pexels-photo-2510428.jpeg?auto=compress&cs=tinysrgb&w=400',
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-old-film-scratches-and-dust-overlay-42748-large.mp4',
    ),
  ];
}