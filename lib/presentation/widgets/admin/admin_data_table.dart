import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final String? emptyMessage;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Text(emptyMessage ?? 'Sin datos', style: AppTextStyles.bodyMedium),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceDark.withAlpha(30)),
        columns: columns.map((c) => DataColumn(label: Text(c, style: AppTextStyles.label))).toList(),
        rows: rows.map((r) => DataRow(
          cells: r.map((c) => DataCell(Text(c, style: AppTextStyles.bodyMedium))).toList(),
        )).toList(),
      ),
    );
  }
}
