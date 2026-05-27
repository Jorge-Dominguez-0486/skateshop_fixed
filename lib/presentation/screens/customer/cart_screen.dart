import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/common/hamburger_drawer.dart';
import '../../widgets/common/custom_app_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HamburgerDrawer(),
      appBar: CustomAppBar(title: 'MI CARRITO'),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 100,
                        color: AppColors.accentOrange.withAlpha(76)),
                    const SizedBox(height: 16),
                    Text('Tu carrito está vacío', style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text('¿Qué esperas?', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('SEGUIR COMPRANDO'),
                      onPressed: () => Navigator.pushNamed(context, '/catalog'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return Dismissible(
                      key: ValueKey(item.idProducto),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => cart.removeItem(item.idProducto),
                      child: Card(
                        color: AppColors.surfaceDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.divider,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: item.imageUrl != null
                                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                                    : const Icon(Icons.image, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.nombre, style: AppTextStyles.bodyMedium, maxLines: 2),
                                    const SizedBox(height: 4),
                                    Text(Helpers.formatCurrency(item.precio),
                                        style: AppTextStyles.bodySmall),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline,
                                              size: 20, color: AppColors.accentOrange),
                                          constraints: const BoxConstraints(minWidth: 28),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => cart.updateQuantity(item.idProducto, item.cantidad - 1),
                                        ),
                                        Text('${item.cantidad}', style: AppTextStyles.bodyLarge),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline,
                                              size: 20, color: AppColors.accentOrange),
                                          constraints: const BoxConstraints(minWidth: 28),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => cart.updateQuantity(item.idProducto, item.cantidad + 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(Helpers.formatCurrency(item.subtotal),
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 16, fontWeight: FontWeight.w700,
                                        color: AppColors.accentOrange,
                                      )),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                                    constraints: const BoxConstraints(minWidth: 28),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => cart.removeItem(item.idProducto),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMedium,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: AppTextStyles.bodyLarge),
                          Text(Helpers.formatCurrency(cart.total), style: GoogleFonts.rajdhani(
                            fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accentOrange,
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('SEGUIR COMPRANDO'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accentOrange,
                                side: const BorderSide(color: AppColors.accentOrange),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/catalog'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/checkout'),
                              child: Text('PAGAR (${Helpers.formatCurrency(cart.total)})'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
