import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para configuración del sistema
class AdminConfiguracionScreen extends ConsumerStatefulWidget {
  const AdminConfiguracionScreen({super.key});

  @override
  ConsumerState<AdminConfiguracionScreen> createState() =>
      _AdminConfiguracionScreenState();
}

class _AdminConfiguracionScreenState
    extends ConsumerState<AdminConfiguracionScreen> {
  bool _notificacionesActivas = true;
  bool _sincronizacionAutomatica = true;
  bool _modoDarkActivado = false;
  String _retencionDatos = '30'; // días

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Sistema')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Notificaciones
            Text(
              'Notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Notificaciones Activas'),
                subtitle: const Text('Recibir alertas del sistema'),
                trailing: Switch(
                  value: _notificacionesActivas,
                  onChanged: (value) {
                    setState(() => _notificacionesActivas = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Sincronización
            Text(
              'Sincronización de Datos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Sincronización Automática'),
                subtitle: const Text('Sincronizar datos automáticamente'),
                trailing: Switch(
                  value: _sincronizacionAutomatica,
                  onChanged: (value) {
                    setState(() => _sincronizacionAutomatica = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Retención de Datos'),
                subtitle: Text('Mantener datos durante $_retencionDatos días'),
                onTap: () {
                  _showRetencionDialog();
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Apariencia
            Text(
              'Apariencia',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Modo Oscuro'),
                subtitle: const Text('Activar tema oscuro'),
                trailing: Switch(
                  value: _modoDarkActivado,
                  onChanged: (value) {
                    setState(() => _modoDarkActivado = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Acciones
            Text(
              'Acciones Administrativas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Base de datos limpiada')),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_sweep),
                  SizedBox(width: 8),
                  Text('Limpiar Datos Antiguos'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Respaldo creado')),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.backup),
                  SizedBox(width: 8),
                  Text('Crear Respaldo'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sistema reiniciado')),
                );
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reiniciar Sistema'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Info
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Sistema',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Versión: 1.0.0\nÚltima actualización: 2026-09-24\nEstado: Operativo',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRetencionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retención de Datos'),
        content: TextField(
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: _retencionDatos),
          onChanged: (value) {
            _retencionDatos = value;
          },
          decoration: const InputDecoration(
            labelText: 'Días',
            hintText: '30',
            suffixText: 'días',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Retención configurada a $_retencionDatos días'),
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
