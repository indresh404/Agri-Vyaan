import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/farm_field.dart';
import '../utils/field_helpers.dart';
import '../utils/app_theme.dart';

/// Reusable card widget displaying a field summary in lists.
class FieldCard extends StatelessWidget {
  final FarmField field;
  final VoidCallback onTap;

  const FieldCard({
    super.key,
    required this.field,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = getHealthStatus(field.healthScore);
    final statusLabel = healthStatusLabel(status);
    final statusColor = healthStatusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Crop icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  cropIcon(field.crop),
                  color: AppTheme.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Field info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${field.crop} • ${field.area} acres',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            field.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Health badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$statusLabel • ${field.healthScore.round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Last scan
                        Text(
                          _formatLastScan(field.lastScan),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textLight,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastScan(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
