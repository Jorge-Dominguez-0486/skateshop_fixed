import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../common/confirm_dialog.dart';

enum AdminFieldType { text, number, bool, dropdown, date, image }

class AdminField {
  final String key;
  final String label;
  final AdminFieldType type;
  final List<String>? options;
  final bool required;

  const AdminField({
    required this.key,
    required this.label,
    this.type = AdminFieldType.text,
    this.options,
    this.required = true,
  });
}

class AdminCrudScreen extends StatefulWidget {
  final String title;
  final String collectionName;
  final List<AdminField> fields;
  final List<String> displayColumns;
  final Widget Function(Map<String, dynamic>, VoidCallback onEdit, VoidCallback onDelete) rowBuilder;
  final IconData icon;

  const AdminCrudScreen({
    super.key,
    required this.title,
    required this.collectionName,
    required this.fields,
    required this.displayColumns,
    required this.rowBuilder,
    this.icon = Icons.folder,
  });

  @override
  State<AdminCrudScreen> createState() => _AdminCrudScreenState();
}

class _AdminCrudScreenState extends State<AdminCrudScreen> {
  final _firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  Map<String, dynamic>? _editingDoc;

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _initControllers([Map<String, dynamic>? data]) {
    _controllers.values.forEach((c) => c.dispose());
    _controllers.clear();
    for (final field in widget.fields) {
      final value = data?[field.key];
      _controllers[field.key] = TextEditingController(
        text: value?.toString() ?? (field.type == AdminFieldType.bool ? '' : ''),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{};
      for (final field in widget.fields) {
        if (field.type == AdminFieldType.bool) {
          data[field.key] = false; // handled separately via switch
        } else {
          data[field.key] = _controllers[field.key]?.text ?? '';
        }
      }
      // Apply bool values from the separate tracking map
      for (final field in widget.fields.where((f) => f.type == AdminFieldType.bool)) {
        data[field.key] = _boolValues[field.key] ?? false;
      }
      // Convert number fields
      for (final field in widget.fields.where((f) => f.type == AdminFieldType.number)) {
        final parsed = double.tryParse(data[field.key]?.toString() ?? '');
        data[field.key] = (parsed != null && parsed == parsed.roundToDouble())
            ? parsed.toInt()
            : (parsed ?? 0);
      }
      if (_editingDoc != null) {
        await _firestore.update(widget.collectionName, _editingDoc!['id'], data);
      } else {
        await _firestore.add(widget.collectionName, data);
      }
      Navigator.pop(context);
      Helpers.showSnackBar(context, _editingDoc != null ? 'Actualizado correctamente' : 'Creado correctamente');
    } catch (e) {
      Helpers.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, bool> _boolValues = {};

  void _showForm([Map<String, dynamic>? doc]) {
    _editingDoc = doc;
    _isUploadingImage = false;
    _initControllers(doc);
    _boolValues = {};
    for (final field in widget.fields.where((f) => f.type == AdminFieldType.bool)) {
      _boolValues[field.key] = doc?[field.key] ?? false;
    }
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  doc != null ? 'Editar ${widget.title}' : 'Nuevo ${widget.title}',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 20),
                ...widget.fields.map(_buildField),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('GUARDAR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(AdminField field) {
    switch (field.type) {
      case AdminFieldType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(labelText: field.label),
            validator: field.required ? (v) => (v == null || v.trim().isEmpty) ? '${field.label} es requerido' : null : null,
          ),
        );
      case AdminFieldType.number:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(labelText: field.label),
            keyboardType: TextInputType.number,
            validator: field.required ? (v) {
              if (v == null || v.trim().isEmpty) return '${field.label} es requerido';
              if (double.tryParse(v) == null) return 'Ingresa un número válido';
              return null;
            } : null,
          ),
        );
      case AdminFieldType.bool:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SwitchListTile(
            title: Text(field.label, style: AppTextStyles.bodyMedium),
            value: _boolValues[field.key] ?? false,
            activeColor: AppColors.accentOrange,
            onChanged: (v) => setState(() => _boolValues[field.key] = v),
          ),
        );
      case AdminFieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: _controllers[field.key]?.text.isNotEmpty == true ? _controllers[field.key]!.text : null,
            decoration: InputDecoration(labelText: field.label),
            items: (field.options ?? []).map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) => _controllers[field.key]?.text = v ?? '',
            validator: field.required ? (v) => v == null ? '${field.label} es requerido' : null : null,
          ),
        );
      case AdminFieldType.date:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(labelText: field.label, suffixIcon: const Icon(Icons.calendar_today)),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                _controllers[field.key]?.text = Helpers.formatDate(date);
              }
            },
          ),
        );
      case AdminFieldType.image:
        return _buildImageField(field);
    }
  }

  bool _isUploadingImage = false;

  Widget _buildImageField(AdminField field) {
    final controller = _controllers[field.key]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.text.isNotEmpty)
            Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.network(controller.text, width: double.infinity, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: AppColors.textSecondary))),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => controller.clear(),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field.label,
              hintText: 'URL de la imagen o pega un link de GitHub',
            ),
            validator: null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: _isUploadingImage
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentOrange))
                      : const Icon(Icons.photo_library, size: 18),
                  label: const Text('Galería', style: TextStyle(fontSize: 12)),
                  onPressed: _isUploadingImage ? null : () async {
                    setState(() => _isUploadingImage = true);
                    try {
                      final url = await CloudinaryService.pickFromGallery();
                      if (url != null) controller.text = url;
                    } catch (e) {
                      Helpers.showSnackBar(context, 'Error al subir imagen: $e', isError: true);
                    } finally {
                      if (mounted) setState(() => _isUploadingImage = false);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: _isUploadingImage
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentOrange))
                      : const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Cámara', style: TextStyle(fontSize: 12)),
                  onPressed: _isUploadingImage ? null : () async {
                    setState(() => _isUploadingImage = true);
                    try {
                      final url = await CloudinaryService.pickFromCamera();
                      if (url != null) controller.text = url;
                    } catch (e) {
                      Helpers.showSnackBar(context, 'Error al subir imagen: $e', isError: true);
                    } finally {
                      if (mounted) setState(() => _isUploadingImage = false);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: _isUploadingImage
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentOrange))
                      : const Icon(Icons.link, size: 18),
                  label: const Text('Descargar', style: TextStyle(fontSize: 12)),
                  onPressed: _isUploadingImage ? null : () async {
                    final url = controller.text.trim();
                    if (url.isEmpty) {
                      Helpers.showSnackBar(context, 'Escribe una URL primero', isError: true);
                      return;
                    }
                    setState(() => _isUploadingImage = true);
                    try {
                      final cloudUrl = await CloudinaryService.uploadFromUrl(url);
                      if (cloudUrl != null) controller.text = cloudUrl;
                    } catch (e) {
                      Helpers.showSnackBar(context, 'Error al descargar imagen: $e', isError: true);
                    } finally {
                      if (mounted) setState(() => _isUploadingImage = false);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.streamAll(widget.collectionName),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentOrange));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 80, color: AppColors.textSecondary.withAlpha(80)),
                  const SizedBox(height: 16),
                  Text('Sin registros', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('AGREGAR'),
                    onPressed: () => _showForm(),
                  ),
                ],
              ),
            );
          }
          final docs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Dismissible(
                    key: ValueKey(doc['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      final ok = await ConfirmDialog.show(
                        context,
                        titulo: '¿Confirmar eliminación?',
                        mensaje: 'Esta acción no se puede deshacer.',
                        textoConfirmar: 'ELIMINAR',
                        peligroso: true,
                      );
                      return ok ?? false;
                    },
                    onDismissed: (_) async {
                      try {
                        await _firestore.delete(widget.collectionName, doc['id']);
                        Helpers.showSnackBar(context, 'Eliminado correctamente');
                      } catch (e) {
                        Helpers.showSnackBar(context, 'Error al eliminar: $e', isError: true);
                      }
                    },
                    child: widget.rowBuilder(doc, () => _showForm(doc), () async {
                      final ok = await ConfirmDialog.show(
                        context,
                        titulo: '¿Confirmar eliminación?',
                        mensaje: 'Esta acción no se puede deshacer.',
                        textoConfirmar: 'ELIMINAR',
                        peligroso: true,
                      );
                      if (ok == true) {
                        try {
                          await _firestore.delete(widget.collectionName, doc['id']);
                          Helpers.showSnackBar(context, 'Eliminado correctamente');
                        } catch (e) {
                          Helpers.showSnackBar(context, 'Error al eliminar: $e', isError: true);
                        }
                      }
                    }),
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
