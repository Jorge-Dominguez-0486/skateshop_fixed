import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import 'package:badges/badges.dart' as badges;

class HamburgerDrawer extends StatelessWidget {
  const HamburgerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      width: 280,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.surfaceMedium],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.downhill_skiing, size: 40, color: AppColors.accentOrange),
                        const SizedBox(height: 4),
                        Text('SKATE SHOP', style: AppTextStyles.heading1.copyWith(fontSize: 28, letterSpacing: 3)),
                        Text('Est. 2024', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ),
                if (!auth.isLoading && auth.isLoggedIn) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accentOrange,
                          child: Text(
                            (auth.currentUser?.nombre ?? auth.currentUser?.correo ?? auth.firebaseUser?.email ?? '?')[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textOnAccent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.currentUser?.nombre ?? 'Usuario',
                                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14)),
                              if (auth.isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentOrange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Admin', style: TextStyle(fontSize: 10, color: AppColors.textOnAccent)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
                _item(context, Icons.home_outlined, 'Inicio', '/home'),
                _item(context, Icons.grid_view_outlined, 'Catálogo', '/catalog'),
                _cartItem(context),
                _item(context, Icons.receipt_long_outlined, 'Mis Pedidos', '/orders'),
                _item(context, Icons.person_outline, 'Mi Perfil', '/profile'),
                if (!auth.isLoading && auth.isAdmin) ...[
                  const Divider(color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('ADMINISTRACIÓN', style: AppTextStyles.label.copyWith(fontSize: 11)),
                  ),
                  _item(context, Icons.bolt, 'Panel Admin', '/admin'),
                ],
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
            onTap: () {
              auth.logout();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: AppColors.accentOrange),
      title: Text(title, style: AppTextStyles.bodyLarge),
      selected: isSelected,
      selectedTileColor: AppColors.accentOrange.withAlpha(38),
      onTap: () {
        Navigator.pop(context);
        if (currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }

  Widget _cartItem(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) => ListTile(
        leading: const Icon(Icons.shopping_cart_outlined, color: AppColors.accentOrange),
        title: Row(
          children: [
            Text('Mi Carrito', style: AppTextStyles.bodyLarge),
            if (cart.itemCount > 0) ...[
              const SizedBox(width: 8),
              badges.Badge(
                badgeContent: Text('${cart.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.accentOrange),
                child: const SizedBox.shrink(),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/cart');
        },
      ),
    );
  }
}
