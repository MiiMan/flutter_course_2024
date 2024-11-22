import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  List<Map<String, dynamic>> _cities = [];
  Map<String, dynamic>? _selectedCity;
  String? _weatherInfo;
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> getCityCoordinates(String city) async {
    const String overpassApiUrl = 'https://overpass-api.de/api/interpreter';
    final query = '''
    [out:json];
    area[name="$city"][admin_level=8];
    node[place~"city|town"](area);
    out body;
  ''';

    final response = await http.post(
      Uri.parse(overpassApiUrl),
      body: {'data': query},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['elements'].isNotEmpty) {
        return decoded['elements']
            .map<Map<String, dynamic>>((e) => {
          'name': e['tags']['name'] ?? 'Unknown',
          'lat': e['lat'],
          'lon': e['lon'],
          'country': e['tags']['addr:country'] ?? 'Unknown Country',
          'timezone': e['tags']['timezone'] ?? 'auto',
        })
            .toList();
      } else {
        throw Exception('No cities found');
      }
    } else {
      throw Exception('Failed to load coordinates');
    }
  }

  Future fetchWeather(double lat, double lon, String timezone) async {
    setState(() {
      _isLoading = true;
      _weatherInfo = null;
    });

    try {
      const String openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';
      final weatherResponse = await http.get(Uri.parse(
          '$openMeteoUrl?latitude=$lat&longitude=$lon&current_weather=true&timezone=$timezone'));

      if (weatherResponse.statusCode == 200) {
        final weatherData =
        jsonDecode(weatherResponse.body)['current_weather'];
        final temperature = weatherData['temperature'];
        final weatherCode = weatherData['weathercode'];

        setState(() {
          _weatherInfo =
          'Температура: ${temperature.toStringAsFixed(1)}°C\n${_getWeatherMessage(weatherCode)}';
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка получения данных о погоде')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getWeatherMessage(int code) {
    if (code == 0) return "Солнышко";
    if (code >= 1 && code <= 3) return "Немного облачков";
    if (code >= 51 && code <= 57) return "Сейчас дождик";
    if (code >= 61 && code <= 67) return "Ой-ой, ливень!";
    if (code >= 80 && code <= 82) return "Гроза, прячьтесь!!!";
    return "Непонятная погода";
  }

  void _searchCityWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите название города')),
      );
      return;
    }

    try {
      final cities = await getCityCoordinates(city);
      setState(() {
        _cities = cities;
        _selectedCity = null;
      });

      if (cities.isNotEmpty) {
        setState(() {
          _selectedCity = cities[0];
        });
        fetchWeather(
            cities[0]['lat'], cities[0]['lon'], cities[0]['timezone']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Город не найден(\nПожалуйста, введите название города on english с большой буквы')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'Введите город',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchCityWeather,
              child: const Text('Найти город'),
            ),
            const SizedBox(height: 16),
            if (_cities.isNotEmpty)
              DropdownButton<Map<String, dynamic>>(
                isExpanded: true,
                hint: const Text('Выберите город'),
                value: _selectedCity,
                onChanged: (selectedCity) {
                  if (selectedCity != null) {
                    setState(() {
                      _selectedCity = selectedCity;
                    });
                    fetchWeather(selectedCity['lat'], selectedCity['lon'],
                        selectedCity['timezone']);
                  }
                },
                items: _cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(
                        //'${city['name']} (${city['country']}), Координаты: ${city['lat']}, ${city['lon']}'),
                        '${city['name']}, ${city['lat']}, ${city['lon']}'),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_weatherInfo != null)
              Column(
                children: [
                  Center(
                    child: Text(
                      _weatherInfo!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedCity != null)
                    Text(
                      //'Страна: ${_selectedCity!['country']}\nКоординаты: ${_selectedCity!['lat']}, ${_selectedCity!['lon']}',
                      'Координаты: ${_selectedCity!['lat']}, ${_selectedCity!['lon']}',
                      style: const TextStyle(fontSize: 18),
                    ),
              Container(
              decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(children: const [
              Icon(
              Icons.cloud,
              size: 100, color: Colors.blue,
                  ),

               ], ), ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
