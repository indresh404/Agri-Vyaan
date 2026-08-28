import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'weather_screen.dart';
import 'tools_screen.dart';
import 'library_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final profile = appState.currentProfile;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Your Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(profile),
            const SizedBox(height: 16),

            // Feedback Card
            _buildFeedbackCard(context),
            const SizedBox(height: 16),

            // Share Card
            _buildShareCard(context),
            const SizedBox(height: 16),

            // Farmer Tools & Resources Section
            const Text(
              'Farmer Tools & Resources',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildToolsCard(context),

            const SizedBox(height: 20),

            // Settings Section
            const Text(
              'My Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsCard(appState, profile),
            const SizedBox(height: 20),

            // Support Section
            const Text(
              'Support',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildSupportCard(context),

            const SizedBox(height: 24),

            // Logout Button
            _buildLogoutButton(appState),
          ],
        ),
      ),
    );
  }

  // Profile Card
  Widget _buildProfileCard(dynamic profile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.green.shade50,
              child: Icon(Icons.person, color: Colors.green.shade800, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.name ?? 'Farmer Rajesh',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Join AgriSwarm Community',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile?.phone ?? '9876543210',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Feedback Card
  Widget _buildFeedbackCard(BuildContext context) {
    return Card(
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
            Row(
              children: [
                Icon(
                  Icons.feedback_outlined,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'How is your experience with AgriSwarm app?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(
                "We'd love to hear your thoughts and suggestions.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showFeedbackDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Give Feedback',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Share Card
  Widget _buildShareCard(BuildContext context) {
    return Card(
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
            Row(
              children: [
                Icon(
                  Icons.share_outlined,
                  color: Colors.green.shade700,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Grow smart together!',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(
                'Share AgriSwarm and help farmers solve their plant problems.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showShareDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Share AgriSwarm',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tools Card
  Widget _buildToolsCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildToolTile(
            icon: Icons.wb_sunny_outlined,
            iconColor: Colors.orange,
            title: 'Weather & Spraying Windows',
            subtitle: 'Check forecasting and spray advisors',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeatherScreen()),
            ),
          ),
          const Divider(height: 1),
          _buildToolTile(
            icon: Icons.calculate_outlined,
            iconColor: Colors.teal,
            title: 'Farm Calculators',
            subtitle: 'Fertilizer, seed, irrigation, & cost calculators',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ToolsScreen()),
            ),
          ),
          const Divider(height: 1),
          _buildToolTile(
            icon: Icons.library_books_outlined,
            iconColor: Colors.indigo,
            title: 'Agriculture Library',
            subtitle: 'Browse crops, pests, and plant diseases',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LibraryScreen(
                  onPushScreen: (screen) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildToolTile(
            icon: Icons.chat_bubble_outline,
            iconColor: Colors.green,
            title: 'AI Farming Assistant',
            subtitle: 'Consult with your AI companion',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  // Settings Card
  Widget _buildSettingsCard(dynamic appState, dynamic profile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            _buildSettingTile(
              icon: Icons.language,
              title: 'App Language',
              trailing: DropdownButton<String>(
                value: appState.currentLanguage,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                  DropdownMenuItem(value: 'mr', child: Text('मराठी')),
                ],
                onChanged: (lang) {
                  if (lang != null) appState.setLanguage(lang);
                },
                underline: const SizedBox(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              icon: Icons.straighten,
              title: 'Preferred Units',
              trailing: Text(
                profile?.areaUnit.toUpperCase() ?? 'ACRES',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              icon: Icons.mic,
              title: 'Voice Commands Enabled',
              trailing: Switch(
                value: true,
                onChanged: (v) {},
                activeColor: Colors.green.shade700,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  // Support Card
  Widget _buildSupportCard(BuildContext context) {
    return Card(
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
            leading: Icon(Icons.help_outline, color: Colors.green.shade700),
            title: const Text(
              'Help & Support',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
            onTap: () => _showHelpDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.green.shade700),
            title: const Text(
              'AgriSwarm v1.0.0',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Logout Button
  Widget _buildLogoutButton(dynamic appState) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Logout Session',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: appState.logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Feedback Dialog
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We value your feedback!'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Share Dialog
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share AgriSwarm'),
        content: const Text(
          'Share AgriSwarm with your fellow farmers and help them grow better crops!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Share Now'),
          ),
        ],
      ),
    );
  }

  // Help Dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AgriSwarm Support'),
          content: const Text(
            'For assistance, contact support at support@agriswarm.com or call 1800-123-4567.\n\nOur agronomy experts are available 24/7.',
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
}
