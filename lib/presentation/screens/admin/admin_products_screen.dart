import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/firestore_service.dart';
import '../../../core/utils/helpers.dart' as helpers;
import '../../widgets/admin/admin_crud_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<String> _categoriaOptions = ['Skateboard', 'Ropa', 'Accesorios', 'Tenis'];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreService.categorias)
          .where('activo', isEqualTo: true)
          .orderBy('orden')
          .get();
      if (snapshot.docs.isNotEmpty) {
        final cats = snapshot.docs.map((d) => d['nombre']?.toString() ?? '').where((n) => n.isNotEmpty).toList();
        if (cats.isNotEmpty && mounted) {
          setState(() => _categoriaOptions = cats);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudScreen(
      title: 'Productos',
      collectionName: FirestoreService.productos,
      icon: Icons.inventory_2,
      fields: [
        const AdminField(key: 'nombre', label: 'Nombre', required: true),
        AdminField(key: 'categoria', label: 'Categoría', type: AdminFieldType.dropdown, options: _categoriaOptions, required: true),
        const AdminField(key: 'marca', label: 'Marca', required: true),
        const AdminField(key: 'precio', label: 'Precio', type: AdminFieldType.number, required: true),
        const AdminField(key: 'stock', label: 'Stock', type: AdminFieldType.number, required: true),
        const AdminField(key: 'talla', label: 'Talla', required: false),
        const AdminField(key: 'color', label: 'Color', required: true),
        const AdminField(key: 'material', label: 'Material', required: true),
        const AdminField(key: 'imageUrl', label: 'Imagen', type: AdminFieldType.image, required: false),
        const AdminField(key: 'activo', label: 'Activo', type: AdminFieldType.bool),
      ],
      displayColumns: ['nombre', 'precio', 'stock', 'categoria'],
      rowBuilder: (doc, onEdit, onDelete) {
        final stock = doc['stock'] ?? 0;
        return Card(
          color: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 50,
                height: 50,
                color: AppColors.divider,
                child: doc['imageUrl'] != null && doc['imageUrl'].toString().isNotEmpty
                    ? Image.network(doc['imageUrl'].toString(), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, color: AppColors.accentOrange))
                    : const Icon(Icons.inventory_2, color: AppColors.accentOrange),
              ),
            ),
            title: Text(doc['nombre']?.toString() ?? '', style: AppTextStyles.bodyMedium),
            subtitle: Row(
              children: [
                Text(helpers.Helpers.formatCurrency((doc['precio'] ?? 0).toDouble()), style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accentOrange)),
                const SizedBox(width: 8),
                Text('Stock: $stock', style: AppTextStyles.bodySmall),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(doc['categoria']?.toString() ?? '', style: const TextStyle(fontSize: 10, color: AppColors.accentOrange)),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: AppColors.accentOrange, size: 20), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete, color: AppColors.error, size: 20), onPressed: onDelete),
              ],
            ),
          ),
        );
      },
    );
  }
}
