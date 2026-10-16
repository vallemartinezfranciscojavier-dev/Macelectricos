import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para crear claros en las líneas eléctricas
class CrearClaroScreen extends ConsumerStatefulWidget {
  const CrearClaroScreen({super.key});

  @override
  ConsumerState<CrearClaroScreen> createState() => _CrearClaroScreenState();
}

class _CrearClaroScreenState extends ConsumerState<CrearClaroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ubicacionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _tecnicoController = TextEditingController();

  String _prioridad = 'media'; // baja, media, alta
  bool _isLoading = false;

  @override
  void dispose() {
    _ubicacionController.dispose();
    _descripcionController.dispose();
    _tecnicoController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claro creado exitosamente')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Claro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'Lat, Lon',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Claro',
                  hintText: 'Describe el área a despejar',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tecnicoController,
                decoration: const InputDecoration(
                  labelText: 'Técnico Asignado',
                  hintText: 'Nombre del técnico',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),
              Text('Prioridad', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(label: Text('Baja'), value: 'baja'),
                  ButtonSegment(label: Text('Media'), value: 'media'),
                  ButtonSegment(label: Text('Alta'), value: 'alta'),
                ],
                selected: {_prioridad},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _prioridad = newSelection.first);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _registrar,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear Claro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
