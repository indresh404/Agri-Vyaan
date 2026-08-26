import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Demo Farmer');
  final _phoneController = TextEditingController(text: '9876543210');
  final _emailController = TextEditingController(text: 'farmer@agriswarm.com');
  final _locationController = TextEditingController(text: 'Wardha, Maharashtra');
  final _areaController = TextEditingController(text: '9.7');
  
  String _selectedLang = 'en';
  String _selectedCrop = 'Cotton';
  String _selectedUnit = 'acres';

  final List<String> _cropsList = ['Cotton', 'Tomato', 'Wheat', 'Rice', 'Soybean'];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo / Icon
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.green.shade50,
                        child: Icon(Icons.psychology_outlined, color: Colors.green.shade700, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to AgriSwarm',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Continuous Farm Intelligence Platform',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Language Selector
                      const Text(
                        'Select Language / भाषा चुनें',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildLangBtn('en', 'English'),
                          const SizedBox(width: 8),
                          _buildLangBtn('hi', 'हिंदी (Hindi)'),
                          const SizedBox(width: 8),
                          _buildLangBtn('mr', 'मराठी (Marathi)'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Fields
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Farmer Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.length < 10 ? 'Enter a valid mobile number' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.mail_outline),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Farm Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Please enter location' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Farm area configuration
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _areaController,
                              decoration: const InputDecoration(
                                labelText: 'Farm Area',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              items: ['acres', 'hectares']
                                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedUnit = val!;
                                });
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sowing Crops Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCrop,
                        items: _cropsList
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCrop = val!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Main Sown Crop',
                          prefixIcon: Icon(Icons.grass),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Onboarding Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            appState.setLanguage(_selectedLang);
                            final profile = FarmerProfile(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              email: _emailController.text,
                              preferredLanguage: _selectedLang,
                              location: _locationController.text,
                              farmArea: double.parse(_areaController.text),
                              areaUnit: _selectedUnit,
                              mainCrop: _selectedCrop,
                            );
                            appState.completeOnboarding(profile);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Let\'s Understand Your Farm',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangBtn(String code, String name) {
    final isSelected = _selectedLang == code;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedLang = code;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green.shade700 : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          side: BorderSide(color: isSelected ? Colors.green.shade700 : Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          name.split(' ').first,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
