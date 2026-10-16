import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macelectricos/core/di/providers.dart';
import 'package:macelectricos/core/models/session_models.dart';
import 'package:macelectricos/features/session_tracking/domain/session_repository.dart';
import 'package:macelectricos/features/session_tracking/presentation/session_graph_screen.dart';
import 'package:macelectricos/features/session_tracking/presentation/session_provider.dart';

/// Pantalla principal de tracking de sesión
class SessionTrackingScreen extends ConsumerWidget {
  const SessionTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión de Trabajo'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          if (sessionState.haySesionActiva) ...[
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: sessionState.cargando ? null : () => notifier.sincronizarSesion(),
              tooltip: 'Sincronizar',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: sessionState.cargando ? null : () => _mostrarExportDialog(context, notifier),
              tooltip: 'Exportar',
            ),
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: sessionState.cargando ? null : () => _mostrarGrafoCompleto(context, sessionState),
              tooltip: 'Ver Grafo Completo',
            ),
          ],
        ],
      ),
      body: sessionState.cargando && !sessionState.haySesionActiva
          ? const Center(child: CircularProgressIndicator())
          : sessionState.haySesionActiva
              ? _SesionActivaView(state: sessionState, notifier: notifier)
              : _SinSesionView(notifier: notifier),
    );
  }

  void _mostrarExportDialog(BuildContext context, SessionNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Exportar Sesión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON'),
              onTap: () => notifier.exportarSesion(ExportFormat.json).then((r) => Navigator.pop(ctx)),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('GeoJSON'),
              onTap: () => notifier.exportarSesion(ExportFormat.geojson).then((r) => Navigator.pop(ctx)),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              onTap: () => notifier.exportarSesion(ExportFormat.csv).then((r) => Navigator.pop(ctx)),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () => notifier.exportarSesion(ExportFormat.pdf).then((r) => Navigator.pop(ctx)),
            ),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('KML (Google Earth)'),
              onTap: () => notifier.exportarSesion(ExportFormat.kml).then((r) => Navigator.pop(ctx)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarGrafoCompleto(BuildContext context, SessionState state) {
    if (state.grafo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay grafo generado aún. Finalice la sesión primero.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SessionGraphScreen(grafo: state.grafo!, resumen: state.resumen!)),
    );
  }
}

/// Vista cuando no hay sesión activa
class _SinSesionView extends ConsumerWidget {
  final SessionNotifier notifier;

  const _SinSesionView({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el usuario autenticado para la sesión
    final usuarioAutenticado = ref.watch(authProvider).user;

    // Datos de la sesión desde el usuario logueado (no hardcodeados)
    final userId = usuarioAutenticado?.id ?? 'SIN_USUARIO';
    final cuadrillaId = usuarioAutenticado?.equipoId ?? 'SIN_CUADRILLA';
    final nombreUsuario = usuarioAutenticado?.nombre ?? userId;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electrical_services, size: 80, color: Colors.blueGrey[300]),
            const SizedBox(height: 24),
            Text(
              'Macelectricos - Tracking de Sesión',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Registre postes, transformadores, árboles, podas y claros durante su jornada de campo.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => notifier.iniciarSesion(userId: userId, cuadrillaId: cuadrillaId),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sesión para: $nombreUsuario | Cuadrilla: $cuadrillaId',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista con sesión activa - contadores y acciones rápidas
class _SesionActivaView extends ConsumerWidget {
  final SessionState state;
  final SessionNotifier notifier;

  const _SesionActivaView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Header con info de sesión
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blueGrey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    'Sesión Activa',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (state.sesionActiva != null)
                    Text(
                      _formatearDuracion(state.sesionActiva!.duracion),
                      style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'),
                    ),
                ],
              ),
              if (state.sesionActiva != null) ...[
                const SizedBox(height: 8),
                Text(
                  'ID: ${state.sesionActiva!.id}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'),
                ),
                Text(
                  'Cuadrilla: ${state.sesionActiva!.cuadrillaId} | Inicio: ${_formatearFecha(state.sesionActiva!.fechaInicio)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ],
          ),
        ),

        // Contadores en cards
        _ContadoresResumen(contadores: state.contadores),

        // Acciones rápidas
        _AccionesRapidas(notifier: notifier, state: state),

        // Lista de elementos recientes
        Expanded(
          child: _ElementosRecientes(
            elementos: state.elementos,
            onVerTodos: () => _mostrarTodosElementos(context, state),
          ),
        ),

        // Botón finalizar sesión
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              icon: const Icon(Icons.stop, size: 24),
              label: const Text('Finalizar Sesión y Generar Grafo', style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: state.cargando ? null : () => _confirmarFinalizar(context, notifier),
            ),
          ),
        ),
      ],
    );
  }

  String _formatearDuracion(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatearFecha(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  void _confirmarFinalizar(BuildContext context, SessionNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Sesión'),
        content: const Text('Se generará el grafo de recorrido con todas las coordenadas y estadísticas. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.finalizarSesion().then((resumen) {
                if (resumen != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sesión finalizada. ${resumen.totalPostes} postes, ${resumen.totalClaros} claros, ${resumen.distanciaTotalClaros.toStringAsFixed(1)}m')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SessionGraphScreen(
                      grafo: state.grafo!,
                      resumen: resumen,
                    )),
                  );
                }
              });
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _mostrarTodosElementos(BuildContext context, SessionState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text('Elementos de la Sesión', style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: state.elementos.length,
                itemBuilder: (_, i) {
                  final e = state.elementos[i];
                  return ListTile(
                    leading: _iconParaTipo(e.type),
                    title: Text(_labelParaElemento(e)),
                    subtitle: Text('${_formatearHora(e.timestamp)} | ${e.userId}'),
                    trailing: Text(e.type.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _iconParaTipo(SessionElementType type) {
    switch (type) {
      case SessionElementType.poste: return const Icon(Icons.electrical_services, color: Colors.blue);
      case SessionElementType.transformador: return const Icon(Icons.transform, color: Colors.orange);
      case SessionElementType.arbol: return const Icon(Icons.park, color: Colors.green);
      case SessionElementType.poda: return const Icon(Icons.content_cut, color: Colors.red);
      case SessionElementType.claro: return const Icon(Icons.straighten, color: Colors.purple);
      case SessionElementType.foto: return const Icon(Icons.photo_camera, color: Colors.teal);
    }
  }

  String _labelParaElemento(SessionElement e) {
    switch (e) {
      case Poste p: return p.codigoPoste ?? 'Poste ${p.id.substring(0, 8)}';
      case Transformador t: return t.codigoTransformador ?? 'Trafo ${t.id.substring(0, 8)}';
      case Arbol a: return a.especie ?? 'Árbol ${a.id.substring(0, 8)}';
      case Poda p: return 'Poda en árbol ${p.arbolId.substring(0, 8)}';
      case Claro c: return 'Claro ${c.posteOrigenId.substring(0, 8)}-${c.posteDestinoId.substring(0, 8)} (${c.distanciaMetros.toStringAsFixed(1)}m)';
      case FotoEvidencia f: return f.descripcion ?? 'Foto ${f.id.substring(0, 8)}';
      default: return 'Elemento ${e.id.substring(0, 8)}';
    }
  }

  String _formatearHora(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

/// Cards de contadores
class _ContadoresResumen extends StatelessWidget {
  final SessionContadores contadores;

  const _ContadoresResumen({required this.contadores});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ContadorCard(
              icon: Icons.electrical_services,
              label: 'Postes',
              valor: contadores.postes.toString(),
              color: Colors.blue,
            ),
            _ContadorCard(
              icon: Icons.transform,
              label: 'Transformadores',
              valor: contadores.transformadores.toString(),
              color: Colors.orange,
            ),
            _ContadorCard(
              icon: Icons.park,
              label: 'Árboles',
              valor: contadores.arboles.toString(),
              color: Colors.green,
            ),
            _ContadorCard(
              icon: Icons.content_cut,
              label: 'Podas',
              valor: contadores.podas.toString(),
              color: Colors.red,
            ),
            _ContadorCard(
              icon: Icons.straighten,
              label: 'Claros',
              valor: contadores.claros.toString(),
              color: Colors.purple,
            ),
            _ContadorCard(
              icon: Icons.photo_camera,
              label: 'Fotos',
              valor: contadores.fotos.toString(),
              color: Colors.teal,
            ),
            _ContadorCard(
              icon: Icons.straighten,
              label: 'Dist. Claros',
              valor: '${contadores.distanciaTotalClaros.toStringAsFixed(1)}m',
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContadorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color color;

  const _ContadorCard({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Botones de acciones rápidas
class _AccionesRapidas extends StatelessWidget {
  final SessionNotifier notifier;
  final SessionState state;

  const _AccionesRapidas({required this.notifier, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _AccionBoton(
            icon: Icons.add_location,
            label: 'Registrar Poste',
            color: Colors.blue,
            onTap: () => _navegarRegistro(context, SessionElementType.poste),
          ),
          _AccionBoton(
            icon: Icons.transform,
            label: 'Registrar Transformador',
            color: Colors.orange,
            onTap: () => _navegarRegistro(context, SessionElementType.transformador),
          ),
          _AccionBoton(
            icon: Icons.park,
            label: 'Registrar Árbol',
            color: Colors.green,
            onTap: () => _navegarRegistro(context, SessionElementType.arbol),
          ),
          _AccionBoton(
            icon: Icons.content_cut,
            label: 'Registrar Poda',
            color: Colors.red,
            onTap: () => _navegarRegistro(context, SessionElementType.poda),
          ),
          _AccionBoton(
            icon: Icons.straighten,
            label: 'Registrar Claro',
            color: Colors.purple,
            onTap: () => _navegarRegistro(context, SessionElementType.claro),
          ),
          _AccionBoton(
            icon: Icons.camera_alt,
            label: 'Tomar Foto',
            color: Colors.teal,
            onTap: () => _navegarRegistro(context, SessionElementType.foto),
          ),
        ],
      ),
    );
  }

  void _navegarRegistro(BuildContext context, SessionElementType tipo) {
    // TODO: Navegar a pantalla de registro específica
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registro de ${tipo.name} - Pendiente de implementar UI')),
    );
  }
}

class _AccionBoton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccionBoton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// Lista de elementos recientes
class _ElementosRecientes extends StatelessWidget {
  final List<SessionElement> elementos;
  final VoidCallback onVerTodos;

  const _ElementosRecientes({required this.elementos, required this.onVerTodos});

  @override
  Widget build(BuildContext context) {
    if (elementos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No hay elementos registrados', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Use los botones de acción para registrar elementos', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    final recientes = elementos.reversed.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Últimos Registros', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(onPressed: onVerTodos, child: const Text('Ver todos')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recientes.length,
            itemBuilder: (_, i) {
              final e = recientes[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _colorParaTipo(e.type).withValues(alpha: 0.2),
                    child: Icon(_iconParaTipo(e.type), color: _colorParaTipo(e.type), size: 20),
                  ),
                  title: Text(_labelParaElemento(e), style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${_formatearHora(e.timestamp)} • ${e.userId}'),
                  trailing: Chip(
                    label: Text(e.type.name, style: const TextStyle(fontSize: 10)),
                    backgroundColor: _colorParaTipo(e.type).withValues(alpha: 0.2),
                    labelStyle: TextStyle(color: _colorParaTipo(e.type)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _colorParaTipo(SessionElementType type) {
    switch (type) {
      case SessionElementType.poste: return Colors.blue;
      case SessionElementType.transformador: return Colors.orange;
      case SessionElementType.arbol: return Colors.green;
      case SessionElementType.poda: return Colors.red;
      case SessionElementType.claro: return Colors.purple;
      case SessionElementType.foto: return Colors.teal;
    }
  }

  IconData _iconParaTipo(SessionElementType type) {
    switch (type) {
      case SessionElementType.poste: return Icons.electrical_services;
      case SessionElementType.transformador: return Icons.transform;
      case SessionElementType.arbol: return Icons.park;
      case SessionElementType.poda: return Icons.content_cut;
      case SessionElementType.claro: return Icons.straighten;
      case SessionElementType.foto: return Icons.photo_camera;
    }
  }

  String _labelParaElemento(SessionElement e) {
    switch (e) {
      case Poste p: return p.codigoPoste ?? 'Poste ${p.id.substring(0, 8)}';
      case Transformador t: return t.codigoTransformador ?? 'Trafo ${t.id.substring(0, 8)}';
      case Arbol a: return a.especie ?? 'Árbol ${a.id.substring(0, 8)}';
      case Poda p: return 'Poda en árbol ${p.arbolId.substring(0, 8)}';
      case Claro c: return 'Claro ${c.posteOrigenId.substring(0, 8)}-${c.posteDestinoId.substring(0, 8)} (${c.distanciaMetros.toStringAsFixed(1)}m)';
      case FotoEvidencia f: return f.descripcion ?? 'Foto ${f.id.substring(0, 8)}';
      default: return 'Elemento ${e.id.substring(0, 8)}';
    }
  }

  String _formatearHora(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}