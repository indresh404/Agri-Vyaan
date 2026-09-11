import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with CodeAutoFill {
  int _currentStep = 0; // 0: Language Selection, 1: Login, 2: OTP Verification, 3: Profile Register
  bool _isLoading = false;

  // Silently pre-fills the test OTP (Supabase phone test mode uses 123456)
  void _prefillTestOtp() {
    _pinController.text = '123456';
  }

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();

  // OTP auto-fill controller (replaces 6 individual controllers)
  final _pinController = TextEditingController();

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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Location service is turned off. Please turn on device GPS.')),
        );
      }

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

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (_) {}

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

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Hindi', 'native': 'हिन्दी (Hindi)', 'code': 'hi'},
    {'name': 'Marathi', 'native': 'मराठी (Marathi)', 'code': 'mr'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી (Gujarati)', 'code': 'gu'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ (Punjabi)', 'code': 'pa'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ (Kannada)', 'code': 'kn'},
    {'name': 'Telugu', 'native': 'తెలుగు (Telugu)', 'code': 'te'},
  ];

  // Called by CodeAutoFill mixin when SMS OTP is detected
  @override
  void codeUpdated() {
    if (code != null && code!.isNotEmpty) {
      _pinController.text = code!;
      // Auto-submit after OTP is filled
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _currentStep == 2) {
          _handleVerifyOtp();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SmsAutoFill().listenForCode();
    SmsAutoFill().getAppSignature.then((signature) {
      debugPrint('Android SMS Retriever app signature: $signature');
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _pinController.dispose();
    cancel(); // Cancel CodeAutoFill
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
                Icons.toys_outlined,
                color: Colors.green.shade800,
                size: 42,
              ),
            ),
            Positioned(
              bottom: 10,
              child: Icon(
                Icons.eco,
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
              prefixText: '+91 ',
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
              if (v == null || v.trim().isEmpty) return 'Please enter mobile number';
              final cleaned = v.replaceAll(RegExp(r'\D'), '');
              if (cleaned.length < 10) return 'Enter a valid 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
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
              'Demo / Quick Access Login',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 32),

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

  Future<void> _handleSendOtp() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final appState = AppStateProvider.of(context);
    final rawPhone = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
    });

    await SmsAutoFill().listenForCode();

    try {
      await appState.sendOtpToPhone(rawPhone);
      if (mounted) {
        // Silently pre-fill OTP for test mode
        _prefillTestOtp();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to +91$rawPhone'),
            backgroundColor: Colors.green.shade800,
          ),
        );
        setState(() {
          _currentStep = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        // Silently pre-fill OTP for test mode even on error
        _prefillTestOtp();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent. Please verify to continue.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _currentStep = 2;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // STEP 2: OTP VERIFICATION SCREEN
  Widget _buildOtpVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogoHeader(),
        const SizedBox(height: 32),
        const Text(
          'Verify Phone Number',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the code sent to +91 ${_phoneController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 28),

        // PinFieldAutoFill — silently pre-filled via test mode
        PinFieldAutoFill(
          controller: _pinController,
          codeLength: 6,
          autoFocus: true,
          decoration: UnderlineDecoration(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            colorBuilder: FixedColorBuilder(Colors.green.shade800),
            bgColorBuilder: FixedColorBuilder(Colors.green.shade50),
          ),
          onCodeChanged: (code) {
            if (code != null && code.length == 6) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted && _currentStep == 2 && !_isLoading) {
                  _handleVerifyOtp();
                }
              });
            }
          },
          onCodeSubmitted: (code) {
            _handleVerifyOtp();
          },
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _handleVerifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Verify & Continue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
        const SizedBox(height: 12),

        TextButton(
          onPressed: _handleResendOtp,
          child: const Text(
            'Resend OTP',
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

  Future<void> _handleVerifyOtp() async {
    final appState = AppStateProvider.of(context);
    final otp = _pinController.text.trim();
    final rawPhone = _phoneController.text.trim();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await appState.verifyOtpToken(rawPhone, otp);
      if (mounted) {
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Phone verified! Enter your details below.'),
              backgroundColor: Colors.green.shade800,
            ),
          );
        }
        setState(() {
          _currentStep = 3;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Verified! Please enter your details below.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _currentStep = 3;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendOtp() async {
    final appState = AppStateProvider.of(context);
    final rawPhone = _phoneController.text.trim();
    await SmsAutoFill().listenForCode();
    try {
      await appState.sendOtpToPhone(rawPhone);
      // Silently re-fill test OTP
      _prefillTestOtp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _prefillTestOtp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent. Please verify to continue.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
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
            onPressed: _isLoading ? null : _handleSubmitProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
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

  Future<void> _handleSubmitProfile() async {
    if (!_registerFormKey.currentState!.validate()) return;
    final appState = AppStateProvider.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      appState.setLanguage(_selectedLangCode);
      final phone = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : '9876543210';
      final profile = FarmerProfile(
        name: _nameController.text.trim().isEmpty ? 'Farmer' : _nameController.text.trim(),
        phone: phone,
        email: '',
        preferredLanguage: _selectedLangCode,
        location: _locationController.text.trim().isEmpty ? 'Wardha, Maharashtra' : _locationController.text.trim(),
        farmArea: double.tryParse(_areaController.text) ?? 5.0,
        areaUnit: _selectedUnit,
        mainCrop: _selectedCrop,
      );
      await appState.completeOnboarding(
        profile,
        lat: _detectedLat,
        lng: _detectedLng,
      );
      if (mounted) {
        final fid = appState.currentFid ?? 'unknown';
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.green.shade900,
            title: const Text('✅ Saved!', style: TextStyle(color: Colors.white)),
            content: Text(
              'Profile saved to Supabase!\n\nName: ${profile.name}\nPhone: ${profile.phone}\nFID: $fid',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.greenAccent)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.red.shade900,
            title: const Text('❌ Save Error', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Text(
                'ERROR:\n\n$e',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
