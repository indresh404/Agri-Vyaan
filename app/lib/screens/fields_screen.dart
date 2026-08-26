import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/custom_widgets.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();

  static void showAddFieldDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    String selectedUnit = 'acres';
    String selectedCrop = 'Cotton';
    String selectedStage = 'Germination stage';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Register New Field'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Field Name (e.g. Field D)'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: areaController,
                            decoration: const InputDecoration(labelText: 'Area Size'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            items: const [
                              DropdownMenuItem(value: 'acres', child: Text('acres')),
                              DropdownMenuItem(value: 'hectares', child: Text('hectares')),
                            ],
                            onChanged: (val) {
                              setDialogState(() {
                                selectedUnit = val!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCrop,
                      items: ['Cotton', 'Tomato', 'Wheat', 'Rice', 'Soybean']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedCrop = val!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Select Crop'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStage,
                      items: const [
                        DropdownMenuItem(value: 'Germination stage', child: Text('Germination stage')),
                        DropdownMenuItem(value: 'Vegetative stage', child: Text('Vegetative stage')),
                        DropdownMenuItem(value: 'Flowering stage', child: Text('Flowering stage')),
                        DropdownMenuItem(value: 'Fruiting stage', child: Text('Fruiting stage')),
                        DropdownMenuItem(value: 'Harvest stage', child: Text('Harvest stage')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedStage = val!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Crop Lifecycle Stage'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && areaController.text.isNotEmpty) {
                      final newField = CropField(
                        id: 'field_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        crop: selectedCrop,
                        area: double.parse(areaController.text),
                        areaUnit: selectedUnit,
                        sowingDate: '2026-08-26',
                        cropStage: selectedStage,
                        healthScore: 90,
                        prevHealthScore: 90,
                        lastScanDate: 'None',
                        moistureStatus: 'NORMAL',
                        activeAlerts: [],
                        zones: [
                          Zone(
                            id: 'z1',
                            name: 'Zone 1',
                            status: 'Healthy',
                            moisture: 50,
                            temperature: 28,
                            risk: 'None',
                            aiExplanation: 'Field conditions are within normal limits.',
                            recommendation: 'Monitor regularly.',
                          ),
                          Zone(
                            id: 'z2',
                            name: 'Zone 2',
                            status: 'Healthy',
                            moisture: 50,
                            temperature: 28,
                            risk: 'None',
                            aiExplanation: 'Field conditions are within normal limits.',
                            recommendation: 'Monitor regularly.',
                          ),
                        ],
                        sensors: [],
                      );
                      appState.addField(newField);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void showGlobalRecordActionModal(BuildContext context, AppState appState) {
    if (appState.fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register a field first.')),
      );
      return;
    }

    String selectedFieldId = appState.fields.first.id;
    CropField selectedField = appState.fields.first;
    String selectedZoneId = selectedField.zones.isNotEmpty ? selectedField.zones.first.id : 'z1';
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Treatment / Action',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade800),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedFieldId,
                    items: appState.fields
                        .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedFieldId = val!;
                        selectedField = appState.fields.firstWhere((f) => f.id == selectedFieldId);
                        selectedZoneId = selectedField.zones.isNotEmpty ? selectedField.zones.first.id : 'z1';
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Select Field'),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedZoneId,
                    items: selectedField.zones
                        .map((z) => DropdownMenuItem(value: z.id, child: Text(z.name)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedZoneId = val!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Select Zone'),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Actions/Notes taken (e.g. Applied Drip Irrigation)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (notesController.text.isNotEmpty) {
                              final zone = selectedField.zones.firstWhere((z) => z.id == selectedZoneId, orElse: () => selectedField.zones.first);
                              appState.recordAction(
                                fieldId: selectedField.id,
                                title: notesController.text,
                                category: zone.status.toLowerCase().contains('moisture') ? 'Water' : 'Nutrient',
                                zoneName: zone.name,
                                notes: 'Farmer action applied at zone. Simulation pipeline activated.',
                                beforeState: {
                                  'Moisture': '${zone.moisture.toStringAsFixed(0)}%',
                                  'Stress': zone.status.toUpperCase(),
                                },
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Action recorded successfully! Simulation activated.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Save Action', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FieldsScreenState extends State<FieldsScreen> {
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  String _selectedCrop = 'Cotton';
  String _selectedStage = 'Vegetative stage';
  String _selectedUnit = 'acres';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildTopNavBar(context),
      body: appState.fields.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No fields registered yet.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddFieldDialog(context, appState),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                    child: const Text('Add your first field', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appState.fields.length,
              itemBuilder: (context, idx) {
                final field = appState.fields[idx];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FieldDetailScreen(fieldId: field.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                field.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Health: ${field.healthScore}',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildChip(Icons.grass, field.crop),
                              const SizedBox(width: 8),
                              _buildChip(Icons.straighten, '${field.area} ${field.areaUnit}'),
                              const SizedBox(width: 8),
                              _buildChip(Icons.timelapse, field.cropStage),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Moisture: ${field.moistureStatus}',
                                    style: TextStyle(
                                      color: field.moistureStatus == 'LOW' ? Colors.red : Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Last scan: ${field.lastScanDate}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade800, fontSize: 11)),
        ],
      ),
    );
  }

  void _showAddFieldDialog(BuildContext context, AppState appState) {
    FieldsScreen.showAddFieldDialog(context, appState);
  }

  PreferredSizeWidget _buildTopNavBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.green.shade800, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'AgriSwarm',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.landscape, color: Colors.green.shade800, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Fields',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- FIELD DETAIL SCREEN ---
class FieldDetailScreen extends StatefulWidget {
  final String fieldId;

  const FieldDetailScreen({super.key, required this.fieldId});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Zone? _selectedZone;
  final _actionNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    
    // Check if field exists
    final fieldExists = appState.fields.any((f) => f.id == widget.fieldId);
    if (!fieldExists) {
      return Scaffold(
        appBar: AppBar(title: const Text('Field Details')),
        body: const Center(child: Text('Field not found.')),
      );
    }

    final field = appState.fields.firstWhere((f) => f.id == widget.fieldId);
    final fieldActions = appState.actions.where((a) => a.fieldId == field.id).toList();
    final fieldScans = appState.scans.where((s) => s.fieldId == field.id).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(field.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green.shade800,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.green.shade700,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'IoT Sensors'),
            Tab(text: 'Actions'),
            Tab(text: 'Scans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview & Map
          _buildOverviewTab(context, appState, field, fieldActions),
          // 2. IoT Sensors
          _buildSensorsTab(context, field),
          // 3. Actions History
          _buildActionsTab(context, appState, field, fieldActions),
          // 4. Scans History
          _buildScansTab(context, fieldScans),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, AppState appState, CropField field, List<ActionEntry> actions) {
    // Check if there is an active irrigation action with before/after state to show outcome comparison
    final feedbackAction = actions.firstWhere(
      (a) => a.title.contains('Irrigation') || a.beforeState != null,
      orElse: () => actions.isNotEmpty ? actions.first : ActionEntry(
        id: '', fieldId: '', title: '', category: '', zoneName: '', date: '', notes: '', isCompleted: false
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop lifecycle card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  HealthScoreCircle(score: field.healthScore, prevScore: field.prevHealthScore, size: 100),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.crop.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 13),
                        ),
                        Text(
                          'Stage: ${field.cropStage}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sown on: ${field.sowingDate}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        Text(
                          'Moisture status: ${field.moistureStatus}',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: field.moistureStatus == 'LOW' ? Colors.red : Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Interactive zone map
          const Text(
            'Interactive Zone Map (USP)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap a zone below to inspect its detailed parameters.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          InteractiveZoneMap(
            zones: field.zones,
            onZoneSelected: (zone) {
              setState(() {
                _selectedZone = zone;
              });
            },
          ),
          const SizedBox(height: 16),

          // Selected zone details panel
          if (_selectedZone != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedZone!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedZone!.status == 'Healthy' ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _selectedZone!.status.toUpperCase(),
                          style: TextStyle(
                            color: _selectedZone!.status == 'Healthy' ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Moisture: ${_selectedZone!.moisture.toStringAsFixed(0)}%  |  Temperature: ${_selectedZone!.temperature.toStringAsFixed(0)}°C',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Divider(height: 20),
                  Text(
                    'AI Finding: ${_selectedZone!.aiExplanation}',
                    style: TextStyle(color: Colors.grey.shade800, height: 1.3, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recommendation: ${_selectedZone!.recommendation}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showWhyModal(context, _selectedZone!),
                          child: const Text('WHY?'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showRecordActionModal(context, appState, field, _selectedZone!),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                          child: const Text('RECORD ACTION', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Before -> Action -> After visual feedback loop
          if (feedbackAction.id.isNotEmpty) ...[
            const Text(
              'Measured Outcome Feed',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            BeforeAfterCard(
              title: feedbackAction.title,
              zoneName: feedbackAction.zoneName,
              date: feedbackAction.date,
              beforeState: feedbackAction.beforeState,
              actionTaken: feedbackAction.title,
              afterState: feedbackAction.afterState,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorsTab(BuildContext context, CropField field) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: field.sensors.length,
      itemBuilder: (context, idx) {
        final sensor = field.sensors[idx];
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sensor.sensorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sensor.status == 'NORMAL' ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sensor.status,
                        style: TextStyle(
                          color: sensor.status == 'NORMAL' ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${sensor.currentValue}${sensor.unit}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Normal range: ${sensor.minNormal} - ${sensor.maxNormal}${sensor.unit}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 16),
                CustomTrendChart(
                  values: sensor.history,
                  labels: List.generate(sensor.history.length, (i) => 'T-${sensor.history.length - 1 - i}'),
                  title: '${sensor.sensorName} Trend Chart',
                  lineColor: sensor.status == 'NORMAL' ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionsTab(BuildContext context, AppState appState, CropField field, List<ActionEntry> actions) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Logged Actions History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Log Action', style: TextStyle(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                onPressed: () {
                  if (field.zones.isNotEmpty) {
                    _showRecordActionModal(context, appState, field, field.zones.first);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: actions.isEmpty
              ? const Center(child: Text('No actions recorded yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: actions.length,
                  itemBuilder: (context, idx) {
                    final act = actions[idx];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: Icon(Icons.check, color: Colors.green.shade800),
                        ),
                        title: Text(act.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Zone: ${act.zoneName}  |  Date: ${act.date}', style: const TextStyle(fontSize: 11)),
                            if (act.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(act.notes, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                            ],
                          ],
                        ),
                        isThreeLine: act.notes.isNotEmpty,
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }

  Widget _buildScansTab(BuildContext context, List<DroneScan> scans) {
    return scans.isEmpty
        ? const Center(child: Text('No drone scans logged yet for this field.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scans.length,
            itemBuilder: (context, idx) {
              final scan = scans[idx];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flight_takeoff, color: Colors.purple.shade700),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.scanType,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text('Pilot: ${scan.operatorName}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            Text('Date: ${scan.date} @ ${scan.time}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              scan.verificationStatus,
                              style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Health: ${scan.healthScore}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
  }

  void _showWhyModal(BuildContext context, Zone zone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Explanation - WHY?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade800),
              ),
              const SizedBox(height: 16),
              Text(
                'Finding: ${zone.status}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                zone.aiExplanation,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Data Sources Correlated:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text('• Drone Multispectral NIR reflection drops\n• Local moisture IoT sensor readings\n• Historical zone trend correlation'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecordActionModal(BuildContext context, AppState appState, CropField field, Zone zone) {
    _actionNotesController.text = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Treatment / Action',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade800),
              ),
              const SizedBox(height: 8),
              Text('Field: ${field.name}  |  Zone: ${zone.name}', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              Text('Recommended action: ${zone.recommendation}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
              const SizedBox(height: 16),
              TextField(
                controller: _actionNotesController,
                decoration: const InputDecoration(
                  labelText: 'Actions/Notes taken (e.g. Applied Drip Irrigation)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_actionNotesController.text.isNotEmpty) {
                          appState.recordAction(
                            fieldId: field.id,
                            title: _actionNotesController.text,
                            category: zone.status.toLowerCase().contains('moisture') ? 'Water' : 'Nutrient',
                            zoneName: zone.name,
                            notes: 'Farmer action applied at zone. Simulation pipeline activated.',
                            beforeState: {
                              'Moisture': '${zone.moisture.toStringAsFixed(0)}%',
                              'Stress': zone.status.toUpperCase(),
                            },
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Action recorded successfully! Simulation activated.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Save Action', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
