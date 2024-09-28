import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:practice_1/features/core/data/osm/models/osm_weather.dart';

class OSMApi {
  final String url;
  final String apiKey;

  OSMApi(this.url, this.apiKey);

  Future<OSMWeather> getWeather(String city) async {
    var response = await http.get(Uri.parse('$url/data/2.5/weather?q=$city&appid=$apiKey'));
    var rJson = jsonDecode(response.body);

    return OSMWeather(rJson['main']['temp'], rJson['weather'][0]['main']);
  }
}