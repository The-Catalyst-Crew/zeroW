import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Function to get status: "Not Cleared" or "Cleared"
  String getStatus(int index) {
    return (index % 2 == 0) ? "Not Cleared" : "Cleared";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme; // Uses the same theme as LoginPage

    return Scaffold(
      backgroundColor: theme.background, // Adapts to system theme
      appBar: AppBar(
        title: const Text(
          "zeroW",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.surface, // Same as LoginPage
        elevation: 0,
        actions: [
          // Profile Button in Top-Right
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              // Navigate to Profile Page (Handled by your friend)
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical, // Vertical scrolling for full-page posts
        itemCount: 10, // Example number of posts
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.onBackground, width: 1), // Consistent with LoginPage
              borderRadius: BorderRadius.circular(12),
              color: theme.surfaceVariant, // Matches LoginPage button background
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Header (Profile Pic + Name + Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.primaryContainer, // Adaptable profile color
                          child: Icon(Icons.person, color: theme.onPrimaryContainer),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "User Name",
                          style: TextStyle(color: theme.onBackground, fontSize: 16),
                        ),
                      ],
                    ),
                    // Post Status ("Not Cleared" / "Cleared")
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getStatus(index) == "Cleared"
                            ? Colors.green.shade300 // Green for "Cleared"
                            : Colors.red.shade300, // Red for "Not Cleared"
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getStatus(index),
                        style: const TextStyle(
                          color: Colors.black, // Ensures contrast
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Post Content (Only First Post Gets an Image)
                Expanded(
                  child: index == 0
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    child: Image.network(
                      "https://images.tribuneindia.com/cms/gall_content/2017/11/2017_11\$largeimg08_Wednesday_2017_004904874.jpg",
                      width: double.infinity,
                      fit: BoxFit.cover, // Adjusts image to fill container
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: theme.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: theme.onBackground.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  )
                      : Container(
                    width: double.infinity,
                    color: theme.surfaceVariant, // Matches LoginPage button background
                    alignment: Alignment.center,
                    child: Text(
                      "Post Will appear  Here",
                      style: TextStyle(color: theme.onBackground),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Footer (Like, Comment, Share + Post Time)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like, Comment, Share
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up, color: theme.onBackground),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.comment, color: theme.onBackground),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.share, color: theme.onBackground),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    // Post Time (Bottom-right)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        "2h ago", // Example timestamp (can be dynamic)
                        style: TextStyle(color: theme.onBackground.withOpacity(0.6), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
