import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerow/data/eco_facts.dart'; // Import the eco facts list

class DailyFactHelper {
  // Key for storing the last displayed fact index
  static const String _lastFactIndexKey = 'last_fact_index';
  // Key for storing the last displayed date
  static const String _lastDisplayDateKey = 'last_display_date';

  // Get the daily fact
  static Future<String> getDailyFact() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the last displayed date
    final lastDisplayDate = prefs.getString(_lastDisplayDateKey);
    final currentDate = DateTime.now().toIso8601String().split('T')[0]; // Get today's date in YYYY-MM-DD format

    // Check if the last displayed date is today
    if (lastDisplayDate == currentDate) {
      // If the fact was already shown today, return the same fact
      final lastFactIndex = prefs.getInt(_lastFactIndexKey) ?? 0;
      return ecoFacts[lastFactIndex];
    } else {
      // If it's a new day, show a new fact
      final randomFactIndex = DateTime.now().day % ecoFacts.length; // Use day of the month to get a fact
      await prefs.setInt(_lastFactIndexKey, randomFactIndex); // Save the new fact index
      await prefs.setString(_lastDisplayDateKey, currentDate); // Save today's date
      return ecoFacts[randomFactIndex];
    }
  }
}