import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macelectricos/core/di/providers.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Estados posibles de un transformador
enum EstadoTransformador {
  operativo,
  mantenimiento,
  fueraServicio;

  String get label => switch (this) {
        EstadoTransformador.operativo => 'Operativo',
        EstadoTransformador.mantenimiento => 'Mantenimiento',
        EstadoTransformador.fueraServicio => 'Fuera de Servicio',
      };
}

/// Pantalla para registrar transformadores en la red eléctrica
class RegistroTransformadorScreen extends ConsumerStatefulWidget {
  const RegistroTransformadorScreen({super.key});

  @override
  ConsumerState<RegistroTransformadorScreen> createState() =>
      _RegistroTransformadorScreenState();
}

class _RegistroTransformadorScreenState
    extends ConsumerState<RegistroTransformadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificadorController = TextEditingController();
  final _tipoController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _tensionController = TextEditingController();
  final _posteController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  String _estado = 'operativo';
  String? _selectedPoste;
  bool _isLoading = false;
  bool _obtenerGPS = false;

  // Lista simulada de postes (en producción vendría del repositorio)
  final List<Map<String, String>> _postesSimulados = [
    {'id': 'PO-001', 'codigo': 'POST-001 - Av. Principal'},
    {'id': 'PO-002', 'codigo': 'POST-002 - Calle 5'},
    {'id': 'PO-003', 'codigo': 'POST-003 - Plaza Central'},
  ];

  @override
  void dispose() {
    _identificadorController.dispose();
    _tipoController.dispose();
    _capacidadController.dispose();
    _tensionController.dispose();
    _posteController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Obtener usuario actual del authProvider
      final usuario = ref.read(authProvider).user;
      final tecnicoId = usuario?.id ?? 'SIN_TÉCNICO';
      final fechaRegistro = DateTime.now();

      // Aquí se guardaría en el repositorio real
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transformador ${_identificadorController.text} registrado\n'
            'Técnico: $tecnicoId\n'
            'Fecha: ${fechaRegistro.day}/${fechaRegistro.month}/${fechaRegistro.year}',
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _obtenerCoordenadasGPS() {
    setState(() => _obtenerGPS = true);
    // Simulación de GPS (en producción usaría location_service)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _latitudController.text = '19.4326';
        _longitudController.text = '-99.1332';
        _obtenerGPS = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordenadas obtenidas')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Transformador')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resumen del elemento
              _buildResumenTransformador(theme),
              const SizedBox(height: 16),

              // Identificador
              TextFormField(
                controller: _identificadorController,
                decoration: const InputDecoration(
                  labelText: 'Identificador',
                  hintText: 'TRF-001, TRA-002',
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Tipo
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  hintText: 'Distribución, Potencia, Medidor',
                  prefixIcon: Icon(Icons.electrical_services),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Capacidad y Tensión en misma fila
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _capacidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad (kVA)',
                        hintText: '100',
                        prefixIcon: Icon(Icons.bolt),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tensionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tensión (kV)',
                        hintText: '13.8',
                        prefixIcon: Icon(Icons.electric_bolt),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Poste relacionado (dropdown)
              DropdownButtonFormField<String>(
                value: _selectedPoste,
                decoration: const InputDecoration(
                  labelText: 'Poste Relacionado',
                  hintText: 'Seleccionar poste',
                  prefixIcon: Icon(Icons.electrical_services),
                ),
                items: _postesSimulados.map((poste) {
                  return DropdownMenuItem(
                    value: poste['id'],
                    child: Text(poste['codigo']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPoste = value);
                },
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // GPS - Coordenadas
              Text('Ubicación GPS', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        hintText: '19.4326',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        hintText: '-99.1332',
                        prefixIcon: Icon(Icons.explore),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _obtenerGPS ? null : _obtenerCoordenadasGPS,
                icon: _obtenerGPS
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.gps_fixed),
                label: const Text('Obtener coordenadas GPS'),
              ),
              const SizedBox(height: 16),

              // Estado
              Text('Estado', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(label: Text('Operativo'), value: 'operativo'),
                  ButtonSegment(label: Text('Mantenimiento'), value: 'mantenimiento'),
                  ButtonSegment(label: Text('Fuera Servicio'), value: 'fueraServicio'),
                ],
                selected: {_estado},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _estado = newSelection.first);
                },
              ),
              const SizedBox(height: 32),

              // Técnico responsable (solo lectura)
              TextFormField(
                initialValue: ref.read(authProvider).user?.nombre ?? 'No autenticado',
                decoration: const InputDecoration(
                  labelText: 'Técnico Responsable',
                  prefixIcon: Icon(Icons.person),
                  enabled: false,
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),

              // Fecha automática
              TextFormField(
                initialValue: 'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                decoration: const InputDecoration(
                  labelText: 'Fecha de Registro',
                  prefixIcon: Icon(Icons.calendar_today),
                  enabled: false,
                ),
                enabled: false,
              ),
              const SizedBox(height: 24),

              // Botón registrar
              ElevatedButton(
                onPressed: _isLoading ? null : _registrar,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar Transformador'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenTransformador(ThemeData theme) {
    final visual = ElementIcons.of(ElementType.transformador);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: AppTouchTarget.min,
              height: AppTouchTarget.min,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(visual.icon, color: visual.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registro de transformador',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Equipo de transformación eléctrica',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const StatusBadge.warning('Pendiente de sincronizar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
