import 'package:flutter/material.dart';
import '../models/farm_field.dart';
import '../utils/app_theme.dart';
import '../utils/field_helpers.dart';

/// Visual grid representation of field zones with color-coded health.
/// Allows farmers to understand which zone has problems at a glance.
class FieldZoneMap extends StatelessWidget {
  final List<FieldZone> zones;
  final void Function(FieldZone zone) onZoneTap;

  const FieldZoneMap({
    super.key,
    required this.zones,
    required this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    if (zones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: const Center(
          child: Text(
            'No zone data available',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    // Determine grid layout based on zone count
    final crossAxisCount = zones.length <= 2 ? zones.length : 2;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view_rounded,
                  size: 16, color: AppTheme.primaryGreen),
              const SizedBox(width: 6),
              const Text(
                'Field Zone Map',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              const Text(
                'Tap a zone for details',
                style: TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: zones.length,
            itemBuilder: (context, index) {
              return _ZoneTile(
                zone: zones[index],
                onTap: () => onZoneTap(zones[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  final FieldZone zone;
  final VoidCallback onTap;

  const _ZoneTile({required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = getHealthStatus(zone.healthScore);
    final color = healthStatusColor(status);
    final hasProblem = zone.problem != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    zone.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${zone.healthScore.round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              if (hasProblem)
                Text(
                  zone.problem!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 13, color: color),
                    const SizedBox(width: 4),
                    Text(
                      'Healthy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  Icon(Icons.water_drop, size: 12, color: color),
                  const SizedBox(width: 3),
                  Text(
                    '${zone.soilMoisture.round()}%',
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.thermostat, size: 12, color: color),
                  const SizedBox(width: 3),
                  Text(
                    '${zone.temperature.round()}°C',
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
