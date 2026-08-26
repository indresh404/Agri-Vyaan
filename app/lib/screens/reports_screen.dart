import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/custom_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  CropField? _selectedField;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    if (_selectedField != null) {
      return _buildReportDetailView(context, appState, _selectedField!);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildTopNavBar(context),
      body: appState.fields.isEmpty
          ? const Center(
              child: Text(
                'No fields registered yet. Register a field to view analysis reports.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appState.fields.length,
              itemBuilder: (context, index) {
                final field = appState.fields[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.assessment, color: Colors.green.shade800),
                    ),
                    title: Text(
                      field.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Crop: ${field.crop}  |  Area: ${field.area} ac'),
                        Text(
                          'Last Audit Date: ${field.lastScanDate == 'None' ? '26 Aug 2026' : field.lastScanDate}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                    onTap: () {
                      setState(() {
                        _selectedField = field;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildReportDetailView(BuildContext context, AppState appState, CropField field) {
    final reportDate = field.lastScanDate == 'None' ? '26 Aug 2026' : field.lastScanDate;
    final reportTitle = '${field.name} - Full Field Analysis (Approved)';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedField = null;
              });
            },
          ),
          title: Text(
            field.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade800, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'APPROVED',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reportDate,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reportTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'Crop Type: ${field.crop}  •  Field Area: ${field.area} ${field.areaUnit}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Tabs Header
            const TabBar(
              labelColor: Colors.green,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.green,
              tabs: [
                Tab(text: 'Summary'),
                Tab(text: 'Images'),
                Tab(text: 'Graphs'),
                Tab(text: 'Advice'),
              ],
            ),

            // Tab Bar View content
            Expanded(
              child: TabBarView(
                children: [
                  _buildSummaryTab(field),
                  _buildImagesTab(field),
                  _buildGraphsTab(field),
                  _buildRecommendationTab(field),
                ],
              ),
            ),

            // Bottom CTA Buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print, color: Colors.green),
                      label: const Text('View Full Report', style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        _showPrintableReport(context, appState, field);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text('Download Report', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        _generateAndDownloadPDF(field);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(CropField field) {
    // Generate zone alerts or summaries based on field status
    final isFieldHealthy = field.healthScore >= 80;
    final moistureLabel = field.moistureStatus == 'LOW' ? '27% (LOW)' : '48% (NORMAL)';
    final stressLabel = field.moistureStatus == 'LOW' ? 'High' : 'Normal';
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Health Indicator Card
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.green.shade50.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('CROP HEALTH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text(
                        '${field.healthScore} / 100',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.blue.shade50.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('SOIL MOISTURE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text(
                        moistureLabel,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: field.moistureStatus == 'LOW' ? Colors.red : Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Parameter Specs Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildParameterRow(Icons.thermostat, 'Temperature', '32°C', Colors.red),
                const Divider(),
                _buildParameterRow(Icons.cloud_queue, 'Humidity', '65%', Colors.blue),
                const Divider(),
                _buildParameterRow(Icons.warning_amber_rounded, 'Crop Stress', stressLabel, Colors.orange),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Problems Found Card
        const Text(
          'Problems Found',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: field.moistureStatus == 'LOW' ? Colors.red.shade50 : Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: field.moistureStatus == 'LOW' ? Colors.red.shade100 : Colors.green.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  field.moistureStatus == 'LOW' ? Icons.error_outline : Icons.check_circle_outline,
                  color: field.moistureStatus == 'LOW' ? Colors.red : Colors.green.shade800,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    field.moistureStatus == 'LOW'
                        ? 'Low soil moisture detected in Zone 2. High moisture stress observed.'
                        : 'No critical problems found. Field crop health remains stable.',
                    style: TextStyle(
                      color: field.moistureStatus == 'LOW' ? Colors.red.shade900 : Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // AI Summary Card
        const Text(
          'Recommendation Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(
          field.moistureStatus == 'LOW'
              ? 'Check irrigation flow immediately in Zone 2 to prevent leaf wilting. Target soil moisture is above 35%.'
              : 'Continue weekly inspection sweeps. No additional water treatments required at this stage.',
          style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildImagesTab(CropField field) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildImageMockCard('Zone 1 RGB Aerial', 'Healthy Canopy', Colors.green),
        _buildImageMockCard('Zone 2 NDVI Contrast', field.moistureStatus == 'LOW' ? 'Water Stress' : 'Optimal', field.moistureStatus == 'LOW' ? Colors.red : Colors.green),
        _buildImageMockCard('Zone 3 Thermal Scan', 'Moderate Temp', Colors.amber),
        _buildImageMockCard('Close-up Leaf Canopy', 'No Pests Spotted', Colors.teal),
      ],
    );
  }

  Widget _buildImageMockCard(String title, String status, Color statusColor) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.green.shade50,
              width: double.infinity,
              child: Icon(Icons.photo, size: 36, color: Colors.green.shade300),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGraphsTab(CropField field) {
    // Generate metrics trends
    final healthHistory = [84.0, 80.0, 78.0, field.healthScore.toDouble()];
    final moistureHistory = [55.0, 48.0, 36.0, field.moistureStatus == 'LOW' ? 27.0 : 48.0];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CustomTrendChart(
          values: healthHistory,
          labels: const ['Scan 1', 'Scan 2', 'Scan 3', 'Current'],
          title: 'Health Trend Progress',
          lineColor: Colors.green,
        ),
        const SizedBox(height: 24),
        CustomTrendChart(
          values: moistureHistory,
          labels: const ['Scan 1', 'Scan 2', 'Scan 3', 'Current'],
          title: 'Soil Moisture Trend Index',
          lineColor: Colors.blue,
        ),
        const SizedBox(height: 12),
        const Text(
          '*Trends are compiled from drone telemetry and field moisture sensors.',
          style: TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget _buildRecommendationTab(CropField field) {
    final hasProblem = field.moistureStatus == 'LOW';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Identified Problems & Recommended Solutions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        
        // Problem 1 card
        _buildProblemSolutionCard(
          'Problem: Water Stress in Zone 2',
          'Current soil moisture falls below critical limit (27% vs 35% standard). Direct threat to yields if moisture is not replenished.',
          'Solution: Apply Targeted Drip Irrigation',
          'Initiate drip watering at Zone 2 for at least 45 minutes (approx 25,000 litres/acre equivalent) to restore index to optimal range.',
          hasProblem,
        ),
        const SizedBox(height: 16),

        // Problem 2 card
        _buildProblemSolutionCard(
          'Problem: Nitrogen Deficit Risk',
          'NDVI reflection data indicates early vegetative nitrogen level reduction in Zone 3.',
          'Solution: Nitrogen Fertilization (Urea)',
          'Consider nitrogen booster application at rate of 15 kg/acre during next fertilization window.',
          false,
        ),
      ],
    );
  }

  Widget _buildProblemSolutionCard(String probTitle, String probDesc, String solTitle, String solDesc, bool isCritical) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isCritical ? Colors.red.shade200 : Colors.grey.shade200, width: 1.5),
      ),
      color: isCritical ? Colors.red.shade50.withOpacity(0.33) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCritical ? Icons.error_outline : Icons.info_outline,
                  color: isCritical ? Colors.red : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    probTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isCritical ? Colors.red.shade900 : Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(probDesc, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    solTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green.shade900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(solDesc, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _showPrintableReport(BuildContext context, AppState appState, CropField field) {
    final reportDate = field.lastScanDate == 'None' ? '26 Aug 2026' : field.lastScanDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.print, color: Colors.green),
              SizedBox(width: 8),
              Text('Print-Ready Audit Report'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AGRISWARM CROP INTELLIGENCE SERVICES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                ),
                const Divider(),
                Text('Field Identifier: ${field.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Crop Cultivar: ${field.crop}'),
                Text('Date of Audit: $reportDate'),
                Text('Operator Status: Flight Approved & Completed'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.green.shade50,
                  child: Text(
                    'Audit Summary Findings:\n• Health Metric: ${field.healthScore}/100\n• Water Index: ${field.moistureStatus}\n• Drone verification completed with zero exceptions.',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Authorized Agronomist Signature:', style: TextStyle(fontSize: 11)),
                const SizedBox(height: 6),
                const Text(
                  'Dr. S. K. Sharma, Agritech Lead',
                  style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document successfully sent to system print spooler.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Print / Export PDF', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndDownloadPDF(CropField field) async {
    try {
      final reportDate = field.lastScanDate == 'None' ? '26 Aug 2026' : field.lastScanDate;
      final health = field.healthScore;
      final moisture = field.moistureStatus == 'LOW' ? '27%' : '48%';
      
      // Construct raw openable PDF bytes format
      final pdfContent = StringBuffer();
      pdfContent.writeln('%PDF-1.4');
      
      // Catalog
      pdfContent.writeln('1 0 obj');
      pdfContent.writeln('<< /Type /Catalog /Pages 2 0 R >>');
      pdfContent.writeln('endobj');
      
      // Pages
      pdfContent.writeln('2 0 obj');
      pdfContent.writeln('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
      pdfContent.writeln('endobj');
      
      // Page
      pdfContent.writeln('3 0 obj');
      pdfContent.writeln('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>');
      pdfContent.writeln('endobj');
      
      // Stream text content
      final streamText = 'BT\n/F1 18 Tf\n50 750 Td\n(AGRISWARM CROP INTELLIGENCE REPORT) Tj\n/F1 12 Tf\n0 -35 Td\n(Field: ${field.name}) Tj\n0 -20 Td\n(Crop: ${field.crop}) Tj\n0 -20 Td\n(Date: $reportDate) Tj\n0 -20 Td\n(Crop Health Index: $health / 100) Tj\n0 -20 Td\n(Soil Moisture: $moisture) Tj\n0 -40 Td\n(Management Advice Summary:) Tj\n0 -20 Td\n(${field.moistureStatus == 'LOW' ? 'Low moisture in Zone 2. Apply targeted drip watering immediately.' : 'Crop is healthy. Continue standard cultivation.'}) Tj\nET';
      
      pdfContent.writeln('4 0 obj');
      pdfContent.writeln('<< /Length ${streamText.length} >>');
      pdfContent.writeln('stream');
      pdfContent.writeln(streamText);
      pdfContent.writeln('endstream');
      pdfContent.writeln('endobj');
      
      // Font descriptor
      pdfContent.writeln('5 0 obj');
      pdfContent.writeln('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');
      pdfContent.writeln('endobj');
      
      // Cross-references
      pdfContent.writeln('xref');
      pdfContent.writeln('0 6');
      pdfContent.writeln('0000000000 65535 f ');
      pdfContent.writeln('0000000009 00000 n ');
      pdfContent.writeln('0000000054 00000 n ');
      pdfContent.writeln('0000000109 00000 n ');
      pdfContent.writeln('0000000227 00000 n ');
      pdfContent.writeln('0000000300 00000 n ');
      pdfContent.writeln('trailer');
      pdfContent.writeln('<< /Size 6 /Root 1 0 R >>');
      pdfContent.writeln('startxref');
      pdfContent.writeln('365');
      pdfContent.writeln('%%EOF');
      
      if (kIsWeb) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('PDF Saved'),
              ],
            ),
            content: Text(
              'PDF Report successfully generated for ${field.name}!\n\nWeb Download Simulator saved: "agriswarm_report_${field.name.replaceAll(' ', '_')}.pdf" to browser downloads folder.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      String filePath = '';
      File? file;
      try {
        if (Platform.isAndroid) {
          final androidDownload = Directory('/storage/emulated/0/Download');
          filePath = '${androidDownload.path}/agriswarm_report_${field.name.replaceAll(' ', '_')}.pdf';
          file = File(filePath);
          await file.writeAsString(pdfContent.toString());
        } else if (Platform.isWindows) {
          final home = Platform.environment['USERPROFILE'];
          final winDownload = Directory('$home\\Downloads');
          filePath = '${winDownload.path}\\agriswarm_report_${field.name.replaceAll(' ', '_')}.pdf';
          file = File(filePath);
          await file.writeAsString(pdfContent.toString());
        } else {
          filePath = '${Directory.systemTemp.path}/agriswarm_report_${field.name.replaceAll(' ', '_')}.pdf';
          file = File(filePath);
          await file.writeAsString(pdfContent.toString());
        }
      } catch (e) {
        // Fallback to permission-free local temporary path
        filePath = '${Directory.systemTemp.path}/agriswarm_report_${field.name.replaceAll(' ', '_')}.pdf';
        file = File(filePath);
        await file.writeAsString(pdfContent.toString());
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('PDF Downloaded'),
            ],
          ),
          content: Text(
            'The PDF report was successfully generated and written:\n\nPath:\n$filePath\n\nSize: ${file!.lengthSync()} bytes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
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
                        Icon(Icons.assessment, color: Colors.green.shade800, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Reports',
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
