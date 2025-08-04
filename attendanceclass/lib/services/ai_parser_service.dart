import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/routine_model.dart';
import '../models/holiday_model.dart';

class AIParserService {
  static const String _apiKey =
      'your-free-api-key'; // Replace with actual API key
  static const String _apiUrl =
      'https://api.example.com/parse'; // Replace with actual API URL

  static Future<List<RoutineDay>> parseRoutineFile(String fileContent) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/routine'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({'content': fileContent}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['routine'] as List)
            .map((e) => RoutineDay.fromMap(e))
            .toList();
      }
      throw Exception('Failed to parse routine: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error parsing routine: $e');
    }
  }

  static Future<List<Holiday>> parseHolidayFile(
    String fileContent,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/holidays'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'content': fileContent,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['holidays'] as List)
            .map((e) => Holiday.fromMap(e))
            .toList();
      }
      throw Exception('Failed to parse holidays: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error parsing holidays: $e');
    }
  }
}
