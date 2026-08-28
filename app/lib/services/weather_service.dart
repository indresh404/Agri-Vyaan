import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class WeatherService {
  static const String _forecastUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<WeatherForecast>> fetchWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.get(
      Uri.parse(_forecastUrl).replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current':
              'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m,cloud_cover',
          'daily':
              'temperature_2m_max,precipitation_probability_max,relative_humidity_2m_max,wind_speed_10m_max,weather_code',
          'forecast_days': '7',
          'timezone': 'auto',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Weather service returned ${response.statusCode}');
    }

    return _parseOpenMeteoData(json.decode(response.body));
  }

  Future<List<WeatherForecast>> fetchWeatherForLocation(String location) async {
    final response = await http.get(
      Uri.parse(_geocodingUrl).replace(
        queryParameters: {
          'name': location,
          'count': '1',
          'language': 'en',
          'format': 'json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Location service returned ${response.statusCode}');
    }

    final results =
        (json.decode(response.body)['results'] as List<dynamic>?) ?? [];
    if (results.isEmpty) {
      throw Exception('Could not find weather location: $location');
    }

    final result = results.first as Map<String, dynamic>;
    return fetchWeatherForecast(
      latitude: (result['latitude'] as num).toDouble(),
      longitude: (result['longitude'] as num).toDouble(),
    );
  }

  Future<String> fetchAISummary({
    required List<WeatherForecast> forecast,
    required String cropType,
  }) async => _generateLocalAISummary(forecast);

  List<WeatherForecast> _parseOpenMeteoData(Map<String, dynamic> data) {
    final forecasts = <WeatherForecast>[];
    final daily = data['daily'] as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final dates = List<String>.from(daily['time'] as List<dynamic>);
    for (int i = 0; i < dates.length; i++) {
      final date = DateTime.parse(dates[i]);
      final rain = _numberAt(daily['precipitation_probability_max'], i);
      final windSpeed = _numberAt(daily['wind_speed_10m_max'], i);
      final temperature = i == 0
          ? _number(current['temperature_2m'])
          : _numberAt(daily['temperature_2m_max'], i);
      final weatherCode = (_numberAt(daily['weather_code'], i)).round();

      forecasts.add(
        WeatherForecast(
          dayName: i == 0 ? 'Today' : _getDayName(date),
          date: _formatDate(date),
          temperature: temperature,
          rainProbability: rain,
          humidity: i == 0
              ? _number(current['relative_humidity_2m'])
              : _numberAt(daily['relative_humidity_2m_max'], i),
          windSpeed: windSpeed,
          weatherCondition: _weatherDescription(weatherCode),
          sprayingCondition: _calculateSprayingCondition(
            rain: rain,
            windSpeed: windSpeed,
          ),
          aiSummary: i == 0
              ? _generateLocalAISummaryForCode(weatherCode, rain)
              : '',
          bestWindow: _calculateBestWindow(rain: rain, windSpeed: windSpeed),
        ),
      );
    }

    return forecasts;
  }

  double _number(dynamic value) => (value as num?)?.toDouble() ?? 0;

  double _numberAt(dynamic values, int index) {
    final list = values as List<dynamic>;
    return _number(list[index]);
  }

  String _weatherDescription(int code) {
    if (code == 0) {
      return 'Clear sky';
    }
    if (code <= 3) {
      return 'Cloudy';
    }
    if (code <= 48) {
      return 'Foggy';
    }
    if (code <= 57) {
      return 'Drizzle';
    }
    if (code <= 67 || code >= 80 && code <= 82) {
      return 'Rainy';
    }
    if (code <= 77) {
      return 'Snowy';
    }
    return 'Thunderstorm';
  }

  String _generateLocalAISummaryForCode(int code, double rain) {
    if (code >= 95) {
      return 'Thunderstorms are possible. Avoid spraying and monitor field drainage.';
    }
    if (rain >= 60) {
      return 'Rain is likely today. Avoid spraying because products may wash off.';
    }
    if (code >= 51 && code <= 82) {
      return 'Rain or drizzle is possible. Check the hourly forecast before spraying.';
    }
    if (code <= 3) {
      return 'Dry conditions are expected. Early morning is the best time to spray.';
    }
    return 'Moderate weather conditions. Check wind and rain before spraying.';
  }

  // Calculate spraying condition based on weather
  String _calculateSprayingCondition({
    required double rain,
    required double windSpeed,
  }) {
    if (rain > 60 || windSpeed > 20) {
      return 'AVOID';
    } else if (rain > 30 || windSpeed > 15) {
      return 'MODERATE';
    } else {
      return 'GOOD';
    }
  }

  String _calculateBestWindow({
    required double rain,
    required double windSpeed,
  }) {
    if (rain < 20 && windSpeed < 10) {
      return '06:00 AM - 10:00 AM';
    } else if (rain < 40 && windSpeed < 15) {
      return '07:00 AM - 09:00 AM';
    } else {
      return 'Limited windows available';
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthAbbr(date.month)}';
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getDayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _generateLocalAISummary(List<WeatherForecast> forecast) {
    if (forecast.isEmpty) return 'No weather data available';

    final today = forecast[0];
    final conditions = today.weatherCondition.toLowerCase();

    if (conditions.contains('rain')) {
      return 'Rain expected today. Avoid spraying as products will be washed off.';
    } else if (conditions.contains('cloud')) {
      return 'Cloudy conditions with moderate temperatures. Good for spraying in the morning.';
    } else if (conditions.contains('sun') || conditions.contains('clear')) {
      return 'Sunny and warm conditions. Best to spray in early morning or late evening.';
    } else {
      return 'Moderate weather conditions. Check hourly forecast for best spraying windows.';
    }
  }

  // Mock data for development
  List<WeatherForecast> getMockWeatherData() {
    return [
      WeatherForecast(
        dayName: 'Today',
        date: '28 Aug',
        temperature: 28,
        rainProbability: 43,
        humidity: 65,
        windSpeed: 8,
        weatherCondition: 'Very Cloudy',
        sprayingCondition: 'MODERATE',
        aiSummary:
            'This morning is warm and very cloudy with light rain at times (about 27–29°C), then this afternoon stays cloudy with occasional light drizzle around 28–29°C.',
        bestWindow: '07:00 AM - 09:00 AM',
      ),
      WeatherForecast(
        dayName: 'Thu',
        date: '29 Aug',
        temperature: 29,
        rainProbability: 60,
        humidity: 72,
        windSpeed: 12,
        weatherCondition: 'Rainy',
        sprayingCondition: 'AVOID',
        aiSummary: '',
        bestWindow: 'None',
      ),
      WeatherForecast(
        dayName: 'Fri',
        date: '30 Aug',
        temperature: 29,
        rainProbability: 45,
        humidity: 68,
        windSpeed: 10,
        weatherCondition: 'Cloudy',
        sprayingCondition: 'MODERATE',
        aiSummary: '',
        bestWindow: '07:00 AM - 09:00 AM',
      ),
      WeatherForecast(
        dayName: 'Sat',
        date: '31 Aug',
        temperature: 29,
        rainProbability: 30,
        humidity: 62,
        windSpeed: 8,
        weatherCondition: 'Partly Cloudy',
        sprayingCondition: 'GOOD',
        aiSummary: '',
        bestWindow: '06:00 AM - 10:00 AM',
      ),
      WeatherForecast(
        dayName: 'Sun',
        date: '1 Sep',
        temperature: 29,
        rainProbability: 25,
        humidity: 58,
        windSpeed: 7,
        weatherCondition: 'Sunny',
        sprayingCondition: 'GOOD',
        aiSummary: '',
        bestWindow: '06:00 AM - 11:00 AM',
      ),
      WeatherForecast(
        dayName: 'Mon',
        date: '2 Sep',
        temperature: 29,
        rainProbability: 20,
        humidity: 55,
        windSpeed: 6,
        weatherCondition: 'Sunny',
        sprayingCondition: 'GOOD',
        aiSummary: '',
        bestWindow: '06:00 AM - 11:00 AM',
      ),
    ];
  }
}

// Helper class for spraying time slots (used in UI)
class SprayingTimeSlot {
  final String time;
  final SprayingCondition condition;

  SprayingTimeSlot({required this.time, required this.condition});
}

enum SprayingCondition { optimal, moderate, unfavourable }

extension SprayingConditionExtension on SprayingCondition {
  Color get color {
    switch (this) {
      case SprayingCondition.optimal:
        return Colors.green;
      case SprayingCondition.moderate:
        return Colors.amber;
      case SprayingCondition.unfavourable:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case SprayingCondition.optimal:
        return 'Optimal';
      case SprayingCondition.moderate:
        return 'Moderate';
      case SprayingCondition.unfavourable:
        return 'Unfavourable';
    }
  }
}
