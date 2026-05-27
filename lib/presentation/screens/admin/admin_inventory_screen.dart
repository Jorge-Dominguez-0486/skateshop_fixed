import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/admin/admin_crud_screen.dart';

class AdminInventoryScreen extends StatelessWidget {
  const AdminInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCrudScreen(
      title: 'Inventario',
      collectionName: FirestoreService.inventario,
      icon: Icons.inventory,
      fields: const [
        AdminField(key: 'idProducto', label: 'ID Producto', required: true),
        AdminField(key: 'nombreProducto', label: 'Nombre Producto', required: true),
        AdminField(key: 'stockActual', label: 'Stock Actual', type: AdminFieldType.number, required: true),
        AdminField(key: 'stockMinimo', label: 'Stock Mínimo', type: AdminFieldType.number, required: true),
        AdminField(key: 'stockMaximo', label: 'Stock Máximo', type: AdminFieldType.number, required: true),
        AdminField(key: 'notas', label: 'Notas', required: false),
      ],
      displayColumns: ['nombreProducto', 'stockActual'],
      rowBuilder: (doc, onEdit, onDelete) {
        final stockActual = (doc['stockActual'] ?? 0).toInt();
        final stockMinimo = (doc['stockMinimo'] ?? 5).toInt();
        final bajoStock = stockActual <= stockMinimo;
        return Card(
          color: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (bajoStock ? AppColors.error : AppColors.success).withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.inventory, color: bajoStock ? AppColors.error : AppColors.success),
            ),
            title: Text(doc['nombreProducto']?.toString() ?? '', style: AppTextStyles.bodyMedium),
            subtitle: Row(
              children: [
                Text('Stock: $stockActual', style: AppTextStyles.bodySmall.copyWith(
                  color: bajoStock ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w600,
                )),
                if (bajoStock) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.error.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                    child: const Text('⚠ Stock bajo', style: TextStyle(fontSize: 10, color: AppColors.error)),
                  ),
                ],
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
