import 'package:flutter/material.dart';

/// Health status levels for fields and zones.
enum HealthStatus { good, fair, poor }

/// Moisture status levels.
enum MoistureStatus { low, normal, high }

/// Temperature status levels.
enum TemperatureStatus { low, normal, high }

/// Humidity status levels.
enum HumidityStatus { low, normal, high }

/// Determines the health status from a numeric score (0–100).
HealthStatus getHealthStatus(double score) {
  if (score >= 75) return HealthStatus.good;
  if (score >= 50) return HealthStatus.fair;
  return HealthStatus.poor;
}

/// Display label for a health status.
String healthStatusLabel(HealthStatus status) {
  switch (status) {
    case HealthStatus.good:
      return 'Good';
    case HealthStatus.fair:
      return 'Fair';
    case HealthStatus.poor:
      return 'Poor';
  }
}

/// Color for a health status.
Color healthStatusColor(HealthStatus status) {
  switch (status) {
    case HealthStatus.good:
      return const Color(0xFF078A48);
    case HealthStatus.fair:
      return const Color(0xFFF59E0B);
    case HealthStatus.poor:
      return const Color(0xFFEF4444);
  }
}

/// Determines the moisture status from a percentage (0–100).
MoistureStatus getMoistureStatus(double moisture) {
  if (moisture < 30) return MoistureStatus.low;
  if (moisture <= 60) return MoistureStatus.normal;
  return MoistureStatus.high;
}

/// Display label for a moisture status.
String moistureStatusLabel(MoistureStatus status) {
  switch (status) {
    case MoistureStatus.low:
      return 'Low';
    case MoistureStatus.normal:
      return 'Normal';
    case MoistureStatus.high:
      return 'High';
  }
}

/// Color for a moisture status.
Color moistureStatusColor(MoistureStatus status) {
  switch (status) {
    case MoistureStatus.low:
      return const Color(0xFFEF4444);
    case MoistureStatus.normal:
      return const Color(0xFF078A48);
    case MoistureStatus.high:
      return const Color(0xFF3B82F6);
  }
}

/// Determines temperature status from °C value.
TemperatureStatus getTemperatureStatus(double temp) {
  if (temp < 15) return TemperatureStatus.low;
  if (temp <= 35) return TemperatureStatus.normal;
  return TemperatureStatus.high;
}

/// Display label for a temperature status.
String temperatureStatusLabel(TemperatureStatus status) {
  switch (status) {
    case TemperatureStatus.low:
      return 'Low';
    case TemperatureStatus.normal:
      return 'Normal';
    case TemperatureStatus.high:
      return 'High';
  }
}

/// Color for a temperature status.
Color temperatureStatusColor(TemperatureStatus status) {
  switch (status) {
    case TemperatureStatus.low:
      return const Color(0xFF3B82F6);
    case TemperatureStatus.normal:
      return const Color(0xFF078A48);
    case TemperatureStatus.high:
      return const Color(0xFFEF4444);
  }
}

/// Determines humidity status from a percentage.
HumidityStatus getHumidityStatus(double humidity) {
  if (humidity < 40) return HumidityStatus.low;
  if (humidity <= 70) return HumidityStatus.normal;
  return HumidityStatus.high;
}

/// Display label for a humidity status.
String humidityStatusLabel(HumidityStatus status) {
  switch (status) {
    case HumidityStatus.low:
      return 'Low';
    case HumidityStatus.normal:
      return 'Normal';
    case HumidityStatus.high:
      return 'High';
  }
}

/// Color for a humidity status.
Color humidityStatusColor(HumidityStatus status) {
  switch (status) {
    case HumidityStatus.low:
      return const Color(0xFFF59E0B);
    case HumidityStatus.normal:
      return const Color(0xFF078A48);
    case HumidityStatus.high:
      return const Color(0xFF3B82F6);
  }
}

/// Color for problem severity.
Color severityColor(String severity) {
  switch (severity.toLowerCase()) {
    case 'high':
      return const Color(0xFFEF4444);
    case 'medium':
      return const Color(0xFFF59E0B);
    case 'low':
      return const Color(0xFF3B82F6);
    default:
      return const Color(0xFF6B7280);
  }
}

/// Icon for a given crop name.
IconData cropIcon(String crop) {
  switch (crop.toLowerCase()) {
    case 'wheat':
      return Icons.grass;
    case 'cotton':
      return Icons.cloud;
    case 'paddy':
    case 'rice':
      return Icons.water_drop;
    case 'maize':
    case 'corn':
      return Icons.spa;
    case 'tomato':
      return Icons.local_florist;
    case 'potato':
      return Icons.eco;
    default:
      return Icons.agriculture;
  }
}
