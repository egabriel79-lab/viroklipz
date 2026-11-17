import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import 'camera_screen.dart';
import 'edit_description_screen.dart';
import 'media_picker_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String nombreUsuario;
  final String arroba;
  final String descripcion;
  final String avatarUrl;

  const EditProfileScreen({
    super.key,
    this.nombreUsuario = 'Eloy',
    this.arroba = '@gabriel_12343',
    this.descripcion = '',
    this.avatarUrl = '',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  late String _nombre;
  late String _username;
  late String _descripcion;
  String _pronombre = '';
  File? _avatarFile;
  String? _uploadedAvatarUrl;
  bool _isUploadingAvatar = false;
  File? _backgroundFile;
  String? _backgroundPublicationUrl;

  @override
  void initState() {
    super.initState();
    _nombre = widget.nombreUsuario;
    _username = widget.arroba.replaceFirst('@', '');
    _descripcion = widget.descripcion;
    if (widget.avatarUrl.isNotEmpty) {
      _uploadedAvatarUrl = widget.avatarUrl;
    }
  }

  String get _profileUrl => 'viroklipz.app/@$_username';

  /// Sube el archivo de avatar a FirebaseStorage (avatars/{uid}.jpg),
  /// obtiene getDownloadURL(), actualiza FirebaseAuth.updatePhotoURL y Firestore users/{uid}.avatarUrl.
  Future<void> _uploadAvatarToFirebase(File imageFile) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _avatarFile = imageFile;
      _isUploadingAvatar = true;
    });

    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref('avatars/${currentUser.uid}.jpg');
      await storageRef.putFile(imageFile);
      final String downloadUrl = await storageRef.getDownloadURL();

      await currentUser.updatePhotoURL(downloadUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'avatarUrl': downloadUrl}, SetOptions(merge: true));

      if (!mounted) return;
      context.read<UserProvider>().updateAvatarFromUrl(downloadUrl);

      setState(() {
        _uploadedAvatarUrl = downloadUrl;
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil actualizada'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo subir la foto de perfil'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _pickImageFromSource({
    required ImageSource source,
    required bool isAvatar,
  }) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (image == null || !mounted) return;

    final File pickedFile = File(image.path);
    if (isAvatar) {
      await _uploadAvatarToFirebase(pickedFile);
    } else {
      setState(() {
        _backgroundFile = pickedFile;
        _backgroundPublicationUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de fondo cargada'),
          backgroundColor: Color(0xFF27272A),
        ),
      );
    }
  }

  Future<void> _openMediaPicker({required bool isAvatar}) async {
    final String? selectedUrl = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const MediaPickerScreen()),
    );
    if (selectedUrl != null && mounted) {
      if (isAvatar) {
        setState(() => _isUploadingAvatar = true);
        await context.read<UserProvider>().updateAvatarFromUrl(selectedUrl);
        if (!mounted) return;
        setState(() {
          _uploadedAvatarUrl = selectedUrl;
          _avatarFile = null;
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        setState(() {
          _backgroundPublicationUrl = selectedUrl;
          _backgroundFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen seleccionada de tus publicaciones'),
            backgroundColor: Color(0xFF27272A),
          ),
        );
      }
    }
  }

  void _removeBackground() {
    setState(() {
      _backgroundFile = null;
      _backgroundPublicationUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fondo de perfil eliminado'),
        backgroundColor: Color(0xFF27272A),
      ),
    );
  }

  void _showMediaOptionsBottomSheet({required bool isAvatar}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              // Opción 1 arriba de todo: Cámara
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.magenta,
                ),
                title: Text(
                  isAvatar ? 'Tomar foto con cámara' : 'Tomar foto o video',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (isAvatar) {
                    _pickImageFromSource(
                      source: ImageSource.camera,
                      isAvatar: true,
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, color: Colors.white12),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white70,
                ),
                title: const Text(
                  'Cargar foto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImageFromSource(
                    source: ImageSource.gallery,
                    isAvatar: isAvatar,
                  );
                },
              ),
              const Divider(height: 1, color: Colors.white12),
              ListTile(
                leading: const Icon(
                  Icons.video_collection_outlined,
                  color: Colors.white70,
                ),
                title: const Text(
                  'Elegir de tus publicaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openMediaPicker(isAvatar: isAvatar);
                },
              ),
              Container(height: 8, color: AppColors.background),
              ListTile(
                title: Text(
                  'Cancelar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyProfileUrl() async {
    await Clipboard.setData(ClipboardData(text: 'https://$_profileUrl'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL del perfil copiada'),
        backgroundColor: Color(0xFF27272A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasBackground =
        _backgroundFile != null || _backgroundPublicationUrl != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _showMediaOptionsBottomSheet(isAvatar: false),
            child: const Text(
              'Agregar fondo',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Banner superior con Fondo seleccionado, Cambiar y Eliminar fondo
          if (hasBackground)
            Container(
              height: 96,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_backgroundFile != null)
                    Image.file(_backgroundFile!, fit: BoxFit.cover)
                  else
                    Image.network(_backgroundPublicationUrl!, fit: BoxFit.cover),
                  Container(color: Colors.black45),
                  const Positioned(
                    left: 12,
                    bottom: 10,
                    child: Text(
                      'Fondo seleccionado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _showMediaOptionsBottomSheet(isAvatar: false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Cambiar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _removeBackground,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Eliminar fondo',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Avatar circular grande + cámara / CircularProgressIndicator + "Cambiar foto"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isUploadingAvatar
                      ? null
                      : () => _showMediaOptionsBottomSheet(isAvatar: true),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Builder(
                        builder: (context) {
                          final liveUrl = context.watch<UserProvider>().avatarUrl;
                          final effectiveUrl = _uploadedAvatarUrl ??
                              (liveUrl.isNotEmpty
                                  ? liveUrl
                                  : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop');
                          return CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.surface,
                            backgroundImage: _avatarFile != null
                                ? FileImage(_avatarFile!) as ImageProvider
                                : NetworkImage(effectiveUrl),
                          );
                        },
                      ),
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        child: _isUploadingAvatar
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.8,
                                    color: AppColors.magenta,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _isUploadingAvatar
                      ? null
                      : () => _showMediaOptionsBottomSheet(isAvatar: true),
                  child: Text(
                    _isUploadingAvatar ? 'Subiendo foto...' : 'Cambiar foto',
                    style: const TextStyle(
                      color: AppColors.magenta,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // Opciones principales
          _buildInfoTile(
            title: 'Nombre',
            value: _nombre,
            onTap: () {},
          ),
          _buildInfoTile(
            title: 'Nombre de usuario',
            value: _username,
            onTap: () {},
          ),
          ListTile(
            title: const Text(
              'URL del perfil',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _profileUrl,
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                ),
                const SizedBox(width: 8),
                Icon(Icons.copy_rounded, size: 17, color: Colors.grey[400]),
              ],
            ),
            onTap: _copyProfileUrl,
          ),

          const Divider(height: 1, color: Colors.white10),

          // Sección: Información básica
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'Información básica',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildInfoTile(
            title: 'Descripción',
            value: _descripcion.isEmpty
                ? 'Agregar una descripción'
                : _descripcion,
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditDescriptionScreen(initialDescription: _descripcion),
                ),
              );
              if (result != null && mounted) {
                setState(() => _descripcion = result);
              }
            },
          ),
          _buildInfoTile(
            title: 'Pronombre',
            value: _pronombre.isEmpty ? 'Agregar pronombres' : _pronombre,
            onTap: () {},
          ),

          const Divider(height: 1, color: Colors.white10),

          // Sección: Otros
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'Otros',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildInfoTile(
            title: 'AI Self',
            value: 'Configurar',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey[500]),
        ],
      ),
      onTap: onTap,
    );
  }
}