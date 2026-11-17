import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/royalty_free_media_service.dart';
import '../theme/app_colors.dart';

class SoundPickerSheet extends StatefulWidget {
  final String? initialSelectedUrl;

  const SoundPickerSheet({super.key, this.initialSelectedUrl});

  @override
  State<SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends State<SoundPickerSheet>
    with SingleTickerProviderStateMixin {
  final RoyaltyFreeMediaService _mediaService = RoyaltyFreeMediaService();
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _previewPlayer = AudioPlayer();
  late final TabController _tabController;

  List<RoyaltyFreeSound> _musicTracks = [];
  List<RoyaltyFreeSound> _sfxTracks = [];
  bool _isLoadingMusic = true;
  bool _isLoadingSfx = true;
  String? _musicWarning;
  String? _sfxWarning;

  String? _playingId;
  String? _loadingAudioId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMusic();
    _loadSfx();
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _stopPreviewAudio() async {
    try {
      await _previewPlayer.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _playingId = null;
        _loadingAudioId = null;
      });
    }
  }

  Future<void> _togglePreview(RoyaltyFreeSound sound) async {
    if (_playingId == sound.id) {
      await _stopPreviewAudio();
      return;
    }

    await _stopPreviewAudio();
    setState(() => _loadingAudioId = sound.id);

    try {
      await _previewPlayer.setUrl(sound.audioUrl);
      await _previewPlayer.setLoopMode(LoopMode.off);
      if (!mounted) return;
      setState(() {
        _playingId = sound.id;
        _loadingAudioId = null;
      });
      await _previewPlayer.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingAudioId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('No se pudo reproducir con just_audio: $e'),
        ),
      );
    }
  }

  Future<void> _loadMusic({String query = ''}) async {
    setState(() {
      _isLoadingMusic = true;
      _musicWarning = null;
    });
    try {
      final list = await _mediaService.fetchJamendoMusic(query: query);
      if (!mounted) return;
      setState(() {
        _musicTracks = list;
        _isLoadingMusic = false;
      });
    } on MissingApiKeyException catch (e) {
      if (!mounted) return;
      setState(() {
        _musicTracks = RoyaltyFreeMediaService.sampleMusicFallback;
        _musicWarning = '${e.toString()} Mostrando pistas de muestra.';
        _isLoadingMusic = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _musicTracks = RoyaltyFreeMediaService.sampleMusicFallback;
        _musicWarning = 'Sin conexión a Jamendo. Mostrando pistas de muestra.';
        _isLoadingMusic = false;
      });
    }
  }

  Future<void> _loadSfx({String query = ''}) async {
    setState(() {
      _isLoadingSfx = true;
      _sfxWarning = null;
    });
    try {
      final list = await _mediaService.fetchFreesoundEffects(query: query);
      if (!mounted) return;
      setState(() {
        _sfxTracks = list;
        _isLoadingSfx = false;
      });
    } on MissingApiKeyException catch (e) {
      if (!mounted) return;
      setState(() {
        _sfxTracks = RoyaltyFreeMediaService.sampleEffectsFallback;
        _sfxWarning = '${e.toString()} Mostrando efectos de muestra.';
        _isLoadingSfx = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sfxTracks = RoyaltyFreeMediaService.sampleEffectsFallback;
        _sfxWarning = 'Sin conexión a Freesound. Mostrando efectos de muestra.';
        _isLoadingSfx = false;
      });
    }
  }

  void _onSearchSubmitted(String value) {
    if (_tabController.index == 0) {
      _loadMusic(query: value);
    } else {
      _loadSfx(query: value);
    }
  }

  Future<void> _selectSound(RoyaltyFreeSound sound) async {
    await _stopPreviewAudio();
    if (!mounted) return;
    Navigator.pop(context, sound);
  }

  String _formatDuration(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildTrackList({
    required List<RoyaltyFreeSound> tracks,
    required bool isLoading,
    String? warning,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.magenta),
      );
    }

    return Column(
      children: [
        if (warning != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
            ),
            child: Text(
              warning,
              style: const TextStyle(color: Colors.amber, fontSize: 11.5),
            ),
          ),
        Expanded(
          child: tracks.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron sonidos',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tracks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final sound = tracks[index];
                    final bool isPlaying = _playingId == sound.id;
                    final bool isLoadingAudio = _loadingAudioId == sound.id;
                    final bool isSelected =
                        widget.initialSelectedUrl == sound.audioUrl;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.magenta
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _togglePreview(sound),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: isPlaying
                                    ? AppColors.brandGradient
                                    : null,
                                color: isPlaying
                                    ? null
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isLoadingAudio
                                  ? const Padding(
                                      padding: EdgeInsets.all(11),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isPlaying
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sound.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${sound.artist} · ${_formatDuration(sound.durationSeconds)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _togglePreview(sound),
                            child: Text(
                              isPlaying ? 'Detener' : 'Reproducir',
                              style: const TextStyle(
                                color: Color(0xFF25F4EE),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectSound(sound),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.magenta,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Usar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sonidos libres de derechos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmitted,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar música (Jamendo) o efectos (Freesound)...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.magenta,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Música'),
              Tab(text: 'Efectos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrackList(
                  tracks: _musicTracks,
                  isLoading: _isLoadingMusic,
                  warning: _musicWarning,
                ),
                _buildTrackList(
                  tracks: _sfxTracks,
                  isLoading: _isLoadingSfx,
                  warning: _sfxWarning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}