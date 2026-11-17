import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/video_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/main_screen.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  // 1. Obligatorio antes de inicializar plugins nativos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar Firebase antes de arrancar la aplicación
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Registrar handler para notificaciones Push cuando la app está cerrada/background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 4. Inicializar FCM + flutter_local_notifications (foreground + clics)
  await PushNotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => VideoProvider()),
      ],
      child: const ViroklipzApp(),
    ),
  );
}

class ViroklipzApp extends StatelessWidget {
  const ViroklipzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viroklipz',
      navigatorKey: PushNotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5722),
          secondary: Color(0xFFE91E63),
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      routes: {
        '/landing': (context) => const LandingScreen(),
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5722)),
            ),
          );
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const LandingScreen();
      },
    );
  }
}