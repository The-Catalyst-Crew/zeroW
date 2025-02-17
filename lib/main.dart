import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zerow/cubit/auth/auth_cubit.dart';
import 'package:zerow/cubit/user/user_cubit.dart';
import 'package:zerow/data/repository/auth_repository.dart';
import 'package:zerow/data/repository/user_repository.dart';
import 'package:zerow/firebase_options.dart';
import 'package:zerow/presentation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ],
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    AppRouter.router.refresh();
  });

  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository, userRepository),
        ),
        BlocProvider(
          create: (context) => UserCubit(
            userRepository,
          ),
        ),
      ],
      child: const ZeroWApp(),
    ),
  );
}

class ZeroWApp extends StatelessWidget {
  const ZeroWApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.materialRouter(
      title: 'ZeroW',
      routerConfig: AppRouter.router,
    );
  }
}
