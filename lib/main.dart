import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_config.dart';
import 'core/config/theme/app_theme.dart';
import 'core/config/routes/app_router.dart';
import 'core/di/providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar configuración de entorno
  await AppConfig.initialize();

  // Inicializar Firebase (tolerante a fallos para modo mock)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('⚠️ Firebase no inicializado (modo mock): $e');
  }

  // Inicializar dependencias (WorkManager, etc.)
  try {
    await initializeDependencies();
  } catch (e) {
    debugPrint('⚠️ Dependencias no inicializadas (modo mock): $e');
  }

  runApp(
    const ProviderScope(
      child: MaCElectricosApp(),
    ),
  );
}

class MaCElectricosApp extends ConsumerWidget {
  const MaCElectricosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MaCElectricos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}