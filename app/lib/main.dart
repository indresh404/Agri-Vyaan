import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
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
import 'screens/profile_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint("Supabase initialization error: $e");
  }
  runApp(const AgrivyaanApp());
}


class AgrivyaanApp extends StatelessWidget {
  const AgrivyaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: AppState(),
      child: MaterialApp(
        title: 'Agrivyaan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
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

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => screen),
              );
            },
          );
          break;
        case 1:
          activeContent = const FieldsScreen();
          break;
        case 2:
          activeContent = const SizedBox.shrink();
          break;
        case 3:
          activeContent = const ReportsScreen();
          break;
        case 4:
          activeContent = const ProfileScreen();
          break;
      }
    }

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Row(
          children: [
            // Responsive Sidebar Navigation for Desktop
            if (isDesktop && appState.currentRole == 'FARMER')
              NavigationRail(
                selectedIndex: _currentTabIndex,
                onDestinationSelected: (idx) {
                  if (idx == 2) {
                    _showActionSelectionModal(context, appState);
                  } else {
                    setState(() {
                      _currentTabIndex = idx;
                    });
                  }
                },
                extended: width > 1000,
                leading: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.psychology_outlined,
                          color: AppTheme.primaryGreen, size: 28),
                      if (width > 1000) ...[
                        const SizedBox(width: 10),
                        const Text(
                          'Agrivyaan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primaryGreen,
                          ),
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
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppTheme.primaryGreen),
                    selectedIcon:
                        const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                    label: Text(appState.translate('add_field')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.assessment_outlined),
                    selectedIcon: const Icon(Icons.assessment),
                    label: Text(appState.translate('reports')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: Text(appState.translate('profile')),
                  ),
                ],
              ),

            // Primary content area
            Expanded(
              child: activeContent,
            ),
          ],
        ),
      ),
      bottomNavigationBar: (!isDesktop && appState.currentRole == 'FARMER')
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavItem(context, appState, 0,
                          Icons.home_outlined, Icons.home, appState.translate('home')),
                      _buildBottomNavItem(context, appState, 1,
                          Icons.landscape_outlined, Icons.landscape, appState.translate('fields')),
                      _buildBottomNavItem(
                          context,
                          appState,
                          2,
                          Icons.add_circle_outline,
                          Icons.add_circle,
                          '+',
                          color: AppTheme.primaryGreen),
                      _buildBottomNavItem(
                          context,
                          appState,
                          3,
                          Icons.assessment_outlined,
                          Icons.assessment,
                          appState.translate('reports')),
                      _buildBottomNavItem(context, appState, 4,
                          Icons.person_outline, Icons.person, appState.translate('profile')),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBottomNavItem(
      BuildContext context,
      AppState appState,
      int index,
      IconData icon,
      IconData activeIcon,
      String label,
      {Color? color}) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 2) {
            _showActionSelectionModal(context, appState);
          } else {
            setState(() {
              _currentTabIndex = index;
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? (color ?? AppTheme.primaryGreen)
                  : Colors.grey.shade600,
              size: index == 2 ? 28 : 22,
            ),
            if (index != 2)
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showActionSelectionModal(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text(
                appState.translate('add_field'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.primaryGreenSurface,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.landscape,
                      color: AppTheme.primaryGreen),
                ),
                title: const Text('Register New Field',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Add a new field, crop, and location details'),
                onTap: () {
                  Navigator.pop(context);
                  FieldsScreen.showAddFieldDialog(context, appState);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.purple.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.flight_takeoff,
                      color: Colors.purple.shade700),
                ),
                title: const Text('Book Drone Scan',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    const Text('Schedule crop health or soil moisture drone scan'),
                onTap: () {
                  Navigator.pop(context);
                  ScansScreen.showRequestScanModal(context, appState);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
