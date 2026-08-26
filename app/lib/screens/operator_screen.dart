import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class OperatorScreen extends StatefulWidget {
  const OperatorScreen({super.key});

  @override
  State<OperatorScreen> createState() => _OperatorScreenState();
}

class _OperatorScreenState extends State<OperatorScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    // Get jobs assigned to operators or scheduled
    final assignedJobs = appState.scans.where((s) => 
      s.status == DroneScanStatus.droneAssigned || 
      s.status == DroneScanStatus.scheduled ||
      s.status == DroneScanStatus.inProgress
    ).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Drone Pilot Console'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operator profile header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.flight, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilot Terminal Active',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                        Text(
                          'Mock Operator Name: Rajesh Kumar',
                          style: TextStyle(color: Colors.purple.shade100, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'My Flight Scans Queue',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            if (assignedJobs.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No active flight jobs assigned.', style: TextStyle(fontSize: 13)),
                  ),
                ),
              )
            else
              ...assignedJobs.map((scan) {
                final field = appState.fields.firstWhere((f) => f.id == scan.fieldId, orElse: () => appState.fields.first);
                return _buildJobCard(context, appState, scan, field);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, AppState appState, DroneScan scan, CropField field) {
    final isInProgress = scan.status == DroneScanStatus.inProgress;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(scan.scanType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                _buildMiniStatusBadge(scan.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Field Target: ${field.name} (${field.crop})', style: const TextStyle(fontSize: 13)),
            Text('Scheduled: ${scan.date} @ ${scan.time}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const Divider(height: 24),

            if (isInProgress) ...[
              // Telemetry simulation bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTelemetryIndicator(Icons.battery_charging_full, '84%', 'Battery'),
                  _buildTelemetryIndicator(Icons.satellite_alt, '18 satellites', 'GPS Lock'),
                  _buildTelemetryIndicator(Icons.height, '12 m', 'Altitude'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                  label: const Text('UPLOAD TELEMETRY & MULTISPECTRAL IMAGES', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    appState.operatorCompleteScan(scan.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Telemetry uploaded. Scan status is now: PROCESSING.')),
                    );
                  },
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_outlined, color: Colors.white),
                  label: const Text('START FLIGHT SCAN', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
                  onPressed: () {
                    appState.operatorStartScan(scan.id);
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatusBadge(DroneScanStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: status == DroneScanStatus.inProgress ? Colors.teal.shade50 : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: status == DroneScanStatus.inProgress ? Colors.teal.shade800 : Colors.purple.shade800,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTelemetryIndicator(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple.shade700, size: 20),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
