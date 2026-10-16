import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para registrar árboles cercanos a las líneas eléctricas
class RegistroArbolScreen extends ConsumerStatefulWidget {
  const RegistroArbolScreen({super.key});

  @override
  ConsumerState<RegistroArbolScreen> createState() =>
      _RegistroArbolScreenState();
}

class _RegistroArbolScreenState extends ConsumerState<RegistroArbolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _especieController = TextEditingController();
  final _alturaController = TextEditingController();
  final _distanciaController = TextEditingController();

  String _riesgo = 'bajo'; // bajo, medio, alto
  bool _isLoading = false;

  @override
  void dispose() {
    _especieController.dispose();
    _alturaController.dispose();
    _distanciaController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Árbol registrado exitosamente')),
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
      appBar: AppBar(title: const Text('Registrar Árbol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _especieController,
                decoration: const InputDecoration(
                  labelText: 'Especie',
                  hintText: 'Eucalipto, Pino, Roble, etc.',
                  prefixIcon: Icon(Icons.local_florist),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alturaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Altura (metros)',
                  hintText: '15.5',
                  prefixIcon: Icon(Icons.height),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanciaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distancia a línea (metros)',
                  hintText: '2.5',
                  prefixIcon: Icon(Icons.straighten),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),
              Text('Nivel de Riesgo', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(label: Text('Bajo'), value: 'bajo'),
                  ButtonSegment(label: Text('Medio'), value: 'medio'),
                  ButtonSegment(label: Text('Alto'), value: 'alto'),
                ],
                selected: {_riesgo},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _riesgo = newSelection.first);
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
                    : const Text('Registrar Árbol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
