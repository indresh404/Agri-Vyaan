import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/models.dart';

// --- HEALTH SCORE CIRCLE ---
class HealthScoreCircle extends StatelessWidget {
  final int score;
  final int prevScore;
  final double size;

  const HealthScoreCircle({
    super.key,
    required this.score,
    required this.prevScore,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final diff = score - prevScore;
    final isImprovement = diff >= 0;
    Color scoreColor = Colors.green.shade700;
    if (score < 60) {
      scoreColor = Colors.red.shade700;
    } else if (score < 80) {
      scoreColor = Colors.orange.shade700;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _CircleProgressPainter(
                  progress: score / 100.0,
                  color: scoreColor,
                  backgroundColor: Colors.grey.shade200,
                  strokeWidth: size * 0.1,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: size * 0.12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (diff != 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isImprovement ? Icons.arrow_upward : Icons.arrow_downward,
                color: isImprovement ? Colors.green.shade700 : Colors.red.shade700,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                '${isImprovement ? "+" : ""}$diff since last scan',
                style: TextStyle(
                  color: isImprovement ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          )
        else
          Text(
            'Stable health score',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- INTERACTIVE ZONE MAP ---
class InteractiveZoneMap extends StatefulWidget {
  final List<Zone> zones;
  final Function(Zone) onZoneSelected;

  const InteractiveZoneMap({
    super.key,
    required this.zones,
    required this.onZoneSelected,
  });

  @override
  State<InteractiveZoneMap> createState() => _InteractiveZoneMapState();
}

class _InteractiveZoneMapState extends State<InteractiveZoneMap> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.zones.isNotEmpty) {
      // Trigger callback on first build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.zones.length > _selectedIndex) {
          widget.onZoneSelected(widget.zones[_selectedIndex]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.zones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No zones configured for this field')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid View representing Zones
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: widget.zones.length,
          itemBuilder: (context, idx) {
            final zone = widget.zones[idx];
            final isSelected = _selectedIndex == idx;
            
            Color cardColor = Colors.green.shade50;
            Color borderColor = Colors.green.shade200;
            Color textColor = Colors.green.shade800;
            IconData icon = Icons.check_circle_outline;

            if (zone.status.toLowerCase().contains('moisture') || zone.status.toLowerCase().contains('water')) {
              cardColor = Colors.blue.shade50;
              borderColor = Colors.blue.shade200;
              textColor = Colors.blue.shade800;
              icon = Icons.opacity;
            } else if (zone.status.toLowerCase().contains('disease') || zone.status.toLowerCase().contains('pest') || zone.status.toLowerCase().contains('stress')) {
              cardColor = Colors.orange.shade50;
              borderColor = Colors.orange.shade300;
              textColor = Colors.orange.shade800;
              icon = Icons.warning_amber_rounded;
            }

            if (isSelected) {
              borderColor = textColor;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = idx;
                });
                widget.onZoneSelected(zone);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 3.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: textColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          zone.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Icon(icon, color: textColor, size: 20),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moisture: ${zone.moisture.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            zone.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// --- CUSTOM TREND LINE CHART ---
class CustomTrendChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String title;
  final double height;
  final Color lineColor;

  const CustomTrendChart({
    super.key,
    required this.values,
    required this.labels,
    this.title = 'Trend Indicator',
    this.height = 140,
    this.lineColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No historical data available')),
      );
    }

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
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height - 50,
              child: Row(
                children: [
                  // Y Axis Min/Max indicators
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${values.reduce(math.max).toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                      Text(
                        '${values.reduce(math.min).toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomPaint(
                      painter: _LineChartPainter(
                        data: values,
                        color: lineColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // X Axis Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Offset for Y axis label
                ...labels.map(
                  (label) => Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.01)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final valRange = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final double stepX = size.width / (data.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      // Invert Y coordinate since Canvas starts from top left
      final double normalizedY = (data[i] - minVal) / valRange;
      final double y = size.height - (normalizedY * (size.height - 10) + 5);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw dot
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- BEFORE-ACTION-AFTER CARD ---
class BeforeAfterCard extends StatelessWidget {
  final String title;
  final String zoneName;
  final String date;
  final Map<String, String>? beforeState;
  final String actionTaken;
  final Map<String, String>? afterState;

  const BeforeAfterCard({
    super.key,
    required this.title,
    required this.zoneName,
    required this.date,
    this.beforeState,
    required this.actionTaken,
    this.afterState,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasOutcome = afterState != null && afterState!.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade100, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.green.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Continuous Feedback Loop',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Before Column
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BEFORE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (beforeState != null)
                              ...beforeState!.entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e.key,
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      Text(
                                        e.value,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const Text('Low Soil Moisture (27%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Arrow symbol
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
                      child: Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400),
                    ),

                    // After Column
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hasOutcome ? Colors.green.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: hasOutcome ? Colors.green.shade200 : Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AFTER SCAN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: hasOutcome ? Colors.green.shade800 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (hasOutcome)
                              ...afterState!.entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e.key,
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      Text(
                                        e.value,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Pending new scan to measure...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Action Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.build_circle, color: Colors.orange.shade800, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FARMER ACTION RECORDED',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                            ),
                            Text(
                              actionTaken,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                if (hasOutcome) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Verified Improvement Outcome Detected!',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- SPRAYING CONDITION CARD ---
class SprayingConditionCard extends StatelessWidget {
  final String condition; // GOOD, MODERATE, AVOID
  final String explanation;
  final String bestWindow;
  final double rainProb;
  final double windSpeed;
  final double humidity;

  const SprayingConditionCard({
    super.key,
    required this.condition,
    required this.explanation,
    required this.bestWindow,
    required this.rainProb,
    required this.windSpeed,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = Colors.green.shade50;
    Color borderColor = Colors.green.shade200;
    Color mainColor = Colors.green.shade700;
    IconData icon = Icons.check_circle;
    String statusText = 'RECOMMENDED';

    if (condition == 'AVOID') {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      mainColor = Colors.red.shade700;
      icon = Icons.cancel;
      statusText = 'AVOID SPRAYING';
    } else if (condition == 'MODERATE') {
      cardColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade300;
      mainColor = Colors.amber.shade800;
      icon = Icons.warning_amber_rounded;
      statusText = 'MODERATE CAUTION';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: mainColor, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: mainColor,
                          ),
                        ),
                        Text(
                          'Weather Spraying Window',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  explanation,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                if (bestWindow.isNotEmpty && bestWindow.toLowerCase() != 'none')
                  Row(
                    children: [
                      Icon(Icons.access_time_filled, color: Colors.grey.shade700, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Best Window: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                      Text(
                        bestWindow,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          Divider(color: borderColor, height: 1),
          
          // Weather metrics grid
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(Icons.umbrella, '${rainProb.toStringAsFixed(0)}%', 'Rain'),
                _buildMetricColumn(Icons.air, '${windSpeed.toStringAsFixed(0)} km/h', 'Wind'),
                _buildMetricColumn(Icons.water_drop, '${humidity.toStringAsFixed(0)}%', 'Humidity'),
              ],
            ),
          ),
          
          // Disclaimer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Text(
              '⚠️ Spray timings are weather-based guidelines. Consult product label.',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
