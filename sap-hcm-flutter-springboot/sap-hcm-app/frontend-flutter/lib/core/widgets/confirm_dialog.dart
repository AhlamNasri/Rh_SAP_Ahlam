import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(BuildContext context, String title, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
      ],
    ),
  );
  return result ?? false;
}
