import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/admin/admin_crud_screen.dart';

class AdminBrandsScreen extends StatelessWidget {
  const AdminBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCrudScreen(
      title: 'Marcas',
      collectionName: FirestoreService.marcas,
      icon: Icons.branding_watermark,
      fields: const [
        AdminField(key: 'nombre', label: 'Nombre', required: true),
        AdminField(key: 'pais', label: 'País', required: true),
        AdminField(key: 'descripcion', label: 'Descripción', required: false),
        AdminField(key: 'activo', label: 'Activo', type: AdminFieldType.bool),
      ],
      displayColumns: ['nombre', 'pais'],
      rowBuilder: (doc, onEdit, onDelete) {
        final activo = doc['activo'] ?? true;
        return Card(
          color: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accentOrange.withAlpha(40),
              child: const Icon(Icons.branding_watermark, color: AppColors.accentOrange),
            ),
            title: Text(doc['nombre']?.toString() ?? '', style: AppTextStyles.bodyMedium),
            subtitle: Row(
              children: [
                Text(doc['pais']?.toString() ?? '', style: AppTextStyles.bodySmall),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: activo == true ? AppColors.success.withAlpha(30) : AppColors.error.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(activo == true ? 'Activo' : 'Inactivo',
                      style: TextStyle(fontSize: 10, color: activo == true ? AppColors.success : AppColors.error)),
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
