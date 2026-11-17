import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/video_model.dart';
import '../models/video_post.dart';

class VideoProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _followingSub;

  AppUser get currentUser {
    final User? user = _auth.currentUser;
    return AppUser(
      id: user?.uid ?? '',
      username: user?.displayName ?? user?.email?.split('@').first ?? 'usuario',
      avatarUrl: user?.photoURL ?? '',
    );
  }

  // Set de IDs de usuarios a los que sigo (sincronizado desde Firestore)
  final Set<String> followingIds = {};
  final Set<String> likedPostIds = {};

  // Lista reactiva proveniente de Firestore (sin datos estáticos falsos)
  final List<VideoPost> allVideos = [];

  VideoProvider() {
    _bindFollowingStream();
  }

  void _bindFollowingStream() {
    _listenFollowing(_auth.currentUser?.uid);
    _authSub = _auth.authStateChanges().listen((user) {
      _listenFollowing(user?.uid);
      notifyListeners();
    });
  }

  void _listenFollowing(String? uid) {
    _followingSub?.cancel();
    followingIds.clear();
    if (uid == null) {
      notifyListeners();
      return;
    }

    _followingSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .listen((snap) {
      followingIds
        ..clear()
        ..addAll(snap.docs.map((doc) => doc.id));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _followingSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  List<VideoPost> get forYouFeed => List.unmodifiable(allVideos);

  List<VideoPost> get friendsFeed {
    final String myUid = currentUser.id;
    return allVideos
        .where(
          (video) =>
              followingIds.contains(video.author.id) ||
              (myUid.isNotEmpty && video.author.id == myUid),
        )
        .toList();
  }

  bool isFollowing(String userId) => followingIds.contains(userId);
  bool isLiked(String videoId) => likedPostIds.contains(videoId);

  void syncFromFirestore(List<VideoPost> remoteVideos) {
    allVideos
      ..clear()
      ..addAll(remoteVideos);
    notifyListeners();
  }

  void syncFromSupabase(List<VideoModel> remoteVideos) {
    final mapped = remoteVideos
        .map(
          (v) => VideoPost(
            id: v.id,
            author: AppUser(id: v.userId, username: v.username, avatarUrl: ''),
            videoUrl: v.videoUrl,
            caption: v.description,
            likes: v.likesCount,
          ),
        )
        .toList();

    allVideos
      ..clear()
      ..addAll(mapped);
    notifyListeners();
  }

  Future<String?> _resolveSenderName(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final String name = (userDoc.data()?['username'] ??
              user.displayName ??
              user.email?.split('@').first ??
              'Alguien')
          .toString()
          .trim();
      return name.isNotEmpty ? name : 'Alguien';
    } catch (_) {
      return user.displayName ?? user.email?.split('@').first ?? 'Alguien';
    }
  }

  /// Registra una notificación en Firestore ("notifications") para que la Cloud Function envíe el Push FCM.
  Future<void> _createNotification({
    required String receiverUid,
    required String type,
    String? videoId,
    String? senderNameOverride,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null || receiverUid.isEmpty || receiverUid == user.uid) {
      return;
    }

    final String senderName = (senderNameOverride != null &&
            senderNameOverride.trim().isNotEmpty)
        ? senderNameOverride.trim()
        : (await _resolveSenderName(user)) ?? 'Alguien';

    await _firestore.collection('notifications').add({
      'senderUid': user.uid,
      'senderName': senderName,
      'receiverUid': receiverUid,
      'type': type, // 'like' | 'comment' | 'follow'
      if (videoId != null && videoId.isNotEmpty) 'videoId': videoId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Seguir / Dejar de seguir en Firestore (users/{miUid}/following + users/{suUid}/followers)
  Future<void> toggleFollow(String targetUid) async {
    final String? myUid = _auth.currentUser?.uid;
    if (myUid == null || targetUid.isEmpty || targetUid == myUid) {
      return;
    }

    final bool currentlyFollowing = followingIds.contains(targetUid);
    if (currentlyFollowing) {
      followingIds.remove(targetUid);
    } else {
      followingIds.add(targetUid);
    }
    notifyListeners();

    final DocumentReference<Map<String, dynamic>> myFollowingRef = _firestore
        .collection('users')
        .doc(myUid)
        .collection('following')
        .doc(targetUid);
    final DocumentReference<Map<String, dynamic>> targetFollowersRef = _firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(myUid);

    try {
      final snapshot = await myFollowingRef.get();
      final WriteBatch batch = _firestore.batch();
      final bool willFollow = !snapshot.exists;

      if (snapshot.exists) {
        batch.delete(myFollowingRef);
        batch.delete(targetFollowersRef);
      } else {
        batch.set(myFollowingRef, {
          'uid': targetUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.set(targetFollowersRef, {
          'uid': myUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (willFollow) {
        await _createNotification(
          receiverUid: targetUid,
          type: 'follow',
        );
      }
    } catch (_) {
      // Revertir en caso de error de red
      if (currentlyFollowing) {
        followingIds.add(targetUid);
      } else {
        followingIds.remove(targetUid);
      }
      notifyListeners();
    }
  }

  /// Sube el video a Firebase Storage (videos/<uuid>.mp4) y crea el documento en Firestore ("videos").
  Future<void> uploadVideoToFirebase({
    required String videoPath,
    required String caption,
    String? username,
    String? avatarUrl,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para publicar un video.');
    }

    String resolvedUsername = (username ?? '').trim();
    String resolvedAvatarUrl = (avatarUrl ?? '').trim();

    if (resolvedUsername.isEmpty || resolvedAvatarUrl.isEmpty) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final data = userDoc.data();
        if (resolvedUsername.isEmpty) {
          resolvedUsername = (data?['username'] ??
                  user.displayName ??
                  user.email?.split('@').first ??
                  'usuario')
              .toString();
        }
        if (resolvedAvatarUrl.isEmpty) {
          resolvedAvatarUrl =
              (data?['avatarUrl'] ?? user.photoURL ?? '').toString();
        }
      } catch (_) {
        if (resolvedUsername.isEmpty) {
          resolvedUsername =
              user.displayName ?? user.email?.split('@').first ?? 'usuario';
        }
      }
    }

    // Paso A: Garantizar extensión .mp4 y subir con SettableMetadata(contentType: 'video/mp4')
    File file = File(videoPath);
    if (!file.path.toLowerCase().endsWith('.mp4')) {
      final Directory tempDir = await getTemporaryDirectory();
      final String mp4Path =
          '${tempDir.path}/viroklipz_${DateTime.now().millisecondsSinceEpoch}.mp4';
      file = await file.copy(mp4Path);
    }

    final String uniqueId = const Uuid().v4();
    final Reference storageRef =
        FirebaseStorage.instance.ref('videos/$uniqueId.mp4');
    final metadata = SettableMetadata(contentType: 'video/mp4');
    final UploadTask uploadTask = storageRef.putFile(file, metadata);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    // Paso B: Extraer hashtags y guardar metadata del video en Cloud Firestore
    final String cleanCaption = caption.trim();
    final List<String> hashtags = RegExp(r'#([p{L}p{N}_]+)', unicode: true)
        .allMatches(cleanCaption)
        .map((m) => (m.group(1) ?? '').trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    await _firestore.collection('videos').add({
      'videoUrl': downloadUrl,
      'caption': cleanCaption,
      'hashtags': hashtags,
      'uid': user.uid,
      'authorId': user.uid,
      'username': resolvedUsername,
      'avatarUrl': resolvedAvatarUrl,
      'likedBy': <String>[],
      'likes': 0,
      'likesCount': 0,
      'comments': 0,
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Like (Fuego) conectado a Firestore: likedBy + likes/likesCount con FieldValue.increment(1 / -1)
  Future<void> toggleLike(String videoId) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null || videoId.isEmpty) return;

    final bool localLiked = likedPostIds.contains(videoId);
    if (localLiked) {
      likedPostIds.remove(videoId);
    } else {
      likedPostIds.add(videoId);
    }
    notifyListeners();

    final DocumentReference<Map<String, dynamic>> videoRef =
        _firestore.collection('videos').doc(videoId);

    String? receiverUid;
    bool didLike = false;

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> snap =
            await transaction.get(videoRef);
        if (!snap.exists) return;

        final data = snap.data();
        receiverUid = (data?['uid'] ?? data?['authorId'] ?? '').toString();
        final List<dynamic> likedBy =
            (data?['likedBy'] as List<dynamic>?) ?? <dynamic>[];
        final bool alreadyLiked = likedBy.contains(uid);

        if (alreadyLiked) {
          didLike = false;
          transaction.update(videoRef, {
            'likedBy': FieldValue.arrayRemove([uid]),
            'likes': FieldValue.increment(-1),
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          didLike = true;
          transaction.update(videoRef, {
            'likedBy': FieldValue.arrayUnion([uid]),
            'likes': FieldValue.increment(1),
            'likesCount': FieldValue.increment(1),
          });
        }
      });

      if (didLike) {
        likedPostIds.add(videoId);
      } else {
        likedPostIds.remove(videoId);
      }
      notifyListeners();

      // Al dar like, guardar documento en "notifications" para disparar Cloud Function FCM
      if (didLike && receiverUid != null && receiverUid!.isNotEmpty) {
        await _createNotification(
          receiverUid: receiverUid!,
          type: 'like',
          videoId: videoId,
        );
      }
    } catch (_) {
      // Revertir en caso de error
      if (localLiked) {
        likedPostIds.add(videoId);
      } else {
        likedPostIds.remove(videoId);
      }
      notifyListeners();
    }
  }

  /// Guarda un comentario en videos/{videoId}/comments, incrementa comments/commentsCount y notifica al autor
  Future<void> addComment({
    required String videoId,
    required String text,
    String? username,
  }) async {
    final String trimmed = text.trim();
    final User? user = _auth.currentUser;
    if (trimmed.isEmpty || user == null) return;

    String resolvedUsername = (username ?? '').trim();
    if (resolvedUsername.isEmpty) {
      resolvedUsername = (await _resolveSenderName(user)) ?? 'usuario';
    }

    final DocumentReference<Map<String, dynamic>> videoRef =
        _firestore.collection('videos').doc(videoId);
    final DocumentReference<Map<String, dynamic>> commentRef =
        videoRef.collection('comments').doc();

    final WriteBatch batch = _firestore.batch();
    batch.set(commentRef, {
      'uid': user.uid,
      'username': resolvedUsername,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      videoRef,
      {
        'comments': FieldValue.increment(1),
        'commentsCount': FieldValue.increment(1),
      },
      SetOptions(merge: true),
    );
    await batch.commit();

    try {
      final videoSnap = await videoRef.get();
      final String receiverUid =
          (videoSnap.data()?['uid'] ?? videoSnap.data()?['authorId'] ?? '')
              .toString();
      if (receiverUid.isNotEmpty) {
        await _createNotification(
          receiverUid: receiverUid,
          type: 'comment',
          videoId: videoId,
          senderNameOverride: resolvedUsername,
        );
      }
    } catch (_) {}
  }
}