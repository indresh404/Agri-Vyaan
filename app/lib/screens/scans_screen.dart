import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class ScansScreen extends StatefulWidget {
  const ScansScreen({super.key});

  @override
  State<ScansScreen> createState() => _ScansScreenState();

  static void showDroneTimelineDialog(BuildContext context, String scanType) {
    showDialog(
      context: context,
      builder: (context) {
        return AnimatedDroneTimelineDialog(scanType: scanType);
      },
    );
  }

  static void showRequestScanModal(BuildContext context, AppState appState) {
    if (appState.fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register a field first.')),
      );
      return;
    }

    String? selectedFieldId = appState.fields.first.id;
    String selectedScanType = 'Crop Health Scan';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
            final timeStr = selectedTime.format(context);

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
                    isExpanded: true,
                    initialValue: selectedFieldId,
                    items: appState.fields
                        .map((f) => DropdownMenuItem(value: f.id, child: Text('${f.name} (${f.crop})')))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedFieldId = val;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Select Field'),
                  ),
                  const SizedBox(height: 12),

                  // Scan Type Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedScanType,
                    items: ['Crop Health Scan', 'Pest & Disease Scan', 'Soil Moisture Audit', 'Thermal Yield Mapping']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedScanType = val!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Scan Type'),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(dateStr),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time, size: 16),
                          label: Text(timeStr),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (selectedFieldId == null) return;
                                  setModalState(() {
                                    isSaving = true;
                                  });

                                  final combinedDatetime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );

                                  await appState.requestDroneScan(
                                    fieldId: selectedFieldId!,
                                    scanType: selectedScanType,
                                    date: dateStr,
                                    time: timeStr,
                                    bookingDatetime: combinedDatetime,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScansScreen.showDroneTimelineDialog(context, selectedScanType);
                                  }
                                },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Confirm Booking', style: TextStyle(color: Colors.white)),
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

class AnimatedDroneTimelineDialog extends StatefulWidget {
  final String scanType;
  const AnimatedDroneTimelineDialog({super.key, required this.scanType});

  @override
  State<AnimatedDroneTimelineDialog> createState() => _AnimatedDroneTimelineDialogState();
}

class _AnimatedDroneTimelineDialogState extends State<AnimatedDroneTimelineDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Banner with Gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade900, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.08),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Drone Delivery Status',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.greenAccent.shade200, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent.shade400.withValues(alpha: 0.4 + (_pulseController.value * 0.6)),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE TRACKING',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Booking for "${widget.scanType}" confirmed. Track real-time fulfillment progress below:',
                    style: TextStyle(fontSize: 12.5, color: Colors.purple.shade50, height: 1.3),
                  ),
                ],
              ),
            ),

            // Scrollable Timeline Steps
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    _buildAnimatedStep(
                      stepNum: '1',
                      title: 'Request Confirmed',
                      desc: 'Drone scan request received in Agrivyaan cloud.',
                      status: 'COMPLETED',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green.shade600,
                      bgColor: Colors.green.shade50,
                      isLast: false,
                    ),
                    _buildAnimatedStep(
                      stepNum: '2',
                      title: 'Admin Approved',
                      desc: 'Drone allocation approved by Wardha Hub Center.',
                      status: 'COMPLETED',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green.shade600,
                      bgColor: Colors.green.shade50,
                      isLast: false,
                    ),
                    _buildAnimatedStep(
                      stepNum: '3',
                      title: 'Pilot Dispatched',
                      desc: 'Pilot assignment: Rajesh Kumar.\nETA to farm: 45 mins.',
                      status: 'IN PROGRESS',
                      icon: Icons.flight_rounded,
                      color: Colors.purple.shade700,
                      bgColor: Colors.purple.shade50,
                      isLast: false,
                      isInProgress: true,
                    ),
                    _buildAnimatedStep(
                      stepNum: '4',
                      title: 'Arrive at Farm Location',
                      desc: 'Drone calibration and field boundary alignment.',
                      status: 'UPCOMING',
                      icon: Icons.location_on_outlined,
                      color: Colors.grey.shade400,
                      bgColor: Colors.grey.shade100,
                      isLast: false,
                    ),
                    _buildAnimatedStep(
                      stepNum: '5',
                      title: 'Flight Execution & Scan',
                      desc: 'Autonomous multi-spectral crop scan flight.',
                      status: 'UPCOMING',
                      icon: Icons.radar_outlined,
                      color: Colors.grey.shade400,
                      bgColor: Colors.grey.shade100,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Footer action
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStep({
    required String stepNum,
    required String title,
    required String desc,
    required String status,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isLast,
    bool isInProgress = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 15),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Line and Icon Node
            Column(
              children: [
                isInProgress
                    ? AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple.shade100.withValues(alpha: 0.5 + (_pulseController.value * 0.5)),
                              border: Border.all(
                                color: Colors.purple.shade600,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.shade300.withValues(alpha: 0.4 * _pulseController.value),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Icon(icon, color: Colors.purple.shade700, size: 20),
                          );
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor,
                          border: Border.all(
                            color: color == Colors.grey.shade400 ? Colors.grey.shade300 : color,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: color == Colors.grey.shade400
                            ? Colors.grey.shade200
                            : (isInProgress ? Colors.purple.shade300 : color.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Card details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isInProgress ? Colors.purple.shade50.withValues(alpha: 0.5) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isInProgress ? Colors.purple.shade200 : Colors.grey.shade200,
                      width: isInProgress ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$stepNum. $title',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: status == 'UPCOMING' ? Colors.black54 : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: status == 'COMPLETED'
                                  ? Colors.green.shade100
                                  : (status == 'IN PROGRESS' ? Colors.purple.shade100 : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: status == 'COMPLETED'
                                    ? Colors.green.shade800
                                    : (status == 'IN PROGRESS' ? Colors.purple.shade900 : Colors.grey.shade700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.3),
                      ),
                      if (isInProgress) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            backgroundColor: Colors.purple.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ScansScreenState extends State<ScansScreen> {
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
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scan.scanType,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Field: ${field.name} (${field.crop})',
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(scan.status),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text('Pilot: ${scan.operatorName}',
                                              style: const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text('${scan.date} @ ${scan.time}',
                                              style: const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
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
    ScansScreen.showRequestScanModal(context, appState);
  }
}
