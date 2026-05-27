import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
      child: Card(
        color: AppColors.surfaceDark,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.divider,
                    child: product.imageUrl != null
                        ? Image.network(product.imageUrl!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.downhill_skiing, size: 40, color: AppColors.textSecondary)),
                  ),
                  if (product.stock == 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Agotado', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withAlpha(230),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(product.categoria, style: const TextStyle(fontSize: 9, color: AppColors.textOnAccent, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.nombre, style: AppTextStyles.bodySmall.copyWith(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(product.marca, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          child: Text(Helpers.formatCurrency(product.precio), style: GoogleFonts.rajdhani(
                            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentOrange,
                          ), overflow: TextOverflow.ellipsis),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, size: 18, color: AppColors.accentOrange),
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (product.stock > 0) {
                              context.read<CartProvider>().addItem(CartItemModel(
                                idProducto: product.id,
                                nombre: product.nombre,
                                precio: product.precio,
                                cantidad: 1,
                                imageUrl: product.imageUrl,
                              ));
                              Helpers.showSnackBar(context, 'Agregado al carrito');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
