import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zerow/cubit/auth/auth_cubit.dart';
import 'package:zerow/cubit/user/user_cubit.dart';
import 'package:zerow/data/repository/user_repository.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({Key? key}) : super(key: key);

  void _showLogoutConfirmDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(dialogContext).pop();

                // Trigger logout
                context.read<AuthCubit>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(
                'Logout',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserCubit(UserRepository())..loadUserData(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // Navigate to login screen when logged out
            context.go('/login');
          } else if (state is AuthError) {
            // Show error if logout fails
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              "My Profile",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onBackground,
                    letterSpacing: 1.2,
                  ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  onPressed: () => _showLogoutConfirmDialog(context),
                ),
              ),
            ],
          ),
          body: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return WillPopScope(
                  onWillPop: () async {
                    context.go('/home');
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage:
                                state.userModel.avatarUrl.isNotEmpty
                                    ? NetworkImage(state.userModel.avatarUrl)
                                    : null,
                            child: state.userModel.avatarUrl.isEmpty
                                ? Icon(Icons.person, size: 80)
                                : null,
                          ),
                          SizedBox(height: 16),
                          Text(
                            state.userModel.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            state.userModel.email,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SwitchListTile(
                                title: Text(
                                  'Anonymous Posting',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  'Hide your name when creating posts',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                value: state.userModel.anonymousPosting,
                                onChanged: (_) => context
                                    .read<UserCubit>()
                                    .toggleAnonymousPosting(),
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/reports'),
                                icon: Icon(
                                  Icons.report_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                label: Text(
                                  'View My Reports',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is UserError) {
                return Center(
                  child: Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
