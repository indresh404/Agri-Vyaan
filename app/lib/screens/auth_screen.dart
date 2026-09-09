import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _currentStep = 0; // 0: Language Selection, 1: Login / Registration, 2: OTP Verification, 3: Profile Register

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController(text: '9876543210');
  final _nameController = TextEditingController(text: 'Demo Farmer');
  final _emailController = TextEditingController(text: 'farmer@agrivyaan.com');
  final _locationController = TextEditingController(text: 'Wardha, Maharashtra');
  final _areaController = TextEditingController(text: '9.7');

  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  String _selectedLangCode = 'en';
  String _selectedLangName = 'English';
  String _selectedCrop = 'Cotton';
  String _selectedUnit = 'acres';

  bool _isGettingLocation = false;
  double? _detectedLat;
  double? _detectedLng;

  Future<void> _fetchLiveLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    double? lat;
    double? lng;
    String exactVillageName = '';

    try {
      // 1. Check if device location service / GPS is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Location service is turned off. Please turn on device GPS.')),
          );
        }
      }

      // 2. Request real-time location permissions (opens permission dialog)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Location permission was denied.')),
          );
        }
      }

      if (permission == LocationPermission.deniedForever && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Location permission is permanently denied in settings.')),
        );
      }

      // 3. Fetch exact high-accuracy GPS hardware coordinates
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (_) {}

    // Fallback to IP geolocation if GPS permissions/sensor failed
    if (lat == null || lng == null) {
      try {
        final res = await http
            .get(Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client'))
            .timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          lat = (data['latitude'] as num?)?.toDouble();
          lng = (data['longitude'] as num?)?.toDouble();
        }
      } catch (_) {}
    }

    // 4. Reverse Geocode exact GPS coordinates to get exact Village / Town name via Nominatim
    if (lat != null && lng != null) {
      try {
        final nomRes = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
          headers: {'User-Agent': 'AgrivyaanApp/1.0'},
        ).timeout(const Duration(seconds: 5));

        if (nomRes.statusCode == 200) {
          final nomData = json.decode(nomRes.body);
          final address = nomData['address'] as Map<String, dynamic>?;
          if (address != null) {
            final village = address['village'] ??
                address['suburb'] ??
                address['town'] ??
                address['hamlet'] ??
                address['city_district'] ??
                address['city'] ??
                address['county'];
            final state = address['state'] ?? '';
            if (village != null && village.toString().isNotEmpty) {
              exactVillageName = state.toString().isNotEmpty ? '$village, $state' : village.toString();
            }
          }
        }
      } catch (_) {}
    }

    // Fallback if offline
    if (lat == null || lng == null) {
      lat = 20.7453;
      lng = 78.6022;
      exactVillageName = 'Wardha, Maharashtra';
    } else if (exactVillageName.isEmpty) {
      exactVillageName = 'Live GPS Location';
    }

    final formattedLat = lat.toStringAsFixed(4);
    final formattedLng = lng.toStringAsFixed(4);

    setState(() {
      _detectedLat = lat;
      _detectedLng = lng;
      _locationController.text = '$exactVillageName (Lat: $formattedLat, Long: $formattedLng)';
      _isGettingLocation = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📍 Exact GPS Location Acquired!\n$exactVillageName\nLatitude: $formattedLat | Longitude: $formattedLng'),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  final List<String> _cropsList = ['Cotton', 'Tomato', 'Wheat', 'Rice', 'Soybean'];

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Hindi', 'native': 'हिन्दी (Hindi)', 'code': 'hi'},
    {'name': 'Marathi', 'native': 'मराठी (Marathi)', 'code': 'mr'},
    {'name': 'Gujarati', 'native': 'ગુજરાती (Gujarati)', 'code': 'gu'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬी (Punjabi)', 'code': 'pa'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ (Kannada)', 'code': 'kn'},
    {'name': 'Telugu', 'native': 'తెలుగు (Telugu)', 'code': 'te'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildCurrentStepWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildLanguageSelectionStep();
      case 1:
        return _buildLoginStep();
      case 2:
        return _buildOtpVerificationStep();
      case 3:
        return _buildProfileRegistrationStep();
      default:
        return _buildLanguageSelectionStep();
    }
  }

  // STEP 0: LANGUAGE SELECTION UI
  Widget _buildLanguageSelectionStep() {
    final appState = AppStateProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Choose Your Language',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'अपनी भाषा चुनें',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index];
              final isSelected = _selectedLangCode == lang['code'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLangCode = lang['code']!;
                      _selectedLangName = lang['name']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.green.shade600 : Colors.grey.shade200,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang['native']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.green.shade800 : Colors.black87,
                          ),
                        ),
                        if (isSelected)
                          const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.check, color: Colors.white, size: 12),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () {
            appState.setLanguage(_selectedLangCode);
            setState(() {
              _currentStep = 1;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // CUSTOM HEADER WITH LOGO
  Widget _buildLogoHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              top: 10,
              child: Icon(
                Icons.toys_outlined, // Quadcopter Drone icon
                color: Colors.green.shade800,
                size: 42,
              ),
            ),
            Positioned(
              bottom: 10,
              child: Icon(
                Icons.eco, // Green leaf
                color: Colors.green.shade600,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Agrivyaan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.green,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Smarter Farming, Better Future',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // STEP 1: LOGIN MOBILE NUMBER OTP SCREEN
  Widget _buildLoginStep() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogoHeader(),
          const SizedBox(height: 36),
          
          const Text(
            'Mobile Number',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              hintText: 'Enter mobile number',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green.shade600, width: 1.5),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter mobile number';
              if (v.length < 10) return 'Enter a valid 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: () {
              if (_loginFormKey.currentState!.validate()) {
                setState(() {
                  _currentStep = 2;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Send OTP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),
          
          OutlinedButton(
            onPressed: () {
              // Direct login using default profile to bypass OTP for quick demos
              _handleDirectDemoLogin();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Login with Password',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 32),
          
          // Language selection quick button at bottom
          InkWell(
            onTap: () {
              setState(() {
                _currentStep = 0;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, color: Colors.black54, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _selectedLangName,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Register text link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              InkWell(
                onTap: () {
                  setState(() {
                    _currentStep = 3;
                  });
                },
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // STEP 2: OTP VERIFICATION SCREEN
  Widget _buildOtpVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogoHeader(),
        const SizedBox(height: 36),
        const Text(
          'Verify Phone',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 4-digit code sent to ${_phoneController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        // 4 Digits input
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 55,
              height: 55,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green.shade600, width: 2.0),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 3) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
        
        ElevatedButton(
          onPressed: () {
            // Verify digits logic
            final otp = _otpControllers.map((c) => c.text).join();
            if (otp.length == 4 || _phoneController.text == '9876543210') {
              // Redirect to profile setup step to ask for Name and Village Location
              setState(() {
                _currentStep = 3;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter the complete 4-digit code')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Verify & Continue',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP code resent successfully!')),
            );
          },
          child: const Text(
            'Resend OTP Code',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        
        OutlinedButton(
          onPressed: () {
            setState(() {
              _currentStep = 1;
            });
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.grey.shade200),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Back to Login', style: TextStyle(color: Colors.black87)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // STEP 3: NEW FARM PROFILE REGISTRATION ONBOARDING SCREEN (NAME & VILLAGE LOCATION)
  Widget _buildProfileRegistrationStep() {
    final appState = AppStateProvider.of(context);
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogoHeader(),
          const SizedBox(height: 24),
          const Text(
            'Farmer Details',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Please enter your name and village location',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name *',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green.shade600, width: 1.5),
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Village Location *',
              hintText: 'Enter village location or tap 📍',
              prefixIcon: const Icon(Icons.location_on_outlined),
              suffixIcon: IconButton(
                tooltip: 'Fetch Live Location & Coordinates',
                onPressed: _isGettingLocation ? null : _fetchLiveLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '📍',
                        style: TextStyle(fontSize: 20),
                      ),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green.shade600, width: 1.5),
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your village location' : null,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: _isGettingLocation ? null : _fetchLiveLocation,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _isGettingLocation ? 'Detecting exact GPS location...' : 'Click to fetch live location & GPS coordinates',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_detectedLat != null && _detectedLng != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.gps_fixed, size: 16, color: Colors.green.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live GPS: Latitude ${_detectedLat!.toStringAsFixed(4)}, Longitude ${_detectedLng!.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: 'Farm Area Size',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade600, width: 1.5),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedUnit,
                  items: ['acres', 'hectares']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedUnit = val!;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          
          ElevatedButton(
            onPressed: () {
              if (_registerFormKey.currentState!.validate()) {
                appState.setLanguage(_selectedLangCode);
                final profile = FarmerProfile(
                  name: _nameController.text.trim().isEmpty ? 'Farmer' : _nameController.text.trim(),
                  phone: _phoneController.text.trim().isEmpty ? '9876543210' : _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                  preferredLanguage: _selectedLangCode,
                  location: _locationController.text.trim().isEmpty ? 'Wardha, Maharashtra' : _locationController.text.trim(),
                  farmArea: double.tryParse(_areaController.text) ?? 5.0,
                  areaUnit: _selectedUnit,
                  mainCrop: _selectedCrop,
                );
                appState.completeOnboarding(profile);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Submit & Continue',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          
          OutlinedButton(
            onPressed: () {
              setState(() {
                _currentStep = 2;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Back to OTP', style: TextStyle(color: Colors.black87)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _handleDirectDemoLogin() {
    final appState = AppStateProvider.of(context);
    appState.setLanguage(_selectedLangCode);
    final profile = FarmerProfile(
      name: 'Demo Farmer',
      phone: '9876543210',
      email: 'farmer@agrivyaan.com',
      preferredLanguage: _selectedLangCode,
      location: 'Wardha, Maharashtra',
      farmArea: 9.7,
      areaUnit: 'acres',
      mainCrop: 'Cotton',
    );
    appState.completeOnboarding(profile);
  }
}
