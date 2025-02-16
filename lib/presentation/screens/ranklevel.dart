import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerow/data/models/user_model.dart';
import 'package:go_router/go_router.dart';

class RankLevel extends StatelessWidget {
  const RankLevel({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _achievementLevels = const [
    {
      "title": "Trash Eliminator",
      "requiredPoints": 50,
      "badge": "assets/images/eliminator_badge.png"
    },
    {
      "title": "Eco Warrior",
      "requiredPoints": 100,
      "badge": "assets/images/warrior_badge.png"
    },
    {
      "title": "Clean-up Champion",
      "requiredPoints": 150,
      "badge": "assets/images/champion_badge.png"
    },
  ];

  Future<List<Map<String, dynamic>>> _fetchTopUsers() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('points', descending: true)
        .limit(10)
        .get();

    return usersSnapshot.docs.map((doc) {
      final userData = doc.data();
      return {
        'name': userData['name'] ?? 'Anonymous',
        'points': userData['points'] ?? 0,
        'avatarUrl': userData['avatarUrl'] ?? '',
      };
    }).toList();
  }

  Widget _buildAchievementCard(
      BuildContext context, Map<String, dynamic> level, int userPoints) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnlocked = userPoints >= level['requiredPoints'];
    final progressPercentage =
        (userPoints / level['requiredPoints']).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Badge
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.3,
              child: Image.asset(
                level['badge'],
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(width: 16),

            // Achievement Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isUnlocked ? FontWeight.bold : FontWeight.normal,
                      color: isUnlocked
                          ? colorScheme.onBackground
                          : colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(isUnlocked
                          ? colorScheme.primary
                          : colorScheme.primary.withOpacity(0.3)),
                      minHeight: 10,
                    ),
                  ),

                  // Points Text
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${userPoints.clamp(0, level['requiredPoints'])} / ${level['requiredPoints']} pts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isUnlocked
                            ? colorScheme.primary
                            : colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumSpot({
    required BuildContext context,
    required Map<String, dynamic> user,
    required int rank,
    required double height,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color _getPodiumColor(int rank) {
      switch (rank) {
        case 1:
          return Colors.yellow.shade600;
        case 2:
          return Colors.grey.shade400;
        case 3:
          return Colors.brown.shade300;
        default:
          return colorScheme.surfaceVariant;
      }
    }

    final titles = ["Clean-up Champion", "Eco Warrior", "Trash Eliminator"];

    return Expanded(
      child: Column(
        children: [
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _getPodiumColor(rank),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 30,
                backgroundImage:
                    user['avatarUrl'] != null && user['avatarUrl'].isNotEmpty
                        ? NetworkImage(user['avatarUrl'])
                        : null,
                child: user['avatarUrl'] == null || user['avatarUrl'].isEmpty
                    ? Icon(Icons.person, color: colorScheme.onPrimary)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user['name'],
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            titles[rank - 1],
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            '${user['points']} pts',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankCard({
    required BuildContext context,
    required Map<String, dynamic> user,
    required int rank,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user['avatarUrl'] != null && user['avatarUrl'].isNotEmpty
                  ? NetworkImage(user['avatarUrl'])
                  : null,
          child: user['avatarUrl'] == null || user['avatarUrl'].isEmpty
              ? Icon(Icons.person, color: colorScheme.onPrimary)
              : null,
        ),
        title: Text(
          user['name'],
          style: theme.textTheme.bodyLarge,
        ),
        trailing: Text(
          '${user['points']} pts',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Achievements',
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
      body: WillPopScope(
        onWillPop: () async {
          context.go('/home');
          return false;
        },
        child: CustomScrollView(
          slivers: [
            // Achievements List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Your Progress",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onBackground,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    ..._achievementLevels
                        .map((level) =>
                            _buildAchievementCard(context, level, 85))
                        .toList(),

                    // Total Points
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Total Points: 85',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Leaderboard Section
            SliverToBoxAdapter(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchTopUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: theme.textTheme.titleMedium,
                      ),
                    );
                  }

                  final topUsers = snapshot.data!;

                  return Column(
                    children: [
                      // Podium Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (topUsers.length > 1)
                              _buildPodiumSpot(
                                context: context,
                                user: topUsers[1],
                                rank: 2,
                                height: 80,
                              ),
                            if (topUsers.isNotEmpty)
                              _buildPodiumSpot(
                                context: context,
                                user: topUsers[0],
                                rank: 1,
                                height: 100,
                              ),
                            if (topUsers.length > 2)
                              _buildPodiumSpot(
                                context: context,
                                user: topUsers[2],
                                rank: 3,
                                height: 70,
                              ),
                          ],
                        ),
                      ),

                      // Leaderboard Title
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Top Performers',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // User List
                      ...topUsers
                          .sublist(3)
                          .asMap()
                          .entries
                          .map((entry) => _buildUserRankCard(
                                context: context,
                                user: entry.value,
                                rank: entry.key + 4,
                              ))
                          .toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
