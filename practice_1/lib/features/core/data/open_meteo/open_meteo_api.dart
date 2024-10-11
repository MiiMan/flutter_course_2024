import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMeteoApi {
  final String url = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        '$url?latitude=$lat&longitude=$lon&current_weather=true'));

    if (response.statusCode == 200) {
      final weatherData = jsonDecode(response.body)['current_weather'];
      return {
        'temp': weatherData['temperature'],
        'condition': weatherData['weathercode'],
      };
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}