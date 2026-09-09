import 'package:flutter/material.dart';
import '../models/farm_field.dart';
import '../services/demo_data.dart';
import '../services/field_storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/field_helpers.dart';
import '../widgets/field_card.dart';
import 'fields_screen.dart';
import 'field_overview_screen.dart';

/// Main dashboard screen — the app's home.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FieldStorageService _storageService = FieldStorageService();
  List<FarmField> _fields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() => _isLoading = true);
    List<FarmField> loaded = await _storageService.loadFields();
    if (loaded.isEmpty) {
      // First launch — seed with demo data
      loaded = DemoData.demoFields;
      await _storageService.saveFields(loaded);
    }
    setState(() {
      _fields = loaded;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen))
            : RefreshIndicator(
                color: AppTheme.primaryGreen,
                onRefresh: _loadFields,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildFieldsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Agrivyaan logo
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.agriculture, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agrivyaan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Smart Farming Assistant',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification bell
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.notifications_outlined,
                          color: AppTheme.textPrimary, size: 24),
                    ),
                    if (_totalProblems > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Hello, Farmer \u{1F44B}',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monitor your fields, track crop health, and get AI-powered recommendations.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.landscape_rounded,
                  iconColor: AppTheme.primaryGreen,
                  title: 'My Fields',
                  value: '${_fields.length}',
                  onTap: _navigateToFields,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.square_foot_rounded,
                  iconColor: AppTheme.info,
                  title: 'Total Area',
                  value: '${_totalArea.toStringAsFixed(1)} ac',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.favorite_rounded,
                  iconColor: healthStatusColor(
                      getHealthStatus(_averageHealth)),
                  title: 'Avg Health',
                  value: '${_averageHealth.round()}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: _totalProblems > 0
                      ? AppTheme.warning
                      : AppTheme.success,
                  title: 'Alerts',
                  value: '$_totalProblems',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Your Fields',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _navigateToFields,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_fields.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.landscape_outlined,
                    size: 64, color: AppTheme.textLight),
                const SizedBox(height: 12),
                const Text(
                  'No fields yet',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add your first field to get started',
                  style:
                      TextStyle(fontSize: 14, color: AppTheme.textLight),
                ),
              ],
            ),
          )
        else
          ...(_fields.take(3).map(
                (field) => FieldCard(
                  field: field,
                  onTap: () => _navigateToFieldOverview(field),
                ),
              )),
        if (_fields.length > 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton(
              onPressed: _navigateToFields,
              child:
                  Text('View All ${_fields.length} Fields'),
            ),
          ),
      ],
    );
  }

  // Computed properties
  double get _totalArea =>
      _fields.fold(0, (sum, f) => sum + f.area);

  double get _averageHealth => _fields.isEmpty
      ? 0
      : _fields.fold(0.0, (sum, f) => sum + f.healthScore) / _fields.length;

  int get _totalProblems =>
      _fields.fold(0, (sum, f) => sum + f.problems.length);

  // Navigation
  void _navigateToFields() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FieldsScreen(
          fields: _fields,
          storageService: _storageService,
        ),
      ),
    );
    _loadFields();
  }

  void _navigateToFieldOverview(FarmField field) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FieldOverviewScreen(
          field: field,
          fields: _fields,
          storageService: _storageService,
        ),
      ),
    );
    _loadFields();
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
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
}
