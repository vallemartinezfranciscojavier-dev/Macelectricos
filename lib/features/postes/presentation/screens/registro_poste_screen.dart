import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Pantalla para registrar un poste de la red eléctrica
class RegistroPosteScreen extends ConsumerStatefulWidget {
  const RegistroPosteScreen({super.key});

  @override
  ConsumerState<RegistroPosteScreen> createState() => _RegistroPosteScreenState();
}

class _RegistroPosteScreenState extends ConsumerState<RegistroPosteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _estadoController = TextEditingController();
  final _ubicacionController = TextEditingController();

  List<XFile> _fotos = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _tipoController.dispose();
    _alturaController.dispose();
    _estadoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() => _fotos.add(foto));
    }
  }

  Future<void> _registrarPoste() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Guardar en repositorio
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poste registrado exitosamente')),
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
      appBar: AppBar(title: const Text('Registrar Poste')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de Poste
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Poste',
                  hintText: 'Concreto, Acero, Madera',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Altura
              TextFormField(
                controller: _alturaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Altura (metros)',
                  hintText: '10.5',
                  prefixIcon: Icon(Icons.height),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Estado
              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  hintText: 'Bueno, Regular, Malo',
                  prefixIcon: Icon(Icons.info_outlined),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Ubicación GPS
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación GPS',
                  hintText: 'Lat, Lon',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),

              // Fotos
              Text(
                'Fotos (${_fotos.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto'),
              ),
              const SizedBox(height: 24),

              // Botón Registrar
              ElevatedButton(
                onPressed: _isLoading ? null : _registrarPoste,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar Poste'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
