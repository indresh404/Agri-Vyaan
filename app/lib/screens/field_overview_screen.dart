import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/farm_field.dart';
import '../services/field_storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/field_helpers.dart';
import '../widgets/health_indicator.dart';
import '../widgets/sensor_card.dart';
import '../widgets/problem_card.dart';
import '../widgets/improvement_card.dart';
import '../widgets/zone_card.dart';
import '../widgets/field_zone_map.dart';
import 'add_field_screen.dart';
import 'zone_details_screen.dart';

/// Comprehensive single-field view with health, sensors, zones, problems, and improvements.
class FieldOverviewScreen extends StatefulWidget {
  final FarmField field;
  final List<FarmField> fields;
  final FieldStorageService storageService;

  const FieldOverviewScreen({
    super.key,
    required this.field,
    required this.fields,
    required this.storageService,
  });

  @override
  State<FieldOverviewScreen> createState() => _FieldOverviewScreenState();
}

class _FieldOverviewScreenState extends State<FieldOverviewScreen> {
  late FarmField _field;

  @override
  void initState() {
    super.initState();
    _field = widget.field;
  }

  @override
  Widget build(BuildContext context) {
    final moistureStatus = getMoistureStatus(_field.soilMoisture);
    final tempStatus = getTemperatureStatus(_field.temperature);
    final humidityStatus = getHumidityStatus(_field.humidity);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // App bar with field name
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 16, right: 56),
              title: Text(
                _field.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreenSurface,
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Edit Field'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                        SizedBox(width: 8),
                        Text('Delete Field',
                            style: TextStyle(color: AppTheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Field info summary
                _buildFieldInfo(),
                const SizedBox(height: 20),

                // Health score
                _buildSectionTitle('Crop Health', Icons.favorite_rounded),
                const SizedBox(height: 12),
                Center(child: HealthIndicator(score: _field.healthScore)),
                const SizedBox(height: 24),

                // Sensor readings
                _buildSectionTitle(
                    'Field Conditions', Icons.sensors_rounded),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SensorCard(
                        icon: Icons.water_drop_rounded,
                        title: 'Soil Moisture',
                        value: '${_field.soilMoisture.round()}',
                        unit: '%',
                        statusLabel:
                            moistureStatusLabel(moistureStatus),
                        statusColor:
                            moistureStatusColor(moistureStatus),
                        isDemoData: _field.isDemoData,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SensorCard(
                        icon: Icons.thermostat_rounded,
                        title: 'Temperature',
                        value: '${_field.temperature.round()}',
                        unit: '°C',
                        statusLabel:
                            temperatureStatusLabel(tempStatus),
                        statusColor:
                            temperatureStatusColor(tempStatus),
                        isDemoData: _field.isDemoData,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SensorCard(
                        icon: Icons.water_outlined,
                        title: 'Humidity',
                        value: '${_field.humidity.round()}',
                        unit: '%',
                        statusLabel:
                            humidityStatusLabel(humidityStatus),
                        statusColor:
                            humidityStatusColor(humidityStatus),
                        isDemoData: _field.isDemoData,
                      ),
                    ),
                  ],
                ),

                // Sensor connection status
                if (_field.isDemoData) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.warning.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppTheme.warning),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Showing demo sensor values. Connect sensors or drones for live data.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Field Zones
                if (_field.zones.isNotEmpty) ...[
                  _buildSectionTitle('Field Zones', Icons.grid_view_rounded),
                  const SizedBox(height: 12),
                  FieldZoneMap(
                    zones: _field.zones,
                    onZoneTap: _openZoneDetails,
                  ),
                  const SizedBox(height: 12),
                  ..._field.zones.map(
                    (zone) => ZoneCard(
                      zone: zone,
                      onTap: () => _openZoneDetails(zone),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Active Problems
                if (_field.problems.isNotEmpty) ...[
                  _buildSectionTitle(
                      'Active Problems (${_field.problems.length})',
                      Icons.warning_amber_rounded),
                  const SizedBox(height: 12),
                  ..._field.problems.map(
                    (p) => ProblemCard(problem: p),
                  ),
                  const SizedBox(height: 24),
                ],

                // Improvements
                if (_field.improvements.isNotEmpty) ...[
                  _buildSectionTitle(
                      'Improvements Needed', Icons.lightbulb_outline),
                  const SizedBox(height: 12),
                  ..._field.improvements.map(
                    (i) => ImprovementCard(improvement: i),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.smart_toy_outlined,
                            size: 14, color: AppTheme.info),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Recommendations are AI-assisted and should be verified when required.',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // If no problems
                if (_field.problems.isEmpty) ...[
                  _buildSectionTitle('Active Problems', Icons.warning_amber_rounded),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreenSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppTheme.primaryGreen, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Problems Detected',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Your field is in good condition.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          _infoRow(Icons.agriculture, 'Crop', _field.crop),
          _infoDivider(),
          _infoRow(Icons.square_foot, 'Area', '${_field.area} acres'),
          _infoDivider(),
          _infoRow(Icons.location_on_outlined, 'Location', _field.location),
          _infoDivider(),
          _infoRow(Icons.calendar_today_outlined, 'Sowing Date',
              DateFormat('MMMM d, y').format(_field.sowingDate)),
          _infoDivider(),
          _infoRow(Icons.schedule_outlined, 'Last Scan',
              DateFormat('MMM d, y – h:mm a').format(_field.lastScan)),
          if (_field.notes != null && _field.notes!.isNotEmpty) ...[
            _infoDivider(),
            _infoRow(Icons.notes_outlined, 'Notes', _field.notes!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textLight),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoDivider() {
    return const Divider(height: 16, color: AppTheme.border);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editField();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _editField() async {
    final result = await Navigator.push<FarmField>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFieldScreen(
          fields: widget.fields,
          storageService: widget.storageService,
          existingField: _field,
        ),
      ),
    );
    if (result != null) {
      // Reload the field from storage
      final updated = await widget.storageService.loadFields();
      final refreshed = updated.firstWhere(
        (f) => f.id == _field.id,
        orElse: () => _field,
      );
      setState(() => _field = refreshed);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Delete Field?'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${_field.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              await widget.storageService
                  .deleteField(widget.fields, _field.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_field.name} deleted'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                Navigator.pop(context); // back to list
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openZoneDetails(FieldZone zone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneDetailsScreen(
          zone: zone,
          fieldName: _field.name,
        ),
      ),
    );
  }
}
