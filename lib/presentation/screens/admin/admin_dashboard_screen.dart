import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/hamburger_drawer.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/admin/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _firestore = FirebaseFirestore.instance;

  Widget _countCard(String label, String collection, IconData icon, Color color) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection(collection).get(),
      builder: (_, snap) {
        final count = snap.data?.docs.length ?? 0;
        return StatCard(
          title: label,
          value: '$count',
          icon: icon,
          color: color,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      drawer: const HamburgerDrawer(),
      appBar: CustomAppBar(title: '⚡ PANEL ADMIN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: AppTextStyles.heading1),
            Text('Bienvenido, ${auth.currentUser?.nombre ?? 'Admin'}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _countCard('Productos', FirestoreService.productos, Icons.inventory_2, AppColors.accentOrange),
                _countCard('Clientes', FirestoreService.clientes, Icons.people, AppColors.accentYellow),
                _countCard('Ventas', FirestoreService.ventas, Icons.receipt_long, AppColors.success),
                _countCard('Empleados', FirestoreService.empleados, Icons.badge, AppColors.warning),
              ],
            ),
            const SizedBox(height: 24),
            Text('Gestionar', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _quickCard(Icons.inventory_2, 'Productos', '/admin/products'),
                _quickCard(Icons.people, 'Clientes', '/admin/clients'),
                _quickCard(Icons.receipt_long, 'Ventas', '/admin/sales'),
                _quickCard(Icons.badge, 'Empleados', '/admin/employees'),
                _quickCard(Icons.local_shipping, 'Proveedores', '/admin/suppliers'),
                _quickCard(Icons.inventory, 'Inventario', '/admin/inventory'),
                _quickCard(Icons.branding_watermark, 'Marcas', '/admin/brands'),
                _quickCard(Icons.category, 'Categorías', '/admin/categories'),
                _quickCard(Icons.admin_panel_settings, 'Usuarios', '/admin/users'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.accentOrange),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
