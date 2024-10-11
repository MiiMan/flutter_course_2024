import 'package:practice_1/features/core/data/overpass/overpass_api.dart';
import 'package:practice_1/features/core/data/open_meteo/open_meteo_api.dart';
import 'package:practice_1/features/core/domain/entities/search_query.dart';
import 'package:practice_1/features/core/domain/entities/search_response.dart';
import 'package:practice_1/features/core/domain/repositories/weather_repository.dart';

class WeatherRepositoryOpenMeteo implements WeatherRepository {
  final OverpassApi _overpassApi;
  final OpenMeteoApi _openMeteoApi;

  WeatherRepositoryOpenMeteo(this._overpassApi, this._openMeteoApi);

  @override
  Future<SearchResponse> getWeather(SearchQuery query) async {
    // Получаем координаты города через Overpass API
    final coordinates = await _overpassApi.getCityCoordinates(query.city);
    final lat = coordinates['lat'];
    final lon = coordinates['lon'];

    // Получаем данные о погоде через Open-Meteo API
    final weatherData = await _openMeteoApi.getWeather(lat!, lon!);
    return SearchResponse(
      weatherData['temp'].toInt(),
      _weatherType(weatherData['condition']),
    );
  }

  WeatherType _weatherType(int code) {
    // Примерная конвертация кодов погоды из Open-Meteo
    if (code == 0) {
      return WeatherType.clear;
    } else if (code >= 1 && code <= 3) {
      return WeatherType.cloudy;
    } else if (code >= 51 && code <= 57) {
      return WeatherType.rain;
    } else {
      return WeatherType.other;
    }
  }
}