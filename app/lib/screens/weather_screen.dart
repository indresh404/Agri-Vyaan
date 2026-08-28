import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/weather_service.dart';
import '../models/models.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  List<WeatherForecast> _forecast = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _dailyNotificationEnabled = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadWeatherData();
    });
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final appState = AppStateProvider.of(context);

    try {
      final location =
          appState.currentProfile?.location ?? 'Wardha, Maharashtra';
      final forecast = await _weatherService.fetchWeatherForLocation(location);

      // Fetch AI summary for the forecast
      if (forecast.isNotEmpty) {
        final cropType = appState.currentProfile?.mainCrop ?? 'Cotton';
        final aiSummary = await _weatherService.fetchAISummary(
          forecast: forecast,
          cropType: cropType,
        );

        if (forecast.isNotEmpty) {
          forecast[0] = WeatherForecast(
            dayName: forecast[0].dayName,
            date: forecast[0].date,
            temperature: forecast[0].temperature,
            rainProbability: forecast[0].rainProbability,
            humidity: forecast[0].humidity,
            windSpeed: forecast[0].windSpeed,
            weatherCondition: forecast[0].weatherCondition,
            sprayingCondition: forecast[0].sprayingCondition,
            aiSummary: aiSummary,
            bestWindow: forecast[0].bestWindow,
          );
        }
      }

      setState(() {
        _forecast = forecast;
        _isLoading = false;
      });
      appState.updateWeatherForecast(forecast);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _forecast = _weatherService.getMockWeatherData();
      });
      appState.updateWeatherForecast(_weatherService.getMockWeatherData());
    }
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadWeatherData();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather Forecast'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_forecast.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather Forecast'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'No weather data available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadWeatherData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final today = _forecast[0];
    final sprayingSlots = _generateSprayingTimeSlots();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Weather Forecast',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshWeather,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather Card
              _buildCurrentWeatherCard(today),
              const SizedBox(height: 16),

              // Listen & AI Summary Section
              _buildListenAndSummarySection(today),
              const SizedBox(height: 16),

              // Daily Notification Toggle
              _buildDailyNotificationToggle(),
              const SizedBox(height: 20),

              // Next 6 Days Forecast
              _buildNextDaysForecast(_forecast),
              const SizedBox(height: 24),

              // Spraying Time Section
              _buildSprayingTimeSection(sprayingSlots),
              const SizedBox(height: 16),

              // How is it calculated?
              _buildHowCalculated(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<SprayingTimeSlot> _generateSprayingTimeSlots() {
    final now = DateTime.now();
    final slots = <SprayingTimeSlot>[];

    for (int i = 0; i < 6; i++) {
      final time = now.add(Duration(hours: i));
      SprayingCondition condition;

      final hour = time.hour;
      if (hour >= 6 && hour <= 10) {
        condition = SprayingCondition.optimal;
      } else if ((hour >= 11 && hour <= 14) || (hour >= 5 && hour <= 6)) {
        condition = SprayingCondition.moderate;
      } else {
        condition = SprayingCondition.unfavourable;
      }

      slots.add(
        SprayingTimeSlot(time: _formatTimeOfDay(time), condition: condition),
      );
    }

    return slots;
  }

  String _formatTimeOfDay(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${time.hour >= 12 ? 'pm' : 'am'}';
  }

  Widget _buildCurrentWeatherCard(WeatherForecast today) {
    final location =
        AppStateProvider.of(context).currentProfile?.location ??
        'Farm location';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      today.date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildWeatherIcon(today.weatherCondition),
            ],
          ),
          const SizedBox(height: 16),

          // Temperature
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${today.temperature.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text(
                      '${(today.temperature - 2).toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(color: Colors.white70, fontSize: 20),
                    ),
                    Text(
                      '${(today.temperature + 1).toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Weather condition
          Text(
            today.weatherCondition,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),

          // Sunset and Humidity
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              const Icon(Icons.wb_sunny, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              const Text(
                'Sunset 6:59 pm',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Icon(Icons.water_drop, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              Text(
                '${today.humidity.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Icon(Icons.air, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              Text(
                '${today.windSpeed.toStringAsFixed(0)} km/h',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor = Colors.white;

    final cond = condition.toLowerCase();
    if (cond.contains('sunny') || cond.contains('clear')) {
      iconData = Icons.wb_sunny;
    } else if (cond.contains('rain') ||
        cond.contains('drizzle') ||
        cond.contains('shower')) {
      iconData = Icons.umbrella;
    } else if (cond.contains('cloud')) {
      iconData = Icons.cloud;
    } else if (cond.contains('thunder') || cond.contains('storm')) {
      iconData = Icons.flash_on;
    } else if (cond.contains('snow')) {
      iconData = Icons.ac_unit;
    } else {
      iconData = Icons.wb_cloudy;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 32),
    );
  }

  Widget _buildListenAndSummarySection(WeatherForecast today) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPillButton(
                icon: Icons.play_arrow,
                label: 'Listen',
                onTap: () {
                  _speakText(today.aiSummary);
                },
              ),
              const SizedBox(width: 12),
              _buildPillButton(
                label: 'AI summary',
                onTap: () {
                  _showAISummaryDialog(today);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            today.aiSummary,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          if (today.bestWindow.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Best Spraying Window: ${today.bestWindow}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPillButton({
    IconData? icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.blue, size: 18),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _speakText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔊 Speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAISummaryDialog(WeatherForecast today) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Weather Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              today.aiSummary,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (today.bestWindow.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Best Spraying Window: ${today.bestWindow}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyNotificationToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Get this as a daily notification',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Switch(
            value: _dailyNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _dailyNotificationEnabled = value;
              });
              _updateNotificationPreference(value);
            },
            activeThumbColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _updateNotificationPreference(bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Daily notifications enabled'
              : 'Daily notifications disabled',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildNextDaysForecast(List<WeatherForecast> forecast) {
    final days = forecast.skip(1).take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next 6 days',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayColumn('Today', forecast[0].temperature, true),
              ...days.map(
                (day) => _buildDayColumn(day.dayName, day.temperature, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, double temp, bool isToday) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: isToday ? Colors.blue.shade700 : Colors.grey.shade600,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          temp > 0 ? '${temp.toStringAsFixed(0)}°C' : '--',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: temp > 0 ? Colors.black87 : Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: temp > 0 ? Colors.blue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildSprayingTimeSection(List<SprayingTimeSlot> slots) {
    // Group slots by condition
    final optimalSlots = slots
        .where((s) => s.condition == SprayingCondition.optimal)
        .toList();
    final moderateSlots = slots
        .where((s) => s.condition == SprayingCondition.moderate)
        .toList();
    final unfavourableSlots = slots
        .where((s) => s.condition == SprayingCondition.unfavourable)
        .toList();

    String dominantLabel = 'Moderate';
    Color dominantColor = Colors.amber;

    if (optimalSlots.length >= moderateSlots.length &&
        optimalSlots.length >= unfavourableSlots.length) {
      dominantLabel = 'Optimal';
      dominantColor = Colors.green;
    } else if (unfavourableSlots.length >= optimalSlots.length &&
        unfavourableSlots.length >= moderateSlots.length) {
      dominantLabel = 'Unfavourable';
      dominantColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spraying time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Best time to spray crops based on weather conditions',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Dominant condition card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dominantColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dominantColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: dominantColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dominantLabel,
                        style: TextStyle(
                          color: dominantColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'spraying conditions',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: slots
                      .map((slot) => _buildDynamicTimeChip(slot))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: SprayingCondition.values.map((condition) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildLegendItem(condition.color, condition.label),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTimeChip(SprayingTimeSlot slot) {
    Color chipColor;
    Color textColor;

    switch (slot.condition) {
      case SprayingCondition.optimal:
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case SprayingCondition.moderate:
        chipColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        break;
      case SprayingCondition.unfavourable:
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        slot.time,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildHowCalculated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'How is it calculated?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700,
          ),
        ),
      ),
    );
  }
}
