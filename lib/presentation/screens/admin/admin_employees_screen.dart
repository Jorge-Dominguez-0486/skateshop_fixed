import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/admin/admin_crud_screen.dart';

class AdminEmployeesScreen extends StatelessWidget {
  const AdminEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCrudScreen(
      title: 'Empleados',
      collectionName: FirestoreService.empleados,
      icon: Icons.badge,
      fields: const [
        AdminField(key: 'nombre', label: 'Nombre', required: true),
        AdminField(key: 'puesto', label: 'Puesto', type: AdminFieldType.dropdown, options: ['Vendedor', 'Gerente', 'Almacenista', 'Cajero'], required: true),
        AdminField(key: 'sueldo', label: 'Sueldo', type: AdminFieldType.number, required: true),
        AdminField(key: 'telefono', label: 'Teléfono', required: true),
        AdminField(key: 'correo', label: 'Correo', required: false),
        AdminField(key: 'activo', label: 'Activo', type: AdminFieldType.bool),
      ],
      displayColumns: ['nombre', 'puesto', 'sueldo'],
      rowBuilder: (doc, onEdit, onDelete) {
        final activo = doc['activo'] ?? true;
        return Card(
          color: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accentOrange.withAlpha(40),
              child: const Icon(Icons.badge, color: AppColors.accentOrange),
            ),
            title: Row(
              children: [
                Text(doc['nombre']?.toString() ?? '', style: AppTextStyles.bodyMedium),
                const Spacer(),
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
            subtitle: Text('${doc['puesto'] ?? ''} · \$${(doc['sueldo'] ?? 0).toDouble().toStringAsFixed(2)}', style: AppTextStyles.bodySmall),
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
