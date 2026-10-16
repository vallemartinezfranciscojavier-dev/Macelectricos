import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:macelectricos/core/models/session_models.dart';
import 'package:macelectricos/features/session_tracking/data/session_service.dart';
import 'package:macelectricos/features/session_tracking/domain/session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementación de almacenamiento local usando SharedPreferences + JSON
/// En producción usar Isar/Hive/SQLite para mejor rendimiento
class SessionLocalStorageImpl implements SessionLocalStorage {
  static const _prefSesionActiva = 'sesion_activa_';
  static const _prefSesiones = 'sesiones_';
  static const _prefElementos = 'elementos_';
  static const _prefGrafos = 'grafos_';

  SharedPreferences? _prefs;

  SessionLocalStorageImpl([SharedPreferences? prefs]) : _prefs = prefs;

  Future<void> init() async {
    await getPrefs();
  }

  Future<SharedPreferences> getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> guardarSesion(Session sesion) async {
    final prefs = await getPrefs();
    final key = '$_prefSesiones${sesion.id}';
    await prefs.setString(key, jsonEncode(sesion.toJson()));

    // Si está activa, guardar referencia
    if (sesion.estado == SessionEstado.activa) {
      await prefs.setString('$_prefSesionActiva${sesion.userId}', sesion.id);
    }
  }

  @override
  Future<Session?> obtenerSesion(String sessionId) async {
    final prefs = await getPrefs();
    final key = '$_prefSesiones$sessionId';
    final data = prefs.getString(key);
    if (data == null) return null;
    return Session.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<Session?> obtenerSesionActiva(String userId) async {
    final prefs = await getPrefs();
    final sessionId = prefs.getString('$_prefSesionActiva$userId');
    if (sessionId == null) return null;
    return obtenerSesion(sessionId);
  }

  @override
  Future<void> guardarElemento(SessionElement elemento) async {
    final prefs = await getPrefs();
    final key = '$_prefElementos${elemento.sessionId}';
    final existing = prefs.getStringList(key) ?? [];
    existing.add(jsonEncode(_elementoAJson(elemento)));
    await prefs.setStringList(key, existing);
  }

  @override
  Future<List<SessionElement>> obtenerElementosSesion(String sessionId) async {
    final prefs = await getPrefs();
    final key = '$_prefElementos$sessionId';
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => _jsonAElemento(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> guardarGrafo(SessionGraph grafo) async {
    final prefs = await getPrefs();
    final key = '$_prefGrafos${grafo.sessionId}';
    await prefs.setString(key, jsonEncode(grafo.toJson()));
  }

  @override
  Future<SessionGraph?> obtenerGrafo(String sessionId) async {
    final prefs = await getPrefs();
    final key = '$_prefGrafos$sessionId';
    final data = prefs.getString(key);
    if (data == null) return null;
    return SessionGraph.fromJson(jsonDecode(data) as Map<String, dynamic>);
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

  SessionElement _jsonAElemento(Map<String, dynamic> json) {
    final type = SessionElementType.values.byName(json['type'] as String);

    switch (type) {
      case SessionElementType.poste:
        return Poste.fromJson(json);
      case SessionElementType.transformador:
        return Transformador.fromJson(json);
      case SessionElementType.arbol:
        return Arbol.fromJson(json);
      case SessionElementType.poda:
        return Poda.fromJson(json);
      case SessionElementType.claro:
        return Claro.fromJson(json);
      case SessionElementType.foto:
        return FotoEvidencia.fromJson(json);
    }
  }
}