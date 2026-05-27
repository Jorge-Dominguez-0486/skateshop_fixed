import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;
  final bool peligroso;

  const ConfirmDialog({
    super.key,
    this.titulo = 'Confirmar',
    required this.mensaje,
    this.textoConfirmar = 'Confirmar',
    this.textoCancelar = 'Cancelar',
    this.peligroso = false,
  });

  static Future<bool?> show(BuildContext context, {
    String titulo = '¿Confirmar eliminación?',
    required String mensaje,
    String textoConfirmar = 'ELIMINAR',
    String textoCancelar = 'CANCELAR',
    bool peligroso = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar,
        textoCancelar: textoCancelar,
        peligroso: peligroso,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
          const SizedBox(height: 16),
          Text(titulo, style: AppTextStyles.heading3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(mensaje, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Text(textoCancelar),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: peligroso ? AppColors.error : AppColors.accentOrange,
                  ),
                  child: Text(textoConfirmar),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
