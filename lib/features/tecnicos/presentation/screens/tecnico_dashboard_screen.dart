import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macelectricos/features/session_tracking/presentation/session_provider.dart';

/// Dashboard principal del técnico
class TecnicoDashboardScreen extends ConsumerWidget {
  const TecnicoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notificaciones
            },
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.sync_outlined),
            onPressed: () {
              context.push('/perfil/sincronizacion');
            },
            tooltip: 'Sincronización',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de bienvenida / Sesión activa
              _buildWelcomeCard(context),
              const SizedBox(height: 24),

              // Acciones rápidas
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Sesión actual (si hay una activa)
              _buildActiveSession(context, sessionState),
              const SizedBox(height: 24),

              // Estadísticas del día
              _buildDailyStats(context),
              const SizedBox(height: 24),

              // Próximas tareas / Recordatorios
              _buildReminders(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewSessionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Sesión'),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, Técnico',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¿Qué vas a registrar hoy?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.electrical_services_rounded,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    final actions = [
      _QuickAction(
        icon: Icons.location_on_outlined,
        label: 'Registrar Poste',
        color: Colors.blue,
        onTap: () => context.push('/tecnico/registro/poste'),
      ),
      _QuickAction(
        icon: Icons.transform_outlined,
        label: 'Transformador',
        color: Colors.orange,
        onTap: () => context.push('/tecnico/registro/transformador'),
      ),
      _QuickAction(
        icon: Icons.park_outlined,
        label: 'Árbol',
        color: Colors.green,
        onTap: () => context.push('/tecnico/registro/arbol'),
      ),
      _QuickAction(
        icon: Icons.content_cut_outlined,
        label: 'Poda',
        color: Colors.purple,
        onTap: () => context.push('/tecnico/registro/poda'),
      ),
      _QuickAction(
        icon: Icons.straighten_outlined,
        label: 'Claro',
        color: Colors.teal,
        onTap: () => context.push('/tecnico/registro/claro'),
      ),
      _QuickAction(
        icon: Icons.camera_alt_outlined,
        label: 'Foto Evidencia',
        color: Colors.indigo,
        onTap: () => context.push('/tecnico/registro/foto'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) => _QuickActionCard(action: actions[index]),
        ),
      ],
    );
  }

  Widget _buildActiveSession(BuildContext context, SessionState session) {
    final theme = Theme.of(context);

    final hasActiveSession = session.haySesionActiva;
    final sessionId = session.sesionActiva?.id;

    if (!hasActiveSession) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No hay sesión activa',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inicia una nueva sesión para comenzar a registrar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _showNewSessionDialog(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      );
    }

    // Si hay sesión activa (placeholder para Fase 3)
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sesión Activa',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: sessionId == null
                      ? null
                      : () => context.push('/tecnico/dashboard/sesion/$sessionId'),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatItem(label: 'Postes', value: '0', icon: Icons.location_on)),
                Expanded(child: _StatItem(label: 'Transformadores', value: '0', icon: Icons.transform)),
                Expanded(child: _StatItem(label: 'Árboles', value: '0', icon: Icons.park)),
                Expanded(child: _StatItem(label: 'Fotos', value: '0', icon: Icons.camera_alt)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas del Día',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Postes', value: '12', icon: Icons.location_on, color: Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Transformadores', value: '3', icon: Icons.transform, color: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Árboles', value: '8', icon: Icons.park, color: Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Podas', value: '5', icon: Icons.content_cut, color: Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Claros', value: '7', icon: Icons.straighten, color: Colors.teal)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Fotos', value: '24', icon: Icons.camera_alt, color: Colors.indigo)),
          ],
        ),
      ],
    );
  }

  Widget _buildReminders(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recordatorios',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/historial'),
              child: const Text('Ver todo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _ReminderItem(
                icon: Icons.sync_problem,
                title: 'Sincronización pendiente',
                subtitle: '3 registros sin subir',
                color: Colors.amber,
                onTap: () => context.push('/perfil/sincronizacion'),
              ),
              const Divider(height: 1),
              _ReminderItem(
                icon: Icons.battery_alert,
                title: 'Batería GPS baja',
                subtitle: 'Considera cargar dispositivo',
                color: Colors.red,
                onTap: () {},
              ),
              const Divider(height: 1),
              _ReminderItem(
                icon: Icons.update,
                title: 'Actualización disponible',
                subtitle: 'Versión 1.0.1 en tienda',
                color: theme.colorScheme.primary,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNewSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nueva Sesión de Trabajo'),
        content: const Text('¿Deseas iniciar una nueva sesión de registro de campo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // La SessionTrackingScreen inicia la sesión (userId/cuadrillaId)
              context.push('/tecnico/dashboard/sesion/nueva');
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGETS AUXILIARES
// ============================================

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, size: 28, color: action.color),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReminderItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}