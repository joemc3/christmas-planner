import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_mark.dart';

/// Shown only until the first auth event; the router then redirects.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: AppMark(size: 64)));
}
