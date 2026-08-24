import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/creator/analytics_screen.dart';
import '../../features/creator/creator_hub_screen.dart';
import '../../features/creator/creator_studio_screen.dart';
import '../../features/creator/publish_video_screen.dart';
import '../../features/discovery/about_screen.dart';
import '../../features/discovery/discovery_screen.dart';
import '../../features/discovery/home_screen.dart';
import '../../features/discovery/player_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/music/music_screen.dart';
import '../../features/music/playlist_screen.dart';
import '../../features/onboarding/interests_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/people/people_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/home_shell.dart';
import '../widgets/gallery_screen.dart';

/// Detail screens live inside a tab's own navigator, so the path is prefixed
/// with the branch that owns it. That is what keeps the bottom bar visible and
/// gives each tab an independent history.
GoRoute _about() => GoRoute(
  path: 'about/:id',
  builder: (context, state) => AboutScreen(id: state.pathParameters['id']!),
);

/// Builds the route table. Tests use this to open the app at a given
/// location; the app uses [appRouter].
GoRouter createRouter({String initialLocation = '/'}) {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,

    // Paths from before the shell existed, and any deep link a user already has.
    redirect: (context, state) {
      final path = state.uri.path;
      const moved = {
        '/people': '/home/people',
        '/creator': '/settings/creator',
        '/creator/studio': '/settings/creator/studio',
        '/creator/publish': '/settings/creator/publish',
        '/creator/analytics': '/settings/creator/analytics',
        '/creator/videos': '/settings/creator/videos',
        '/creator/balance': '/settings/creator/balance',
        '/now-playing': '/music/now-playing',
        '/library/owned': '/library/owned',
      };
      if (moved.containsKey(path) && moved[path] != path) return moved[path];
      if (path.startsWith('/about/')) {
        return '/home/about/${path.substring('/about/'.length)}';
      }
      if (path.startsWith('/player/')) {
        return '/watch/${path.substring('/player/'.length)}';
      }
      if (path.startsWith('/playlist/')) {
        return '/music/playlist/${path.substring('/playlist/'.length)}';
      }
      return null;
    },

    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/interests',
        builder: (context, state) => const InterestsScreen(),
      ),

      /// Video playback covers the shell — a bottom bar next to player controls
      /// competes for the same thumb and the same pixels.
      GoRoute(
        path: '/watch/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) =>
            PlayerScreen(id: state.pathParameters['id']!),
      ),

      /// Internal design-system reference. Not reachable from the main UI.
      GoRoute(
        path: '/gallery',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const GalleryScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  _about(),
                  GoRoute(
                    path: 'people',
                    builder: (context, state) => const PeopleScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const DiscoveryScreen(),
                routes: [_about()],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  _about(),
                  GoRoute(
                    path: 'owned',
                    builder: (context, state) =>
                        const OwnershipListScreen(kind: OwnershipKind.owned),
                  ),
                  GoRoute(
                    path: 'rented',
                    builder: (context, state) =>
                        const OwnershipListScreen(kind: OwnershipKind.rented),
                  ),
                  GoRoute(
                    path: 'gifted',
                    builder: (context, state) =>
                        const OwnershipListScreen(kind: OwnershipKind.gifted),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/music',
                builder: (context, state) => const MusicScreen(),
                routes: [
                  GoRoute(
                    path: 'now-playing',
                    builder: (context, state) => const NowPlayingScreen(),
                  ),
                  GoRoute(
                    path: 'playlist/:id',
                    builder: (context, state) =>
                        PlaylistScreen(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'creator',
                    builder: (context, state) => const CreatorHubScreen(),
                    routes: [
                      GoRoute(
                        path: 'studio',
                        builder: (context, state) =>
                            const CreatorStudioScreen(),
                      ),
                      GoRoute(
                        path: 'publish',
                        builder: (context, state) => const PublishVideoScreen(),
                      ),
                      GoRoute(
                        path: 'analytics',
                        builder: (context, state) => const AnalyticsScreen(),
                      ),
                      GoRoute(
                        path: 'videos',
                        builder: (context, state) => const MyVideosScreen(),
                      ),
                      GoRoute(
                        path: 'balance',
                        builder: (context, state) =>
                            const AccountBalanceScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}

final appRouter = createRouter();

/// Pushes a screen inside whichever tab is currently active, so the bottom bar
/// stays put and the tab keeps its own back stack.
extension EvcNavigation on BuildContext {
  void pushInTab(String subPath) {
    final segments = GoRouterState.of(this).uri.pathSegments;
    final branch = segments.isEmpty ? 'home' : segments.first;
    push('/$branch/$subPath');
  }
}
