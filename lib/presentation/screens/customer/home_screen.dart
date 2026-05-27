import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/products_provider.dart';
import '../../widgets/common/hamburger_drawer.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/product/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      drawer: const HamburgerDrawer(),
      appBar: CustomAppBar(title: 'SK8 SHOP', showCart: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.accentOrange, Color(0xFFFF8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NUEVA TEMPORADA', style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    letterSpacing: 0.8, color: AppColors.accentYellow,
                  )),
                  const SizedBox(height: 8),
                  Text('Todo para tu', style: AppTextStyles.heading2),
                  Text('ESTILO SKATE', style: GoogleFonts.rajdhani(
                    fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textOnAccent,
                  )),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textOnAccent,
                      foregroundColor: AppColors.accentOrange,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/catalog'),
                    child: const Text('VER CATÁLOGO'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Categorías', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _categoryChip(context, 'Skateboard', '🛹'),
                  _categoryChip(context, 'Ropa', '👕'),
                  _categoryChip(context, 'Accesorios', '⚙️'),
                  _categoryChip(context, 'Tenis', '👟'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Destacados', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Consumer<ProductsProvider>(
              builder: (_, productsProv, __) {
                final destacados = productsProv.products.where((p) => p.activo).take(6).toList();
                if (productsProv.isLoading) {
                  return GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(4, (_) => const _ShimmerCard()),
                  );
                }
                if (destacados.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      message: 'No hay productos disponibles',
                    ),
                  );
                }
                return GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 0.68,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: destacados.map((p) => ProductCard(product: p)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceMedium,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('¿Eres administrador?', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  if (auth.isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/admin'),
                        child: const Text('Panel de Administración'),
                      ),
                    )
                  else
                    Text('Inicia sesión o regístrate para acceder al panel',
                        style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(BuildContext context, String label, String emoji) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/catalog', arguments: label),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceDark,
      child: Column(
        children: [
          Expanded(flex: 3, child: Container(
            decoration: const BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          )),
          Expanded(flex: 2, child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: double.infinity, color: AppColors.divider),
                SizedBox(height: 6),
                Container(height: 10, width: 60, color: AppColors.divider),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
