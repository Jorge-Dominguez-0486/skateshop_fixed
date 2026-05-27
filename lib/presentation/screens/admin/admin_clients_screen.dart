import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/admin/admin_crud_screen.dart';

class AdminClientsScreen extends StatelessWidget {
  const AdminClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCrudScreen(
      title: 'Clientes',
      collectionName: FirestoreService.clientes,
      icon: Icons.people,
      fields: const [
        AdminField(key: 'nombre', label: 'Nombre', required: true),
        AdminField(key: 'telefono', label: 'Teléfono', required: true),
        AdminField(key: 'correo', label: 'Correo', required: true),
        AdminField(key: 'calle', label: 'Calle', required: false),
        AdminField(key: 'ciudad', label: 'Ciudad', required: false),
        AdminField(key: 'estado', label: 'Estado', required: false),
        AdminField(key: 'frecuente', label: 'Cliente Frecuente', type: AdminFieldType.bool),
      ],
      displayColumns: ['nombre', 'correo', 'telefono'],
      rowBuilder: (doc, onEdit, onDelete) {
        final frecuente = doc['frecuente'] ?? false;
        return Card(
          color: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accentOrange.withAlpha(40),
              child: const Icon(Icons.person, color: AppColors.accentOrange),
            ),
            title: Text(doc['nombre']?.toString() ?? '', style: AppTextStyles.bodyMedium),
            subtitle: Row(
              children: [
                Text(doc['correo']?.toString() ?? '', style: AppTextStyles.bodySmall),
                if (frecuente == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.accentYellow.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Frecuente', style: TextStyle(fontSize: 10, color: AppColors.accentYellow)),
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
