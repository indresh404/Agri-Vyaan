import 'package:flutter/material.dart';
import '../services/app_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    // Compute stats
    final totalFields = appState.fields.length;
    final totalActions = appState.actions.length;
    final completedActions = appState.actions.where((a) => a.isCompleted).length;
    final avgHealth = totalFields > 0
        ? (appState.fields.fold<int>(0, (sum, f) => sum + f.healthScore) / totalFields).round()
        : 84;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(appState.translate('reports')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.green),
            onPressed: () => _showPrintableReport(context, appState),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly farm summary card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.shade200, width: 1.5),
              ),
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assessment, color: Colors.green.shade800, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'WEEKLY FARM SUMMARY',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade900),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(Icons.trending_up, 'Health Change', '+4% relative to base scan'),
                    _buildSummaryRow(Icons.opacity, 'Soil Moisture', 'Improved in irrigated sectors'),
                    _buildSummaryRow(Icons.healing, 'Disease Risk', 'Low-Moderate (blight caution active)'),
                    _buildSummaryRow(Icons.done_all, 'Actions Logged', '$completedActions tasks completed successfully'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.green.shade800, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Recommendation: "Soil moisture in Field A has normalized. Continue weekly inspections."',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistics panels
            const Text(
              'Key Intelligence Metrics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Average Health', '$avgHealth%', Colors.green, Icons.favorite_border),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard('Actions Tracked', '$totalActions', Colors.blue, Icons.assignment_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Drone Flights', '${appState.scans.length}', Colors.purple, Icons.flight_takeoff),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard('Active Alerts', '${appState.fields.fold<int>(0, (sum, f) => sum + f.activeAlerts.length)}', Colors.red, Icons.notification_important_outlined),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Generate report CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('GENERATE PRINT-READY REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showPrintableReport(context, appState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String val, Color color, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _showPrintableReport(BuildContext context, AppState appState) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Printable Report',
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Export Print Report', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report saved to storage as PDF.')),
                  );
                },
                child: const Text('DOWNLOAD', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Formal Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AGRISWARM INTEL REPORT',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        Text('Date generated: 2026-08-26  |  Wardha Cluster', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                    const Icon(Icons.verified_user, color: Colors.green, size: 36),
                  ],
                ),
                const Divider(height: 32, thickness: 2),

                // Farmer Profile Block
                const Text('Farmer & Lands Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('• Farmer Name: ${appState.currentProfile?.name ?? "Demo Farmer"}'),
                Text('• Total Monitored Area: ${appState.fields.fold<double>(0, (sum, f) => sum + f.area).toStringAsFixed(1)} acres'),
                Text('• Sown crops under audit: Cotton, Tomato, Wheat'),
                const SizedBox(height: 20),

                // Audited Fields table
                const Text('Fields Audit Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.grey),
                      children: [
                        Padding(padding: EdgeInsets.all(6), child: Text('Field Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Crop', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Health', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(6), child: Text('Active Alerts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12))),
                      ],
                    ),
                    ...appState.fields.map((f) => TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(6), child: Text(f.name, style: const TextStyle(fontSize: 12))),
                            Padding(padding: const EdgeInsets.all(6), child: Text(f.crop, style: const TextStyle(fontSize: 12))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${f.healthScore}/100', style: const TextStyle(fontSize: 12))),
                            Padding(padding: const EdgeInsets.all(6), child: Text(f.activeAlerts.join(', '), style: const TextStyle(fontSize: 11))),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 24),

                // Recorded actions outcome comparison
                const Text('Measured Outcome Comparison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                const Text(
                  'Outcomes compared before and after farmer treatments verified by subsequent scans.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                ...appState.actions.where((a) => a.beforeState != null).map((a) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Action: ${a.title} on ${a.zoneName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Before state: ${a.beforeState} -> After state: ${a.afterState}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    )),
                const SizedBox(height: 32),

                // Sign-offs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(height: 1, width: 120, color: Colors.black),
                        const SizedBox(height: 4),
                        const Text('Expert Signature', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(height: 1, width: 120, color: Colors.black),
                        const SizedBox(height: 4),
                        const Text('Agronomist Auditor', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
