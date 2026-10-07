import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:someday/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:someday/features/ideas/presentation/screens/home_screen.dart';
import 'package:someday/features/ideas/presentation/screens/idea_detail_screen.dart';
import 'package:someday/features/ideas/presentation/screens/edit_idea_screen.dart';
import 'package:someday/features/ideas/presentation/screens/new_idea_screen.dart';
import 'package:someday/features/ideas/presentation/screens/verdict_screen.dart';

// Route constants
const kRouteOnboarding = '/onboarding';
const kRouteHome = '/home';
const kRouteNewIdea = '/home/idea/new';
const kRouteIdea = '/idea/:id';
const kRouteVerdict = '/idea/:id/verdict';
const kRouteEditIdea = '/idea/:id/edit';
const kRouteContext = '/idea/:id/context';

GoRouter buildRouter() {
  final authListenable = _AuthListenable();

  return GoRouter(
    refreshListenable: authListenable,
    initialLocation: kRouteHome,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthed = session != null;
      final isOnboarding = state.matchedLocation == kRouteOnboarding;

      if (!isAuthed && !isOnboarding) return kRouteOnboarding;
      if (isAuthed && isOnboarding) return kRouteHome;
      return null;
    },
    routes: [
      GoRoute(
        path: kRouteOnboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: kRouteHome,
        builder: (_, _) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'idea/new',
            builder: (_, state) => NewIdeaScreen(
              initialDescription: state.extra as String?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: kRouteIdea,
        builder: (_, state) => IdeaDetailScreen(ideaId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => EditIdeaScreen(ideaId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'verdict',
            builder: (_, state) => VerdictScreen(ideaId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'context',
            builder: (_, state) =>
                _PlaceholderScreen(label: 'Context ${state.pathParameters['id']}'),
          ),
        ],
      ),
    ],
  );
}

/// Bridges Supabase auth state changes to GoRouter's refresh mechanism.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label)),
    );
  }
}
