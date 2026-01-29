import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A simple loading indicator widget.
class LoadingIndicator extends StatelessWidget {
  /// Optional message to display
  final String? message;

  const LoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTextStyles.body2,
            ),
          ],
        ],
      ),
    );
  }
}
