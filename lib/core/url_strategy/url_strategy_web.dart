import 'package:flutter_web_plugins/url_strategy.dart';

/// Clean paths (`/home`) instead of hash fragments (`/#/home`).
///
/// Requires the host to rewrite unknown paths to index.html — see the
/// rewrite rule in vercel.json — otherwise a refresh on a deep link 404s.
void configureUrlStrategy() => usePathUrlStrategy();
