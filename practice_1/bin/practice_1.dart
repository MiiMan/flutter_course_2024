import 'package:practice_1/features/core/data/debug/weather_repository_debug.dart';
import 'package:practice_1/features/core/data/osm/osm_api.dart';
import 'package:practice_1/features/core/data/osm/weather_repository_osm.dart';
import 'package:practice_1/features/core/presentation/app.dart';

const String version = '0.0.1';
const String url = 'https://api.openweathermap.org';
const String apiKey = 'f11a8d09666e4acbd56e3ecc1ccbe31b';

void main(List<String> arguments) {
  var app = App(WeatherRepositoryDebug());

  app.run();
}
