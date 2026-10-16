import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para gestionar usuarios del sistema
class AdminUsuariosScreen extends ConsumerStatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  ConsumerState<AdminUsuariosScreen> createState() =>
      _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends ConsumerState<AdminUsuariosScreen> {
  final _usuarios = [
    {'id': '1', 'email': 'tecnico@macelectricos.com', 'rol': 'Técnico', 'estado': 'Activo'},
    {'id': '2', 'email': 'supervisor@macelectricos.com', 'rol': 'Supervisor', 'estado': 'Activo'},
    {'id': '3', 'email': 'admin@macelectricos.com', 'rol': 'Admin', 'estado': 'Activo'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Crear nuevo usuario')),
              );
            },
            tooltip: 'Nuevo Usuario',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(usuario['email']![0].toUpperCase()),
              ),
              title: Text(usuario['email']!),
              subtitle: Text('${usuario['rol']} • ${usuario['estado']}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('Editar')),
                  const PopupMenuItem(child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
