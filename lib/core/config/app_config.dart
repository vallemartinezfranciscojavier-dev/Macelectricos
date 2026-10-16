/// Configuración de entorno de la aplicación
enum Environment {
  development,
  staging,
  production,
}

/// Configuración global de la app
class AppConfig {
  static Environment _environment = Environment.development;
  static bool _initialized = false;

  // Configuración por entorno
  static const Map<Environment, Map<String, String>> _configs = {
    Environment.development: {
      'apiBaseUrl': 'https://us-central1-macelectricos-dev.cloudfunctions.net',
      'firestoreDb': 'macelectricos-dev',
      'storageBucket': 'macelectricos-dev.appspot.com',
      'mapsApiKey': 'DEV_MAPS_API_KEY',
      'enableLogging': 'true',
      'enableCrashlytics': 'false',
    },
    Environment.staging: {
      'apiBaseUrl': 'https://us-central1-macelectricos-staging.cloudfunctions.net',
      'firestoreDb': 'macelectricos-staging',
      'storageBucket': 'macelectricos-staging.appspot.com',
      'mapsApiKey': 'STAGING_MAPS_API_KEY',
      'enableLogging': 'true',
      'enableCrashlytics': 'true',
    },
    Environment.production: {
      'apiBaseUrl': 'https://us-central1-macelectricos-prod.cloudfunctions.net',
      'firestoreDb': 'macelectricos-prod',
      'storageBucket': 'macelectricos-prod.appspot.com',
      'mapsApiKey': 'PROD_MAPS_API_KEY',
      'enableLogging': 'false',
      'enableCrashlytics': 'true',
    },
  };

  /// Inicializar configuración (llamar al inicio de main)
  static Future<void> initialize({
    Environment environment = Environment.development,
  }) async {
    if (_initialized) return;

    _environment = environment;
    _initialized = true;

    // Configurar logging según entorno
    if (getBool('enableLogging')) {
      // Logger se configurará en providers.dart
    }
  }

  /// Obtener entorno actual
  static Environment get environment => _environment;

  /// Verificar si está inicializado
  static bool get isInitialized => _initialized;

  /// Obtener valor de configuración como String
  static String get(String key) {
    _checkInitialized();
    return _configs[_environment]?[key] ?? '';
  }

  /// Obtener valor de configuración como bool
  static bool getBool(String key) {
    _checkInitialized();
    return _configs[_environment]?[key]?.toLowerCase() == 'true';
  }

  /// Obtener valor de configuración como int
  static int getInt(String key) {
    _checkInitialized();
    return int.tryParse(_configs[_environment]?[key] ?? '') ?? 0;
  }

  /// Obtener valor de configuración como double
  static double getDouble(String key) {
    _checkInitialized();
    return double.tryParse(_configs[_environment]?[key] ?? '') ?? 0.0;
  }

  // Getters de conveniencia
  static String get apiBaseUrl => get('apiBaseUrl');
  static String get firestoreDb => get('firestoreDb');
  static String get storageBucket => get('storageBucket');
  static String get mapsApiKey => get('mapsApiKey');
  static bool get enableLogging => getBool('enableLogging');
  static bool get enableCrashlytics => getBool('enableCrashlytics');

  static void _checkInitialized() {
    if (!_initialized) {
      throw StateError('AppConfig no inicializado. Llama a AppConfig.initialize() primero.');
    }
  }

  /// Verificar si es entorno de desarrollo
  static bool get isDevelopment => _environment == Environment.development;

  /// Verificar si es entorno de producción
  static bool get isProduction => _environment == Environment.production;
}