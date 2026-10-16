import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workmanager/workmanager.dart';
import 'package:logger/logger.dart';

import '../../features/sincronizacion/data/sync_queue.dart';
import '../../features/sincronizacion/domain/sync_service.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/mapa/data/repositories/mock_map_element_repository.dart';
import '../../features/mapa/data/repositories/map_element_repository_impl.dart';
import '../../features/mapa/data/services/location_service.dart';
import '../../features/mapa/domain/repositories/map_element_repository.dart';
import '../../features/mapa/presentation/providers/location_provider.dart';
import '../../features/mapa/presentation/providers/map_elements_provider.dart';

// ============================================
// CORE SERVICES PROVIDERS
// ============================================

/// Logger global
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
});

/// SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Connectivity
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// WorkManager
final workmanagerProvider = Provider<Workmanager>((ref) {
  return Workmanager();
});

/// Firebase Auth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Storage
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Firebase Messaging
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

/// Isar Database
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      // Schemas se registrarán aquí cuando estén listos
      // UserSchema, CrewSchema, SessionSchema, etc.
    ],
    directory: dir.path,
    name: 'macelectricos',
    inspector: true, // Para debugging en desarrollo
  );
  return isar;
});

// ============================================
// AUTH FEATURE PROVIDERS
// ============================================

/// Auth Local DataSource
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
    data: (prefs) => prefs,
    orElse: () => throw StateError('SharedPreferences no inicializado'),
  );
  return AuthLocalDataSourceImpl(prefs);
});

/// Auth Repository (Real con Firebase)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

/// Auth Use Cases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository: repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository: repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository: repository);
});

/// Auth State Notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final signInUseCase = ref.watch(signInUseCaseProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  return AuthNotifier(
    signInUseCase: signInUseCase,
    signOutUseCase: signOutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
});

// ============================================
// MAPA FEATURE PROVIDERS (Fase 5)
// ============================================

/// Servicio de ubicación GPS del dispositivo.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Estado de la ubicación actual + permisos GPS.
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.watch(locationServiceProvider));
});

/// Repositorio de elementos del mapa (Real con Firestore).
final mapElementRepositoryProvider = Provider<MapElementRepository>((ref) {
  return MapElementRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Estado de los elementos del mapa + capas visibles.
final mapElementsProvider =
    StateNotifierProvider<MapElementsNotifier, MapElementsState>((ref) {
  return MapElementsNotifier(ref.watch(mapElementRepositoryProvider));
});

// ============================================
// INITIALIZATION
// ============================================

/// Inicializar todas las dependencias
Future<void> initializeDependencies() async {
  // WorkManager initialization
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // Registrar tareas periódicas
  await Workmanager().registerPeriodicTask(
    'periodic-sync',
    'periodicSyncTask',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
  );
}

/// Cola de sincronización
final syncQueueProvider = FutureProvider<SyncQueue>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final queue = SyncQueue(prefs: prefs);
  await queue.init();
  return queue;
});

/// Estado de conectividad (real con Connectivity)
final networkStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged;
});

/// Sync Service que procesa la cola
final syncServiceProvider = Provider<SyncService>((ref) {
  final syncQueue = ref.watch(syncQueueProvider.future);
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  return SyncServiceImpl(
    syncQueue: syncQueue,
    firestore: firestore,
    firebaseAuth: firebaseAuth,
  );
});

/// WorkManager callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = SyncQueue(prefs: prefs);
    await queue.init();

    switch (task) {
      case 'periodicSyncTask':
        // Procesar cola
        final pendientes = queue.getPendientesPorPrioridad();
        for (final item in pendientes) {
          await Future.delayed(const Duration(seconds: 1));
        }
        break;
      case 'retryFailedSync':
        await queue.limpiarErrores();
        break;
    }
    return Future.value(true);
  });
}