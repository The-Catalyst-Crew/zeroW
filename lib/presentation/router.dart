import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zerow/presentation/screens/create_post.dart';
import 'package:zerow/presentation/screens/home.dart';
import 'package:zerow/presentation/screens/login.dart';
import 'package:zerow/cubit/auth/auth_cubit.dart';
import 'package:zerow/presentation/screens/ranklevel.dart';
import 'package:zerow/presentation/screens/my_profile.dart';
import 'package:zerow/presentation/screens/reports.dart';

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
      GoRoute(
        path: '/create_post',
        name: 'create_post',
        builder: (BuildContext context, GoRouterState state) =>
            CreatePostScreen(),
      ),
      GoRoute(
        path: '/ranklevel',
        name: 'ranklevel',
        builder: (BuildContext context, GoRouterState state) => RankLevel(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) => MyProfile(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (BuildContext context, GoRouterState state) => Report(),
      ),
    ],
    initialLocation: '/login',
  );

  static GoRouter get router => _router;
}
