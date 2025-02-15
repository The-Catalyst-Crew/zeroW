import 'package:flutter/material.dart';
import 'package:zerow/utils/daily_fact_helper.dart'; // Import the helper class

class EcoFactScreen extends StatefulWidget {
  const EcoFactScreen({super.key});

  @override
  State<EcoFactScreen> createState() => _EcoFactScreenState();
}

class _EcoFactScreenState extends State<EcoFactScreen> {
  String _currentFact = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDailyFact();
  }

  Future<void> _loadDailyFact() async {
    final fact = await DailyFactHelper.getDailyFact();
    setState(() {
      _currentFact = fact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Fact of the Day'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            _currentFact,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}