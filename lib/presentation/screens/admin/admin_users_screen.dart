import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/helpers.dart';
import '../../widgets/common/confirm_dialog.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isAdminNew = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showNewUserForm() {
    _nombreCtrl.clear();
    _correoCtrl.clear();
    _telefonoCtrl.clear();
    _passwordCtrl.clear();
    _isAdminNew = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nuevo Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _correoCtrl, decoration: const InputDecoration(labelText: 'Correo'), keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextFormField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true,
                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Administrador'),
                value: _isAdminNew,
                activeColor: AppColors.accentOrange,
                onChanged: (v) => setState(() => _isAdminNew = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _crearUsuario,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('CREAR USUARIO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.register(
        _correoCtrl.text.trim(),
        _passwordCtrl.text,
        _nombreCtrl.text.trim(),
        _telefonoCtrl.text.trim(),
      );
      // Need to get the user created to set admin. The register returns UserModel.
      // But we need the uid. Since register creates user and returns UserModel,
      // we can't directly get the uid to set isAdmin after registration.
      // Instead, we'll use a workaround: getCurrentUser after registration
      // Actually, let's just update isAdmin after registering if needed
      if (_isAdminNew) {
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null) {
          await _authService.updateUserAdminStatus(currentUser.id, true);
        }
      }
      Navigator.pop(context);
      Helpers.showSnackBar(context, 'Usuario creado correctamente');
    } catch (e) {
      Helpers.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showNewUserForm),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _authService.getAllUsers(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentOrange));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Sin usuarios', style: TextStyle(color: AppColors.textSecondary)));
          }
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (_, i) {
              final user = users[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  color: AppColors.surfaceDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentOrange.withAlpha(40),
                      child: Text(user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
                    ),
                    title: Row(
                      children: [
                        Text(user.nombre, style: AppTextStyles.bodyMedium),
                        const SizedBox(width: 8),
                        Icon(user.isAdmin ? Icons.bolt : Icons.person, size: 16, color: user.isAdmin ? AppColors.accentOrange : AppColors.textSecondary),
                      ],
                    ),
                    subtitle: Text('${user.correo} · ${user.telefono}', style: AppTextStyles.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: user.isAdmin,
                          activeColor: AppColors.accentOrange,
                          onChanged: (v) => authProv.toggleAdminStatus(user.id, v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                          onPressed: () async {
                            final ok = await ConfirmDialog.show(context, mensaje: '¿Eliminar a ${user.nombre}?');
                            if (ok == true) {
                              try {
                                await _authService.deleteUser(user.id);
                                Helpers.showSnackBar(context, 'Usuario eliminado');
                              } catch (e) {
                                Helpers.showSnackBar(context, 'Error: $e', isError: true);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
