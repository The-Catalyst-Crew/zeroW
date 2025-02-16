import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:zerow/data/models/user_model.dart';
import 'package:zerow/data/repository/user_repository.dart';

class RankLevel extends StatefulWidget {
  const RankLevel({Key? key}) : super(key: key);

  @override
  _RankLevelState createState() => _RankLevelState();
}

class _RankLevelState extends State<RankLevel> {
  final UserRepository _userRepository = UserRepository();
  UserModel? _currentUser;
  List<UserModel> _topUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userModel =
            await _userRepository.getFirestoreUser(currentUser.uid);

        // Fetch top users with ranking
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .get();

        final topUsers = usersSnapshot.docs
            .asMap()
            .map((index, doc) {
              final user = UserModel.fromFirestore(doc);
              return MapEntry(
                index,
                user.copyWith(rank: index + 1),
              );
            })
            .values
            .toList()
            .take(10)
            .toList();

        // Update user's rank
        final currentUserRank =
            topUsers.indexWhere((u) => u.id == currentUser.uid) + 1;
        final updatedCurrentUser = userModel?.copyWith(rank: currentUserRank);

        setState(() {
          _currentUser = updatedCurrentUser;
          _topUsers = topUsers;
          _isLoading = false;
        });
      } else {
        throw Exception('No authenticated user');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user data: ${e.toString()}';
      });
      print('User data fetching error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final int userPoints = _currentUser?.points ?? 0;
    final String userLevel = _currentUser?.level ?? 'Beginner';
    final int userRank = _currentUser?.rank ?? 0;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onBackground),
            onPressed: _fetchUserData,
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          context.go('/home');
          return false;
        },
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchUserData,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Your Progress",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onBackground,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 16),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        userLevel,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Rank #$userRank',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Total Points: $userPoints',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Achievement Levels
                              ..._achievementLevels
                                  .map((level) => _buildAchievementCard(
                                      context, level, userPoints))
                                  .toList(),
                            ],
                          ),
                        ),

                        // Top Users Ranking
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Users',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ..._topUsers
                                  .map((user) => _buildUserRankCard(
                                        context: context,
                                        user: user,
                                        rank: user.rank,
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
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

  Widget _buildUserRankCard({
    required BuildContext context,
    required UserModel user,
    required int rank,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null && user.avatarUrl.isNotEmpty
              ? NetworkImage(user.avatarUrl)
              : null,
          child: user.avatarUrl == null || user.avatarUrl.isEmpty
              ? Icon(Icons.person, color: colorScheme.onPrimary)
              : null,
        ),
        title: Text(
          user.name,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          user.level,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${user.points} pts',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rank #${user.rank}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
