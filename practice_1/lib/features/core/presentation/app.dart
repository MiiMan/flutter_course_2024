import 'package:practice_1/features/core/domain/entities/search_query.dart';
import 'package:practice_1/features/core/domain/repositories/weather_repository.dart';
import 'dart:io';

class App {
  final WeatherRepository repository;

  App(this.repository);

  void run() async {
    print('Введите город:');
    var city = stdin.readLineSync();

    if (city == null) {
      print('Ошибка ввода');
      return;
    }

    try {
      var resp = await repository.getWeather(SearchQuery(city));
      // Выводим температуру в градусах Цельсия и тип погоды
      print('Погода в городе $city: ${resp.temp}°C, тип: ${resp.type}');
    } catch (e) {
      print('Ошибка при получении данных: $e');
    }
  }
}