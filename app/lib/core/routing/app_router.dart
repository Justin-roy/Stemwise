import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/calculator/presentation/career_screen.dart';
import '../../features/calculator/presentation/costs_screen.dart';
import '../../features/calculator/presentation/degree_screen.dart';
import '../../features/calculator/presentation/funding_screen.dart';
import '../../features/calculator/presentation/loan_screen.dart';
import '../../features/calculator/presentation/result_screen.dart';
import '../../features/career/career_explorer_screen.dart';
import '../../features/comparison/compare_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/saved_plans/saved_plans_screen.dart';
import '../../features/what_if/what_if_screen.dart';
import '../../shared/widgets/main_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

/// Full route map (spec §11). Calculator sub-steps are pushed above the shell.
final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),

    // Calculator flow (full-screen, above bottom nav).
    GoRoute(path: '/calculate/costs', parentNavigatorKey: _rootKey, builder: (_, __) => const CostsScreen()),
    GoRoute(path: '/calculate/funding', parentNavigatorKey: _rootKey, builder: (_, __) => const FundingScreen()),
    GoRoute(path: '/calculate/loan', parentNavigatorKey: _rootKey, builder: (_, __) => const LoanScreen()),
    GoRoute(path: '/calculate/career', parentNavigatorKey: _rootKey, builder: (_, __) => const CareerScreen()),
    GoRoute(path: '/calculate/result', parentNavigatorKey: _rootKey, builder: (_, __) => const ResultScreen()),

    GoRoute(path: '/what-if', parentNavigatorKey: _rootKey, builder: (_, __) => const WhatIfScreen()),
    GoRoute(path: '/saved-plans', parentNavigatorKey: _rootKey, builder: (_, __) => const SavedPlansScreen()),
    GoRoute(path: '/notifications', parentNavigatorKey: _rootKey, builder: (_, __) => const NotificationsScreen()),

    // Auth.
    GoRoute(
      path: '/auth/login',
      parentNavigatorKey: _rootKey,
      builder: (_, state) => LoginScreen(intent: state.uri.queryParameters['intent']),
    ),
    GoRoute(
      path: '/auth/signup',
      parentNavigatorKey: _rootKey,
      builder: (_, state) => SignupScreen(intent: state.uri.queryParameters['intent']),
    ),

    // Main tabs.
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(navigatorKey: _shellKey, routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/calculate/degree', builder: (_, __) => const DegreeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/compare', builder: (_, __) => const CompareScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/career', builder: (_, __) => const CareerExplorerScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ]),
      ],
    ),
  ],
);
