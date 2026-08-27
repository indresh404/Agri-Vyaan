import 'package:flutter/material.dart';
import '../services/app_state.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(appState.translate('weather_spraying')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appState.weatherForecast.length,
        itemBuilder: (context, idx) {
          final forecast = appState.weatherForecast[idx];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${forecast.dayName} (${forecast.date})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(forecast.weatherCondition, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: forecast.sprayingCondition == 'GOOD'
                              ? Colors.green.shade50
                              : (forecast.sprayingCondition == 'AVOID' ? Colors.red.shade50 : Colors.amber.shade50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          forecast.sprayingCondition,
                          style: TextStyle(
                            color: forecast.sprayingCondition == 'GOOD'
                                ? Colors.green.shade800
                                : (forecast.sprayingCondition == 'AVOID' ? Colors.red.shade800 : Colors.amber.shade800),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniWeatherSpec(Icons.thermostat, '${forecast.temperature.toStringAsFixed(0)}°C', 'Temp'),
                      _buildMiniWeatherSpec(Icons.umbrella, '${forecast.rainProbability.toStringAsFixed(0)}%', 'Rain'),
                      _buildMiniWeatherSpec(Icons.air, '${forecast.windSpeed.toStringAsFixed(0)} km/h', 'Wind'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    forecast.aiSummary,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniWeatherSpec(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 18),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}
