import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user.dart';
import '../../../../core/di/providers.dart';

/// Pantalla de login
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 40),

                  // Formulario de login
                  const LoginForm(),

                  const SizedBox(height: 24),

                  // Footer
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.electrical_services_rounded,
            size: 44,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),

        // Título
        Text(
          'Iniciar Sesión',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtítulo
        Text(
          'Ingresa tus credenciales para acceder',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Versión / Info
        Text(
          'MaCElectricos v1.0.0',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),

        // Enlaces
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Navegar a recuperación de contraseña
              },
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {
                // TODO: Navegar a soporte
              },
              child: const Text('Soporte'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Formulario de login con validación
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Autenticar contra el repositorio mock (o Firebase cuando esté activo)
      await ref.read(authProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      final user = ref.read(authProvider).user;
      if (user == null) {
        setState(() {
          _errorMessage = ref.read(authProvider).errorMessage ??
              'Correo o contraseña incorrectos. Verifica tus datos.';
        });
        return;
      }

      // Navegar según el rol del usuario
      if (user.role == UserRole.admin) {
        context.go('/admin');
      } else if (user.role == UserRole.supervisor) {
        context.go('/supervisor/dashboard');
      } else {
        context.go('/tecnico/dashboard');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found') || error.contains('wrong-password') || error.contains('invalid-credential')) {
      return 'Credenciales incorrectas. Verifica tu email y contraseña.';
    }
    if (error.contains('network')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    if (error.contains('too-many-requests')) {
      return 'Demasiados intentos. Intenta más tarde.';
    }
    return 'Error al iniciar sesión. Intenta nuevamente.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'tecnico@macelectricos.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El correo es obligatorio';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo Contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es obligatoria';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Recordar sesión / Olvidé contraseña
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: true, // TODO: Guardar preferencia
                    onChanged: (value) {},
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    'Recordarme',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navegar a recuperación
                },
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ],
          ),

          // Mensaje de error
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Botón Login
          FilledButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}