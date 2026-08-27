import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<String> _operators = ['Rajesh Kumar', 'Amit Patil', 'Vijay Shinde'];
  String _selectedOperator = 'Rajesh Kumar';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    // Filter requests
    final pendingAssignments = appState.scans.where((s) => s.status == DroneScanStatus.requested).toList();
    final pendingVerifications = appState.scans.where((s) => s.status == DroneScanStatus.aiAnalysis || s.status == DroneScanStatus.processing).toList();
    final completedReports = appState.scans.where((s) => s.status == DroneScanStatus.reportReady).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Expert / Admin Panel'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin summary cards
            Row(
              children: [
                Expanded(child: _buildMetricCard('Total Farmers', '1', Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Fields', '${appState.fields.length}', Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Active Alerts', '${appState.fields.fold<int>(0, (sum, f) => sum + f.activeAlerts.length)}', Colors.red)),
              ],
            ),
            const SizedBox(height: 24),

            // Section 1: Assign pilots
            const Text(
              'Drone Requests Assignment Queue',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (pendingAssignments.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No pending drone bookings.', style: TextStyle(fontSize: 13))),
                ),
              )
            else
              ...pendingAssignments.map((scan) {
                final field = appState.fields.firstWhere((f) => f.id == scan.fieldId, orElse: () => appState.fields.first);
                return _buildAssignmentCard(context, appState, scan, field);
              }),

            const SizedBox(height: 24),

            // Section 2: Review AI findings
            const Text(
              'AI Findings Verification Queue',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (pendingVerifications.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No reports awaiting expert verification.', style: TextStyle(fontSize: 13))),
                ),
              )
            else
              ...pendingVerifications.map((scan) {
                final field = appState.fields.firstWhere((f) => f.id == scan.fieldId, orElse: () => appState.fields.first);
                return _buildVerificationCard(context, appState, scan, field);
              }),

            const SizedBox(height: 24),

            // Section 3: Completed scans
            const Text(
              'Verified Audit History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...completedReports.map((scan) {
              final field = appState.fields.firstWhere((f) => f.id == scan.fieldId, orElse: () => appState.fields.first);
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.verified, color: Colors.green)),
                title: Text('${field.name} - ${scan.scanType}'),
                subtitle: Text('Verified on: ${scan.date}  |  Health Score: ${scan.healthScore}/100'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text(scan.verificationStatus, style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, AppState appState, DroneScan scan, CropField field) {
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
                Text('Scheduled: ${scan.date}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Field: ${field.name} (${field.crop} | ${field.area} ac)', style: const TextStyle(fontSize: 13)),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedOperator,
                    items: _operators.map((op) => DropdownMenuItem(value: op, child: Text(op, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedOperator = val!;
                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    appState.operatorAcceptScan(scan.id, _selectedOperator);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Assigned pilot $_selectedOperator successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text('Assign Pilot', style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard(BuildContext context, AppState appState, DroneScan scan, CropField field) {
    int revisedScore = scan.healthScore;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange.shade200, width: 1.5),
      ),
      color: Colors.orange.shade50.withOpacity(0.5),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(scan.scanType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                  child: const Text('REQUIRES AUDIT', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Field: ${field.name} (${field.crop})  |  Pilot: ${scan.operatorName}', style: const TextStyle(fontSize: 12)),
            const Divider(height: 24),
            const Text(
              'AI Finding Summary:\n• Water stress warning in Zone 2 (moisture levels dropped to 27%).\n• Biomass reduction indicates potential health index decrement.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(builder: (context, setStateScore) {
              return Row(
                children: [
                  const Text('Adjust Verified Health Index:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: revisedScore.toDouble(),
                      min: 50,
                      max: 100,
                      divisions: 50,
                      activeColor: Colors.orange,
                      label: '$revisedScore',
                      onChanged: (val) {
                        setStateScore(() {
                          revisedScore = val.round();
                        });
                      },
                    ),
                  ),
                  Text('$revisedScore/100', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              );
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      appState.adminVerifyReport(scan.id, 'REQUIRES REVIEW', healthScore: revisedScore);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    child: const Text('Reject/Redo', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      appState.adminVerifyReport(scan.id, 'VERIFIED', healthScore: revisedScore);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audit finalized and report published to farmer.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Verify & Publish', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
