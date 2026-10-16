import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Dashboard principal del administrador
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notificaciones
            },
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Logout
              context.go('/login');
            },
            tooltip: 'Salir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bienvenida
            _buildWelcomeSection(context),
            const SizedBox(height: 32),

            // Sección: Gestión de usuarios
            _buildSectionHeader(context, 'Gestión de Usuarios'),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              icon: Icons.people_outline,
              title: 'Usuarios',
              subtitle: 'Crear, editar, eliminar usuarios',
              onTap: () => context.push('/admin/usuarios'),
            ),
            const SizedBox(height: 24),

            // Sección: Gestión de cuadrillas
            _buildSectionHeader(context, 'Gestión de Cuadrillas'),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              icon: Icons.groups_outlined,
              title: 'Cuadrillas',
              subtitle: 'Asignar técnicos a cuadrillas',
              onTap: () => context.push('/admin/cuadrillas'),
            ),
            const SizedBox(height: 24),

            // Sección: Catálogos
            _buildSectionHeader(context, 'Catálogos y Configuración'),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              icon: Icons.inventory_outlined,
              title: 'Catálogos',
              subtitle: 'Tipos de postes, transformadores, podas',
              onTap: () => context.push('/admin/catalogos'),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              context,
              icon: Icons.settings_outlined,
              title: 'Configuración del Sistema',
              subtitle: 'Parámetros y políticas globales',
              onTap: () => context.push('/admin/configuracion'),
            ),
            const SizedBox(height: 24),

            // Sección: Reportes y Estadísticas
            _buildSectionHeader(context, 'Reportes y Estadísticas'),
            const SizedBox(height: 12),
            _buildStatsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, Administrador',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenido al panel de control de MaCElectricos',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          title: 'Usuarios Activos',
          value: '28',
          icon: Icons.people_alt_outlined,
        ),
        _buildStatCard(
          context,
          title: 'Cuadrillas',
          value: '6',
          icon: Icons.groups_outlined,
        ),
        _buildStatCard(
          context,
          title: 'Sesiones Hoy',
          value: '42',
          icon: Icons.assignment_outlined,
        ),
        _buildStatCard(
          context,
          title: 'Elementos Registrados',
          value: '1,247',
          icon: Icons.inventory_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
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
