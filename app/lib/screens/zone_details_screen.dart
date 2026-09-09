import 'package:flutter/material.dart';
import '../models/farm_field.dart';
import '../utils/app_theme.dart';
import '../utils/field_helpers.dart';
import '../widgets/sensor_card.dart';

/// Detailed view for a single field zone.
class ZoneDetailsScreen extends StatelessWidget {
  final FieldZone zone;
  final String fieldName;

  const ZoneDetailsScreen({
    super.key,
    required this.zone,
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    final healthStatus = getHealthStatus(zone.healthScore);
    final healthColor = healthStatusColor(healthStatus);
    final moistureStatus = getMoistureStatus(zone.soilMoisture);
    final tempStatus = getTemperatureStatus(zone.temperature);
    final humidityStatus = getHumidityStatus(zone.humidity);
    final hasProblem = zone.problem != null;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text('$fieldName — ${zone.name}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Zone health header
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${zone.healthScore.round()}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: healthColor,
                        ),
                      ),
                      Text(
                        healthStatusLabel(healthStatus),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: healthColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                zone.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                hasProblem ? zone.problem! : 'Healthy',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: hasProblem
                      ? severityColor(zone.severity ?? 'Low')
                      : AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Severity badge if problem exists
            if (hasProblem && zone.severity != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: severityColor(zone.severity!)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: severityColor(zone.severity!)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: severityColor(zone.severity!)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: severityColor(zone.severity!),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${zone.severity!} Severity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: severityColor(zone.severity!),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            zone.problem!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Sensor readings
            _sectionTitle('Zone Conditions'),
            const SizedBox(height: 12),
            SensorCard(
              icon: Icons.water_drop_rounded,
              title: 'Soil Moisture',
              value: '${zone.soilMoisture.round()}',
              unit: '%',
              statusLabel: moistureStatusLabel(moistureStatus),
              statusColor: moistureStatusColor(moistureStatus),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    icon: Icons.thermostat_rounded,
                    title: 'Temperature',
                    value: '${zone.temperature.round()}',
                    unit: '°C',
                    statusLabel: temperatureStatusLabel(tempStatus),
                    statusColor: temperatureStatusColor(tempStatus),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SensorCard(
                    icon: Icons.water_outlined,
                    title: 'Humidity',
                    value: '${zone.humidity.round()}',
                    unit: '%',
                    statusLabel: humidityStatusLabel(humidityStatus),
                    statusColor: humidityStatusColor(humidityStatus),
                  ),
                ),
              ],
            ),

            // Recommendation
            if (zone.recommendation != null) ...[
              const SizedBox(height: 24),
              _sectionTitle('Recommendation'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreenSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.primaryGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'AI Recommendation',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      zone.recommendation!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This recommendation is AI-assisted and should be verified.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
