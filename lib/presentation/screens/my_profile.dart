import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zerow/cubit/auth/auth_cubit.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate to login screen when logged out
          context.go('/login');
        } else if (state is AuthError) {
          // Show error if logout fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          title: Text(
            "My Profile",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onBackground,
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
                  color: colorScheme.onBackground,
                ),
                onPressed: () => _showLogoutConfirmDialog(context),
              ),
            ),
          ],
        ),
        body: WillPopScope(
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
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.surfaceVariant,
                    backgroundImage: NetworkImage(
                      "https://www.w3schools.com/howto/img_avatar.png", // Replace with user profile URL
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User ID
                  Text(
                    "User ID: 123456",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Additional Profile Details
                  Text(
                    "Username",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Rank and Level Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Rank and Level",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Rank",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    "Silver",
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              // Badge in the middle
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    colorScheme.primary.withOpacity(0.2),
                                child: Icon(
                                  Icons.military_tech_outlined,
                                  size: 40,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Level",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    "5",
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reports Button
                  ElevatedButton.icon(
                    onPressed: () => context.push('/reports'),
                    icon: Icon(
                      Icons.report_outlined,
                      color: colorScheme.onPrimary,
                    ),
                    label: Text(
                      'View My Reports',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional Sections can be added here
                  // For example: Achievements, Stats, etc.
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
