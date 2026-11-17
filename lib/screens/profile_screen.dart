import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/video_provider.dart';
import 'activity_center_screen.dart';
import 'balance_screen.dart';
import 'edit_description_screen.dart';
import 'edit_profile_screen.dart';
import 'get_coins_screen.dart';
import 'legal_screen.dart';
import 'offline_videos_screen.dart';
import 'qr_profile_screen.dart';
import 'select_highlight_media_screen.dart';
import 'settings_privacy_screen.dart';
import 'story_viewer_screen.dart';
import 'video_detail_screen.dart';
import 'viroklipz_studio_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embeddedInMainShell;
  final String? username;
  final String? userId;

  const ProfileScreen({
    super.key,
    this.embeddedInMainShell = true,
    this.username,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Llave para abrir el menú lateral desde el botón de hamburguesa
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String seguidores = '269';
  final String siguiendo = '17';
  final String meGusta = '577';
  String miVariableDescripcion = '';
  int _selectedTabIndex = 0;
  bool _isDeletingAccount = false;
  bool _isFollowingScannedUser = false;

  bool get _isViewingOtherUser =>
      (widget.username != null && widget.username!.trim().isNotEmpty) ||
      (widget.userId != null && widget.userId!.trim().isNotEmpty);

  final List<String> videosUrls = const [
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=400&auto=format&fit=crop',
  ];

  String get _resolvedUsername {
    final auth = context.read<AuthProvider>();
    return (auth.userProfile?['username'] ??
            auth.currentUser?.username ??
            FirebaseAuth.instance.currentUser?.displayName ??
            'usuario')
        .toString();
  }

  Future<void> _openEditDescription() async {
    final nuevaDescripcion = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => EditDescriptionScreen(
          initialDescription: miVariableDescripcion,
        ),
      ),
    );

    if (!mounted || nuevaDescripcion == null) return;
    setState(() {
      miVariableDescripcion = nuevaDescripcion;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'bio': nuevaDescripcion});
      } catch (_) {}
    }
  }

  void _openViroklipzStudio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ViroklipzStudioScreen(),
      ),
    );
  }

  void _openQrProfile() {
    final username = _resolvedUsername;
    final liveAvatar = context.read<UserProvider>().avatarUrl;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrProfileScreen(
          nombreUsuario: username,
          arroba: '@$username',
          avatarUrl: liveAvatar.isNotEmpty
              ? liveAvatar
              : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop',
        ),
      ),
    );
  }

  void _openEditProfile() {
    final username = _resolvedUsername;
    final liveAvatar = context.read<UserProvider>().avatarUrl;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          nombreUsuario: username,
          arroba: '@$username',
          descripcion: miVariableDescripcion,
          avatarUrl: liveAvatar,
        ),
      ),
    );
  }

  void _openActivityCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActivityCenterScreen(),
      ),
    );
  }

  void _openOfflineVideos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OfflineVideosScreen(),
      ),
    );
  }

  void _openBalance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BalanceScreen(),
      ),
    );
  }

  void _openGetCoins() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GetCoinsScreen(),
      ),
    );
  }

  void _openSettingsPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPrivacyScreen(),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: !_isDeletingAccount,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            '¿Estás seguro de que deseas eliminar tu cuenta?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Esta acción es permanente e irreversible. Se eliminarán todos tus videos, seguidores y datos personales en Viroklipz.',
            style: TextStyle(
              color: Color(0xFFD4D4D8),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFA1A1AA)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _confirmDeleteAccount();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount() async {
    setState(() => _isDeletingAccount = true);

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (!mounted) return;
        setState(() => _isDeletingAccount = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFDC2626),
            content: Text(
              'No se encontró una sesión activa.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      // Paso A: Eliminar documento del usuario en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .delete();

      // Paso B: Eliminar cuenta en Firebase Authentication
      await currentUser.delete();

      if (!mounted) return;
      await context.read<AuthProvider>().signOut();

      if (!mounted) return;
      setState(() => _isDeletingAccount = false);

      // Paso C: Navegar a Landing Page limpiando el historial
      Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);

      final String message = e.code == 'requires-recent-login'
          ? 'Por seguridad, debes cerrar sesión y volver a iniciarla antes de eliminar tu cuenta'
          : 'Error al eliminar la cuenta: ${e.message ?? e.code}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text(
            'No se pudo eliminar tu cuenta. Intenta nuevamente.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isViewingOtherUser) {
      final rawHandle = (widget.username ?? 'creador').trim();
      final cleanHandle =
          rawHandle.startsWith('@') ? rawHandle.substring(1) : rawHandle;
      final displayHandle = '@$cleanHandle';
      final bool lookupByUid =
          widget.userId != null && widget.userId!.trim().isNotEmpty;

      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: lookupByUid
            ? FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, isEqualTo: widget.userId!.trim())
                .limit(1)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: cleanHandle)
                .limit(1)
                .snapshots(),
        builder: (context, snapshot) {
          final docData = snapshot.data?.docs.isNotEmpty == true
              ? snapshot.data!.docs.first.data()
              : null;
          final resolvedName =
              (docData?['username'] ?? cleanHandle).toString();
          final resolvedBio = (docData?['bio'] ?? '').toString();
          final resolvedAvatar = (docData?['avatarUrl'] ??
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop')
              .toString();

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    pinned: true,
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      displayHandle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resolvedName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                displayHandle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildStat('142', 'Siguiendo'),
                                  const SizedBox(width: 16),
                                  _buildStat('12.4K', 'Seguidores'),
                                  const SizedBox(width: 16),
                                  _buildStat('84.2K', 'Me gusta'),
                                ],
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(resolvedAvatar),
                            onBackgroundImageError: (_, __) {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (resolvedBio.isNotEmpty) ...[
                            Text(
                              resolvedBio,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Builder(
                            builder: (context) {
                              final String? myUid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              final String targetUid =
                                  snapshot.data?.docs.isNotEmpty == true
                                      ? snapshot.data!.docs.first.id
                                      : cleanHandle;
                              final videoProvider =
                                  context.watch<VideoProvider>();

                              Widget buildFollowButton(bool isFollowing) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (myUid == null) {
                                        setState(() {
                                          _isFollowingScannedUser =
                                              !_isFollowingScannedUser;
                                        });
                                      } else {
                                        videoProvider.toggleFollow(targetUid);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFollowing
                                          ? const Color(0xFFF4F4F5)
                                          : const Color(0xFFFE2C55),
                                      foregroundColor: isFollowing
                                          ? Colors.black
                                          : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      isFollowing ? 'Siguiendo' : 'Seguir',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (myUid == null) {
                                return buildFollowButton(
                                  _isFollowingScannedUser,
                                );
                              }

                              return StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(myUid)
                                    .collection('following')
                                    .doc(targetUid)
                                    .snapshots(),
                                builder: (context, followSnap) {
                                  final bool isFollowing = followSnap.hasData
                                      ? followSnap.data!.exists
                                      : videoProvider.isFollowing(targetUid);
                                  return buildFollowButton(isFollowing);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 9 / 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Image.network(
                        videosUrls[index],
                        fit: BoxFit.cover,
                      ),
                      childCount: videosUrls.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final User? fbUser = FirebaseAuth.instance.currentUser ?? auth.firebaseUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: fbUser != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(fbUser.uid)
              .snapshots()
          : null,
      builder: (context, snapshot) {
        final Map<String, dynamic>? firestoreData = snapshot.data?.data();
        final String username = (firestoreData?['username'] ??
                auth.userProfile?['username'] ??
                auth.currentUser?.username ??
                fbUser?.displayName ??
                'gabriel_12343')
            .toString();
        final String email = (firestoreData?['email'] ??
                fbUser?.email ??
                auth.currentUser?.email ??
                '')
            .toString();
        final String liveAvatarUrl = (userProvider.avatarUrl.isNotEmpty
                ? userProvider.avatarUrl
                : (firestoreData?['avatarUrl'] ??
                    fbUser?.photoURL ??
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300&auto=format&fit=crop'))
            .toString();
        final String nombreUsuario = username;
        final String arroba = '@$username';

        // DefaultTabController obligatorio para que TabBar funcione sin errores
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,

            // MENÚ LATERAL DERECHO (endDrawer)
            endDrawer: _buildEndDrawer(email: email),

            body: Stack(
              children: [
                CustomScrollView(
              slivers: [
                // 1. APP BAR PERSONALIZADO
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: _openEditProfile,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                      onPressed: _openQrProfile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add_alt, color: Colors.black),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),

                // 2. INFORMACIÓN DEL PERFIL (FirebaseAuth + Firestore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreUsuario,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              email.isNotEmpty ? '$arroba · $email' : arroba,
                              style:
                                  const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildStat(siguiendo, 'Siguiendo'),
                                const SizedBox(width: 16),
                                _buildStat(seguidores, 'Seguidores'),
                                const SizedBox(width: 16),
                                _buildStat(meGusta, 'Me gusta'),
                              ],
                            ),
                          ],
                        ),
                    GestureDetector(
                      onTap: _openEditProfile,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(
                          liveAvatarUrl.isNotEmpty
                              ? liveAvatarUrl
                              : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300&auto=format&fit=crop',
                        ),
                        onBackgroundImageError: (_, __) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. BOTONES DE DESCRIPCIÓN Y STUDIO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Botón de Agregar Descripción
                    GestureDetector(
                      onTap: _openEditDescription,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          miVariableDescripcion.isEmpty
                              ? '+ Agregar descripción'
                              : miVariableDescripcion,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: miVariableDescripcion.isEmpty
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 2. Botón de Viroklipz Studio
                    GestureDetector(
                      onTap: _openViroklipzStudio,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.pink, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Viroklipz Studio',
                              style: TextStyle(
                                color: Colors.black,
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
            ),

            // 4. HISTORIAS / DESTACADOS
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildStoryItem('Nuevo', Icons.add),
                    ..._highlights.map(
                      (item) => _buildStoryItem(
                        item.title,
                        null,
                        isImage: true,
                        coverUrl: item.coverUrl,
                        slides: item.slides,
                      ),
                    ),
                    _buildStoryItem('Moment...', null, isImage: true),
                  ],
                ),
              ),
            ),

            // 5. PESTAÑAS FIJAS (TABS)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  onTap: (index) => setState(() => _selectedTabIndex = index),
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.lock_outline)),
                    Tab(icon: Icon(Icons.repeat)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                    Tab(icon: Icon(Icons.favorite_border)),
                  ],
                ),
              ),
            ),

            // 6. GRID DE VÍDEOS CONECTADO A FIRESTORE (videos where authorId == miUid)
            if (_selectedTabIndex == 0 && fbUser != null)
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('videos')
                    .where('authorId', isEqualTo: fbUser.uid)
                    .snapshots(),
                builder: (context, videosSnapshot) {
                  if (videosSnapshot.connectionState == ConnectionState.waiting &&
                      !videosSnapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    );
                  }

                  final docs = videosSnapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 24,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.videocam_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aún no has publicado videos',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(2.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 9 / 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final String thumbUrl =
                              (data['thumbnailUrl'] ?? '').toString();
                          final int likesCount =
                              (data['likesCount'] as num?)?.toInt() ??
                                  (data['likes'] as num?)?.toInt() ??
                                  0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VideoDetailScreen(videoId: doc.id),
                                ),
                              );
                            },
                            child: Container(
                              color: const Color(0xFF1F1F23),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (thumbUrl.isNotEmpty)
                                    Image.network(
                                      thumbUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white54,
                                          size: 32,
                                        ),
                                      ),
                                    )
                                  else
                                    const Center(
                                      child: Icon(
                                        Icons.play_circle_filled_rounded,
                                        color: Colors.white54,
                                        size: 34,
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          likesCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: docs.length,
                      ),
                    ),
                  );
                },
              )
            else
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  child: Column(
                    children: [
                      Icon(Icons.videocam_off_outlined,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Aún no hay videos en esta pestaña',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
                if (_isDeletingAccount)
                  Container(
                    color: Colors.black.withValues(alpha: 0.75),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFEF4444)),
                          SizedBox(height: 14),
                          Text(
                            'Eliminando cuenta...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        // Evita duplicar la barra inferior cuando se monta dentro de MainScreen
        bottomNavigationBar: widget.embeddedInMainShell
            ? null
            : BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                currentIndex: 4,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'Inicio',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline),
                    label: 'Amigos',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.cyan, Colors.pink],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    label: '',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined),
                    label: 'Mensajes',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
              ),
          ),
        );
      },
    );
  }

  // ==========================================
  // DISEÑO DEL MENÚ LATERAL (DRAWER)
  // ==========================================
  Widget _buildEndDrawer({String email = ''}) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          children: [
            if (email.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sesión iniciada',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Recursos',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            _buildDrawerItem(
              Icons.account_balance_wallet_outlined,
              'Saldo',
              () {
                Navigator.of(context).pop();
                _openBalance();
              },
            ),
            _buildDrawerItem(
              Icons.monetization_on_outlined,
              'Obtener Monedas',
              () {
                Navigator.of(context).pop();
                _openGetCoins();
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Herramientas personales',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            _buildDrawerItem(
              Icons.access_time,
              'Centro de actividades',
              () {
                Navigator.of(context).pop();
                _openActivityCenter();
              },
            ),
            _buildDrawerItem(
              Icons.cloud_download_outlined,
              'Vídeos sin conexión',
              () {
                Navigator.of(context).pop();
                _openOfflineVideos();
              },
            ),
            _buildDrawerItem(
              Icons.qr_code,
              'Tu código QR',
              () {
                Navigator.of(context).pop();
                _openQrProfile();
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Herramientas de creación y negocios',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            _buildDrawerItem(
              Icons.star_border,
              'Viroklipz Studio',
              () {
                Navigator.of(context).pop();
                _openViroklipzStudio();
              },
            ),
            const Divider(),
          // Ajustes y privacidad + Pantallas Legales
          _buildDrawerItem(
            Icons.settings_outlined,
            'Ajustes y privacidad',
            () {
              Navigator.of(context).pop();
              _openSettingsPrivacy();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.black,
              size: 28,
            ),
            title: const Text(
              'Términos y Condiciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalScreen(
                    title: 'Términos y Condiciones',
                    content: LegalTexts.termsAndConditions,
                  ),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            leading: const Icon(
              Icons.shield_outlined,
              color: Colors.black,
              size: 28,
            ),
            title: const Text(
              'Política de Privacidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalScreen(
                    title: 'Política de Privacidad',
                    content: LegalTexts.privacyPolicy,
                  ),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
            ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 26),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await _handleSignOut();
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever_rounded,
                color: Colors.red.shade900,
                size: 26,
              ),
              title: Text(
                'Eliminar cuenta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade900,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteAccountDialog();
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de ayuda para crear cada ítem del menú
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
    );
  }

  // ==========================================
  // WIDGETS DE AYUDA (ESTADÍSTICAS E HISTORIAS)
  // ==========================================
  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  final List<HighlightStoryData> _highlights = [];

  Widget _buildStoryItem(
    String title,
    IconData? icon, {
    bool isImage = false,
    String? coverUrl,
    List<String>? slides,
  }) {
    final String resolvedCover = coverUrl ??
        'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=200&auto=format&fit=crop';

    return GestureDetector(
      onTap: () async {
        if (!isImage) {
          // Si es el botón de "Nuevo", abrimos la galería de selección
          final HighlightStoryData? created =
              await Navigator.push<HighlightStoryData>(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectHighlightMediaScreen(),
            ),
          );
          if (created != null && mounted) {
            setState(() => _highlights.insert(0, created));
          }
        } else {
          // Abrimos el visor del Storie / Destacado
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryViewerScreen(
                title: title,
                coverUrl: resolvedCover,
                slides: slides ??
                    const [
                      'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=900&auto=format&fit=crop',
                      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=900&auto=format&fit=crop',
                    ],
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: isImage
                  ? Image.network(
                      resolvedCover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, color: Colors.grey),
                    )
                  : Icon(icon, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}