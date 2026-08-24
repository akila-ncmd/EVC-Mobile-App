import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_scroll_behavior.dart';
import 'core/router/app_router.dart';
import 'data/local_store.dart';
import 'core/theme/app_theme.dart';
import 'core/url_strategy/url_strategy.dart';
import 'core/widgets/phone_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  // Loaded before the first frame so the app opens straight into the state
  // the user left it in, rather than flashing signed-out first.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [keyValueStoreProvider.overrideWithValue(PrefsStore(prefs))],
      child: const EvcApp(),
    ),
  );
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
      scrollBehavior: const EvcScrollBehavior(),
      // Desktop browsers get the app letterboxed at phone size; real phones
      // are unaffected.
      builder: (context, child) => PhoneFrame(child: child ?? const SizedBox()),
    );
  }
}
