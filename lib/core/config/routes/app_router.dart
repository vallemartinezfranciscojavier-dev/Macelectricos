import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/screens/splash_screen.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../features/tecnicos/presentation/screens/tecnico_dashboard_screen.dart';
import '../../../features/mapa/presentation/screens/mapa_screen.dart';
import '../../../features/auth/presentation/screens/profile_screen.dart';
import '../../../features/postes/presentation/screens/registro_poste_screen.dart';
import '../../../features/postes/presentation/screens/detalle_poste_screen.dart';
import '../../../features/transformadores/presentation/screens/registro_transformador_screen.dart';
import '../../../features/arboles/presentation/screens/registro_arbol_screen.dart';
import '../../../features/podas/presentation/screens/registro_poda_screen.dart';
import '../../../features/claros/presentation/screens/crear_claro_screen.dart';
import '../../../features/historial/presentation/screens/historial_screen.dart';
import '../../../features/historial/presentation/screens/detalle_actividad_screen.dart';
import '../../../features/sincronizacion/presentation/screens/sincronizacion_screen.dart';
import '../../../features/supervisores/presentation/screens/supervisor_dashboard_screen.dart';
import '../../../features/supervisores/presentation/screens/supervisor_panel_screen.dart';
import '../../../features/session_tracking/presentation/session_screen.dart';
import '../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../features/admin/presentation/screens/admin_usuarios_screen.dart';
import '../../../features/admin/presentation/screens/admin_cuadrillas_screen.dart';
import '../../../features/admin/presentation/screens/admin_catalogos_screen.dart';
import '../../../features/admin/presentation/screens/admin_configuracion_screen.dart';

// Provider del router para acceso global
final appRouterProvider = Provider<GoRouter>((ref) {
  return _createRouter();
});

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash - Punto de entrada
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth flow
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell principal con bottom navigation (para usuario autenticado)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard Técnico
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tecnico/dashboard',
                name: 'tecnico-dashboard',
                builder: (context, state) => const TecnicoDashboardScreen(),
                routes: [
                  // Sesión de trabajo
                  GoRoute(
                    path: 'sesion/:sessionId',
                    name: 'session-tracking',
                    builder: (context, state) => const SessionTrackingScreen(),
                  ),
                  // Registro elementos
                  GoRoute(
                    path: 'registro/:tipo',
                    name: 'registro-elemento',
                    builder: (context, state) {
                      final tipo = state.pathParameters['tipo']!;
                      return switch (tipo) {
                        'poste' => const RegistroPosteScreen(),
                        'transformador' => const RegistroTransformadorScreen(),
                        'arbol' => const RegistroArbolScreen(),
                        'poda' => const RegistroPodaScreen(),
                        'claro' => const CrearClaroScreen(),
                        _ => _RegistroPlaceholder(tipo: tipo),
                      };
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Mapa
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mapa',
                name: 'mapa',
                builder: (context, state) => const MapaScreen(),
                routes: [
                  GoRoute(
                    path: 'detalle/:elementoId',
                    name: 'mapa-detalle',
                    builder: (context, state) {
                      final elementoId = state.pathParameters['elementoId']!;
                      return DetallePosteScreen(elementoId: elementoId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Historial
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/historial',
                name: 'historial',
                builder: (context, state) => const HistorialScreen(),
                routes: [
                  GoRoute(
                    path: 'detalle/:recordId',
                    name: 'historial-detalle',
                    builder: (context, state) {
                      final recordId = state.pathParameters['recordId']!;
                      return DetalleActividadScreen(recordId: recordId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Perfil / Configuración
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                name: 'perfil',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'configuracion',
                    name: 'configuracion',
                    builder: (context, state) => _ConfiguracionPlaceholder(),
                  ),
                  GoRoute(
                    path: 'sincronizacion',
                    name: 'sincronizacion',
                    builder: (context, state) => const SincronizacionScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Rutas para Supervisor (acceso desde dashboard)
      GoRoute(
        path: '/supervisor/dashboard',
        name: 'supervisor-dashboard',
        builder: (context, state) => const SupervisorDashboardScreen(),
        routes: [
          GoRoute(
            path: 'revision/:sessionId',
            name: 'supervisor-revision',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId']!;
              return SupervisorPanelScreen(sessionId: sessionId);
            },
          ),
          GoRoute(
            path: 'reportes',
            name: 'supervisor-reportes',
            builder: (context, state) => _SupervisorReportesPlaceholder(),
          ),
          GoRoute(
            path: 'cuadrillas',
            name: 'supervisor-cuadrillas',
            builder: (context, state) => _SupervisorCuadrillasPlaceholder(),
          ),
        ],
      ),

      // Rutas para Admin
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'usuarios',
            name: 'admin-usuarios',
            builder: (context, state) => const AdminUsuariosScreen(),
          ),
          GoRoute(
            path: 'cuadrillas',
            name: 'admin-cuadrillas',
            builder: (context, state) => const AdminCuadrillasScreen(),
          ),
          GoRoute(
            path: 'catalogos',
            name: 'admin-catalogos',
            builder: (context, state) => const AdminCatalogosScreen(),
          ),
          GoRoute(
            path: 'configuracion',
            name: 'admin-configuracion',
            builder: (context, state) => const AdminConfiguracionScreen(),
          ),
        ],
      ),
    ],

    // Redirectors (guards de autenticación/roles)
    redirect: (context, state) {
      // TODO: Implementar auth guard cuando tengamos AuthService
      // final authState = ref.read(authProvider);
      // final isLoggedIn = authState.isAuthenticated;
      // final userRole = authState.user?.role;

      // Por ahora permitir todo para desarrollo
      return null;
    },

    // Error handling
    errorBuilder: (context, state) => _ErrorScreen(error: state.error.toString()),
  );
}

/// Shell principal con BottomNavigationBar
class _MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ============================================
// PLACEHOLDERS - Pantallas vacías para Fase 2
// ============================================

class _RegistroPlaceholder extends StatelessWidget {
  final String tipo;
  const _RegistroPlaceholder({required this.tipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar: ${tipo.toUpperCase()}')),
      body: Center(child: Text('RegistroFormScreen - $tipo - Fase 3')),
    );
  }
}

class _ConfiguracionPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: const Center(child: Text('ConfiguracionScreen - Fase 3')),
    );
  }
}

class _SupervisorReportesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Supervisor')),
      body: const Center(child: Text('SupervisorReportesScreen - Fase 8')),
    );
  }
}

class _SupervisorCuadrillasPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuadrillas')),
      body: const Center(child: Text('SupervisorCuadrillasScreen - Fase 6')),
    );
  }
}

class _AdminDashboardPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('AdminDashboardScreen - Fase 7')),
    );
  }
}

class _AdminUsuariosPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión Usuarios')),
      body: const Center(child: Text('AdminUsuariosScreen - Fase 7')),
    );
  }
}

class _AdminCuadrillasPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión Cuadrillas')),
      body: const Center(child: Text('AdminCuadrillasScreen - Fase 7')),
    );
  }
}

class _AdminCatalogosPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogos')),
      body: const Center(child: Text('AdminCatalogosScreen - Fase 7')),
    );
  }
}

class _AdminConfiguracionPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración Admin')),
      body: const Center(child: Text('AdminConfiguracionScreen - Fase 7')),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error de Navegación')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Página no encontrada',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/splash'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}