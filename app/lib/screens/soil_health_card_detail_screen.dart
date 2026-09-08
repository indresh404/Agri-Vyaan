import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/soil_health_card.dart';
import '../utils/app_theme.dart';

/// Read-only detail view for a historical Soil Health Card record.
class SoilHealthCardDetailScreen extends StatelessWidget {
  final SoilHealthCard card;
  final String fieldName;

  const SoilHealthCardDetailScreen({
    super.key,
    required this.card,
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final year = card.sampleDate?.year.toString() ??
        card.uploadDate.year.toString();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil Health Card — $year',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              fieldName,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: card.isCurrent
                      ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      card.isCurrent
                          ? Icons.verified_rounded
                          : Icons.history_rounded,
                      size: 14,
                      color: card.isCurrent
                          ? AppTheme.primaryGreen
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      card.isCurrent ? 'Current Record' : 'Historical Record',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: card.isCurrent
                            ? AppTheme.primaryGreen
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (card.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outlined,
                          size: 14, color: AppTheme.success),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Card info
          _buildInfoCard([
            if (card.cardNumber != null)
              _InfoRow('Card Number', card.cardNumber!),
            if (card.sampleId != null)
              _InfoRow('Sample ID', card.sampleId!),
            if (card.sampleDate != null)
              _InfoRow('Sample Date', dateFormat.format(card.sampleDate!)),
            _InfoRow('Upload Date', dateFormat.format(card.uploadDate)),
          ]),
          const SizedBox(height: 16),

          // Farmer details
          _buildSectionTitle('Farmer & Sample Details'),
          const SizedBox(height: 10),
          _buildInfoCard([
            if (card.farmerName != null)
              _InfoRow('Farmer Name', card.farmerName!),
            if (card.fatherHusbandName != null)
              _InfoRow('Father/Husband', card.fatherHusbandName!),
            if (card.village != null)
              _InfoRow('Village', card.village!),
            if (card.tehsil != null)
              _InfoRow('Tehsil', card.tehsil!),
            if (card.district != null)
              _InfoRow('District', card.district!),
            if (card.state != null) _InfoRow('State', card.state!),
            if (card.totalLandHolding != null)
              _InfoRow('Land Holding', card.totalLandHolding!),
            if (card.soilType != null)
              _InfoRow('Soil Type', card.soilType!),
            if (card.soilColour != null)
              _InfoRow('Soil Colour', card.soilColour!),
            if (card.soilTexture != null)
              _InfoRow('Soil Texture', card.soilTexture!),
          ]),
          const SizedBox(height: 16),

          // Soil test results
          _buildSectionTitle('Soil Test Results'),
          const SizedBox(height: 10),
          _buildTestResults(),
          const SizedBox(height: 16),

          // Recommendations
          if (card.fertilizerRecommendations.isNotEmpty ||
              card.nutrientRecommendations.isNotEmpty) ...[
            _buildSectionTitle('Recommendations'),
            const SizedBox(height: 10),
            _buildListCard(
              [
                ...card.fertilizerRecommendations,
                ...card.nutrientRecommendations,
              ],
              Icons.lightbulb_outline_rounded,
            ),
            const SizedBox(height: 16),
          ],

          // Crop suggestions
          if (card.cropRecommendations.isNotEmpty) ...[
            _buildSectionTitle('Crop Suggestions'),
            const SizedBox(height: 10),
            _buildListCard(
              card.cropRecommendations,
              Icons.agriculture_outlined,
            ),
            const SizedBox(height: 16),
          ],

          // Source file
          if (card.sourceFileName != null) ...[
            _buildSectionTitle('Source Document'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined,
                      color: AppTheme.primaryGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      card.sourceFileName!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.eco_rounded, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    final filtered = rows.where((r) => r.value.isNotEmpty).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: filtered.asMap().entries.map((entry) {
          final row = entry.value;
          final isLast = entry.key == filtered.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        row.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 12, color: AppTheme.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTestResults() {
    if (card.nutrients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: const Center(
          child: Text(
            'No soil test data available.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: NutrientCategory.values.map((category) {
        final readings = card.getNutrientsByCategory(category);
        if (readings.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            children: [
              // Category header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSurface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreenDark,
                  ),
                ),
              ),
              // Data rows
              ...readings.map((r) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: AppTheme.border, width: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            r.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            r.value.toStringAsFixed(
                                r.value == r.value.roundToDouble()
                                    ? 0
                                    : 2),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            r.unit.isEmpty ? '—' : r.unit,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(r.status)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r.status.displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(r.status),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListCard(List<String> items, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon,
                          size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Color _statusColor(NutrientStatus status) {
    switch (status) {
      case NutrientStatus.normal:
      case NutrientStatus.sufficient:
        return AppTheme.success;
      case NutrientStatus.medium:
        return AppTheme.warning;
      case NutrientStatus.low:
      case NutrientStatus.deficient:
        return AppTheme.error;
      case NutrientStatus.high:
        return AppTheme.info;
    }
  }
}

/// Simple data holder for info rows.
class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
