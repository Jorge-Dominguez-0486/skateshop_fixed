import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _firestore = FirestoreService();
  String _metodoPago = 'Efectivo';
  bool _isLoading = false;

  Future<void> _confirmarPedido() async {
    setState(() => _isLoading = true);
    try {
      final cart = context.read<CartProvider>();
      final auth = context.read<AuthProvider>();
      final sale = SaleModel(
        id: '',
        idCliente: auth.currentUser?.id ?? '',
        nombreCliente: auth.currentUser?.nombre ?? auth.firebaseUser?.email ?? '',
        productos: cart.items
            .map((item) => SaleItemModel(
                  idProducto: item.idProducto,
                  nombre: item.nombre,
                  cantidad: item.cantidad,
                  precioUnitario: item.precio,
                ))
            .toList(),
        total: cart.total,
        metodoPago: _metodoPago,
        estado: 'Completada',
      );
      await _firestore.add(FirestoreService.ventas, sale.toMap());
      cart.clearCart();
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 64, color: AppColors.success),
                const SizedBox(height: 16),
                const Text('¡Pedido realizado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Tu pedido ha sido confirmado', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(context, '/orders');
                    },
                    child: const Text('Ver mis pedidos'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(context, '/catalog');
                  },
                  child: const Text('Seguir comprando'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error al confirmar pedido: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: CustomAppBar(title: 'PAGAR'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen del pedido', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Card(
              color: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('${item.cantidad}x ${item.nombre}',
                                    style: AppTextStyles.bodyMedium, overflow: TextOverflow.ellipsis),
                              ),
                              Text(Helpers.formatCurrency(item.precio * item.cantidad),
                                  style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        )),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text(Helpers.formatCurrency(cart.total),
                            style: GoogleFonts.rajdhani(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accentOrange)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Método de pago', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _metodoPago,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.payment)),
              items: const [
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
              ],
              onChanged: (v) => setState(() => _metodoPago = v ?? 'Efectivo'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmarPedido,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('CONFIRMAR PEDIDO'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
