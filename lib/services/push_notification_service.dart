import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';
import '../screens/profile_screen.dart';
import '../screens/video_detail_screen.dart';

/// Handler top-level obligatorio para mensajes recibidos con la app cerrada o en segundo plano.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  /// Llave global conectada a MaterialApp.navigatorKey para navegar desde notificaciones
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
    'viroklipz_high_importance',
    'Notificaciones Viroklipz',
    description: 'Alertas de likes, comentarios y nuevos seguidores.',
    importance: Importance.max,
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null || response.payload!.isEmpty) return;
        try {
          final Map<String, dynamic> data =
              jsonDecode(response.payload!) as Map<String, dynamic>;
          _navigateFromData(data);
        } catch (_) {}
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_highImportanceChannel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 1. Notificación recibida con la app abierta (Foreground) -> flutter_local_notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final RemoteNotification? notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Viroklipz',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _highImportanceChannel.id,
            _highImportanceChannel.name,
            channelDescription: _highImportanceChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });

    // 2. Clic en la notificación cuando la app estaba en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateFromData(message.data);
    });

    // 3. Clic en la notificación que abrió la app desde estado completamente cerrado (Terminated)
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateFromData(initialMessage.data);
      });
    }
  }

  /// Solicita permiso al usuario al iniciar sesión y guarda el fcmToken en users/{uid}/fcmToken
  Future<void> requestPermissionAndSaveToken(String uid) async {
    if (uid.trim().isEmpty) return;

    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final bool granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!granted) return;

    try {
      final String? token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'fcmToken': token,
            'fcmUpdatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      // Mantener sincronizado el token si FCM lo rota automáticamente
      _messaging.onTokenRefresh.listen((String newToken) async {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'fcmToken': newToken,
            'fcmUpdatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } catch (_) {
      // Silencioso en simuladores sin APNs/Google Play Services
    }
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final String type = (data['type'] ?? '').toString();
    final String videoId = (data['videoId'] ?? '').toString();
    final String senderUid = (data['senderUid'] ?? '').toString();
    final String senderName = (data['senderName'] ?? '').toString();

    if ((type == 'like' || type == 'comment') && videoId.isNotEmpty) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => VideoDetailScreen(videoId: videoId),
        ),
      );
      return;
    }

    if (type == 'follow' && (senderName.isNotEmpty || senderUid.isNotEmpty)) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            embeddedInMainShell: false,
            username: senderName.isNotEmpty ? senderName : null,
            userId: senderUid.isNotEmpty ? senderUid : null,
          ),
        ),
      );
    }
  }
}