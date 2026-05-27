import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/products_provider.dart';
import 'core/utils/seed_data.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/customer/home_screen.dart';
import 'presentation/screens/customer/catalog_screen.dart';
import 'presentation/screens/customer/product_detail_screen.dart';
import 'presentation/screens/customer/cart_screen.dart';
import 'presentation/screens/customer/checkout_screen.dart';
import 'presentation/screens/customer/orders_screen.dart';
import 'presentation/screens/customer/profile_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/admin/admin_products_screen.dart';
import 'presentation/screens/admin/admin_clients_screen.dart';
import 'presentation/screens/admin/admin_sales_screen.dart';
import 'presentation/screens/admin/admin_employees_screen.dart';
import 'presentation/screens/admin/admin_suppliers_screen.dart';
import 'presentation/screens/admin/admin_inventory_screen.dart';
import 'presentation/screens/admin/admin_brands_screen.dart';
import 'presentation/screens/admin/admin_users_screen.dart';
import 'presentation/screens/admin/admin_categories_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseOk = false;
  final opts = DefaultFirebaseOptions.currentPlatform;
  if (opts.apiKey.isNotEmpty && opts.appId.isNotEmpty) {
    try {
      await Firebase.initializeApp(options: opts);
      firebaseOk = true;
    } catch (_) {}
  }

  if (firebaseOk && kDebugMode) {
    try {
      await insertSeedData(FirebaseFirestore.instance);
    } catch (_) {}
  }

  await initializeDateFormatting('es_MX');

  runApp(SkateShopApp(firebaseReady: firebaseOk));
}

class SkateShopApp extends StatelessWidget {
  final bool firebaseReady;
  const SkateShopApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _FirebaseSetupScreen(),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
      ],
      child: MaterialApp(
        title: 'SkateShop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('SK8', style: GoogleFonts.rajdhani(
                fontSize: 72, fontWeight: FontWeight.w700,
                color: AppColors.accentOrange,
              )),
              Text('SHOP', style: GoogleFonts.rajdhani(
                fontSize: 36, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
              const SizedBox(height: 8),
              Container(width: 60, height: 3, color: AppColors.accentOrange),
              const SizedBox(height: 40),
              const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
              const SizedBox(height: 16),
              Text('Firebase no configurado', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Ejecuta:\n  flutterfire configure --project=skateshop-app\n\ny vuelve a cargar la página.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {}, // no-op, just shows it's clickable
                icon: const Icon(Icons.refresh),
                label: const Text('RECARGAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route<dynamic>? _generateRoute(RouteSettings settings) {
  if (settings.name == '/') {
    return MaterialPageRoute(
      builder: (_) => Consumer<AuthProvider>(
        builder: (_, auth, __) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accentOrange),
              ),
            );
          }
          if (auth.isLoggedIn) return const HomeScreen();
          return const LoginScreen();
        },
      ),
    );
  }

  if (settings.name!.startsWith('/admin')) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => _AdminGuard(child: _adminScreenForRoute(settings.name!)),
    );
  }

  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/register':
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case '/catalog':
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CatalogScreen(),
      );
    case '/product-detail':
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ProductDetailScreen(),
      );
    case '/cart':
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case '/checkout':
      return MaterialPageRoute(builder: (_) => const CheckoutScreen());
    case '/orders':
      return MaterialPageRoute(builder: (_) => const OrdersScreen());
    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}

Widget _adminScreenForRoute(String route) {
  switch (route) {
    case '/admin':
      return const AdminDashboardScreen();
    case '/admin/products':
      return const AdminProductsScreen();
    case '/admin/clients':
      return const AdminClientsScreen();
    case '/admin/sales':
      return const AdminSalesScreen();
    case '/admin/employees':
      return const AdminEmployeesScreen();
    case '/admin/suppliers':
      return const AdminSuppliersScreen();
    case '/admin/inventory':
      return const AdminInventoryScreen();
    case '/admin/brands':
      return const AdminBrandsScreen();
    case '/admin/users':
      return const AdminUsersScreen();
    case '/admin/categories':
      return const AdminCategoriesScreen();
    default:
      return const AdminDashboardScreen();
  }
}

class _AdminGuard extends StatefulWidget {
  final Widget child;
  const _AdminGuard({required this.child});

  @override
  State<_AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<_AdminGuard> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
