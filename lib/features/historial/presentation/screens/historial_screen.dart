import 'package:flutter/material.dart';

import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_empty_state.dart';

import '../mock_actividades.dart';
import '../widgets/actividad_tile.dart';
import 'detalle_actividad_screen.dart';

/// Pantalla de historial de actividades registradas en campo.
///
/// Muestra la lista de actividades con filtros por tipo de elemento y por
/// estado. Usa datos mock durante la Fase 3. Cada fila navega al detalle.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  /// Tipo de elemento seleccionado en el filtro; `null` equivale a "Todos".
  ElementType? _filtroTipo;

  /// Estado seleccionado en el filtro; `null` equivale a "Todos".
  ActividadEstado? _filtroEstado;

  /// Registros que coinciden con los filtros activos.
  List<ActividadRecord> get _registrosFiltrados {
    return mockActividades.where((registro) {
      final cumpleTipo = _filtroTipo == null || registro.tipo == _filtroTipo;
      final cumpleEstado =
          _filtroEstado == null || registro.estado == _filtroEstado;
      return cumpleTipo && cumpleEstado;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final registros = _registrosFiltrados;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltrosTipo(),
          _buildFiltrosEstado(),
          const Divider(),
          Expanded(
            child: registros.isEmpty
                ? _buildEstadoVacio()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: registros.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    itemBuilder: (context, index) {
                      final registro = registros[index];
                      return ActividadTile(
                        registro: registro,
                        onTap: () => _abrirDetalle(registro.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Fila horizontal de filtros por tipo de elemento.
  Widget _buildFiltrosTipo() {
    final opciones = <({String etiqueta, ElementType? tipo})>[
      (etiqueta: 'Todos', tipo: null),
      (etiqueta: 'Poste', tipo: ElementType.poste),
      (etiqueta: 'Transformador', tipo: ElementType.transformador),
      (etiqueta: 'Arbol', tipo: ElementType.arbol),
      (etiqueta: 'Poda', tipo: ElementType.poda),
      (etiqueta: 'Claro', tipo: ElementType.claro),
    ];

    return SizedBox(
      height: AppTouchTarget.min,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        itemCount: opciones.length,
        separatorBuilder: (context, index) => const SizedBox(
          width: AppSpacing.sm,
        ),
        itemBuilder: (context, index) {
          final opcion = opciones[index];
          return ChoiceChip(
            label: Text(opcion.etiqueta),
            selected: _filtroTipo == opcion.tipo,
            onSelected: (_) => setState(() => _filtroTipo = opcion.tipo),
          );
        },
      ),
    );
  }

  /// Fila horizontal de filtros por estado.
  Widget _buildFiltrosEstado() {
    final opciones = <({String etiqueta, ActividadEstado? estado})>[
      (etiqueta: 'Todos', estado: null),
      (etiqueta: 'Completado', estado: ActividadEstado.completado),
      (etiqueta: 'En progreso', estado: ActividadEstado.enProgreso),
      (etiqueta: 'Pendiente', estado: ActividadEstado.pendiente),
      (etiqueta: 'Reportado', estado: ActividadEstado.reportado),
    ];

    return SizedBox(
      height: AppTouchTarget.min,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        itemCount: opciones.length,
        separatorBuilder: (context, index) => const SizedBox(
          width: AppSpacing.sm,
        ),
        itemBuilder: (context, index) {
          final opcion = opciones[index];
          return ChoiceChip(
            label: Text(opcion.etiqueta),
            selected: _filtroEstado == opcion.estado,
            onSelected: (_) => setState(() => _filtroEstado = opcion.estado),
          );
        },
      ),
    );
  }

  /// Estado vacío cuando el filtro activo no devuelve resultados.
  Widget _buildEstadoVacio() {
    return EmptyState(
      icon: Icons.filter_alt_off_outlined,
      title: 'Sin resultados',
      message:
          'No se encontraron actividades con los filtros seleccionados.',
      action: TextButton(
        onPressed: () {
          setState(() {
            _filtroTipo = null;
            _filtroEstado = null;
          });
        },
        child: const Text('Limpiar filtros'),
      ),
    );
  }

  /// Abre el detalle de la actividad con el identificador indicado.
  void _abrirDetalle(String recordId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleActividadScreen(recordId: recordId),
      ),
    );
  }
}