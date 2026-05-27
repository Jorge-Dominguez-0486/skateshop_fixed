import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSalesScreen extends StatelessWidget {
  const AdminSalesScreen({super.key});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Completada': return AppColors.success;
      case 'Cancelada': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  Future<void> _cambiarEstado(BuildContext context, String id, String nuevoEstado) async {
    try {
      await FirebaseFirestore.instance.collection(FirestoreService.ventas).doc(id).update({'estado': nuevoEstado});
      Helpers.showSnackBar(context, 'Estado actualizado a $nuevoEstado');
    } catch (e) {
      Helpers.showSnackBar(context, 'Error: $e', isError: true);
    }
  }

  Future<void> _eliminarVenta(BuildContext context, String id) async {
    final ok = await ConfirmDialog.show(context, mensaje: '¿Eliminar esta venta?');
    if (ok == true) {
      try {
        await FirebaseFirestore.instance.collection(FirestoreService.ventas).doc(id).delete();
        Helpers.showSnackBar(context, 'Venta eliminada');
      } catch (e) {
        Helpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreService.ventas)
            .orderBy('fechaVenta', descending: true)
            .snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text('Error al cargar ventas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentOrange));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('Sin ventas', style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }
          final docs = snapshot.data!.docs;
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final rawFecha = data['fechaVenta'];
            DateTime? fecha;
            if (rawFecha is Timestamp) {
              fecha = rawFecha.toDate();
            } else if (rawFecha is DateTime) {
              fecha = rawFecha;
            }
            final key = Helpers.formatDate(fecha ?? DateTime.now());
            grouped.putIfAbsent(key, () => []).add(data);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key, style: AppTextStyles.heading3),
                  ),
                  ...entry.value.map((data) {
                    final estado = data['estado']?.toString() ?? 'Pendiente';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        color: AppColors.surfaceDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.receipt, color: AppColors.accentOrange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(data['nombreCliente']?.toString() ?? '', style: AppTextStyles.bodyMedium),
                                  const Spacer(),
                                  Text(Helpers.formatCurrency((data['total'] ?? 0).toDouble()), style: GoogleFonts.rajdhani(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accentOrange)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${data['metodoPago'] ?? ''}', style: AppTextStyles.bodySmall),
                                  const Spacer(),
                                  DropdownButton<String>(
                                    value: estado,
                                    underline: const SizedBox(),
                                    isDense: true,
                                    dropdownColor: AppColors.surfaceDark,
                                    style: TextStyle(fontSize: 12, color: _estadoColor(estado), fontWeight: FontWeight.w600),
                                    items: ['Pendiente', 'Completada', 'Cancelada'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                    onChanged: (v) => v != null ? _cambiarEstado(context, data['id'] ?? '', v) : null,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                                    constraints: const BoxConstraints(minWidth: 28),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _eliminarVenta(context, data['id'] ?? ''),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
