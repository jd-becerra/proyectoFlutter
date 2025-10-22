import 'package:flutter/material.dart';

Future<void> showPendingAlert(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Funcionalidad pendiente'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
      ],
    ),
  );
}
