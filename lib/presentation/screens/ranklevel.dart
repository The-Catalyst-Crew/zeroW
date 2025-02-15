import 'package:flutter/material.dart';

class AchievementPodiumPage extends StatelessWidget {
  final List<Map<String, dynamic>> podiumLevels = [
    {
      "title": "Clean-up Champion",
      "requiredPoints": 150,
      "badge": "assets/images/champion_badge.png"
    },
    {
      "title": "Eco Warrior",
      "requiredPoints": 100,
      "badge": "assets/images/warrior_badge.png"
    },
    {
      "title": "Trash Eliminator",
      "requiredPoints": 50,
      "badge": "assets/images/eliminator_badge.png"
    },
  ];

  final int userPoints = 85; // Replace with dynamic user points data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Achievements'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Achievements Podium",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumSpot(podiumLevels[1], Colors.grey, 80, userPoints),
              _buildPodiumSpot(podiumLevels[0], Colors.yellow, 100, userPoints),
              _buildPodiumSpot(podiumLevels[2], Colors.brown, 70, userPoints),
            ],
          ),
          SizedBox(height: 40),
          Text(
            "Your Current Points",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Text(
            userPoints.toString(),
            style: TextStyle(fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(Map<String, dynamic> level, Color color,
      double height, int userPoints) {
    final bool achieved = userPoints >= level['requiredPoints'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: height,
          width: 60,
          decoration: BoxDecoration(
            color: achieved ? color : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "${level['requiredPoints']} pts",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: achieved ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Image.asset(
          level['badge'],
          height: 40,
          width: 40,
          fit: BoxFit.cover,
          color: achieved ? null : Colors.grey,
        ),
        SizedBox(height: 5),
        Text(
          level['title'],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: achieved ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}