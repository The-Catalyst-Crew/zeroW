import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zerow/presentation/screens/home.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'root',
        builder: (BuildContext context, GoRouterState state) => Home(),
      ),
    ],
    initialLocation: '/home',
  );

  static GoRouter get router => _router;
}
