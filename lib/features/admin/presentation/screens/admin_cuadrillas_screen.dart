import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para gestionar cuadrillas de trabajo
class AdminCuadrillasScreen extends ConsumerStatefulWidget {
  const AdminCuadrillasScreen({super.key});

  @override
  ConsumerState<AdminCuadrillasScreen> createState() =>
      _AdminCuadrillasScreenState();
}

class _AdminCuadrillasScreenState extends ConsumerState<AdminCuadrillasScreen> {
  final _cuadrillas = [
    {'nombre': 'Cuadrilla A', 'supervisor': 'Juan García', 'tecnicos': '5', 'estado': 'Activa'},
    {'nombre': 'Cuadrilla B', 'supervisor': 'María López', 'tecnicos': '4', 'estado': 'Activa'},
    {'nombre': 'Cuadrilla C', 'supervisor': 'Pedro Martínez', 'tecnicos': '6', 'estado': 'Inactiva'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Cuadrillas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Crear nueva cuadrilla')),
              );
            },
            tooltip: 'Nueva Cuadrilla',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cuadrillas.length,
        itemBuilder: (context, index) {
          final cuadrilla = _cuadrillas[index];
          final estaActiva = cuadrilla['estado'] == 'Activa';

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: estaActiva ? Colors.green : Colors.grey,
                child: const Icon(Icons.groups, color: Colors.white),
              ),
              title: Text(cuadrilla['nombre'] ?? ''),
              subtitle: Text(
                'Supervisor: ${cuadrilla['supervisor'] ?? ''}\nTécnicos: ${cuadrilla['tecnicos'] ?? ''}',
              ),
              isThreeLine: true,
              trailing: Chip(
                label: Text(cuadrilla['estado'] ?? ''),
                backgroundColor: estaActiva ? Colors.green.shade100 : Colors.grey.shade200,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ver detalles: ${cuadrilla['nombre']}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

