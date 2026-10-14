import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/gifts/gifts_module.dart';
import '../features/home/home_module.dart';
import '../features/meals/meals_module.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../shared/widgets/main_shell.dart';
import 'modules/app_module.dart';

/// The tabs, in order. Adding one is a new feature folder and a line here.
final List<AppModule> appModules = [HomeModule(), GiftsModule(), MealsModule()];

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class _AuthRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

const _authRoutes = {'/login', '/register', '/forgot', '/reset'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  // A record so "loading" -> "loaded, nobody signed in" counts as a change.
  ref.listen(
    authStateProvider.select((s) => (s.isLoading, s.value?.id)),
    (_, _) => refresh.refresh(),
  );
  ref.listen(passwordRecoveryProvider, (_, _) => refresh.refresh());
  ref.onDispose(refresh.dispose);

  final home = appModules.first.path;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final location = state.matchedLocation;
      if (auth.isLoading) return location == '/' ? null : '/';

      final signedIn = auth.value != null;
      final recovering = ref.read(passwordRecoveryProvider);
      final onAuthRoute = _authRoutes.contains(location);

      if (recovering) return location == '/reset' ? null : '/reset';
      if (location == '/') return signedIn ? home : '/login';
      if (!signedIn && !onAuthRoute) return '/login';
      if (signedIn && onAuthRoute) return home;
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset', builder: (_, _) => const ResetPasswordScreen()),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainShell(navigationShell: shell, modules: appModules),
        branches: [
          for (final m in appModules)
            StatefulShellBranch(routes: m.routes(rootNavigatorKey)),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
