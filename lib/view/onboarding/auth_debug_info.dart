import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthDebugInfo extends StatelessWidget {
  const AuthDebugInfo({
    super.key,
    required this.projectRef,
    required this.lastRawAuthErrorCode,
  });

  final String? projectRef;
  final String? lastRawAuthErrorCode;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final ref = projectRef ?? 'n/a';
    final code = lastRawAuthErrorCode ?? 'none';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Text(
        'DEBUG: project_ref=$ref, auth_error_code=$code',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
