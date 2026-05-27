import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto')),
        body: const Center(child: Text('Producto no encontrado')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product.nombre, style: AppTextStyles.heading3),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 280,
              color: AppColors.divider,
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl!, height: 280, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.downhill_skiing, size: 60, color: AppColors.textSecondary)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(product.categoria, style: const TextStyle(fontSize: 11, color: AppColors.textOnAccent, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Text(
                        product.stock > 0 ? 'Stock: ${product.stock}' : 'Agotado',
                        style: AppTextStyles.bodySmall.copyWith(color: product.stock > 0 ? AppColors.success : AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(product.nombre, style: AppTextStyles.heading2),
                  const SizedBox(height: 4),
                  Text(product.marca, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  Text(Helpers.formatCurrency(product.precio),
                      style: GoogleFonts.rajdhani(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accentOrange)),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  Text('Detalles', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  _detailRow('Color', product.color),
                  _detailRow('Material', product.material),
                  if (product.talla != null) _detailRow('Talla', product.talla!),
                  _detailRow('Disponibilidad', product.stock > 0 ? 'En stock' : 'Agotado'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.surfaceMedium,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('AGREGAR AL CARRITO'),
                  onPressed: product.stock > 0
                      ? () {
                          context.read<CartProvider>().addItem(CartItemModel(
                            idProducto: product.id,
                            nombre: product.nombre,
                            precio: product.precio,
                            cantidad: 1,
                            imageUrl: product.imageUrl,
                          ));
                          Helpers.showSnackBar(context, 'Agregado al carrito');
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  foregroundColor: AppColors.accentOrange,
                  side: const BorderSide(color: AppColors.accentOrange),
                ),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                child: const Icon(Icons.shopping_bag),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
