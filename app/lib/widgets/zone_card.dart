import 'package:flutter/material.dart';
import '../models/farm_field.dart';
import '../utils/app_theme.dart';
import '../utils/field_helpers.dart';

/// Card displaying a single zone's status with color-coded health.
class ZoneCard extends StatelessWidget {
  final FieldZone zone;
  final VoidCallback onTap;

  const ZoneCard({
    super.key,
    required this.zone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = getHealthStatus(zone.healthScore);
    final statusColor = healthStatusColor(status);
    final statusLabel = healthStatusLabel(status);
    final hasProblem = zone.problem != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Zone status indicator dot
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${zone.healthScore.round()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (hasProblem)
                      Text(
                        zone.problem!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: severityColor(zone.severity ?? 'Low'),
                        ),
                      )
                    else
                      Text(
                        'Healthy — $statusLabel',
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasProblem && zone.severity != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: severityColor(zone.severity!)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    zone.severity!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: severityColor(zone.severity!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
