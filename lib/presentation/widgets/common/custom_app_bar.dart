import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCart;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showCart = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AppBar(
      title: Text(title, style: AppTextStyles.heading2),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: [
        if (showCart)
          Consumer<CartProvider>(
            builder: (_, cart, __) => badges.Badge(
              badgeContent: Text('${cart.itemCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.accentOrange),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
                onPressed: () => Navigator.pushReplacementNamed(context, '/cart'),
              ),
            ),
          ),
        if (auth.isLoggedIn && auth.isAdmin)
          IconButton(
            icon: const Icon(Icons.bolt, color: AppColors.accentOrange),
            onPressed: () => Navigator.pushReplacementNamed(context, '/admin'),
            tooltip: 'Panel Admin',
          ),
      ],
    );
  }
}
