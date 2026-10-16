import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para registrar podas realizadas en árboles
class RegistroPodaScreen extends ConsumerStatefulWidget {
  const RegistroPodaScreen({super.key});

  @override
  ConsumerState<RegistroPodaScreen> createState() =>
      _RegistroPodaScreenState();
}

class _RegistroPodaScreenState extends ConsumerState<RegistroPodaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arbolController = TextEditingController();
  final _tipoController = TextEditingController();
  final _tecnicoController = TextEditingController();

  String _estado = 'completada'; // completada, parcial, pendiente
  bool _isLoading = false;

  @override
  void dispose() {
    _arbolController.dispose();
    _tipoController.dispose();
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
        const SnackBar(content: Text('Poda registrada exitosamente')),
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
      appBar: AppBar(title: const Text('Registrar Poda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _arbolController,
                decoration: const InputDecoration(
                  labelText: 'Árbol Afectado',
                  hintText: 'ID o ubicación del árbol',
                  prefixIcon: Icon(Icons.local_florist),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Poda',
                  hintText: 'Ligera, Moderada, Severa',
                  prefixIcon: Icon(Icons.content_cut),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tecnicoController,
                decoration: const InputDecoration(
                  labelText: 'Técnico',
                  hintText: 'Nombre del técnico responsable',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),
              Text('Estado de la Poda', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(label: Text('Completada'), value: 'completada'),
                  ButtonSegment(label: Text('Parcial'), value: 'parcial'),
                  ButtonSegment(label: Text('Pendiente'), value: 'pendiente'),
                ],
                selected: {_estado},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _estado = newSelection.first);
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
                    : const Text('Registrar Poda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
