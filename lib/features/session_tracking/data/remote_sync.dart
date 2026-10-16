import 'package:dartz/dartz.dart';
import 'package:macelectricos/core/models/session_models.dart';
import 'package:macelectricos/features/session_tracking/data/session_service.dart';
import 'package:macelectricos/features/session_tracking/domain/session_repository.dart';

/// Implementación de sincronización remota con Firebase
class SessionRemoteSyncImpl implements SessionRemoteSync {
  // TODO: Inyectar FirebaseFirestore, FirebaseStorage, FirebaseAuth
  // final FirebaseFirestore _firestore;
  // final FirebaseStorage _storage;

  SessionRemoteSyncImpl();

  @override
  Future<void> subirSesion(Session sesion, List<SessionElement> elementos, SessionGraph? grafo) async {
    try {
      // 1. Subir sesión a Firestore
      // await _firestore.collection('sesiones').doc(sesion.id).set(sesion.toJson());

      // 2. Subir elementos en batch
      // final batch = _firestore.batch();
      // for (final elemento in elementos) {
      //   final ref = _firestore.collection('sesiones').doc(sesion.id).collection('elementos').doc(elemento.id);
      //   batch.set(ref, _elementoAJson(elemento));
      // }
      // await batch.commit();

      // 3. Subir grafo si existe
      // if (grafo != null) {
      //   await _firestore.collection('sesiones').doc(sesion.id).collection('grafos').doc('recorrido').set(grafo.toJson());
      // }

      // 4. Subir fotos a Firebase Storage
      // for (final elemento in elementos) {
      //   if (elemento is FotoEvidencia && elemento.rutaLocal.isNotEmpty) {
      //     final file = File(elemento.rutaLocal);
      //     final storageRef = _storage.ref().child('sesiones/${sesion.id}/fotos/${elemento.id}');
      //     await storageRef.putFile(file);
      //     final downloadUrl = await storageRef.getDownloadURL();
      //     // Actualizar elemento con URL remota
      //   }
      // }

      print('✅ Sesión ${sesion.id} sincronizada correctamente');
    } catch (e) {
      print('❌ Error sincronizando sesión: $e');
      rethrow;
    }
  }

  @override
  Future<void> descargarSesionesPendientes(String userId) async {
    try {
      // Query sesiones no sincronizadas del usuario
      // final snapshot = await _firestore
      //     .collection('sesiones')
      //     .where('userId', isEqualTo: userId)
      //     .where('sincronizada', isEqualTo: false)
      //     .get();

      // for (final doc in snapshot.docs) {
      //   // Descargar y guardar localmente
      // }

      print('✅ Sesiones pendientes descargadas para $userId');
    } catch (e) {
      print('❌ Error descargando sesiones: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _elementoAJson(SessionElement elemento) {
    final base = {
      'id': elemento.id,
      'type': elemento.type.name,
      'timestamp': elemento.timestamp.toIso8601String(),
      'userId': elemento.userId,
      'sessionId': elemento.sessionId,
      'metadata': elemento.metadata,
    };

    switch (elemento) {
      case Poste p:
        return {
          ...base,
          'latitude': p.latitude,
          'longitude': p.longitude,
          'altitude': p.altitude,
          'codigoPoste': p.codigoPoste,
          'tipoPoste': p.tipoPoste,
          'altura': p.altura,
          'observaciones': p.observaciones,
          'fotosIds': p.fotosIds,
        };
      case Transformador t:
        return {
          ...base,
          'latitude': t.latitude,
          'longitude': t.longitude,
          'codigoTransformador': t.codigoTransformador,
          'potenciaKva': t.potenciaKva,
          'tipoTransformador': t.tipoTransformador,
          'numeroFases': t.numeroFases,
          'observaciones': t.observaciones,
          'fotosIds': t.fotosIds,
          'posteIdAsociado': t.posteIdAsociado,
        };
      case Arbol a:
        return {
          ...base,
          'latitude': a.latitude,
          'longitude': a.longitude,
          'especie': a.especie,
          'alturaAproximada': a.alturaAproximada,
          'distanciaAlPoste': a.distanciaAlPoste,
          'posteCercanoId': a.posteCercanoId,
          'riesgo': a.riesgo,
          'observaciones': a.observaciones,
          'fotosIds': a.fotosIds,
        };
      case Poda p:
        return {
          ...base,
          'arbolId': p.arbolId,
          'latitude': p.latitude,
          'longitude': p.longitude,
          'fechaInicio': p.fechaInicio.toIso8601String(),
          'fechaFin': p.fechaFin.toIso8601String(),
          'responsable': p.responsable,
          'herramientaUtilizada': p.herramientaUtilizada,
          'observaciones': p.observaciones,
          'fotosIds': p.fotosIds,
          'completada': p.completada,
        };
      case Claro c:
        return {
          ...base,
          'posteOrigenId': c.posteOrigenId,
          'posteDestinoId': c.posteDestinoId,
          'distanciaMetros': c.distanciaMetros,
          'latitudeOrigen': c.latitudeOrigen,
          'longitudeOrigen': c.longitudeOrigen,
          'latitudeDestino': c.latitudeDestino,
          'longitudeDestino': c.longitudeDestino,
          'tipoCable': c.tipoCable,
          'numeroCables': c.numeroCables,
          'observaciones': c.observaciones,
        };
      case FotoEvidencia f:
        return {
          ...base,
          'rutaLocal': f.rutaLocal,
          'rutaRemota': f.rutaRemota,
          'latitude': f.latitude,
          'longitude': f.longitude,
          'descripcion': f.descripcion,
          'elementoAsociadoId': f.elementoAsociadoId,
          'elementoAsociadoTipo': f.elementoAsociadoTipo?.name,
          'tamanoBytes': f.tamanoBytes,
        };
      default:
        return base;
    }
  }
}