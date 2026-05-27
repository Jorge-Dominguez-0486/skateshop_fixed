import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/category_model.dart';
import '../../widgets/common/confirm_dialog.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  static const _iconOptions = [
    {'value': 'skateboarding', 'label': 'Skateboard', 'icon': Icons.skateboarding},
    {'value': 'checkroom', 'label': 'Ropa', 'icon': Icons.checkroom},
    {'value': 'settings', 'label': 'Accesorios', 'icon': Icons.settings},
    {'value': 'directions_run', 'label': 'Tenis / Calzado', 'icon': Icons.directions_run},
    {'value': 'star', 'label': 'Destacados', 'icon': Icons.star},
    {'value': 'new_releases', 'label': 'Novedades', 'icon': Icons.new_releases},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreService.categorias)
            .orderBy('orden')
            .snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentOrange));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.category, size: 80, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('Sin categorías', style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snapshot.data!.docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final cat = CategoryModel.fromMap(data);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  color: AppColors.surfaceDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentOrange.withAlpha(30),
                      child: Icon(cat.iconData, color: AppColors.accentOrange),
                    ),
                    title: Text(cat.nombre, style: AppTextStyles.bodyMedium),
                    subtitle: Row(
                      children: [
                        Text(cat.descripcion, style: AppTextStyles.bodySmall),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cat.activo ? AppColors.success.withAlpha(30) : AppColors.error.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(cat.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(fontSize: 10, color: cat.activo ? AppColors.success : AppColors.error)),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('#${cat.orden}',
                              style: const TextStyle(fontSize: 10, color: AppColors.accentOrange)),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                      onSelected: (v) {
                        if (v == 'editar') {
                          _mostrarFormulario(context, data: data);
                        } else if (v == 'eliminar') {
                          _eliminarCategoria(context, data['id'], cat.nombre);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'editar', child: ListTile(
                          leading: Icon(Icons.edit, color: AppColors.accentOrange),
                          title: Text('Editar', style: TextStyle(color: AppColors.textPrimary)),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        )),
                        const PopupMenuItem(value: 'eliminar', child: ListTile(
                          leading: Icon(Icons.delete, color: AppColors.error),
                          title: Text('Eliminar', style: TextStyle(color: AppColors.error)),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        )),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: AppColors.textOnAccent,
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Map<String, dynamic>? data}) {
    final isEdit = data != null;
    final nombreCtrl = TextEditingController(text: data?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: data?['descripcion'] ?? '');
    final ordenCtrl = TextEditingController(text: '${data?['orden'] ?? 1}');
    final formKey = GlobalKey<FormState>();
    String iconoSeleccionado = data?['icono'] ?? 'skateboarding';
    bool activo = data?['activo'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (_, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16, right: 16, top: 16,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text(isEdit ? 'Editar Categoría' : 'Nueva Categoría', style: AppTextStyles.heading2)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Mínimo 2 caracteres' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: iconoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Icono'),
                      items: _iconOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['value'] as String,
                          child: Row(
                            children: [
                              Icon(opt['icon'] as IconData, size: 20, color: AppColors.accentOrange),
                              const SizedBox(width: 8),
                              Text(opt['label'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => iconoSeleccionado = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ordenCtrl,
                      decoration: const InputDecoration(labelText: 'Orden'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Número válido > 0';
                        return null;
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Activo'),
                      value: activo,
                      onChanged: (v) => setModalState(() => activo = v),
                      activeColor: AppColors.accentOrange,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: AppColors.textOnAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final db = FirebaseFirestore.instance;
                          final col = FirestoreService.categorias;
                          try {
                            if (isEdit) {
                              await db.collection(col).doc(data!['id']).update({
                                'nombre': nombreCtrl.text.trim(),
                                'descripcion': descCtrl.text.trim(),
                                'icono': iconoSeleccionado,
                                'orden': int.parse(ordenCtrl.text.trim()),
                                'activo': activo,
                              });
                              Helpers.showSnackBar(ctx, 'Categoría actualizada');
                            } else {
                              final ref = db.collection(col).doc();
                              await ref.set({
                                'id': ref.id,
                                'nombre': nombreCtrl.text.trim(),
                                'descripcion': descCtrl.text.trim(),
                                'icono': iconoSeleccionado,
                                'orden': int.parse(ordenCtrl.text.trim()),
                                'activo': activo,
                                'fechaCreacion': FieldValue.serverTimestamp(),
                              });
                              Helpers.showSnackBar(ctx, 'Categoría creada');
                            }
                            Navigator.pop(ctx);
                          } catch (e) {
                            Helpers.showSnackBar(ctx, 'Error: $e', isError: true);
                          }
                        },
                        child: Text(isEdit ? 'GUARDAR CAMBIOS' : 'GUARDAR'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _eliminarCategoria(BuildContext context, String id, String nombre) async {
    final ok = await ConfirmDialog.show(context, mensaje: '¿Eliminar categoría "$nombre"?');
    if (ok == true) {
      try {
        await FirebaseFirestore.instance.collection(FirestoreService.categorias).doc(id).delete();
        Helpers.showSnackBar(context, 'Categoría eliminada');
      } catch (e) {
        Helpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }
}
