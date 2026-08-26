import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class ScansScreen extends StatefulWidget {
  const ScansScreen({super.key});

  @override
  State<ScansScreen> createState() => _ScansScreenState();
}

class _ScansScreenState extends State<ScansScreen> {
  String? _selectedFieldId;
  String _selectedScanType = 'Crop Health Scan';
  final _dateController = TextEditingController(text: '2026-08-27');
  final _timeController = TextEditingController(text: '10:00 AM');

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(appState.translate('scans')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_outlined, color: Colors.purple),
            onPressed: () => _showRequestScanModal(context, appState),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info header banner
          Container(
            width: double.infinity,
            color: Colors.purple.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.flight_takeoff, color: Colors.purple.shade800, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drone-as-a-Service (DaaS) Platform',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade800, fontSize: 13),
                      ),
                      Text(
                        'Request localized sensor and imaging scans without owning a drone.',
                        style: TextStyle(color: Colors.purple.shade900, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showRequestScanModal(context, appState),
                  child: Text('BOOK', style: TextStyle(color: Colors.purple.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ),

          // Scans timeline list
          Expanded(
            child: appState.scans.isEmpty
                ? const Center(child: Text('No drone scans logged yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appState.scans.length,
                    itemBuilder: (context, idx) {
                      final scan = appState.scans[idx];
                      final field = appState.fields.firstWhere(
                        (f) => f.id == scan.fieldId,
                        orElse: () => CropField(
                          id: '', name: 'Unknown Field', crop: '', area: 0, areaUnit: '', sowingDate: '', cropStage: '',
                          healthScore: 0, prevHealthScore: 0, lastScanDate: '', moistureStatus: '', zones: [], sensors: [], activeAlerts: []
                        ),
                      );

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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scan.scanType,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        'Field: ${field.name} (${field.crop})',
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  _buildStatusBadge(scan.status),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('Pilot: ${scan.operatorName}', style: const TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${scan.date} @ ${scan.time}', style: const TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Progress indicators line
                              _buildTimelineProgress(scan.status),

                              if (scan.status == DroneScanStatus.aiAnalysis && appState.currentRole == 'ADMIN') ...[
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Requires Verification',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Auto verify for testing convenience
                                        appState.adminVerifyReport(scan.id, 'VERIFIED', healthScore: 82);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      child: const Text('Auto-Verify Report', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ],
                                )
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DroneScanStatus status) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade800;

    switch (status) {
      case DroneScanStatus.requested:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      case DroneScanStatus.scheduled:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        break;
      case DroneScanStatus.droneAssigned:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        break;
      case DroneScanStatus.inProgress:
        bg = Colors.teal.shade50;
        fg = Colors.teal.shade800;
        break;
      case DroneScanStatus.processing:
      case DroneScanStatus.aiAnalysis:
      case DroneScanStatus.verification:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade800;
        break;
      case DroneScanStatus.reportReady:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.displayName,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildTimelineProgress(DroneScanStatus status) {
    final stages = [
      DroneScanStatus.requested,
      DroneScanStatus.droneAssigned,
      DroneScanStatus.inProgress,
      DroneScanStatus.reportReady,
    ];

    final currentIndex = stages.indexOf(status);
    final maxIndex = currentIndex == -1 ? 2 : currentIndex; // Fallback mapping

    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isEven) {
          final stageIdx = index ~/ 2;
          final isCompleted = stageIdx <= maxIndex;
          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.purple : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          );
        } else {
          final lineIdx = index ~/ 2;
          final isCompleted = lineIdx < maxIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? Colors.purple : Colors.grey.shade300,
            ),
          );
        }
      }),
    );
  }

  void _showRequestScanModal(BuildContext context, AppState appState) {
    if (appState.fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register a field first.')),
      );
      return;
    }

    _selectedFieldId = appState.fields.first.id;

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
                  const Text(
                    'Book New Drone Scan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple),
                  ),
                  const SizedBox(height: 16),

                  // Field Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedFieldId,
                    items: appState.fields
                        .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedFieldId = val;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Select Field'),
                  ),
                  const SizedBox(height: 12),

                  // Scan Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedScanType,
                    items: ['Crop Health Scan', 'Moisture/Soil Scan', 'Full Field Analysis']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedScanType = val!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Select Scan Type'),
                  ),
                  const SizedBox(height: 12),

                  // Date & Time entries
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(labelText: 'Target Date'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _timeController,
                          decoration: const InputDecoration(labelText: 'Target Time'),
                        ),
                      ),
                    ],
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
                            if (_selectedFieldId != null) {
                              appState.requestDroneScan(
                                fieldId: _selectedFieldId!,
                                scanType: _selectedScanType,
                                date: _dateController.text,
                                time: _timeController.text,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Scan requested! Switch role to Operator/Admin to complete it.'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                          child: const Text('Confirm Booking', style: TextStyle(color: Colors.white)),
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
