import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/hamburger_drawer.dart';
import '../../widgets/common/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user = auth.currentUser;
    final initial = (user?.nombre ?? auth.firebaseUser?.email ?? '?')[0].toUpperCase();

    return Scaffold(
      drawer: const HamburgerDrawer(),
      appBar: CustomAppBar(title: 'MI PERFIL'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.accentOrange,
              child: Text(initial,
                  style: GoogleFonts.rajdhani(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textOnAccent)),
            ),
            const SizedBox(height: 12),
            Text(user?.nombre ?? 'Usuario', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text(user?.correo ?? auth.firebaseUser?.email ?? '', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 32),
            Card(
              color: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Nombre', style: AppTextStyles.bodySmall),
                    subtitle: Text(user?.nombre ?? '-', style: AppTextStyles.bodyMedium),
                  ),
                  const Divider(color: AppColors.divider, height: 0),
                  ListTile(
                    title: Text('Correo', style: AppTextStyles.bodySmall),
                    subtitle: Text(user?.correo ?? auth.firebaseUser?.email ?? '-', style: AppTextStyles.bodyMedium),
                  ),
                  const Divider(color: AppColors.divider, height: 0),
                  ListTile(
                    title: Text('Teléfono', style: AppTextStyles.bodySmall),
                    subtitle: Text(user?.telefono.isNotEmpty == true ? user!.telefono : '-', style: AppTextStyles.bodyMedium),
                  ),
                  const Divider(color: AppColors.divider, height: 0),
                  ListTile(
                    title: Text('Tipo de cuenta', style: AppTextStyles.bodySmall),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(auth.isAdmin ? 'Admin' : 'Cliente',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentOrange)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('CERRAR SESIÓN'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
