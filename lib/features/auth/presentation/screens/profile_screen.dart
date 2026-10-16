import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de perfil / configuración
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Obtener datos reales del usuario desde AuthProvider
    final userName = 'Juan Pérez';
    final userEmail = 'juan.perez@macelectricos.com';
    final userRole = 'Técnico';
    final crewName = 'Cuadrilla Norte';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Editar perfil
            },
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header del perfil
          _buildProfileHeader(context, userName, userEmail, userRole, crewName),
          const SizedBox(height: 24),

          // Sección: Cuenta
          _buildSectionTitle(context, 'Cuenta'),
          _buildSettingsItem(
            context,
            icon: Icons.person_outline,
            title: 'Información personal',
            subtitle: 'Nombre, correo, teléfono',
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.lock_outline,
            title: 'Cambiar contraseña',
            subtitle: 'Actualizar credenciales de acceso',
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.fingerprint,
            title: 'Autenticación biométrica',
            subtitle: 'Huella / Face ID para acceso rápido',
            trailing: Switch(
              value: false, // TODO: Leer de preferences
              onChanged: (value) {},
            ),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // Sección: Trabajo
          _buildSectionTitle(context, 'Trabajo'),
          _buildSettingsItem(
            context,
            icon: Icons.group_outlined,
            title: 'Mi cuadrilla',
            subtitle: crewName,
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.assignment_outlined,
            title: 'Mis sesiones',
            subtitle: 'Historial de sesiones de trabajo',
            onTap: () => context.push('/historial'),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.map_outlined,
            title: 'Mapa offline',
            subtitle: 'Descargar mapas para trabajo sin internet',
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // Sección: Sincronización
          _buildSectionTitle(context, 'Sincronización'),
          _buildSettingsItem(
            context,
            icon: Icons.sync_outlined,
            title: 'Estado de sincronización',
            subtitle: '3 elementos pendientes',
            trailing: Chip(
              label: const Text('Pendiente', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.amber.withValues(alpha: 0.2),
              side: BorderSide.none,
            ),
            onTap: () => context.push('/perfil/sincronizacion'),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.cloud_upload_outlined,
            title: 'Sincronizar ahora',
            subtitle: 'Forzar subida de datos al servidor',
            onTap: _syncNow,
          ),
          _buildSettingsItem(
            context,
            icon: Icons.wifi_off_outlined,
            title: 'Solo WiFi para sync',
            subtitle: 'Ahorrar datos móviles',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // Sección: App
          _buildSectionTitle(context, 'Aplicación'),
          _buildSettingsItem(
            context,
            icon: Icons.palette_outlined,
            title: 'Tema',
            subtitle: 'Sistema (Automático)',
            onTap: () => _showThemeDialog(context),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: 'Español',
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Versión 1.0.0 - Build 1',
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 32),

          // Botón cerrar sesión
          OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Versión
          Center(
            child: Text(
              'MaCElectricos v1.0.0\n© 2024 - Gestión de infraestructura eléctrica',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String email,
    String role,
    String crew,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name.split(' ').map((e) => e[0]).take(2).join(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Chips rol y cuadrilla
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(role),
                  avatar: Icon(
                    role == 'Admin' ? Icons.admin_panel_settings :
                    role == 'Supervisor' ? Icons.supervisor_account : Icons.engineering,
                    size: 16,
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
                Chip(
                  label: Text(crew),
                  avatar: const Icon(Icons.group, size: 16),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 22, color: theme.colorScheme.primary),
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
        trailing: trailing ?? const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _syncNow() {
    // TODO: Implementar sync manual
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema de la aplicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              groupValue: ThemeMode.system, // TODO: Leer valor real
              onChanged: (value) {},
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Oscuro'),
              value: ThemeMode.dark,
              groupValue: ThemeMode.system,
              onChanged: (value) {},
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sistema (Automático)'),
              value: ThemeMode.system,
              groupValue: ThemeMode.system,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MaCElectricos',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.electrical_services, size: 48, color: Colors.blue),
      children: [
        const Text('Aplicación para gestión de infraestructura eléctrica y trabajo de campo.'),
        const SizedBox(height: 16),
        const Text('Funcionalidades:'),
        const Text('• Registro de postes, transformadores, árboles'),
        const Text('• Trabajos de poda y claros'),
        const Text('• Evidencia fotográfica con GPS'),
        const Text('• Modo offline con sincronización automática'),
        const Text('• Reportes PDF, CSV, GeoJSON, KML'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: AuthService.signOut()
              context.go('/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}