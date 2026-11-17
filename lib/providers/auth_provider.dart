import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/push_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  static const int maxSavedAccounts = 10;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final StreamSubscription<User?> _authSubscription;

  User? _firebaseUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  final List<UserAccount> _savedAccounts = [
    const UserAccount(
      id: 'acc_gabriel',
      username: 'gabriel_12343',
      email: 'gabriel_12343@viroklipz.app',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop',
      unreadCount: 0,
    ),
    const UserAccount(
      id: 'acc_eloy',
      username: 'eloy_p79',
      email: 'eloy_p79@viroklipz.app',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop',
      unreadCount: 1,
    ),
  ];

  UserAccount? _currentUser;

  AuthProvider() {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      _loadUserProfile(_firebaseUser!.uid);
      PushNotificationService.instance
          .requestPermissionAndSaveToken(_firebaseUser!.uid);
    } else if (_savedAccounts.isNotEmpty) {
      _currentUser = _savedAccounts.first;
    }

    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserProfile(user.uid);
        await PushNotificationService.instance
            .requestPermissionAndSaveToken(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  User? get firebaseUser => _firebaseUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  List<UserAccount> get savedAccounts => List.unmodifiable(_savedAccounts);
  UserAccount? get currentUser => _currentUser;

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userProfile = doc.data();
        final data = doc.data()!;
        final account = UserAccount(
          id: uid,
          username: (data['username'] ?? 'usuario').toString(),
          email: (data['email'] ?? _firebaseUser?.email ?? '').toString(),
          avatarUrl: (data['avatarUrl'] ??
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop')
              .toString(),
          unreadCount: 0,
        );
        addAccount(account);
      }
    } catch (_) {
      // Silencioso si no hay conexión temporal al cargar perfil
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado. Verifica tu correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Intenta nuevamente.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-email':
        return 'El correo electrónico no tiene un formato válido.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado en Viroklipz.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera unos minutos.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      default:
        return e.message ?? 'Error de autenticación (${e.code}).';
    }
  }

  /// Inicia sesión con correo y contraseña. Devuelve null si fue exitoso, o mensaje de error en español.
  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        await _loadUserProfile(credential.user!.uid);
        // Solicitar permiso Push y guardar fcmToken en users/{uid}/fcmToken
        await PushNotificationService.instance
            .requestPermissionAndSaveToken(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } on SocketException {
      return 'Sin conexión a internet. Verifica tu red.';
    } catch (_) {
      return 'Ocurrió un error inesperado al iniciar sesión.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea el usuario en Firebase Auth y guarda su documento en Firestore (colección "users").
  /// Si [isMinor] es true (edad < 18), exige y almacena el sub-mapa [tutor] junto con [isMinor: true].
  Future<String?> signUp(
    String email,
    String password,
    String username, {
    String? firstName,
    String? lastName,
    String? country,
    int? age,
    bool isMinor = false,
    Map<String, dynamic>? tutor,
  }) async {
    if (isMinor) {
      final tutorNombre = (tutor?['nombre'] ?? '').toString().trim();
      final tutorApellido = (tutor?['apellido'] ?? '').toString().trim();
      final tutorEmail = (tutor?['email'] ?? '').toString().trim();
      if (tutorNombre.isEmpty || tutorApellido.isEmpty || tutorEmail.isEmpty) {
        return 'Debes completar toda la información del representante legal.';
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final cleanUsername = username.trim().replaceFirst('@', '').toLowerCase();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        return 'No se pudo crear la cuenta de usuario.';
      }

      await user.updateDisplayName(cleanUsername);

      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': cleanEmail,
        'username': cleanUsername,
        if (firstName != null && firstName.trim().isNotEmpty)
          'firstName': firstName.trim(),
        if (lastName != null && lastName.trim().isNotEmpty)
          'lastName': lastName.trim(),
        if (country != null && country.trim().isNotEmpty)
          'country': country.trim(),
        if (age != null) 'age': age,
        'isMinor': isMinor,
        if (isMinor && tutor != null) 'tutor': tutor,
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      _userProfile = userData;

      // Solicitar permisos FCM y almacenar fcmToken en users/{uid}
      await PushNotificationService.instance
          .requestPermissionAndSaveToken(user.uid);

      addAccount(
        UserAccount(
          id: user.uid,
          username: cleanUsername,
          email: cleanEmail,
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop',
          unreadCount: 0,
        ),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } on FirebaseException catch (e) {
      return 'Error al guardar tu perfil en Firestore: ${e.message ?? e.code}';
    } on SocketException {
      return 'Sin conexión a internet. Verifica tu red.';
    } catch (_) {
      return 'Ocurrió un error inesperado al crear la cuenta.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void switchAccount(UserAccount account) {
    final index = _savedAccounts.indexWhere((item) => item.id == account.id);
    if (index != -1) {
      _savedAccounts[index] = _savedAccounts[index].copyWith(unreadCount: 0);
      _currentUser = _savedAccounts[index];
    } else {
      _currentUser = account.copyWith(unreadCount: 0);
    }
    notifyListeners();
  }

  String? addAccount(UserAccount account) {
    final existingIndex = _savedAccounts.indexWhere(
      (item) =>
          item.id == account.id ||
          item.username.toLowerCase() == account.username.toLowerCase(),
    );
    if (existingIndex != -1) {
      switchAccount(_savedAccounts[existingIndex]);
      return null;
    }

    if (_savedAccounts.length >= maxSavedAccounts) {
      return 'Error: límite máximo de $maxSavedAccounts cuentas alcanzado';
    }

    final normalized = account.copyWith(unreadCount: 0);
    _savedAccounts.add(normalized);
    _currentUser = normalized;
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userProfile = null;
    try {
      await _auth.signOut();
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> deleteAccount(UserAccount account) async {
    final bool isCurrent = _currentUser?.id == account.id;
    _savedAccounts.removeWhere((item) => item.id == account.id);
    if (isCurrent) {
      try {
        final String? uid = _auth.currentUser?.uid;
        if (uid != null) {
          await _firestore.collection('users').doc(uid).delete();
        }
        await _auth.currentUser?.delete();
      } catch (_) {}
      await signOut();
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Elimina permanentemente el documento en Firestore (users/{uid}) y la cuenta en FirebaseAuth.
  /// Devuelve null si tuvo éxito, o un mensaje de error en español (incluyendo requires-recent-login).
  Future<String?> deleteCurrentUserAccount() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return 'No hay una sesión activa para eliminar.';
    }

    try {
      // Paso A: Eliminar documento del usuario en Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Paso B: Eliminar cuenta en Firebase Authentication
      await user.delete();

      _savedAccounts.removeWhere((item) => item.id == user.uid);
      _currentUser = null;
      _userProfile = null;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Por seguridad, debes cerrar sesión y volver a iniciarla antes de eliminar tu cuenta';
      }
      return _mapAuthError(e);
    } on FirebaseException catch (e) {
      return 'Error al eliminar los datos en Firestore: ${e.message ?? e.code}';
    } catch (_) {
      return 'Ocurrió un error inesperado al eliminar tu cuenta.';
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

