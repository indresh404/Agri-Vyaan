import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import 'weather_screen.dart';
import 'tools_screen.dart';
import 'library_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final profile = appState.currentProfile;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildTopNavBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Profile Hero Header ──
            _buildProfileHeader(context, appState, profile),
            const SizedBox(height: 16),

            // ── 2. Contact & Info Details ──
            _buildInfoDetailsCard(context, appState, profile),
            const SizedBox(height: 20),

            // ── 3. Farmer Tools & Resources (preserved) ──
            const Text(
              'Farmer Tools & Resources',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    leading: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                    title: const Text('Weather & Spraying Windows'),
                    subtitle: const Text('Check forecasting and spray advisors'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.calculate_outlined, color: Colors.teal),
                    title: const Text('Farm Calculators'),
                    subtitle: const Text('Fertilizer, seed, irrigation, & cost calculators'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.library_books_outlined, color: Colors.indigo),
                    title: const Text('Agriculture Library'),
                    subtitle: const Text('Browse crops, pests, and plant diseases'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LibraryScreen(
                          onPushScreen: (screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                    title: const Text('AI Farming Assistant'),
                    subtitle: const Text('Consult with your AI companion'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 4. My Settings (preserved) ──
            const Text(
              'My Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.language, color: Colors.green.shade700),
                      title: const Text('App Language'),
                      trailing: DropdownButton<String>(
                        value: appState.currentLanguage,
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'hi', child: Text('हिंदी (Hindi)')),
                          DropdownMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
                        ],
                        onChanged: (lang) {
                          if (lang != null) appState.setLanguage(lang);
                        },
                        underline: const SizedBox(),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.straighten, color: Colors.green.shade700),
                      title: const Text('Preferred Units'),
                      trailing: Text(
                        profile?.areaUnit.toUpperCase() ?? 'ACRES',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.mic, color: Colors.green.shade700),
                      title: const Text('Voice Commands Enabled'),
                      trailing: Switch(
                        value: true,
                        onChanged: (v) {},
                        activeThumbColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 5. Support (preserved) ──
            const Text(
              'Support',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    onTap: () => _showHelpDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Agrivyaan v1.0.0'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 6. Logout Button (preserved) ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout Session'),
                onPressed: () {
                  appState.logout();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PROFILE HERO HEADER — gradient card with initials avatar
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileHeader(BuildContext context, AppState appState, FarmerProfile? profile) {
    final name = profile?.name ?? 'Farmer';
    final location = profile?.location ?? 'Unknown Location';
    final initials = _getInitials(name);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              children: [
                // Avatar with initials
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),

                // Location row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.white.withValues(alpha: 0.85), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Edit Profile button
                OutlinedButton.icon(
                  onPressed: () => _showEditProfileSheet(context, appState, profile),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CONTACT & INFO DETAILS CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoDetailsCard(BuildContext context, AppState appState, FarmerProfile? profile) {
    final fieldsCount = appState.fields.length;
    final langLabel = _languageDisplayName(profile?.preferredLanguage ?? 'en');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.phone_outlined,
              iconColor: AppTheme.primaryGreen,
              label: 'Mobile',
              value: profile?.phone ?? '—',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(
              icon: Icons.email_outlined,
              iconColor: Colors.blue.shade600,
              label: 'Email',
              value: profile?.email ?? '—',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(
              icon: Icons.landscape_outlined,
              iconColor: Colors.teal.shade600,
              label: 'Registered Fields',
              value: '$fieldsCount',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(
              icon: Icons.square_foot_outlined,
              iconColor: Colors.orange.shade700,
              label: 'Farm Area',
              value: profile != null
                  ? '${profile.farmArea} ${profile.areaUnit}'
                  : '—',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(
              icon: Icons.grass_outlined,
              iconColor: AppTheme.primaryGreenDark,
              label: 'Main Crop',
              value: profile?.mainCrop ?? '—',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoRow(
              icon: Icons.translate_outlined,
              iconColor: Colors.purple.shade600,
              label: 'Preferred Language',
              value: langLabel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  EDIT PROFILE BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  void _showEditProfileSheet(BuildContext context, AppState appState, FarmerProfile? profile) {
    if (profile == null) return;

    final nameCtrl = TextEditingController(text: profile.name);
    final phoneCtrl = TextEditingController(text: profile.phone);
    final emailCtrl = TextEditingController(text: profile.email);
    final locationCtrl = TextEditingController(text: profile.location);
    final cropCtrl = TextEditingController(text: profile.mainCrop);
    final areaCtrl = TextEditingController(text: profile.farmArea.toString());
    String selectedUnit = profile.areaUnit;
    String selectedLang = profile.preferredLanguage;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(stateContext).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 14),

                      // Phone
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.isEmpty) ? 'Please enter phone' : null,
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      // Location
                      TextFormField(
                        controller: locationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Main Crop
                      TextFormField(
                        controller: cropCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Main Crop',
                          prefixIcon: Icon(Icons.grass_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Farm Area + Unit row
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: areaCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Farm Area',
                                prefixIcon: Icon(Icons.square_foot_outlined),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedUnit,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
                              items: const [
                                DropdownMenuItem(value: 'acres', child: Text('Acres')),
                                DropdownMenuItem(value: 'hectares', child: Text('Hectares')),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setSheetState(() => selectedUnit = v);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Preferred Language
                      DropdownButtonFormField<String>(
                        initialValue: selectedLang,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Language',
                          prefixIcon: Icon(Icons.translate_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'hi', child: Text('हिंदी (Hindi)')),
                          DropdownMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setSheetState(() => selectedLang = v);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updated = profile.copyWith(
                                name: nameCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                location: locationCtrl.text.trim(),
                                mainCrop: cropCtrl.text.trim(),
                                farmArea: double.tryParse(areaCtrl.text.trim()) ?? profile.farmArea,
                                areaUnit: selectedUnit,
                                preferredLanguage: selectedLang,
                              );
                              appState.updateProfile(updated);
                              appState.setLanguage(selectedLang);
                              Navigator.pop(stateContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                  backgroundColor: AppTheme.primaryGreen,
                                ),
                              );
                              setState(() {}); // Refresh the screen
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  String _languageDisplayName(String code) {
    switch (code) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'mr':
        return 'मराठी (Marathi)';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agrivyaan Support'),
          content: const Text(
            'For assistance, contact support at support@agrivyaan.com or call 1800-123-4567.\n\nOur agronomy experts are available 24/7.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
                  color: Colors.black.withValues(alpha: 0.08),
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
                        'Agrivyaan',
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
                        Icon(Icons.person, color: Colors.green.shade800, size: 16),
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
