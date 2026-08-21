/// Selects the web URL strategy without dragging web-only libraries into
/// mobile builds.
///
/// On web this switches go_router from hash URLs (`/#/home`) to clean paths
/// (`/home`). Everywhere else it is a no-op.
library;

export 'url_strategy_stub.dart'
    if (dart.library.js_interop) 'url_strategy_web.dart';
