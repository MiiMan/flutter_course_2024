class OSMWeather {
  final double temp;
  final String type;

  const OSMWeather(this.temp, this.type);

  @override
  String toString() {
    return 'OSMWeather{temp: $temp, type: $type}';
  }
}