import 'dart:convert';
import 'package:flutter/material.dart'; // Add this import for Color
import 'package:http/http.dart' as http;
import '../models/models.dart';

class WeatherService {
  static const String baseUrl = 'YOUR_API_BASE_URL';
  static const String apiKey = 'YOUR_API_KEY';

  // Fetch weather data from API
  Future<List<WeatherForecast>> fetchWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherData(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return getMockWeatherData();
    }
  }

  // Fetch AI summary from your backend
  Future<String> fetchAISummary({
    required List<WeatherForecast> forecast,
    required String cropType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/weather-summary'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'forecast': forecast.map((f) => _forecastToJson(f)).toList(),
          'cropType': cropType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary'] ?? _generateLocalAISummary(forecast);
      } else {
        return _generateLocalAISummary(forecast);
      }
    } catch (e) {
      return _generateLocalAISummary(forecast);
    }
  }

  // Parse API response
  List<WeatherForecast> _parseWeatherData(Map<String, dynamic> data) {
    final forecasts = <WeatherForecast>[];

    // Parse daily forecast from API response
    final daily = data['daily'] ?? [];
    final current = data['current'] ?? {};

    // Add today's forecast
    if (current.isNotEmpty) {
      forecasts.add(
        WeatherForecast(
          dayName: 'Today',
          date: _formatDate(DateTime.now()),
          temperature: (current['temp'] ?? 0).toDouble(),
          rainProbability: (current['rain'] ?? 0).toDouble(),
          humidity: (current['humidity'] ?? 0).toDouble(),
          windSpeed: (current['wind_speed'] ?? 0).toDouble(),
          weatherCondition: current['weather']?[0]?['description'] ?? '',
          sprayingCondition: _calculateSprayingCondition(
            rain: (current['rain'] ?? 0).toDouble(),
            windSpeed: (current['wind_speed'] ?? 0).toDouble(),
          ),
          aiSummary: 'Weather data loaded successfully',
          bestWindow: _calculateBestWindow(
            rain: (current['rain'] ?? 0).toDouble(),
            windSpeed: (current['wind_speed'] ?? 0).toDouble(),
          ),
        ),
      );
    }

    // Add next 5 days
    if (daily.isNotEmpty) {
      for (int i = 0; i < daily.length && i < 5; i++) {
        final day = daily[i];
        final date = DateTime.now().add(Duration(days: i + 1));
        forecasts.add(
          WeatherForecast(
            dayName: _getDayName(date),
            date: _formatDate(date),
            temperature: (day['temp']?['day'] ?? 0).toDouble(),
            rainProbability: (day['rain'] ?? 0).toDouble(),
            humidity: (day['humidity'] ?? 0).toDouble(),
            windSpeed: (day['wind_speed'] ?? 0).toDouble(),
            weatherCondition: day['weather']?[0]?['description'] ?? '',
            sprayingCondition: _calculateSprayingCondition(
              rain: (day['rain'] ?? 0).toDouble(),
              windSpeed: (day['wind_speed'] ?? 0).toDouble(),
            ),
            aiSummary: '',
            bestWindow: _calculateBestWindow(
              rain: (day['rain'] ?? 0).toDouble(),
              windSpeed: (day['wind_speed'] ?? 0).toDouble(),
            ),
          ),
        );
      }
    }

    return forecasts;
  }

  Map<String, dynamic> _forecastToJson(WeatherForecast forecast) {
    return {
      'dayName': forecast.dayName,
      'date': forecast.date,
      'temperature': forecast.temperature,
      'rainProbability': forecast.rainProbability,
      'humidity': forecast.humidity,
      'windSpeed': forecast.windSpeed,
      'weatherCondition': forecast.weatherCondition,
      'sprayingCondition': forecast.sprayingCondition,
    };
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
