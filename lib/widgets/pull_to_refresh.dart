import 'package:flutter/material.dart';
import '../themes/palette.dart';

class PullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: primaryBlue,
      backgroundColor: white,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
