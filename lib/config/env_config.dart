class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://TU_PROYECTO.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'TU_SUPABASE_ANON_KEY',
  );

  // Cloudflare R2 (endpoint S3 SIN https://)
  static const String r2Endpoint = String.fromEnvironment(
    'R2_ENDPOINT',
    defaultValue: 'TU_ACCOUNT_ID.r2.cloudflarestorage.com',
  );

  static const String r2AccessKey = String.fromEnvironment(
    'R2_ACCESS_KEY',
    defaultValue: 'TU_R2_ACCESS_KEY_ID',
  );

  static const String r2SecretKey = String.fromEnvironment(
    'R2_SECRET_KEY',
    defaultValue: 'TU_R2_SECRET_ACCESS_KEY',
  );

  static const String r2BucketName = String.fromEnvironment(
    'R2_BUCKET_NAME',
    defaultValue: 'viroklipz-videos',
  );

  // Dominio público del bucket (r2.dev o dominio personalizado)
  static const String r2PublicBaseUrl = String.fromEnvironment(
    'R2_PUBLIC_BASE_URL',
    defaultValue: 'https://pub-TU_HASH.r2.dev',
  );

  // Jamendo API (Música libre de derechos: https://devportal.jamendo.com)
  static const String jamendoClientId = String.fromEnvironment(
    'JAMENDO_CLIENT_ID',
    defaultValue: 'TU_JAMENDO_CLIENT_ID',
  );

  // Freesound API (Efectos de sonido: https://freesound.org/apiv2/apply)
  static const String freesoundApiKey = String.fromEnvironment(
    'FREESOUND_API_KEY',
    defaultValue: 'TU_FREESOUND_API_KEY',
  );
}