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
import '../../features/discovery/player_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/music/music_screen.dart';
import '../../features/music/playlist_screen.dart';
import '../../features/onboarding/interests_screen.dart';
import '../../features/people/people_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/shell/home_shell.dart';
import '../widgets/widgets.dart';
import '../widgets/gallery_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
    GoRoute(path: '/signin', builder: (context, state) => const SignInScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(
      path: '/interests',
      builder: (context, state) => const InterestsScreen(),
    ),

    GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
    GoRoute(
      path: '/search',
      builder: (context, state) => const HomeShell(initialTab: EvcTab.search),
    ),

    GoRoute(
      path: '/about/:id',
      builder: (context, state) => AboutScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/player/:id',
      builder: (context, state) =>
          PlayerScreen(id: state.pathParameters['id']!),
    ),

    GoRoute(
      path: '/library/owned',
      builder: (context, state) =>
          const OwnershipListScreen(kind: OwnershipKind.owned),
    ),
    GoRoute(
      path: '/library/rented',
      builder: (context, state) =>
          const OwnershipListScreen(kind: OwnershipKind.rented),
    ),
    GoRoute(
      path: '/library/gifted',
      builder: (context, state) =>
          const OwnershipListScreen(kind: OwnershipKind.gifted),
    ),

    GoRoute(
      path: '/playlist/:id',
      builder: (context, state) =>
          PlaylistScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/now-playing',
      builder: (context, state) => const NowPlayingScreen(),
    ),

    // Creator side
    GoRoute(
      path: '/creator',
      builder: (context, state) => const CreatorHubScreen(),
    ),
    GoRoute(
      path: '/creator/studio',
      builder: (context, state) => const CreatorStudioScreen(),
    ),
    GoRoute(
      path: '/creator/publish',
      builder: (context, state) => const PublishVideoScreen(),
    ),
    GoRoute(
      path: '/creator/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/creator/videos',
      builder: (context, state) => const MyVideosScreen(),
    ),
    GoRoute(
      path: '/creator/balance',
      builder: (context, state) => const AccountBalanceScreen(),
    ),

    GoRoute(path: '/people', builder: (context, state) => const PeopleScreen()),

    /// Internal design-system reference. Not reachable from the main UI.
    GoRoute(
      path: '/gallery',
      builder: (context, state) => const GalleryScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
);
