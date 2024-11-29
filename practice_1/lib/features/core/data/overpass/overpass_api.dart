import 'dart:convert';
import 'package:http/http.dart' as http;

class OverpassApi {
  final String url = 'https://overpass-api.de/api/interpreter';

  Future<Map<String, double>> getCityCoordinates(String city) async {
    final query = '''
    [out:json];
    area[name="$city"][admin_level=8];
    node[place~"city|town"](area);
    out center;
    ''';

    final response = await http.post(Uri.parse(url), body: {'data': query});

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['elements'].isNotEmpty) {
        final element = decoded['elements'][0];
        return {
          'lat': element['lat'],
          'lon': element['lon'],
        };
      } else {
        throw Exception('City not found');
      }
    } else {
      throw Exception('Failed to load coordinates');
    }
  }
}