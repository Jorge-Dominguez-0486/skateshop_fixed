import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class CrudFormDialog extends StatelessWidget {
  final String titulo;
  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback? onCancel;

  const CrudFormDialog({
    super.key,
    required this.titulo,
    required this.fields,
    required this.onSave,
    this.onCancel,
  });

  static Future<void> show(BuildContext context, {
    required String titulo,
    required List<Widget> fields,
    required VoidCallback onSave,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CrudFormDialog(titulo: titulo, fields: fields, onSave: onSave),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo, style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      onSave();
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
