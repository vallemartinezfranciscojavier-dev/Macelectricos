import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:macelectricos/features/sincronizacion/data/sync_queue.dart';
import 'package:macelectricos/core/ui/element_icons.dart';

/// Interfaz del servicio de sincronización
abstract class SyncService {
  /// Procesar cola completa
  Future<int> procesarCola();

  /// Agregar elemento a la cola
  Future<void> agregarElemento({
    required ElementType tipo,
    required Map<String, dynamic> datos,
    required String descripcion,
    SyncPrioridad prioridad,
  });

  /// Obtener estadísticas
  Future<Map<String, int>> obtenerEstadisticas();

  /// Verificar conexión
  Future<bool> tieneConexion();
}

/// Implementación real con Firebase
class SyncServiceImpl implements SyncService {
  final Future<SyncQueue> syncQueue;
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  SyncServiceImpl({
    required this.syncQueue,
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<void> agregarElemento({
    required ElementType tipo,
    required Map<String, dynamic> datos,
    required String descripcion,
    SyncPrioridad prioridad = SyncPrioridad.normal,
  }) async {
    final queue = await syncQueue;
    await queue.agregar(
      tipo: tipo,
      operacion: SyncOperacion.create,
      descripcion: descripcion,
      datos: datos,
      prioridad: prioridad,
    );
  }

  @override
  Future<int> procesarCola() async {
    final queue = await syncQueue;
    final pendientes = queue.getPendientesPorPrioridad();
    int procesados = 0;

    for (final item in pendientes) {
      try {
        await queue.marcarSincronizando(item.id);

        switch (item.tipo) {
          case ElementType.poste:
            await _syncPoste(item);
            break;
          case ElementType.transformador:
            await _syncTransformador(item);
            break;
          case ElementType.arbol:
            await _syncArbol(item);
            break;
          case ElementType.poda:
            await _syncPoda(item);
            break;
          case ElementType.claro:
            await _syncClaro(item);
            break;
          case ElementType.foto:
            await _syncFoto(item);
            break;
        }

        await queue.marcarSincronizado(item.id);
        procesados++;
      } catch (e) {
        await queue.marcarError(item.id, e.toString());
      }
    }

    if (procesados > 0) {
      await queue.actualizarLastSyncTime();
    }

    return procesados;
  }

  /// Sincronizar poste
  Future<void> _syncPoste(SyncQueueItem item) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final datos = {
      ...item.datos,
      'userId': user.uid,
      'syncedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('postes')
        .doc(item.id)
        .set(datos, SetOptions(merge: true));
  }

  /// Sincronizar transformador
  Future<void> _syncTransformador(SyncQueueItem item) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final datos = {
      ...item.datos,
      'userId': user.uid,
      'syncedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('transformadores')
        .doc(item.id)
        .set(datos, SetOptions(merge: true));
  }

  /// Sincronizar árbol
  Future<void> _syncArbol(SyncQueueItem item) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final datos = {
      ...item.datos,
      'userId': user.uid,
      'syncedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('arboles')
        .doc(item.id)
        .set(datos, SetOptions(merge: true));
  }

  /// Sincronizar poda
  Future<void> _syncPoda(SyncQueueItem item) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final datos = {
      ...item.datos,
      'userId': user.uid,
      'syncedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('podas')
        .doc(item.id)
        .set(datos, SetOptions(merge: true));
  }

  /// Sincronizar claro
  Future<void> _syncClaro(SyncQueueItem item) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final datos = {
      ...item.datos,
      'userId': user.uid,
      'syncedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('claros')
        .doc(item.id)
        .set(datos, SetOptions(merge: true));
  }

  /// Sincronizar foto
  Future<void> _syncFoto(SyncQueueItem item) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final datos = {
      ...item.datos,
      'userId': user.uid,
      'syncedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('fotos')
        .doc(item.id)
        .set(datos, SetOptions(merge: true));
  }

  @override
  Future<Map<String, int>> obtenerEstadisticas() async {
    final queue = await syncQueue;
    return queue.estadisticas;
  }

  @override
  Future<bool> tieneConexion() async {
    // Esto sería implementado con Connectivity package
    // Por ahora retornamos true para testing
    return true;
  }
}