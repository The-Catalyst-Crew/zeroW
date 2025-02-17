import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    // Initialize with current user data
    _usernameController.text = "Username";
    _bioController.text = "Your eco-warrior bio";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onBackground,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Edit
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.surfaceVariant,
                    backgroundImage: NetworkImage(
                      "https://www.w3schools.com/howto/img_avatar.png", // Replace with user profile URL
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: colorScheme.primary,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.edit,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          // Implement image picker
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Username Input
              Card(
                elevation: 2,
                color: colorScheme.surfaceVariant,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: TextField(
                    controller: _usernameController,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bio Input
              Card(
                elevation: 2,
                color: colorScheme.surfaceVariant,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: TextField(
                    controller: _bioController,
                    maxLines: 3,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    decoration: InputDecoration(
                      labelText: "Bio",
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Implement save profile logic
                },
                child: Text(
                  "Save Changes",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
