import 'package:flutter/material.dart';
import 'document_service.dart';

Future<void> routeFromJwt(BuildContext context, String jwt) async {
  try {
    final status = await DocumentService(jwt).getStatus();

    if (!context.mounted) return;

    if (!status.submitted) {
      Navigator.of(context)
          .pushReplacementNamed('/verification', arguments: jwt);
    } else if (status.status == 'approved') {
      Navigator.of(context)
          .pushReplacementNamed('/dashboard', arguments: jwt);
    } else {
      // pending / rejected
      Navigator.of(context)
          .pushReplacementNamed('/status', arguments: jwt);
    }
  } catch (_) {
    if (context.mounted) {
      Navigator.of(context)
          .pushReplacementNamed('/verification', arguments: jwt);
    }
  }
}
