import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/phone_frame.dart';

void main() {
  runApp(const ProviderScope(child: EvcApp()));
}

class EvcApp extends StatelessWidget {
  const EvcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EVC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      // Desktop browsers get the app letterboxed at phone size; real phones
      // are unaffected.
      builder: (context, child) => PhoneFrame(child: child ?? const SizedBox()),
    );
  }
}
