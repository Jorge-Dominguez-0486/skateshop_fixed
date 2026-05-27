import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class Helpers {
  Helpers._();

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return format.format(amount);
  }

  static String formatPrice(double price) {
    final format = NumberFormat('#,##0.00', 'es_MX');
    return '\$${format.format(price)}';
  }

  static String formatDate(DateTime date) {
    final format = DateFormat('d MMM yyyy', 'es_MX');
    return format.format(date);
  }

  static String formatDateTime(DateTime date) {
    final format = DateFormat('dd/MM/yyyy HH:mm');
    return format.format(date);
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + (1000 + (DateTime.now().microsecondsSinceEpoch % 1000)).toString();
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static Color getStockColor(int stock, int min) {
    if (stock <= 0) return AppColors.error;
    if (stock < min) return AppColors.warning;
    return AppColors.success;
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
