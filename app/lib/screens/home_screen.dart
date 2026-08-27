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
    const String reportDate = '27 Aug 2026';

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
            const SizedBox(height: 16),

            // DYNAMIC WEATHER & SPRAYING CONDITIONS HEADER (LEFT: Date/Temp, RIGHT: Spray Condition)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.shade100),
              ),
              color: Colors.green.shade50.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Side: Date and Temp
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reportDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.thermostat, color: Colors.orange.shade700, size: 28),
                            const SizedBox(width: 4),
                            Text(
                              '${todayWeather.temperature.toStringAsFixed(0)}°C',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Right Side: Spraying Condition
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'SPRAY CONDITION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: todayWeather.sprayingCondition == 'OPTIMAL' || todayWeather.sprayingCondition == 'GOOD'
                                ? Colors.green.shade700
                                : Colors.amber.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                todayWeather.sprayingCondition == 'OPTIMAL' || todayWeather.sprayingCondition == 'GOOD'
                                    ? Icons.check_circle
                                    : Icons.warning,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                todayWeather.sprayingCondition,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Critical Alerts Panel (If any)
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
                            'Active Alerts (${allAlerts.length})',
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

            // FARM TOOLS CALCULATORS SECTION
            const Text(
              'Farm Tools',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildToolQuickCard(
                    'Fertilizer Calculator',
                    Icons.opacity,
                    Colors.green.shade700,
                    () => onPushScreen(const ToolsScreen(initialCalculator: 'fertilizer')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildToolQuickCard(
                    'Pesticide Calculator',
                    Icons.pest_control,
                    Colors.orange.shade800,
                    () => onPushScreen(const ToolsScreen(initialCalculator: 'pesticide')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildToolQuickCard(
                    'Farming Calculator',
                    Icons.payments,
                    Colors.teal.shade700,
                    () => onPushScreen(const ToolsScreen(initialCalculator: 'cost')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),

            // --- AGRISWARM LIBRARY SECTION ---
            const Text(
              'Crops Library',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap any crop to view growing conditions, soil parameters & cultivation tips.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            
            // Crops Box Grid (Rice, Wheat, Cotton, Tomato, Maize, Sugarcane)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
              children: _mockCrops.map((crop) => _buildCropBoxCard(context, crop)).toList(),
            ),
            const SizedBox(height: 24),

            // PESTS & DISEASES LIBRARY SECTION
            const Text(
              'Pests & Diseases Library',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap on a pest/disease to see diagnostics, prevention, and control methods.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Pests Grid Layout
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.8,
              children: _mockPests.map((pest) => _buildPestBoxCard(context, pest)).toList(),
            ),
            const SizedBox(height: 24),

            // CULTIVATION QUICK TIPS CAROUSAL/LIST
            const Text(
              'Cultivation Tips',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            _buildQuickTipsList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildToolQuickCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropBoxCard(BuildContext context, _CropLibraryItem crop) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => _showCropDetailsSheet(context, crop),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grass, color: Colors.green.shade800, size: 20),
              const SizedBox(height: 6),
              Text(
                crop.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade900),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPestBoxCard(BuildContext context, _PestLibraryItem pest) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => _showPestDetailsSheet(context, pest),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bug_report, color: Colors.red.shade900, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pest.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red.shade900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Crop: ${pest.crop}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTipsList() {
    final tips = [
      'Perform deep summer tillage to destroy hibernating pests and soil pathogens naturally.',
      'Adopt drip irrigation instead of flooding. It can save up to 40% water and reduce weed growth.',
      'Apply nitrogen fertilizer in split doses rather than all at once to minimize run-off loss.',
      'Rotate cereal crops like wheat and maize with leguminous crops like cowpea to fix soil nitrogen.',
    ];

    return Column(
      children: tips.map((tip) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
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

  // --- DETAILS BOTTOM SHEET DIALOGS ---

  void _showCropDetailsSheet(BuildContext context, _CropLibraryItem crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      crop.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.green),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Growing Guide',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  crop.description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const Divider(height: 32),
                
                const Text(
                  'GROWING CONDITIONS & SOIL',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade200, width: 1, borderRadius: BorderRadius.circular(8)),
                  children: [
                    TableRow(children: [
                      _buildTableCell('Temperature', crop.temp),
                      _buildTableCell('Rainfall/Water', crop.rain),
                    ]),
                    TableRow(children: [
                      _buildTableCell('Sowing Period', crop.sowing),
                      _buildTableCell('Soil Type', crop.soilType),
                    ]),
                    TableRow(children: [
                      _buildTableCell('Soil pH', crop.soilPh),
                      _buildTableCell('Fertilizer (N:P:K)', crop.npk),
                    ]),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'CULTIVATION TIPS',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 12),
                ...crop.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_alt, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                
                const Text(
                  'COMMON PESTS & REMEDIES',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 12),
                ...crop.pests.map((pest) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pest['name'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pest['solution'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableCell(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  void _showPestDetailsSheet(BuildContext context, _PestLibraryItem pest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pest.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.red.shade900),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pest Diagnostic',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Affects crop: ${pest.crop}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const Divider(height: 24),
              const Text(
                'SYMPTOMS & DAMAGE',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Text(
                pest.symptoms,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                'PREVENTION MEASURES',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Text(
                pest.prevention,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                'TREATMENT & CONTROL',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Text(
                pest.solution,
                style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Dismiss', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- MOCK LIBRARY DATA ---

class _CropLibraryItem {
  final String name;
  final String description;
  final String temp;
  final String rain;
  final String sowing;
  final String soilPh;
  final String soilType;
  final String npk;
  final List<String> tips;
  final List<Map<String, String>> pests;

  const _CropLibraryItem({
    required this.name,
    required this.description,
    required this.temp,
    required this.rain,
    required this.sowing,
    required this.soilPh,
    required this.soilType,
    required this.npk,
    required this.tips,
    required this.pests,
  });
}

class _PestLibraryItem {
  final String name;
  final String crop;
  final String symptoms;
  final String prevention;
  final String solution;

  const _PestLibraryItem({
    required this.name,
    required this.crop,
    required this.symptoms,
    required this.prevention,
    required this.solution,
  });
}

const List<_CropLibraryItem> _mockCrops = [
  _CropLibraryItem(
    name: 'Rice (Paddy)',
    description: 'The primary staple food of India. Cultivated mostly under flooded, puddled wetland conditions during the Kharif season.',
    temp: '22°C - 32°C',
    rain: '150 - 300 cm',
    sowing: 'June - July (Kharif)',
    soilPh: '5.5 - 6.5',
    soilType: 'Clayey loam / Silty clay',
    npk: '120:60:40 kg/ha',
    tips: [
      'Ensure continuous standing water of 2-5 cm during the vegetative stage.',
      'Transplant healthy seedlings that are 21-25 days old into puddled field.',
      'Drain the field water 10-15 days before harvesting for uniform ripening.',
    ],
    pests: [
      {'name': 'Leaf Blast (Disease)', 'solution': 'Spindle-shaped spots on leaves. Spray Tricyclazole at first sight.'},
      {'name': 'Yellow Stem Borer', 'solution': ' Larvae chew stems leading to dead hearts. Apply Chlorantraniliprole granules.'},
    ],
  ),
  _CropLibraryItem(
    name: 'Wheat',
    description: 'A major Rabi crop in Northern and Central India. Prefers a cool, moist growing phase and dry, sunny harvesting phase.',
    temp: '15°C - 25°C',
    rain: '75 - 100 cm',
    sowing: 'Nov - Dec (Rabi)',
    soilPh: '6.0 - 7.5',
    soilType: 'Loamy soil / Clay loam',
    npk: '100:50:25 kg/ha',
    tips: [
      'First irrigation is critical at the Crown Root Initiation (CRI) stage, around 21 days after sowing.',
      'Prepare a clean, fine tilth seedbed to allow uniform seed germination.',
      'Harvest when grains are mature, dry (below 12% moisture), and golden-yellow.',
    ],
    pests: [
      {'name': 'Yellow Rust (Disease)', 'solution': 'Powdery yellow stripes on leaves. Apply Propiconazole 25 EC.'},
      {'name': 'Wheat Aphids', 'solution': 'Suck juice from ears and leaves. Spray neem seed kernel extract (NSKE).'},
    ],
  ),
  _CropLibraryItem(
    name: 'Cotton',
    description: 'An important cash crop of India. Widely grown in black cotton soils. Extremely sensitive to waterlogging.',
    temp: '21°C - 30°C',
    rain: '50 - 100 cm',
    sowing: 'May - June',
    soilPh: '6.0 - 8.0',
    soilType: 'Black cotton soil (Regur)',
    npk: '80:40:40 kg/ha',
    tips: [
      'Perform deep summer ploughing to expose pupae of pink bollworm to heat and predators.',
      'Maintain an optimum plant spacing of 60 x 30 cm to maximize boll development.',
      'Avoid excess nitrogen application in late stages to prevent boll shedding and rot.',
    ],
    pests: [
      {'name': 'Pink Bollworm', 'solution': 'Larvae bore into cotton bolls. Hang pheromone traps and use Bt varieties.'},
      {'name': 'Whitefly', 'solution': 'Transmit leaf curl virus. Spray Diafenthiuron or Imidacloprid.'},
    ],
  ),
  _CropLibraryItem(
    name: 'Tomato',
    description: 'A highly productive commercial vegetable grown round the year. Thrives in warm, sunny weather with stable irrigation.',
    temp: '20°C - 28°C',
    rain: '60 - 80 cm',
    sowing: 'Oct - Nov / Feb - Mar',
    soilPh: '6.0 - 7.0',
    soilType: 'Sandy loam with organic matter',
    npk: '90:60:60 kg/ha',
    tips: [
      'Provide sturdy trellis or staking support to prevent fruits from touching the soil.',
      'Apply mulching to conserve moisture, prevent weeds, and reduce blight diseases.',
      'Add calcium nitrate to prevent blossom end rot, which is caused by calcium deficiency.',
    ],
    pests: [
      {'name': 'Early Blight (Disease)', 'solution': 'Concentric ring spots on leaves. Spray Mancozeb or Copper Oxychloride.'},
      {'name': 'Tomato Fruit Borer', 'solution': 'Holes in fruits. Use Helicoverpa pheromone traps and spray Spinosad.'},
    ],
  ),
  _CropLibraryItem(
    name: 'Maize (Corn)',
    description: 'Versatile crop used for grain, fodder, and raw material. Grows on a variety of soils with excellent drainage.',
    temp: '21°C - 27°C',
    rain: '50 - 100 cm',
    sowing: 'June - July',
    soilPh: '5.8 - 7.0',
    soilType: 'Loamy sand / Well-drained loam',
    npk: '120:60:40 kg/ha',
    tips: [
      'Ensure the field is completely free of weeds during the first 30-45 days of growth.',
      'Silking and tasseling stages are highly sensitive to water stress. Irrigate during these times.',
      'Intercrop with blackgram or cowpea to manage weeds and increase soil nutrients.',
    ],
    pests: [
      {'name': 'Fall Armyworm', 'solution': 'Voracious leaf feeding. Apply Spinetoram 11.7 SC or Chlorantraniliprole.'},
      {'name': 'Turcicum Leaf Blight', 'solution': 'Cigar-shaped gray lesions. Spray Zineb or Mancozeb.'},
    ],
  ),
  _CropLibraryItem(
    name: 'Sugarcane',
    description: 'A long-duration high water-demand cash crop. Requires hot and humid climate for growth, cold dry weather for maturity.',
    temp: '20°C - 35°C',
    rain: '150 - 250 cm',
    sowing: 'Jan - Mar (Spring)',
    soilPh: '6.5 - 7.5',
    soilType: 'Heavy clay loam / Alluvial soil',
    npk: '150:80:60 kg/ha',
    tips: [
      'Use healthy 3-budded setts treated with Trichoderma for planting to prevent seed-borne rot.',
      'Carry out earthing-up operations at 4 months to prevent crop lodging (falling down).',
      'Adopt trash mulching in inter-rows to conserve soil moisture and suppress weeds.',
    ],
    pests: [
      {'name': 'Red Rot (Disease)', 'solution': 'Red internal tissues with white bands. Plant disease-resistant varieties.'},
      {'name': 'Sugarcane Top Borer', 'solution': 'Dead hearts in shoots. Release Trichogramma chilonis wasps.'},
    ],
  ),
];

const List<_PestLibraryItem> _mockPests = [
  _PestLibraryItem(
    name: 'Fall Armyworm',
    crop: 'Maize / Sorghum',
    symptoms: 'Ragged, torn holes in leaves, whorl damage, sawdust-like golden frass inside the plant shoot.',
    prevention: 'Deep summer ploughing, intercropping with leguminous crops, and planting trap crops like Napier grass.',
    solution: 'For chemical control, spray Spinetoram 11.7% SC or Emamectin Benzoate 5% SG directly into the plant whorls.',
  ),
  _PestLibraryItem(
    name: 'Leaf Blast',
    crop: 'Rice (Paddy)',
    symptoms: 'Spindle-shaped lesions on leaves with gray centers and reddish-brown borders. Can choke node and neck joints.',
    prevention: 'Avoid excess nitrogen fertilizer, use wider crop spacing, and burn crop debris of the previous harvest.',
    solution: 'Foliar spray of Tricyclazole 75% WP or Isoprothiolane 40% EC at early detection.',
  ),
  _PestLibraryItem(
    name: 'Pink Bollworm',
    crop: 'Cotton',
    symptoms: 'Rosette flowers, bored holes on cotton bolls, stained lint, damaged seeds, and premature boll opening.',
    prevention: 'Strict crop termination, crop rotation, pheromone trap deployment, and growing BT seed varieties.',
    solution: 'Spray Chlorantraniliprole 18.5% SC or Cypermethrin 10% EC when trap catches cross ETL threshold.',
  ),
  _PestLibraryItem(
    name: 'Early Blight',
    crop: 'Tomato / Potato',
    symptoms: 'Circular black/brown leaf spots with concentric target-board pattern. Defoliation of lower leaves.',
    prevention: 'Drip irrigation, staking to lift leaves from ground, mulching, and crop rotation with non-solanaceous crops.',
    solution: 'Spray Mancozeb 75% WP or Copper Oxychloride 50% WP at first spotting.',
  ),
];
