import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zerow/presentation/screens/home.dart';
import 'package:zerow/presentation/screens/login.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) => Home(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => LoginPage(),
      ),
    ],
    initialLocation: '/login',


  );

  static GoRouter get router => _router;
}
