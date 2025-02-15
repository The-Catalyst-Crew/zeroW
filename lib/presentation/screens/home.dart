import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  // Function to get status: "Not Cleared" or "Cleared"
  String getStatus(int index) {
    return (index % 2 == 0) ? "Not Cleared" : "Cleared";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: Text(
          "zeroW",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        backgroundColor: theme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to Profile Page
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border:
                  Border.all(color: theme.onSurface.withOpacity(0.1), width: 1),
              borderRadius: BorderRadius.circular(12),
              color: theme.surfaceVariant,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.primaryContainer,
                          child: Icon(Icons.person,
                              color: theme.onPrimaryContainer),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "User Name",
                          style:
                              TextStyle(color: theme.onSurface, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getStatus(index) == "Cleared"
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getStatus(index),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Post Content
                Expanded(
                  child: index == 0
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "https://images.tribuneindia.com/cms/gall_content/2017/11/2017_11\$largeimg08_Wednesday_2017_004904874.jpg",
                            width: double.infinity,
                            fit: BoxFit.cover,
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
                                  color: theme.onSurface.withOpacity(0.5),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            "Post Will Appear Here",
                            style: TextStyle(color: theme.onSurface),
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up, color: theme.onSurface),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.comment, color: theme.onSurface),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.share, color: theme.onSurface),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Text(
                      "2h ago",
                      style: TextStyle(
                        color: theme.onSurface.withOpacity(0.6),
                        fontSize: 12,
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
