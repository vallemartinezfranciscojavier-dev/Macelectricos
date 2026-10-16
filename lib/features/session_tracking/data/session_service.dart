import 'dart:math' as math;
import 'package:dartz/dartz.dart';
import 'package:macelectricos/core/models/session_models.dart';
import 'package:macelectricos/features/session_tracking/domain/session_repository.dart';

/// Implementación del servicio de sesiones con tracking automático y generación de grafo
class SessionService implements SessionRepository {
  final SessionLocalStorage _localStorage;
  final SessionRemoteSync _remoteSync;
  final GraphGenerator _graphGenerator;

  SessionService({
    required SessionLocalStorage localStorage,
    required SessionRemoteSync remoteSync,
    required GraphGenerator graphGenerator,
  })  : _localStorage = localStorage,
        _remoteSync = remoteSync,
        _graphGenerator = graphGenerator;

  @override
  Future<Either<SessionFailure, Session>> iniciarSesion({
    required String userId,
    required String cuadrillaId,
  }) async {
    try {
      // Verificar si ya hay una sesión activa
      final sesionActiva = await _localStorage.obtenerSesionActiva(userId);
      if (sesionActiva != null && sesionActiva.estado == SessionEstado.activa) {
        return Left(SessionFailure(
          'Ya existe una sesión activa para este usuario',
          tipo: SessionFailureType.sesionYaActiva,
        ));
      }

      final nuevaSesion = Session(
        id: _generarIdSesion(),
        userId: userId,
        cuadrillaId: cuadrillaId,
        fechaInicio: DateTime.now(),
        estado: SessionEstado.activa,
        contadores: const SessionContadores(),
        tecnicosIds: [userId],
      );

      await _localStorage.guardarSesion(nuevaSesion);
      return Right(nuevaSesion);
    } catch (e) {
      return Left(SessionFailure(
        'Error al iniciar sesión: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, SessionSummary>> finalizarSesion({
    required String sessionId,
  }) async {
    try {
      final sesion = await _localStorage.obtenerSesion(sessionId);
      if (sesion == null) {
        return Left(SessionFailure(
          'Sesión no encontrada',
          tipo: SessionFailureType.sesionNoEncontrada,
        ));
      }

      if (sesion.estado != SessionEstado.activa) {
        return Left(SessionFailure(
          'La sesión no está activa',
          tipo: SessionFailureType.sesionNoFinalizada,
        ));
      }

      // Generar grafo de recorrido antes de finalizar
      final grafo = await _graphGenerator.generarGrafo(sessionId);
      await _localStorage.guardarGrafo(grafo);

      // Actualizar sesión a finalizada
      final sesionFinalizada = sesion.copyWith(
        fechaFin: DateTime.now(),
        estado: SessionEstado.finalizada,
      );
      await _localStorage.guardarSesion(sesionFinalizada);

      // Generar resumen final
      final elementos = await _localStorage.obtenerElementosSesion(sessionId);
      final resumen = _construirResumen(sesionFinalizada, elementos);

      return Right(resumen);
    } catch (e) {
      return Left(SessionFailure(
        'Error al finalizar sesión: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, Session?>> obtenerSesionActiva(String userId) async {
    try {
      final sesion = await _localStorage.obtenerSesionActiva(userId);
      return Right(sesion);
    } catch (e) {
      return Left(SessionFailure(
        'Error al obtener sesión activa: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, SessionSummary>> obtenerResumenSesion(String sessionId) async {
    try {
      final sesion = await _localStorage.obtenerSesion(sessionId);
      if (sesion == null) {
        return Left(SessionFailure(
          'Sesión no encontrada',
          tipo: SessionFailureType.sesionNoEncontrada,
        ));
      }

      final elementos = await _localStorage.obtenerElementosSesion(sessionId);
      final resumen = _construirResumen(sesion, elementos);
      return Right(resumen);
    } catch (e) {
      return Left(SessionFailure(
        'Error al obtener resumen: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, void>> guardarElemento(SessionElement elemento) async {
    try {
      // Guardar elemento
      await _localStorage.guardarElemento(elemento);

      // Actualizar contadores de la sesión
      final sesion = await _localStorage.obtenerSesion(elemento.sessionId);
      if (sesion != null && sesion.estado == SessionEstado.activa) {
        double distanciaClaro = 0.0;
        if (elemento is Claro) {
          distanciaClaro = elemento.distanciaMetros;
        }
        final nuevosContadores = sesion.contadores.incrementar(elemento.type, distanciaClaro: distanciaClaro);
        final sesionActualizada = sesion.copyWith(contadores: nuevosContadores);
        await _localStorage.guardarSesion(sesionActualizada);
      }

      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(
        'Error al guardar elemento: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, List<SessionElement>>> obtenerElementosSesion(String sessionId) async {
    try {
      final elementos = await _localStorage.obtenerElementosSesion(sessionId);
      return Right(elementos);
    } catch (e) {
      return Left(SessionFailure(
        'Error al obtener elementos: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, List<SessionElement>>> obtenerElementosPorTipo(
    String sessionId,
    SessionElementType tipo,
  ) async {
    try {
      final elementos = await _localStorage.obtenerElementosSesion(sessionId);
      final filtrados = elementos.where((e) => e.type == tipo).toList();
      return Right(filtrados);
    } catch (e) {
      return Left(SessionFailure(
        'Error al obtener elementos por tipo: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, void>> actualizarContadores(String sessionId) async {
    try {
      final elementos = await _localStorage.obtenerElementosSesion(sessionId);
      final sesion = await _localStorage.obtenerSesion(sessionId);

      if (sesion == null) {
        return Left(SessionFailure(
          'Sesión no encontrada',
          tipo: SessionFailureType.sesionNoEncontrada,
        ));
      }

      var contadores = const SessionContadores();
      for (final elemento in elementos) {
        double distancia = 0.0;
        if (elemento is Claro) distancia = elemento.distanciaMetros;
        contadores = contadores.incrementar(elemento.type, distanciaClaro: distancia);
      }

      final sesionActualizada = sesion.copyWith(contadores: contadores);
      await _localStorage.guardarSesion(sesionActualizada);
      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(
        'Error al actualizar contadores: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, SessionGraph>> generarGrafoRecorrido(String sessionId) async {
    try {
      final grafo = await _graphGenerator.generarGrafo(sessionId);
      await _localStorage.guardarGrafo(grafo);
      return Right(grafo);
    } catch (e) {
      return Left(SessionFailure(
        'Error al generar grafo: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, String>> exportarSesion(String sessionId, ExportFormat formato) async {
    try {
      final sesion = await _localStorage.obtenerSesion(sessionId);
      if (sesion == null) {
        return Left(SessionFailure(
          'Sesión no encontrada',
          tipo: SessionFailureType.sesionNoEncontrada,
        ));
      }

      final elementos = await _localStorage.obtenerElementosSesion(sessionId);
      final grafo = await _localStorage.obtenerGrafo(sessionId);
      final resumen = _construirResumen(sesion, elementos);

      final exportData = SessionExportData(
        sesion: sesion,
        resumen: resumen,
        elementos: elementos,
        grafo: grafo,
      );

      final ruta = await _exportarPorFormato(exportData, formato);
      return Right(ruta);
    } catch (e) {
      return Left(SessionFailure(
        'Error al exportar sesión: $e',
        tipo: SessionFailureType.errorAlmacenamiento,
      ));
    }
  }

  @override
  Future<Either<SessionFailure, void>> sincronizarSesion(String sessionId) async {
    try {
      final sesion = await _localStorage.obtenerSesion(sessionId);
      if (sesion == null) {
        return Left(SessionFailure(
          'Sesión no encontrada',
          tipo: SessionFailureType.sesionNoEncontrada,
        ));
      }

      final elementos = await _localStorage.obtenerElementosSesion(sessionId);
      final grafo = await _localStorage.obtenerGrafo(sessionId);

      await _remoteSync.subirSesion(sesion, elementos, grafo);

      final sesionSync = sesion.copyWith(sincronizada: true);
      await _localStorage.guardarSesion(sesionSync);

      return const Right(null);
    } catch (e) {
      return Left(SessionFailure(
        'Error al sincronizar: $e',
        tipo: SessionFailureType.errorRed,
      ));
    }
  }

  SessionSummary _construirResumen(Session sesion, List<SessionElement> elementos) {
    var totalPostes = 0;
    var totalTransformadores = 0;
    var totalArboles = 0;
    var totalPodas = 0;
    var totalClaros = 0;
    var totalFotos = 0;
    var distanciaTotal = 0.0;
    final tecnicos = <String>{sesion.userId};

    for (final elemento in elementos) {
      switch (elemento.type) {
        case SessionElementType.poste:
          totalPostes++;
          break;
        case SessionElementType.transformador:
          totalTransformadores++;
          break;
        case SessionElementType.arbol:
          totalArboles++;
          break;
        case SessionElementType.poda:
          totalPodas++;
          tecnicos.add(elemento.userId);
          break;
        case SessionElementType.claro:
          totalClaros++;
          if (elemento is Claro) distanciaTotal += elemento.distanciaMetros;
          break;
        case SessionElementType.foto:
          totalFotos++;
          break;
      }
      tecnicos.add(elemento.userId);
    }

    return SessionSummary(
      sessionId: sesion.id,
      userId: sesion.userId,
      fechaInicio: sesion.fechaInicio,
      fechaFin: sesion.fechaFin,
      totalPostes: totalPostes,
      totalTransformadores: totalTransformadores,
      totalArboles: totalArboles,
      totalPodas: totalPodas,
      totalClaros: totalClaros,
      totalFotos: totalFotos,
      distanciaTotalClaros: distanciaTotal,
      duracionSesion: sesion.duracion,
      tecnicosParticipantes: tecnicos.toList(),
    );
  }

  Future<String> _exportarPorFormato(SessionExportData data, ExportFormat formato) async {
    // Implementación según formato
    switch (formato) {
      case ExportFormat.json:
        return _exportarJson(data);
      case ExportFormat.geojson:
        return _exportarGeoJson(data);
      case ExportFormat.csv:
        return _exportarCsv(data);
      case ExportFormat.kml:
        return _exportarKml(data);
      case ExportFormat.pdf:
        return _exportarPdf(data);
    }
  }

  String _exportarJson(SessionExportData data) {
    // TODO: Implementar exportación JSON completa
    return '';
  }

  String _exportarGeoJson(SessionExportData data) {
    // TODO: Implementar GeoJSON para mapas
    return '';
  }

  String _exportarCsv(SessionExportData data) {
    // TODO: Implementar CSV
    return '';
  }

  String _exportarKml(SessionExportData data) {
    // TODO: Implementar KML para Google Earth
    return '';
  }

  String _exportarPdf(SessionExportData data) {
    // TODO: Implementar PDF con reporte gráfico
    return '';
  }

  String _generarIdSesion() {
    return 'SES_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000).toString().padLeft(4, '0')}';
  }
}

/// Datos completos para exportación
class SessionExportData {
  final Session sesion;
  final SessionSummary resumen;
  final List<SessionElement> elementos;
  final SessionGraph? grafo;

  const SessionExportData({
    required this.sesion,
    required this.resumen,
    required this.elementos,
    this.grafo,
  });
}

/// Almacenamiento local (SQLite/Hive/Isar)
abstract class SessionLocalStorage {
  Future<void> guardarSesion(Session sesion);
  Future<Session?> obtenerSesion(String sessionId);
  Future<Session?> obtenerSesionActiva(String userId);
  Future<void> guardarElemento(SessionElement elemento);
  Future<List<SessionElement>> obtenerElementosSesion(String sessionId);
  Future<void> guardarGrafo(SessionGraph grafo);
  Future<SessionGraph?> obtenerGrafo(String sessionId);
}

/// Sincronización remota (Firebase)
abstract class SessionRemoteSync {
  Future<void> subirSesion(Session sesion, List<SessionElement> elementos, SessionGraph? grafo);
  Future<void> descargarSesionesPendientes(String userId);
}

/// Generador de grafo de recorrido
class GraphGenerator {
  final SessionLocalStorage _storage;

  GraphGenerator(this._storage);

  Future<SessionGraph> generarGrafo(String sessionId) async {
    final elementos = await _storage.obtenerElementosSesion(sessionId);
    final sesion = await _storage.obtenerSesion(sessionId);

    if (sesion == null) {
      throw Exception('Sesión no encontrada');
    }

    final nodos = <GraphNode>[];
    final aristas = <GraphEdge>[];
    final rutas = <GraphRoute>[];
    final nodosPorTipo = <GraphNodeType, int>{};
    final aristasPorTipo = <GraphEdgeType, int>{};

    // Convertir elementos a nodos del grafo
    for (final elemento in elementos) {
      final nodo = _elementoANodo(elemento);
      nodos.add(nodo);
      nodosPorTipo[nodo.tipo] = (nodosPorTipo[nodo.tipo] ?? 0) + 1;
    }

    // Generar aristas (conexiones)
    _generarAristasClaros(elementos, aristas, aristasPorTipo);
    _generarAristasPodas(elementos, aristas, aristasPorTipo);
    _generarAristasDesplazamiento(elementos, aristas, aristasPorTipo);

    // Calcular rutas óptimas
    final rutasCalculadas = _calcularRutas(nodos, aristas);
    rutas.addAll(rutasCalculadas);

    // Estadísticas
    final distanciaTotal = aristas.fold(0.0, (sum, a) => sum + a.distanciaMetros);
    final area = _calcularAreaCubierta(nodos);
    final componentes = _calcularComponentesConexos(nodos, aristas);

    final stats = GraphStats(
      totalNodos: nodos.length,
      totalAristas: aristas.length,
      distanciaTotalRecorrida: distanciaTotal,
      areaCubiertaKm2: area,
      componentesConexos: componentes,
      tiempoTotalTrabajo: sesion.duracion,
      nodosPorTipo: nodosPorTipo,
      aristasPorTipo: aristasPorTipo,
    );

    return SessionGraph(
      sessionId: sessionId,
      nodos: nodos,
      aristas: aristas,
      rutas: rutas,
      estadisticas: stats,
      generadoEn: DateTime.now(),
    );
  }

  GraphNode _elementoANodo(SessionElement elemento) {
    switch (elemento) {
      case Poste p:
        return GraphNode(
          id: p.id,
          label: p.codigoPoste ?? 'Poste ${p.id.substring(0, 8)}',
          tipo: GraphNodeType.poste,
          latitude: p.latitude,
          longitude: p.longitude,
          altitude: p.altitude,
          timestamp: p.timestamp,
          codigo: p.codigoPoste,
          propiedades: {
            'tipoPoste': p.tipoPoste,
            'altura': p.altura,
            'observaciones': p.observaciones,
          },
          fotosIds: p.fotosIds,
        );
      case Transformador t:
        return GraphNode(
          id: t.id,
          label: t.codigoTransformador ?? 'Trafo ${t.id.substring(0, 8)}',
          tipo: GraphNodeType.transformador,
          latitude: t.latitude,
          longitude: t.longitude,
          timestamp: t.timestamp,
          codigo: t.codigoTransformador,
          propiedades: {
            'potenciaKva': t.potenciaKva,
            'tipoTransformador': t.tipoTransformador,
            'numeroFases': t.numeroFases,
            'posteAsociado': t.posteIdAsociado,
          },
          fotosIds: t.fotosIds,
        );
      case Arbol a:
        return GraphNode(
          id: a.id,
          label: a.especie ?? 'Árbol ${a.id.substring(0, 8)}',
          tipo: GraphNodeType.arbol,
          latitude: a.latitude,
          longitude: a.longitude,
          timestamp: a.timestamp,
          propiedades: {
            'especie': a.especie,
            'altura': a.alturaAproximada,
            'riesgo': a.riesgo,
            'distanciaPoste': a.distanciaAlPoste,
            'posteCercano': a.posteCercanoId,
          },
          fotosIds: a.fotosIds,
        );
      case Poda p:
        return GraphNode(
          id: p.id,
          label: 'Poda ${p.id.substring(0, 8)}',
          tipo: GraphNodeType.poda,
          latitude: p.latitude,
          longitude: p.longitude,
          timestamp: p.timestamp,
          propiedades: {
            'arbolId': p.arbolId,
            'herramienta': p.herramientaUtilizada,
            'completada': p.completada,
            'duracionMinutos': p.duracion.inMinutes,
          },
          fotosIds: p.fotosIds,
        );
      default:
        return GraphNode(
          id: elemento.id,
          label: elemento.type.name,
          tipo: GraphNodeType.poste,
          latitude: 0,
          longitude: 0,
          timestamp: elemento.timestamp,
        );
    }
  }

  void _generarAristasClaros(
    List<SessionElement> elementos,
    List<GraphEdge> aristas,
    Map<GraphEdgeType, int> contador,
  ) {
    final claros = elementos.whereType<Claro>().toList();
    final postes = {for (var e in elementos.whereType<Poste>()) e.id: e};

    for (final claro in claros) {
      final origen = postes[claro.posteOrigenId];
      final destino = postes[claro.posteDestinoId];

      if (origen != null && destino != null) {
        aristas.add(GraphEdge(
          id: claro.id,
          origenId: claro.posteOrigenId,
          destinoId: claro.posteDestinoId,
          tipo: GraphEdgeType.claro,
          distanciaMetros: claro.distanciaMetros,
          timestamp: claro.timestamp,
          propiedades: {
            'tipoCable': claro.tipoCable,
            'numeroCables': claro.numeroCables,
          },
        ));
        contador[GraphEdgeType.claro] = (contador[GraphEdgeType.claro] ?? 0) + 1;
      }
    }
  }

  void _generarAristasPodas(
    List<SessionElement> elementos,
    List<GraphEdge> aristas,
    Map<GraphEdgeType, int> contador,
  ) {
    final podas = elementos.whereType<Poda>().toList();
    final arboles = {for (var e in elementos.whereType<Arbol>()) e.id: e};

    for (final poda in podas) {
      final arbol = arboles[poda.arbolId];
      if (arbol != null) {
        final distancia = _calcularDistancia(
          poda.latitude, poda.longitude,
          arbol.latitude, arbol.longitude,
        );
        aristas.add(GraphEdge(
          id: poda.id,
          origenId: poda.arbolId,
          destinoId: poda.id,
          tipo: GraphEdgeType.poda,
          distanciaMetros: distancia,
          timestamp: poda.timestamp,
          propiedades: {
            'herramienta': poda.herramientaUtilizada,
            'completada': poda.completada,
          },
        ));
        contador[GraphEdgeType.poda] = (contador[GraphEdgeType.poda] ?? 0) + 1;
      }
    }
  }

  void _generarAristasDesplazamiento(
    List<SessionElement> elementos,
    List<GraphEdge> aristas,
    Map<GraphEdgeType, int> contador,
  ) {
    // Ordenar por timestamp para crear ruta de desplazamiento
    final conCoordenadas = elementos.where((e) {
      if (e is Poste) return true;
      if (e is Transformador) return true;
      if (e is Arbol) return true;
      if (e is Poda) return true;
      if (e is Claro) return true;
      return false;
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (var i = 1; i < conCoordenadas.length; i++) {
      final anterior = conCoordenadas[i - 1];
      final actual = conCoordenadas[i];

      double lat1, lon1, lat2, lon2;
      if (anterior is Poste) { lat1 = anterior.latitude; lon1 = anterior.longitude; }
      else if (anterior is Transformador) { lat1 = anterior.latitude; lon1 = anterior.longitude; }
      else if (anterior is Arbol) { lat1 = anterior.latitude; lon1 = anterior.longitude; }
      else if (anterior is Poda) { lat1 = anterior.latitude; lon1 = anterior.longitude; }
      else if (anterior is Claro) { lat1 = anterior.latitudeOrigen; lon1 = anterior.longitudeOrigen; }
      else continue;

      if (actual is Poste) { lat2 = actual.latitude; lon2 = actual.longitude; }
      else if (actual is Transformador) { lat2 = actual.latitude; lon2 = actual.longitude; }
      else if (actual is Arbol) { lat2 = actual.latitude; lon2 = actual.longitude; }
      else if (actual is Poda) { lat2 = actual.latitude; lon2 = actual.longitude; }
      else if (actual is Claro) { lat2 = actual.latitudeOrigen; lon2 = actual.longitudeOrigen; }
      else continue;

      final distancia = _calcularDistancia(lat1, lon1, lat2, lon2);

      if (distancia > 10) { // Solo registrar desplazamientos > 10m
        aristas.add(GraphEdge(
          id: 'DESP_${anterior.id}_${actual.id}',
          origenId: anterior.id,
          destinoId: actual.id,
          tipo: GraphEdgeType.desplazamiento,
          distanciaMetros: distancia,
          timestamp: actual.timestamp,
          propiedades: {},
        ));
        contador[GraphEdgeType.desplazamiento] = (contador[GraphEdgeType.desplazamiento] ?? 0) + 1;
      }
    }
  }

  List<GraphRoute> _calcularRutas(List<GraphNode> nodos, List<GraphEdge> aristas) {
    final rutas = <GraphRoute>[];

    if (nodos.isEmpty) return rutas;

    // Ruta principal: recorrido cronológico
    final nodosOrdenados = List<GraphNode>.from(nodos)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final idsOrdenados = nodosOrdenados.map((n) => n.id).toList();
    double distanciaRuta = 0;

    for (var i = 1; i < nodosOrdenados.length; i++) {
      final arista = aristas.firstWhere(
        (e) => (e.origenId == nodosOrdenados[i-1].id && e.destinoId == nodosOrdenados[i].id) ||
               (e.origenId == nodosOrdenados[i].id && e.destinoId == nodosOrdenados[i-1].id),
        orElse: () => GraphEdge(
          id: '',
          origenId: '',
          destinoId: '',
          tipo: GraphEdgeType.desplazamiento,
          distanciaMetros: _calcularDistancia(
            nodosOrdenados[i-1].latitude, nodosOrdenados[i-1].longitude,
            nodosOrdenados[i].latitude, nodosOrdenados[i].longitude,
          ),
          timestamp: nodosOrdenados[i].timestamp,
        ),
      );
      distanciaRuta += arista.distanciaMetros;
    }

    rutas.add(GraphRoute(
      id: 'RUTA_PRINCIPAL',
      nodosOrdenados: idsOrdenados,
      distanciaTotal: distanciaRuta,
      tiempoEstimado: Duration(minutes: (distanciaRuta / 50).round()), // ~50 m/min caminando
      descripcion: 'Recorrido cronológico de la sesión',
    ));

    // Ruta por claros (red eléctrica)
    final postes = nodos.where((n) => n.tipo == GraphNodeType.poste).toList();
    if (postes.length >= 2) {
      final clarosAristas = aristas.where((a) => a.tipo == GraphEdgeType.claro).toList();
      if (clarosAristas.isNotEmpty) {
        final idsClaros = <String>[];
        final visitados = <String>{};

        // DFS simple para recorrer la red
        void dfs(String nodoId) {
          visitados.add(nodoId);
          idsClaros.add(nodoId);
          for (final arista in clarosAristas) {
            if (arista.origenId == nodoId && !visitados.contains(arista.destinoId)) {
              dfs(arista.destinoId);
            } else if (arista.destinoId == nodoId && !visitados.contains(arista.origenId)) {
              dfs(arista.origenId);
            }
          }
        }

        dfs(postes.first.id);

        double distClaros = clarosAristas.fold(0.0, (sum, a) => sum + a.distanciaMetros);

        rutas.add(GraphRoute(
          id: 'RUTA_RED_ELECTRICA',
          nodosOrdenados: idsClaros,
          distanciaTotal: distClaros,
          tiempoEstimado: Duration(minutes: (distClaros / 30).round()),
          descripcion: 'Recorrido de la red eléctrica (claros)',
        ));
      }
    }

    return rutas;
  }

  double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Radio de la Tierra en metros
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * math.pi / 180.0;

  double _calcularAreaCubierta(List<GraphNode> nodos) {
    if (nodos.length < 3) return 0.0;

    // Convex hull simplificado (área aproximada)
    final coords = nodos.map((n) => (n.latitude, n.longitude)).toList();
    // Fórmula del zapato (shoelace formula) para polígono
    double area = 0;
    for (var i = 0; i < coords.length; i++) {
      final j = (i + 1) % coords.length;
      area += coords[i].$1 * coords[j].$2;
      area -= coords[j].$1 * coords[i].$2;
    }
    area = area.abs() / 2.0;
    // Convertir grados^2 a km^2 (aproximado)
    return area * 111.32 * 111.32; // 1 grado ≈ 111.32 km
  }

  int _calcularComponentesConexos(List<GraphNode> nodos, List<GraphEdge> aristas) {
    final visitados = <String>{};
    var componentes = 0;
    final adyacencia = <String, List<String>>{};

    for (final nodo in nodos) {
      adyacencia[nodo.id] = [];
    }
    for (final arista in aristas) {
      adyacencia[arista.origenId]?.add(arista.destinoId);
      adyacencia[arista.destinoId]?.add(arista.origenId);
    }

    void dfs(String nodoId) {
      visitados.add(nodoId);
      for (final vecino in adyacencia[nodoId] ?? []) {
        if (!visitados.contains(vecino)) {
          dfs(vecino);
        }
      }
    }

    for (final nodo in nodos) {
      if (!visitados.contains(nodo.id)) {
        dfs(nodo.id);
        componentes++;
      }
    }

    return componentes;
  }
}