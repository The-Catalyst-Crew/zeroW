import 'package:flutter/material.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
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
            child: CircleAvatar(
              backgroundColor: colorScheme.surfaceVariant,
              child: IconButton(
                icon: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
                onPressed: () {
                  // Navigate to Settings Page
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: colorScheme.surfaceVariant,
                backgroundImage: NetworkImage(
                  "https://www.w3schools.com/howto/img_avatar.png", // Replace with user profile URL
                ),
              ),
              const SizedBox(height: 16),

              // User ID
              Text(
                "User ID: 123456",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              // Additional Profile Details
              Text(
                "Username",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 24),

              // Rank and Level Section
              Card(
                elevation: 2,
                color: colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Rank and Level",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
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
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
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
                            backgroundColor: colorScheme.primary.withOpacity(0.2),
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
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
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

              // Additional Sections can be added here
              // For example: Achievements, Stats, etc.
            ],
          ),
        ),
      ),
    );
  }
}
