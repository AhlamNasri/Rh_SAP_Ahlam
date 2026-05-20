import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  const CustomDataTable({super.key, required this.columns, required this.rows});

  final List<String> columns;
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const Text('Aucune donnee a afficher.');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
        rows: rows
            .map(
              (row) => DataRow(
                cells: columns.map((c) => DataCell(Text('${row[c] ?? '-'}'))).toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}
