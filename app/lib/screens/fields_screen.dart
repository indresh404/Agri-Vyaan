import 'package:flutter/material.dart';
import '../models/farm_field.dart';
import '../services/field_storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/field_card.dart';
import 'add_field_screen.dart';
import 'field_overview_screen.dart';

/// Displays all farm fields with search, add, and navigation.
class FieldsScreen extends StatefulWidget {
  final List<FarmField> fields;
  final FieldStorageService storageService;

  const FieldsScreen({
    super.key,
    required this.fields,
    required this.storageService,
  });

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  late List<FarmField> _fields;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fields = List.from(widget.fields);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmField> get _filteredFields {
    if (_searchQuery.isEmpty) return _fields;
    final q = _searchQuery.toLowerCase();
    return _fields.where((f) {
      return f.name.toLowerCase().contains(q) ||
          f.crop.toLowerCase().contains(q) ||
          f.location.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _reload() async {
    final loaded = await widget.storageService.loadFields();
    setState(() => _fields = loaded);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFields;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Fields'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _addField,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Field'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search fields...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            // Fields list
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final field = filtered[index];
                        return FieldCard(
                          field: field,
                          onTap: () => _openField(field),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: AppTheme.textLight),
            const SizedBox(height: 12),
            Text(
              'No fields match "$_searchQuery"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.landscape_outlined,
                size: 44, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Fields Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add your first field to start monitoring crop health and conditions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Field'),
          ),
        ],
      ),
    );
  }

  void _addField() async {
    final result = await Navigator.push<FarmField>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFieldScreen(
          fields: _fields,
          storageService: widget.storageService,
        ),
      ),
    );
    if (result != null) {
      await _reload();
    }
  }

  void _openField(FarmField field) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FieldOverviewScreen(
          field: field,
          fields: _fields,
          storageService: widget.storageService,
        ),
      ),
    );
    await _reload();
  }
}
