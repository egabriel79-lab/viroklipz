import 'package:flutter/material.dart';

class LegalTexts {
  static const String termsAndConditions = '''
**TÉRMINOS Y CONDICIONES DE USO DE VIROKLIPZ**
Última actualización: Noviembre 2026

**1. Aceptación de los términos**
Al descargar, registrarte o utilizar la aplicación móvil Viroklipz, aceptas quedar vinculado por estos Términos y Condiciones de Uso y por nuestra Política de Privacidad. Si no estás de acuerdo con alguno de estos términos, por favor no utilices la plataforma.

**2. Elegibilidad y edad mínima**
Para crear una cuenta y publicar contenido en Viroklipz debes tener al menos 13 años de edad (o la edad mínima legal aplicable en tu país). Los usuarios menores de 18 años declaran contar con la autorización expresa de su padre, madre o tutor legal.

**3. Cuenta de usuario y seguridad**
Eres responsable de mantener la confidencialidad de tus credenciales de acceso y de toda actividad realizada desde tu cuenta. Debes notificarnos de inmediato si detectas un uso no autorizado de tu perfil.

**4. Contenido generado por los usuarios**
Conservas la titularidad de los videos, audios, descripciones y comentarios que publiques en Viroklipz. No obstante, al publicar contenido en la plataforma nos concedes una licencia mundial, no exclusiva y gratuita para alojarlo, reproducirlo y mostrarlo dentro de la aplicación.

Queda estrictamente prohibido publicar contenido que:
• Sea ilegal, difamatorio, violento, sexualmente explícito o promueva el odio.
• Infrinja derechos de autor, marcas comerciales o derechos de terceros.
• Suplante la identidad de otra persona o distribuya spam o software malicioso.

**5. Moderación y eliminación de cuenta**
Viroklipz se reserva el derecho de retirar contenido que infrinja las normas de la comunidad y de suspender o cancelar cuentas reincidentes. Puedes eliminar tu cuenta en cualquier momento desde el menú lateral en la opción "Eliminar cuenta".

**6. Funciones virtuales y modificaciones**
Los saldos, monedas o herramientas de estudio mostrados en la aplicación están sujetos a disponibilidad y pueden actualizarse o modificarse para mejorar el servicio.

**7. Contacto**
Si tienes dudas sobre estos Términos y Condiciones, puedes contactarnos a través del Centro de Ayuda dentro de la aplicación.
''';

  static const String privacyPolicy = '''
**POLÍTICA DE PRIVACIDAD DE VIROKLIPZ**
Última actualización: Noviembre 2026

**1. Información que recopilamos**
En Viroklipz respetamos tu privacidad y recopilamos únicamente los datos necesarios para brindarte el servicio:
• Datos de cuenta: correo electrónico, nombre de usuario, nombre visible, biografía y foto de perfil.
• Contenido publicado: videos, descripciones, hashtags, comentarios, "Me gusta" y relaciones de seguimiento.
• Datos técnicos: token de notificaciones push (FCM) para enviarte alertas de actividad cuando lo autorices.

**2. Uso de cámara, micrófono, galería y almacenamiento**
Viroklipz solicita acceso a la cámara, micrófono y galería del dispositivo únicamente cuando decides grabar un clip, seleccionar un video existente, escanear un código QR de perfil o guardar un video en tu galería. No grabamos ni accedemos a estos sensores en segundo plano sin tu acción directa.

**3. Finalidad del tratamiento de datos**
Utilizamos tu información para:
• Autenticar tu sesión de forma segura mediante Firebase Authentication.
• Almacenar y reproducir tus videos mediante Firebase Storage y Cloud Firestore.
• Mostrar tu perfil, seguidores y notificaciones en tiempo real.
• Prevenir abusos, spam y mantener la seguridad de la comunidad.

**4. Compartición de información**
No vendemos ni alquilamos tus datos personales a terceros. Tu nombre de usuario, avatar y videos públicos son visibles para otros usuarios de Viroklipz. Los proveedores de infraestructura (como Google Firebase) procesan los datos bajo estrictas medidas de seguridad y cifrado.

**5. Retención y eliminación de datos**
Conservamos tus datos mientras tu cuenta permanezca activa. Puedes actualizar tu perfil, revocar permisos del sistema operativo o eliminar permanentemente tu cuenta y datos asociados desde el menú lateral ("Eliminar cuenta").

**6. Privacidad de menores**
No recopilamos de manera consciente información personal de niños menores de la edad mínima legal sin el consentimiento de sus padres o tutores.

**7. Cambios en esta política**
Podemos actualizar esta Política de Privacidad periódicamente. Cualquier cambio relevante será notificado dentro de la aplicación.
''';
}

class LegalScreen extends StatefulWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<TextSpan> _buildFormattedSpans(String rawText) {
    final List<TextSpan> spans = <TextSpan>[];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final RegExpMatch match in boldRegex.allMatches(rawText)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: rawText.substring(lastIndex, match.start),
            style: const TextStyle(
              color: Color(0xFFD4D4D8),
              fontSize: 14.5,
              height: 1.65,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(1) ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            height: 1.65,
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < rawText.length) {
      spans.add(
        TextSpan(
          text: rawText.substring(lastIndex),
          style: const TextStyle(
            color: Color(0xFFD4D4D8),
            fontSize: 14.5,
            height: 1.65,
          ),
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Text.rich(
            TextSpan(children: _buildFormattedSpans(widget.content)),
          ),
        ),
      ),
    );
  }
}