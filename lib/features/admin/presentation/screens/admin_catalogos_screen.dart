import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para gestionar catálogos del sistema (tipos de elementos)
class AdminCatalogosScreen extends ConsumerStatefulWidget {
  const AdminCatalogosScreen({super.key});

  @override
  ConsumerState<AdminCatalogosScreen> createState() =>
      _AdminCatalogosScreenState();
}

class _AdminCatalogosScreenState extends ConsumerState<AdminCatalogosScreen> {
  String _selectedCatalogo = 'postes';

  final _catalogos = {
    'postes': [
      {'id': '1', 'nombre': 'Poste Concreto 10m', 'estado': 'Activo'},
      {'id': '2', 'nombre': 'Poste Acero 12m', 'estado': 'Activo'},
      {'id': '3', 'nombre': 'Poste Madera 8m', 'estado': 'Inactivo'},
    ],
    'transformadores': [
      {'id': '1', 'nombre': 'Distribución 100kVA', 'estado': 'Activo'},
      {'id': '2', 'nombre': 'Potencia 250kVA', 'estado': 'Activo'},
    ],
    'arboles': [
      {'id': '1', 'nombre': 'Eucalipto', 'estado': 'Activo'},
      {'id': '2', 'nombre': 'Pino', 'estado': 'Activo'},
      {'id': '3', 'nombre': 'Roble', 'estado': 'Activo'},
    ],
    'podas': [
      {'id': '1', 'nombre': 'Ligera', 'estado': 'Activo'},
      {'id': '2', 'nombre': 'Moderada', 'estado': 'Activo'},
      {'id': '3', 'nombre': 'Severa', 'estado': 'Activo'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _catalogos[_selectedCatalogo] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agregar nuevo elemento')),
              );
            },
            tooltip: 'Agregar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs de catálogos
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCatalogoTab('postes', 'Postes'),
                  const SizedBox(width: 8),
                  _buildCatalogoTab('transformadores', 'Transformadores'),
                  const SizedBox(width: 8),
                  _buildCatalogoTab('arboles', 'Árboles'),
                  const SizedBox(width: 8),
                  _buildCatalogoTab('podas', 'Podas'),
                ],
              ),
            ),
          ),
          // Lista de elementos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    title: Text(item['nombre']!),
                    trailing: Chip(
                      label: Text(item['estado']!),
                      backgroundColor: item['estado'] == 'Activo'
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Editar: ${item['nombre']}')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogoTab(String value, String label) {
    final isSelected = _selectedCatalogo == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedCatalogo = value);
      },
    );
  }
}
