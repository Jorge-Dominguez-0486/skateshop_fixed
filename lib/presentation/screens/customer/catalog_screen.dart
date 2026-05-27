import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/products_provider.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/common/hamburger_drawer.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/product/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();
  bool _initialized = false;

  static const _fallbackCategories = ['Skateboard', 'Ropa', 'Accesorios', 'Tenis'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args != 'Todos') {
        context.read<ProductsProvider>().setSelectedCategory(args);
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HamburgerDrawer(),
      appBar: CustomAppBar(title: 'CATÁLOGO', showCart: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<ProductsProvider>().setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => context.read<ProductsProvider>().setSearchQuery(v),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(FirestoreService.categorias)
                .where('activo', isEqualTo: true)
                .orderBy('orden')
                .snapshots(),
            builder: (_, snapshot) {
              List<String> cats;
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                cats = ['Todos', ...snapshot.data!.docs.map((d) => d['nombre']?.toString() ?? '')];
              } else {
                cats = ['Todos', ..._fallbackCategories];
              }
              return Consumer<ProductsProvider>(
                builder: (_, prov, __) => SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cats.length,
                    itemBuilder: (_, i) {
                      final cat = cats[i];
                      final selected = (cat == 'Todos' && (prov.selectedCategory == null || prov.selectedCategory!.isEmpty))
                          || prov.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) {
                            prov.setSelectedCategory(cat == 'Todos' ? null : cat);
                          },
                          selectedColor: AppColors.accentOrange,
                          labelStyle: TextStyle(
                            color: selected ? AppColors.textOnAccent : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (_, prov, __) {
                if (prov.isLoading) {
                  return GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: List.generate(6, (_) => const _ShimmerGridCard()),
                  );
                }
                final products = prov.filteredProducts;
                if (products.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off,
                    message: 'Sin productos',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (_, cart, __) => FloatingActionButton.extended(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: AppColors.textOnAccent,
          icon: const Icon(Icons.shopping_cart),
          label: Text('Ver Carrito (${cart.itemCount})'),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }
}

class _ShimmerGridCard extends StatelessWidget {
  const _ShimmerGridCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceDark,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(color: AppColors.divider),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: double.infinity, color: AppColors.divider),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 60, color: AppColors.divider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
