import 'package:flutter/material.dart';
import 'models/models.dart';
import 'services/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/fields_screen.dart';
import 'screens/scans_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/library_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/operator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: AppState(),
      child: MaterialApp(
        title: 'AgriSwarm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green.shade700,
            secondary: Colors.teal.shade700,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentTabIndex = 0;
  bool _showDemoConsole = true;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 768;

    // Check Authentication
    if (!appState.isLoggedIn) {
      return const AuthScreen();
    }

    // Determine content based on Active Role
    Widget activeContent = const SizedBox();
    if (appState.currentRole == 'ADMIN') {
      activeContent = const AdminScreen();
    } else if (appState.currentRole == 'OPERATOR') {
      activeContent = const OperatorScreen();
    } else {
      // Farmer Mode
      switch (_currentTabIndex) {
        case 0:
          activeContent = HomeScreen(
            onTabSelected: (idx) {
              setState(() {
                _currentTabIndex = idx;
              });
            },
            onPushScreen: (screen) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
            },
          );
          break;
        case 1:
          activeContent = const FieldsScreen();
          break;
        case 2:
          activeContent = const ScansScreen();
          break;
        case 3:
          activeContent = const ReportsScreen();
          break;
        case 4:
          activeContent = _buildMoreScreen(context, appState);
          break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Responsive Sidebar Navigation for Desktop
            if (isDesktop && appState.currentRole == 'FARMER')
              NavigationRail(
                selectedIndex: _currentTabIndex,
                onDestinationSelected: (idx) {
                  setState(() {
                    _currentTabIndex = idx;
                  });
                },
                extended: width > 1000,
                leading: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.psychology_outlined, color: Colors.green.shade800, size: 28),
                      if (width > 1000) ...[
                        const SizedBox(width: 10),
                        Text(
                          'AgriSwarm',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade900),
                        ),
                      ]
                    ],
                  ),
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                    label: Text(appState.translate('home')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.landscape_outlined),
                    selectedIcon: const Icon(Icons.landscape),
                    label: Text(appState.translate('fields')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.flight_takeoff_outlined),
                    selectedIcon: const Icon(Icons.flight_takeoff),
                    label: Text(appState.translate('scans')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.assessment_outlined),
                    selectedIcon: const Icon(Icons.assessment),
                    label: Text(appState.translate('reports')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.more_horiz_outlined),
                    selectedIcon: const Icon(Icons.more_horiz),
                    label: Text(appState.translate('more')),
                  ),
                ],
              ),
            
            // Primary content area
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: _showDemoConsole ? 70.0 : 0.0),
                      child: activeContent,
                    ),
                  ),

                  // Simulated Floating Role/Demo Console Deck
                  if (_showDemoConsole)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 8,
                      child: _buildDemoConsoleCard(context, appState),
                    ),

                  // Toggle Button for Demo Console
                  Positioned(
                    right: 16,
                    bottom: _showDemoConsole ? 80 : 16,
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          _showDemoConsole = !_showDemoConsole;
                        });
                      },
                      child: Icon(_showDemoConsole ? Icons.close : Icons.build),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Mobile Bottom Navigation Bar
      bottomNavigationBar: (!isDesktop && appState.currentRole == 'FARMER')
          ? BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: (idx) {
                setState(() {
                  _currentTabIndex = idx;
                });
              },
              selectedItemColor: Colors.green.shade800,
              unselectedItemColor: Colors.grey.shade600,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: appState.translate('home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.landscape_outlined),
                  activeIcon: const Icon(Icons.landscape),
                  label: appState.translate('fields'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.flight_takeoff_outlined),
                  activeIcon: const Icon(Icons.flight_takeoff),
                  label: appState.translate('scans'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assessment_outlined),
                  activeIcon: const Icon(Icons.assessment),
                  label: appState.translate('reports'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.more_horiz_outlined),
                  activeIcon: const Icon(Icons.more_horiz),
                  label: appState.translate('more'),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMoreScreen(BuildContext context, AppState appState) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(appState.translate('more')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMoreMenuTile(
            Icons.wb_sunny_outlined,
            appState.translate('weather_spraying'),
            '6-day forecast and best spraying windows',
            Colors.orange,
            () => _pushScreen(context, _buildWeatherPage(context, appState)),
          ),
          _buildMoreMenuTile(
            Icons.calculate_outlined,
            appState.translate('farm_tools'),
            'Fertilizer, Seed, Cost, & Irrigation calculators',
            Colors.teal,
            () => _pushScreen(context, const ToolsScreen()),
          ),
          _buildMoreMenuTile(
            Icons.library_books_outlined,
            'Agriculture Library',
            'Search Crop, Pest, and Disease directories',
            Colors.indigo,
            () => _pushScreen(context, LibraryScreen(onPushScreen: (scr) => _pushScreen(context, scr))),
          ),
          _buildMoreMenuTile(
            Icons.chat_bubble_outline,
            appState.translate('ai_assistant'),
            'Chat with farm expert AI companion',
            Colors.green,
            () => _pushScreen(context, const ChatScreen()),
          ),
          _buildMoreMenuTile(
            Icons.settings_outlined,
            'Settings & Localization',
            'Change preferred languages and simulation details',
            Colors.grey,
            () => _pushScreen(context, _buildSettingsPage(context, appState)),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout Session'),
            onPressed: () {
              appState.logout();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMoreMenuTile(IconData icon, String title, String desc, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildWeatherPage(BuildContext context, AppState appState) {
    return Scaffold(
      appBar: AppBar(title: Text(appState.translate('weather_spraying'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appState.weatherForecast.length,
        itemBuilder: (context, idx) {
          final forecast = appState.weatherForecast[idx];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${forecast.dayName} (${forecast.date})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(forecast.weatherCondition, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: forecast.sprayingCondition == 'GOOD'
                              ? Colors.green.shade50
                              : (forecast.sprayingCondition == 'AVOID' ? Colors.red.shade50 : Colors.amber.shade50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          forecast.sprayingCondition,
                          style: TextStyle(
                            color: forecast.sprayingCondition == 'GOOD'
                                ? Colors.green.shade800
                                : (forecast.sprayingCondition == 'AVOID' ? Colors.red.shade800 : Colors.amber.shade800),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniWeatherSpec(Icons.thermostat, '${forecast.temperature.toStringAsFixed(0)}°C', 'Temp'),
                      _buildMiniWeatherSpec(Icons.umbrella, '${forecast.rainProbability.toStringAsFixed(0)}%', 'Rain'),
                      _buildMiniWeatherSpec(Icons.air, '${forecast.windSpeed.toStringAsFixed(0)} km/h', 'Wind'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    forecast.aiSummary,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniWeatherSpec(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 18),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _buildSettingsPage(BuildContext context, AppState appState) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('App Localization (Language)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLangSelectBtn(appState, 'en', 'English'),
              const SizedBox(width: 8),
              _buildLangSelectBtn(appState, 'hi', 'हिंदी (Hindi)'),
              const SizedBox(width: 8),
              _buildLangSelectBtn(appState, 'mr', 'मराठी (Marathi)'),
            ],
          ),
          const Divider(height: 40),
          const Text('Farmer Account Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Demo Farmer'),
            subtitle: Text('Mobile: ${appState.currentProfile?.phone}'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Farm Location'),
            subtitle: Text(appState.currentProfile?.location ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildLangSelectBtn(AppState appState, String code, String label) {
    final isSelected = appState.currentLanguage == code;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          appState.setLanguage(code);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green.shade700 : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: 0,
          side: BorderSide(color: isSelected ? Colors.green.shade700 : Colors.grey.shade300),
        ),
        child: Text(label),
      ),
    );
  }

  // --- FLOATING DEMO CONTROL CARD ---
  Widget _buildDemoConsoleCard(BuildContext context, AppState appState) {
    return Card(
      elevation: 6,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade300, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AGRISWARM SIMULATOR',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.amber),
                ),
                Row(
                  children: [
                    const Text('Role: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: appState.currentRole,
                      items: ['FARMER', 'ADMIN', 'OPERATOR']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          appState.setRole(val);
                        }
                      },
                      underline: const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
            
            // Fast Forward Scan Steps Button
            ElevatedButton.icon(
              icon: const Icon(Icons.fast_forward, size: 14, color: Colors.white),
              label: const Text('AUTO SCAN STEP', style: TextStyle(fontSize: 10, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              onPressed: () {
                _triggerAutomaticFastForward(context, appState);
              },
            ),

            // Offline Switch
            IconButton(
              icon: Icon(appState.isOffline ? Icons.cloud_off : Icons.cloud_queue, color: appState.isOffline ? Colors.red : Colors.green),
              onPressed: () {
                appState.toggleOfflineMode();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      appState.isOffline ? 'Offline Mode activated. Actions will queue.' : 'Sync completed. Online state restored.',
                    ),
                  ),
                );
              },
              tooltip: 'Toggle Offline Cache',
            ),
          ],
        ),
      ),
    );
  }

  void _triggerAutomaticFastForward(BuildContext context, AppState appState) {
    // Find active scans that are not reportReady
    final pendingScan = appState.scans.firstWhere(
      (s) => s.status != DroneScanStatus.reportReady,
      orElse: () => DroneScan(
        id: '', fieldId: '', scanType: '', date: '', time: '', operatorName: '', status: DroneScanStatus.reportReady, verificationStatus: ''
      ),
    );

    if (pendingScan.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending drone scans in loop. Request a scan first.')),
      );
      return;
    }

    final curStatus = pendingScan.status;

    if (curStatus == DroneScanStatus.requested) {
      appState.operatorAcceptScan(pendingScan.id, 'Rajesh Kumar');
      _showFeedback(context, 'Fast-Forward: Scan status assigned to pilot Rajesh Kumar.');
    } else if (curStatus == DroneScanStatus.droneAssigned) {
      appState.operatorStartScan(pendingScan.id);
      _showFeedback(context, 'Fast-Forward: Flight launched. Status: IN PROGRESS.');
    } else if (curStatus == DroneScanStatus.inProgress) {
      appState.operatorCompleteScan(pendingScan.id);
      _showFeedback(context, 'Fast-Forward: Flight complete. Processing images. Status: PROCESSING.');
    } else if (curStatus == DroneScanStatus.processing || curStatus == DroneScanStatus.aiAnalysis || curStatus == DroneScanStatus.verification) {
      appState.adminVerifyReport(pendingScan.id, 'VERIFIED', healthScore: 82);
      _showFeedback(context, 'Fast-Forward: Expert audit complete! Outcome evaluated & published.');
    }
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
