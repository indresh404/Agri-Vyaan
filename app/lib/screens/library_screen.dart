import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import 'chat_screen.dart';

class LibraryScreen extends StatefulWidget {
  final Function(Widget) onPushScreen;
  final int initialTab;

  const LibraryScreen({
    super.key,
    required this.onPushScreen,
    this.initialTab = 0,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    // Filter items
    final crops = appState.libraryCrops.where((i) => i.name.toLowerCase().contains(_searchQuery) || i.description.toLowerCase().contains(_searchQuery)).toList();
    final pests = appState.libraryPests.where((i) => i.name.toLowerCase().contains(_searchQuery) || i.description.toLowerCase().contains(_searchQuery)).toList();
    final diseases = appState.libraryDiseases.where((i) => i.name.toLowerCase().contains(_searchQuery) || i.description.toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Agriculture Library'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green.shade800,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.green.shade700,
          tabs: const [
            Tab(text: 'Crops'),
            Tab(text: 'Pests'),
            Tab(text: 'Diseases'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search crops, pests, symptoms...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLibraryGrid(crops, 'Crops'),
                _buildLibraryGrid(pests, 'Pests'),
                _buildLibraryGrid(diseases, 'Diseases'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryGrid(List<LibraryItem> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('No matching $type found.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openDetailsPage(item),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _getThemeColor(item.type).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIcon(item.type),
                      color: _getThemeColor(item.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      item.description,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDetailsPage(LibraryItem item) {
    widget.onPushScreen(LibraryDetailsScreen(item: item, onPushScreen: widget.onPushScreen));
  }

  Color _getThemeColor(String type) {
    if (type == 'Crop') return Colors.green.shade700;
    if (type == 'Pest') return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  IconData _getIcon(String type) {
    if (type == 'Crop') return Icons.grass;
    if (type == 'Pest') return Icons.bug_report;
    return Icons.coronavirus_outlined;
  }
}

// --- DETAILED VIEW PAGE ---
class LibraryDetailsScreen extends StatelessWidget {
  final LibraryItem item;
  final Function(Widget) onPushScreen;

  const LibraryDetailsScreen({
    super.key,
    required this.item,
    required this.onPushScreen,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor(item.type);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getIcon(item.type), color: themeColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        item.type.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Detail metrics list (e.g. cultivation, temperature, symptoms)
            if (item.details.isNotEmpty) ...[
              const Text(
                'Key Guidelines / Facts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              ...item.details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_right, color: themeColor, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            detail,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            if (item.symptoms.isNotEmpty) ...[
              _buildSectionCard('Symptoms', item.symptoms, Colors.orange.shade800, Icons.warning_amber),
              const SizedBox(height: 12),
            ],

            if (item.prevention.isNotEmpty) ...[
              _buildSectionCard('Prevention Steps', item.prevention, Colors.green.shade800, Icons.shield_outlined),
              const SizedBox(height: 12),
            ],

            if (item.management.isNotEmpty) ...[
              _buildSectionCard('Management Info', item.management, Colors.teal.shade800, Icons.healing_outlined),
              const SizedBox(height: 16),
            ],

            // Action triggers
            Row(
              children: [
                if (item.type != 'Crop') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                      label: const Text('ASK AI ABOUT THIS', style: TextStyle(color: Colors.white, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        onPushScreen(ChatScreen(
                          prefilledPrompt: 'How should I manage ${item.name} in my fields?',
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.grass, color: themeColor, size: 18),
                    label: Text(
                      item.type == 'Crop' ? 'View Pests' : 'Affected Crops',
                      style: TextStyle(color: themeColor, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: themeColor),
                    ),
                    onPressed: () {
                      _showRelatedInfo(context, themeColor);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String text, Color headerColor, IconData icon) {
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
            Row(
              children: [
                Icon(icon, color: headerColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: headerColor),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _showRelatedInfo(BuildContext context, Color themeColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.type == 'Crop' ? 'Related Vectors / Pests' : 'Affected Crops',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: themeColor),
              ),
              const SizedBox(height: 16),
              if (item.type == 'Crop')
                const Text('• Pink Bollworm (Cotton Vector)\n• Early Blight (Tomato Fungal Disease)\n• Cotton Leaf Curl Virus')
              else
                ...item.affectedCrops.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('• $c', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getThemeColor(String type) {
    if (type == 'Crop') return Colors.green.shade700;
    if (type == 'Pest') return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  IconData _getIcon(String type) {
    if (type == 'Crop') return Icons.grass;
    if (type == 'Pest') return Icons.bug_report;
    return Icons.coronavirus_outlined;
  }
}
