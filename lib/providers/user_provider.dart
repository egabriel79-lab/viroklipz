import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSubscription;

  String? _uid;
  String _avatarUrl = '';
  String _username = '';
  String _displayName = '';
  String _bio = '';
  bool _isUploadingAvatar = false;

  UserProvider() {
    _bindUser(_auth.currentUser);
    _authSubscription = _auth.authStateChanges().listen(_bindUser);
  }

  String? get uid => _uid;
  String get avatarUrl => _avatarUrl;
  String get username => _username;
  String get displayName => _displayName;
  String get bio => _bio;
  bool get isUploadingAvatar => _isUploadingAvatar;

  void _bindUser(User? user) {
    _userDocSubscription?.cancel();
    _userDocSubscription = null;

    if (user == null) {
      _uid = null;
      _avatarUrl = '';
      _username = '';
      _displayName = '';
      _bio = '';
      notifyListeners();
      return;
    }

    _uid = user.uid;
    _avatarUrl = user.photoURL ?? '';
    _username = user.displayName ?? '';
    notifyListeners();

    _userDocSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      if (data == null) return;
      _avatarUrl = (data['avatarUrl'] ?? user.photoURL ?? '').toString();
      _username = (data['username'] ?? user.displayName ?? '').toString();
      _displayName = (data['firstName'] ?? data['username'] ?? '').toString();
      _bio = (data['bio'] ?? '').toString();
      notifyListeners();
    });
  }

  /// Sube la imagen a avatars/{uid}.jpg, actualiza FirebaseAuth photoURL y Firestore users/{uid}.avatarUrl
  Future<String?> updateProfileAvatar(File imageFile) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para actualizar tu foto.');
    }

    _isUploadingAvatar = true;
    notifyListeners();

    try {
      final Reference storageRef = _storage.ref('avatars/${user.uid}.jpg');
      await storageRef.putFile(imageFile);
      final String downloadUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await _firestore.collection('users').doc(user.uid).set(
        {'avatarUrl': downloadUrl},
        SetOptions(merge: true),
      );

      _avatarUrl = downloadUrl;
      notifyListeners();
      return downloadUrl;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  /// Permite asignar una URL existente (ej. desde publicaciones) y propagarla en tiempo real
  Future<void> updateAvatarFromUrl(String url) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    _isUploadingAvatar = true;
    notifyListeners();

    try {
      await user.updatePhotoURL(url);
      await _firestore.collection('users').doc(user.uid).set(
        {'avatarUrl': url},
        SetOptions(merge: true),
      );
      _avatarUrl = url;
      notifyListeners();
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}