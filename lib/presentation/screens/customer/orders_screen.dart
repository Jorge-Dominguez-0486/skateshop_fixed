import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/sale_model.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/hamburger_drawer.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state_widget.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Completada':
        return AppColors.success;
      case 'Cancelada':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';
    return Scaffold(
      drawer: const HamburgerDrawer(),
      appBar: CustomAppBar(title: 'MIS PEDIDOS'),
      body: userId.isEmpty
          ? const EmptyStateWidget(icon: Icons.receipt_long, message: 'Sin pedidos aún')
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirestoreService.ventas)
                  .where('idCliente', isEqualTo: userId)
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
                          const Text('Error al cargar pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text('${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (_, __) => Card(
                      color: AppColors.surfaceDark,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Container(height: 80),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.receipt_long,
                    message: 'Sin pedidos aún',
                  );
                }
                final sales = snapshot.data!.docs
                    .map((doc) => SaleModel.fromMap(doc.data() as Map<String, dynamic>))
                    .toList()
                  ..sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sales.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final sale = sales[i];
                    return Card(
                      color: AppColors.surfaceDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.receipt, color: AppColors.accentOrange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Helpers.formatDateTime(sale.fechaVenta),
                                      style: AppTextStyles.bodySmall),
                                  const SizedBox(height: 2),
                                  Text(sale.metodoPago, style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _estadoColor(sale.estado).withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(sale.estado,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _estadoColor(sale.estado))),
                            ),
                            const SizedBox(width: 8),
                            Text(Helpers.formatCurrency(sale.total),
                                style: GoogleFonts.rajdhani(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accentOrange)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
