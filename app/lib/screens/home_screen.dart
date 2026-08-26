import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/custom_widgets.dart';
import 'weather_screen.dart';
import 'tools_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTabSelected;
  final Function(Widget) onPushScreen;

  const HomeScreen({
    super.key,
    required this.onTabSelected,
    required this.onPushScreen,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    
    // Compute Farm Stats
    final fieldsCount = appState.fields.length;
    final totalArea = appState.fields.fold<double>(0, (sum, f) => sum + f.area);
    final avgHealth = fieldsCount > 0
        ? (appState.fields.fold<int>(0, (sum, f) => sum + f.healthScore) / fieldsCount).round()
        : 90;

    // Get Active Alerts
    final allAlerts = appState.fields.expand((f) => f.activeAlerts).toList();

    // Today's Weather Summary
    final todayWeather = appState.weatherForecast.first;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildTopNavBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Sync status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Namaste, ${appState.currentProfile?.name ?? "Farmer"}!',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    appState.currentProfile?.location ?? 'Your Farm Profile',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              if (appState.isOffline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, color: Colors.red.shade800, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'OFFLINE',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_done, color: Colors.green.shade800, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'CONNECTED',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Critical Alerts Panel
          if (allAlerts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${appState.translate("active_alerts")} (${allAlerts.length})',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 13),
                        ),
                        Text(
                          allAlerts.first,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => onTabSelected(1), // Go to fields tab
                    child: Text('RESOLVE', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // MY FARM SUMMARY
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.translate("my_farm").toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFarmStatColumn(fieldsCount.toString(), 'Fields'),
                      _buildDivider(),
                      _buildFarmStatColumn('${totalArea.toStringAsFixed(1)} ac', 'Total Area'),
                      _buildDivider(),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: avgHealth >= 80 ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$avgHealth/100',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: avgHealth >= 80 ? Colors.green.shade800 : Colors.orange.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Farm Health', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TODAY CARD
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.translate("today").toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeatherMiniItem(Icons.thermostat, '${todayWeather.temperature.toStringAsFixed(0)}°C', 'Temp'),
                      _buildWeatherMiniItem(Icons.water_drop, '${todayWeather.humidity.toStringAsFixed(0)}%', 'Humidity'),
                      _buildWeatherMiniItem(Icons.grain, 'Low', 'Disease Risk'),
                      _buildWeatherMiniItem(Icons.sensors, 'Moderate', 'Soil moisture'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // SPRAYING CONDITION CARD
          Text(
            appState.translate("spraying_condition"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SprayingConditionCard(
            condition: todayWeather.sprayingCondition,
            explanation: todayWeather.aiSummary,
            bestWindow: todayWeather.bestWindow,
            rainProb: todayWeather.rainProbability,
            windSpeed: todayWeather.windSpeed,
            humidity: todayWeather.humidity,
          ),
          const SizedBox(height: 20),

          // QUICK ACTIONS TILE GRID
          const Text(
            'Quick Actions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _buildQuickActionBtn(
                Icons.add_location_alt,
                'Add Field',
                Colors.blue,
                () => onTabSelected(1), // Go to fields (will open add modal)
              ),
              _buildQuickActionBtn(
                Icons.book_online,
                'Request Scan',
                Colors.purple,
                () => onTabSelected(2), // Go to Scans
              ),
              _buildQuickActionBtn(
                Icons.wb_sunny_outlined,
                'Weather & Spray',
                Colors.orange,
                () => onPushScreen(const WeatherScreen()),
              ),
              _buildQuickActionBtn(
                Icons.calculate_outlined,
                'Farm Tools',
                Colors.teal,
                () => onPushScreen(const ToolsScreen()),
              ),
              _buildQuickActionBtn(
                Icons.chat_bubble_outline_rounded,
                'Ask AI',
                Colors.green,
                () => onPushScreen(const ChatScreen()),
              ),
              _buildQuickActionBtn(
                Icons.assessment_outlined,
                'View Report',
                Colors.red,
                () => onTabSelected(3), // Reports
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  Widget _buildFarmStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildWeatherMiniItem(IconData icon, String val, String desc) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 22),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
      ],
    );
  }

  Widget _buildQuickActionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
                        Icon(Icons.home, color: Colors.green.shade800, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Home',
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
