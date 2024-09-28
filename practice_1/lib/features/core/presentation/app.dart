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

    var resp = await repository.getWeather(SearchQuery(city));
    print('Погода в городе $city: ${resp.temp-273} по Цельсию, тип: ${resp.type}');
  }
}