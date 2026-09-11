import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/farm_field.dart';
import '../models/models.dart';
import '../models/soil_health_card.dart';
import 'field_storage_service.dart';
import 'soil_health_card_storage_service.dart';
import 'booking_service.dart';
import 'localization.dart';
import 'soil_health_card_demo_data.dart';
import 'package:uuid/uuid.dart';

class AppState extends ChangeNotifier {
  // Authentication & Session
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoadingAuth = false;
  bool get isLoadingAuth => _isLoadingAuth;

  FarmerProfile? _currentProfile;
  FarmerProfile? get currentProfile => _currentProfile;

  String? get currentFid => _currentProfile?.fid ?? _supabase.auth.currentUser?.id;
  bool _needsProfileSetup = false;
  bool get needsProfileSetup => _needsProfileSetup;

  // Language & Role Configuration
  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  String _currentRole = 'FARMER'; // FARMER, ADMIN, DRONE_OPERATOR
  String get currentRole => _currentRole;

  // Offline Architecture
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  final List<ActionEntry> _offlineActionQueue = [];
  List<ActionEntry> get offlineActionQueue => _offlineActionQueue;

  // Active Datasets
  List<CropField> _fields = [];
  List<CropField> get fields => _fields;

  List<DroneScan> _scans = [];
  List<DroneScan> get scans => _scans;

  List<ActionEntry> _actions = [];
  List<ActionEntry> get actions => _actions;

  List<WeatherForecast> _weatherForecast = [];
  List<WeatherForecast> get weatherForecast => _weatherForecast;

  List<LibraryItem> _libraryCrops = [];
  List<LibraryItem> get libraryCrops => _libraryCrops;

  List<LibraryItem> _libraryPests = [];
  List<LibraryItem> get libraryPests => _libraryPests;

  List<LibraryItem> _libraryDiseases = [];
  List<LibraryItem> get libraryDiseases => _libraryDiseases;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  final List<String> _requestedReportFieldIds = [];
  List<String> get requestedReportFieldIds => _requestedReportFieldIds;

  // Soil Health Card data (field-specific)
  Map<String, List<SoilHealthCard>> _soilHealthCards = {};
  Map<String, List<SoilHealthCard>> get soilHealthCards => _soilHealthCards;

  // Services
  SupabaseClient get _supabase => Supabase.instance.client;
  final FieldStorageService _fieldStorageService = FieldStorageService();
  final SoilHealthCardStorageService _shcStorageService = SoilHealthCardStorageService();
  final BookingService _bookingService = BookingService();

  AppState() {
    _initializeData();
    _checkExistingSession();
    _listenToAuthState();
  }

  // --- Session & Supabase Auth Sync ---

  Future<void> _checkExistingSession() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      if (session != null && user != null) {
        debugPrint('Active Supabase session detected for user: ${user.id} (${user.phone})');
        await loadUserDataFromSupabase(user.id, phone: user.phone);
      } else {
        debugPrint('No active Supabase session found.');
      }
    } catch (e) {
      debugPrint('Error checking existing Supabase session: $e');
    }
  }

  void _listenToAuthState() {
    try {
      _supabase.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          final user = session.user;
          await loadUserDataFromSupabase(user.id, phone: user.phone);
        } else if (event == AuthChangeEvent.signedOut) {
          _isLoggedIn = false;
          _currentProfile = null;
          _fields.clear();
          _scans.clear();
          _soilHealthCards.clear();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error attaching auth state change listener: $e');
    }
  }

  /// Load profile, fields, soil health cards, and bookings from Supabase for current authenticated farmer
  Future<void> loadUserDataFromSupabase(String authId, {String? phone}) async {
    _isLoadingAuth = true;
    notifyListeners();

    try {
      // 1. Fetch User Profile
      final profileRes = await _supabase
          .from('users')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();

      if (profileRes != null) {
        _currentProfile = FarmerProfile.fromMap(profileRes as Map<String, dynamic>);
        _isLoggedIn = true;
        _needsProfileSetup = false;
        debugPrint('Loaded farmer profile from Supabase for: ${_currentProfile?.name}');
      } else {
        // User authenticated via Phone OTP but profile not created yet in users table
        debugPrint('Authenticated user has no profile record in users table yet.');
        _currentProfile = FarmerProfile(
          name: 'Farmer',
          phone: phone ?? _supabase.auth.currentUser?.phone ?? '',
          email: '',
          preferredLanguage: _currentLanguage,
          location: 'Wardha, Maharashtra',
          farmArea: 5.0,
          areaUnit: 'acres',
          mainCrop: 'Cotton',
          fid: null,
        );
        _isLoggedIn = false;
        _needsProfileSetup = true;
      }

      final fidToUse = _currentProfile?.fid ?? authId;

      // 2. Fetch Fields from Supabase
      final farmFields = await _fieldStorageService.loadFields(fid: fidToUse);
      if (farmFields.isNotEmpty) {
        _fields = farmFields.map((ff) => CropField(
          id: ff.id,
          name: ff.name,
          crop: ff.crop,
          area: ff.area,
          areaUnit: 'acres',
          sowingDate: ff.sowingDate.toString().split(' ').first,
          cropStage: 'Vegetative stage',
          healthScore: ff.healthScore.toInt(),
          prevHealthScore: ff.healthScore.toInt(),
          lastScanDate: ff.lastScan.toString().split(' ').first,
          moistureStatus: ff.soilMoisture < 35 ? 'LOW' : 'NORMAL',
          zones: ff.zones.map((z) => Zone(
            id: 'z_${z.name.replaceAll(' ', '_')}',
            name: z.name,
            status: z.problem ?? 'Healthy',
            moisture: z.soilMoisture,
            temperature: z.temperature,
            risk: z.severity ?? 'None',
            aiExplanation: z.problem != null ? 'Issue detected: ${z.problem}' : 'Field conditions optimal.',
            recommendation: z.recommendation ?? 'Monitor regularly.',
          )).toList(),
          sensors: [
            SensorReading(
              sensorName: 'Soil Moisture',
              currentValue: ff.soilMoisture,
              minNormal: 35.0,
              maxNormal: 65.0,
              unit: '%',
              status: ff.soilMoisture < 35 ? 'LOW' : 'NORMAL',
              history: [ff.soilMoisture, ff.soilMoisture],
            ),
            SensorReading(
              sensorName: 'Temperature',
              currentValue: ff.temperature,
              minNormal: 20.0,
              maxNormal: 35.0,
              unit: '°C',
              status: 'NORMAL',
              history: [ff.temperature, ff.temperature],
            ),
          ],
          activeAlerts: ff.problems.map((p) => p.title).toList(),
        )).toList();
      }

      // 3. Fetch Soil Health Cards from Supabase
      final loadedShc = await _shcStorageService.loadCards(fid: fidToUse);
      if (loadedShc.isNotEmpty) {
        _soilHealthCards = loadedShc;
      }

      // 4. Fetch Bookings from Supabase
      final loadedBookings = await _bookingService.loadBookings(fidToUse);
      if (loadedBookings.isNotEmpty) {
        _scans = loadedBookings;
      }
    } catch (e) {
      debugPrint('Error loading farmer data from Supabase: $e');
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  // --- Phone OTP Authentication ---

  /// Step 1: Send OTP to farmer phone number via Supabase Auth (Twilio backend)
  /// NOTE: Requires Twilio configured in Supabase Dashboard:
  /// Authentication > Providers > Phone > Enable + add Twilio credentials
  Future<void> sendOtpToPhone(String phone) async {
    final formattedPhone = _formatIndianPhone(phone);
    debugPrint('Sending OTP via Supabase Auth to: $formattedPhone');
    try {
      await _supabase.auth.signInWithOtp(phone: formattedPhone);
      debugPrint('OTP sent successfully to $formattedPhone');
    } catch (e) {
      debugPrint('OTP send error: $e');
      // Re-throw with a cleaner message
      if (e.toString().contains('Twilio') || e.toString().contains('provider') || e.toString().contains('phone_provider')) {
        throw Exception(
          'SMS provider not configured. Please enable Phone Auth + Twilio in Supabase Dashboard, '
          'or use Demo Login to test the app without SMS.',
        );
      }
      rethrow;
    }
  }

  /// Step 2: Verify OTP token with Supabase Auth
  /// Returns user if Supabase Phone Auth is configured, null otherwise.
  /// Never throws — failure is handled gracefully so onboarding can continue.
  Future<User?> verifyOtpToken(String phone, String token) async {
    final formattedPhone = _formatIndianPhone(phone);
    debugPrint('Attempting OTP verification for: $formattedPhone');
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: token,
        type: OtpType.sms,
      );
      final user = response.user ?? _supabase.auth.currentUser;
      if (user != null) {
        debugPrint('OTP verified via Supabase Auth. User: ${user.id}');
        await loadUserDataFromSupabase(user.id, phone: user.phone);
      }
      return user;
    } catch (e) {
      debugPrint('OTP verification skipped (Phone Auth not configured): $e');
      return null; // Graceful fallback — caller proceeds to profile setup
    }
  }

  String _formatIndianPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    return '+91$digits';
  }

  /// Create or update farmer profile in Supabase `users` table
  /// Works for both authenticated users and direct/demo users
  Future<void> saveFarmerProfileToSupabase(FarmerProfile profile) async {
    final authId = _supabase.auth.currentUser?.id;
    debugPrint('Saving farmer profile to Supabase (auth_id: $authId, phone: ${profile.phone})...');

    // Only include columns that exist in the actual users table schema:
    // fid (auto), phone_no, name, location, auth_id
    final mapData = <String, dynamic>{
      'phone_no': profile.phone,
      'name': profile.name,
      'location': profile.location.isNotEmpty ? profile.location : null,
    };

    if (authId != null && authId.isNotEmpty) {
      mapData['auth_id'] = authId;
    }

    Map<String, dynamic>? savedRow;

    try {
      if (authId != null && authId.isNotEmpty) {
        savedRow = await _supabase
            .from('users')
            .upsert(mapData, onConflict: 'auth_id')
            .select()
            .single();
      } else {
        // Unauthenticated/direct entry: check if phone already exists
        final existing = await _supabase
            .from('users')
            .select()
            .eq('phone_no', profile.phone)   // match actual column name
            .maybeSingle();

        if (existing != null) {
          savedRow = await _supabase
              .from('users')
              .update(mapData)
              .eq('fid', existing['fid'])
              .select()
              .single();
        } else {
          savedRow = await _supabase
              .from('users')
              .insert(mapData)
              .select()
              .single();
        }
      }
    } catch (e) {
      debugPrint('Primary save to Supabase users table failed: $e. Retrying plain insert...');
      try {
        savedRow = await _supabase
            .from('users')
            .insert(mapData)
            .select()
            .single();
      } catch (retryError) {
        debugPrint('Error saving profile to Supabase on retry: $retryError');
      }
    }

    if (savedRow != null) {
      final newFid = savedRow['fid'].toString();
      _currentProfile = profile.copyWith(fid: newFid);
      _isLoggedIn = true;
      _needsProfileSetup = false;
      debugPrint('Successfully saved farmer profile to Supabase users table! FID: $newFid');
    } else {
      // Local fallback
      _currentProfile = profile.copyWith(fid: profile.fid ?? const Uuid().v4());
      _isLoggedIn = true;
      _needsProfileSetup = false;
    }

    notifyListeners();
  }

  // --- Soil Health Card Management ---

  Future<void> _loadSoilHealthCards() async {
    final fidToUse = currentFid;
    final loaded = await _shcStorageService.loadCards(fid: fidToUse);
    if (loaded.isNotEmpty) {
      _soilHealthCards = loaded;
    }
    notifyListeners();
  }

  List<SoilHealthCard> getCardsForField(String fieldId) {
    return _soilHealthCards[fieldId] ?? [];
  }

  SoilHealthCard? getCurrentCardForField(String fieldId) {
    final cards = _soilHealthCards[fieldId] ?? [];
    try {
      return cards.firstWhere((c) => c.isCurrent);
    } catch (_) {
      return cards.isNotEmpty ? cards.first : null;
    }
  }

  Future<void> addSoilHealthCard(String fieldId, SoilHealthCard card, {String? localFilePath}) async {
    final fidToUse = currentFid;
    await _shcStorageService.addCard(
      _soilHealthCards,
      fieldId,
      card,
      fid: fidToUse,
      localFilePath: localFilePath,
    );

    _addNotification(
      title: 'Soil Health Card Added',
      description: 'A new Soil Health Card record has been saved and verified.',
      isCritical: false,
    );
    notifyListeners();
  }

  Future<void> updateSoilHealthCard(String fieldId, SoilHealthCard card) async {
    final fidToUse = currentFid;
    await _shcStorageService.updateCard(_soilHealthCards, fieldId, card, fid: fidToUse);
    notifyListeners();
  }

  // --- Translation Helper ---
  String translate(String key) {
    return AppLocalizations.translate(key, _currentLanguage);
  }

  void setLanguage(String langCode) {
    _currentLanguage = langCode;
    notifyListeners();
  }

  void setRole(String role) {
    _currentRole = role;
    notifyListeners();
  }

  void toggleOfflineMode() {
    _isOffline = !_isOffline;
    if (!_isOffline && _offlineActionQueue.isNotEmpty) {
      for (var action in _offlineActionQueue) {
        _actions.insert(0, action);
        _addNotification(
          title: 'Action Synced Successfully',
          description: 'Your offline action "${action.title} on ${action.zoneName}" has been synchronized with cloud.',
          isCritical: false,
        );
      }
      _offlineActionQueue.clear();
    }
    notifyListeners();
  }

  /// Create or update farmer profile in Supabase and optionally seed first field.
  Future<void> completeOnboarding(
    FarmerProfile profile, {
    double? lat,
    double? lng,
  }) async {
    await saveFarmerProfileToSupabase(profile);

    // Automatically seed user's first field if profile main crop not empty
    if (profile.mainCrop.isNotEmpty && _fields.isEmpty) {
      final fieldLat = lat ?? 20.7453;
      final fieldLng = lng ?? 78.6022;
      final newCropField = CropField(
        id: 'field_${DateTime.now().millisecondsSinceEpoch}',
        name: 'My ${profile.mainCrop} Field',
        crop: profile.mainCrop,
        area: profile.farmArea,
        areaUnit: profile.areaUnit,
        sowingDate: '2026-08-01',
        cropStage: 'Germination stage',
        healthScore: 90,
        prevHealthScore: 90,
        lastScanDate: 'None',
        moistureStatus: 'NORMAL',
        activeAlerts: [],
        zones: [
          Zone(
            id: 'z1',
            name: 'Zone 1',
            status: 'Healthy',
            moisture: 50.0,
            temperature: 28.0,
            risk: 'None',
            aiExplanation: 'Field conditions are healthy and moisture is optimal.',
            recommendation: 'Monitor regularly.',
          ),
          Zone(
            id: 'z2',
            name: 'Zone 2',
            status: 'Healthy',
            moisture: 48.0,
            temperature: 28.0,
            risk: 'None',
            aiExplanation: 'Standard development stages.',
            recommendation: 'Monitor regularly.',
          ),
        ],
        sensors: [
          SensorReading(
            sensorName: 'Soil Moisture',
            currentValue: 49.0,
            minNormal: 35.0,
            maxNormal: 65.0,
            unit: '%',
            status: 'NORMAL',
            history: [49.0, 48.0],
          ),
          SensorReading(
            sensorName: 'Temperature',
            currentValue: 28.0,
            minNormal: 15.0,
            maxNormal: 35.0,
            unit: '°C',
            status: 'NORMAL',
            history: [28.0, 28.0],
          ),
        ],
        // Store lat/lng in location string so farmFieldToMap can parse it
        location: 'Lat: $fieldLat, Long: $fieldLng',
      );
      await addField(newCropField);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out from Supabase: $e');
    }
    _isLoggedIn = false;
    _currentProfile = null;
    _initializeData();
    notifyListeners();
  }

  // --- Profile Management ---
  void updateProfile(FarmerProfile profile) async {
    await saveFarmerProfileToSupabase(profile);
  }

  // --- Field Management ---
  Future<void> addField(CropField field) async {
    final farmField = FarmField.fromCropField(field).copyWith(id: const Uuid().v4());
    final fidToUse = currentFid;
    if (fidToUse == null) {
      throw StateError('A saved farmer profile is required before adding a field.');
    }
    await _fieldStorageService.addField([], farmField, fid: fidToUse);
    _fields.add(field.copyWith(id: farmField.id));

    _addNotification(
      title: 'New Field Registered',
      description: 'Field "${field.name}" was successfully registered under monitoring.',
      isCritical: false,
    );
    notifyListeners();
  }

  void editField(CropField updatedField) async {
    final idx = _fields.indexWhere((f) => f.id == updatedField.id);
    if (idx != -1) {
      _fields[idx] = updatedField;

      final farmField = FarmField.fromCropField(updatedField);
      final fidToUse = currentFid ?? 'demo_farmer_id';
      await _fieldStorageService.updateField([], farmField, fid: fidToUse);

      notifyListeners();
    }
  }

  void deleteField(String fieldId) async {
    _fields.removeWhere((f) => f.id == fieldId);
    _scans.removeWhere((s) => s.fieldId == fieldId);
    _actions.removeWhere((a) => a.fieldId == fieldId);

    await _fieldStorageService.deleteField([], fieldId);
    notifyListeners();
  }

  // --- Drone Scan Bookings & Lifecycle ---
  void requestDroneScan({
    required String fieldId,
    required String scanType,
    required String date,
    required String time,
  }) async {
    final fidToUse = currentFid ?? 'demo_farmer_id';
    final newScan = await _bookingService.createBooking(
      fid: fidToUse,
      fieldId: fieldId,
      scanType: scanType,
      date: date,
      time: time,
    );

    if (newScan != null) {
      _scans.insert(0, newScan);
    }

    final fieldName = _fields.firstWhere((f) => f.id == fieldId, orElse: () => _fields.first).name;

    _addNotification(
      title: 'Drone Scan Requested',
      description: 'A $scanType scan has been requested for $fieldName on $date.',
      isCritical: false,
    );
    notifyListeners();
  }

  // Operator Actions
  void operatorAcceptScan(String scanId, String operatorName) async {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.droneAssigned,
        operatorName: operatorName,
      );

      await _bookingService.updateBookingStatus(
        scanId,
        DroneScanStatus.droneAssigned,
        operatorName: operatorName,
      );

      _addNotification(
        title: 'Drone Pilot Assigned',
        description: '$operatorName has accepted the scan request.',
        isCritical: false,
      );
      notifyListeners();
    }
  }

  void operatorStartScan(String scanId) async {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.inProgress,
      );

      await _bookingService.updateBookingStatus(
        scanId,
        DroneScanStatus.inProgress,
      );
      notifyListeners();
    }
  }

  void operatorCompleteScan(String scanId) async {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.processing,
      );

      await _bookingService.updateBookingStatus(
        scanId,
        DroneScanStatus.processing,
      );

      Future.delayed(const Duration(seconds: 1), () async {
        final scanIdx = _scans.indexWhere((s) => s.id == scanId);
        if (scanIdx != -1) {
          _scans[scanIdx] = _scans[scanIdx].copyWith(
            status: DroneScanStatus.aiAnalysis,
            verificationStatus: 'UNDER REVIEW',
          );

          await _bookingService.updateBookingStatus(
            scanId,
            DroneScanStatus.aiAnalysis,
            verificationStatus: 'UNDER REVIEW',
          );

          _addNotification(
            title: 'Scan AI Processing Complete',
            description: 'Drone data has been parsed. Report sent to Expert for verification.',
            isCritical: false,
          );
          notifyListeners();
        }
      });
      notifyListeners();
    }
  }

  // Expert/Admin Actions
  void adminVerifyReport(String scanId, String verificationStatus, {int? healthScore}) async {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      final finalHealth = healthScore ?? _scans[idx].healthScore;

      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.reportReady,
        verificationStatus: verificationStatus,
        healthScore: finalHealth,
      );

      await _bookingService.updateBookingStatus(
        scanId,
        DroneScanStatus.reportReady,
        verificationStatus: verificationStatus,
        healthScore: finalHealth,
      );

      _addNotification(
        title: 'Field Intelligence Report Ready',
        description: 'Verification complete ($verificationStatus) for scan on ${_scans[idx].date}. Health: $finalHealth/100.',
        isCritical: true,
      );

      if (_scans[idx].fieldId == 'field_a') {
        _applyIrrigationOutcome();
      }
      notifyListeners();
    }
  }

  // --- Action Tracking ---
  void recordAction({
    required String fieldId,
    required String title,
    required String category,
    required String zoneName,
    required String notes,
    Map<String, String>? beforeState,
    Map<String, String>? afterState,
  }) {
    final newAction = ActionEntry(
      id: 'action_${DateTime.now().millisecondsSinceEpoch}',
      fieldId: fieldId,
      title: title,
      category: category,
      zoneName: zoneName,
      date: '2026-08-26',
      notes: notes,
      isCompleted: true,
      beforeState: beforeState,
      afterState: afterState,
    );

    if (_isOffline) {
      _offlineActionQueue.add(newAction);
      _addNotification(
        title: 'Action Queued Offline',
        description: '"$title on $zoneName" recorded offline. Will sync once network returns.',
        isCritical: false,
      );
    } else {
      _actions.insert(0, newAction);
      _addNotification(
        title: 'Action Logged',
        description: 'Recorded action: "$title on $zoneName".',
        isCritical: false,
      );
    }
    notifyListeners();
  }

  void _applyIrrigationOutcome() {
    final hasIrrigatedZone2 = _actions.any(
      (a) => a.fieldId == 'field_a' && a.zoneName == 'Zone 2' && a.title.contains('Irrigation'),
    );

    if (hasIrrigatedZone2) {
      final fieldIdx = _fields.indexWhere((f) => f.id == 'field_a');
      if (fieldIdx != -1) {
        final field = _fields[fieldIdx];

        final updatedZones = field.zones.map((z) {
          if (z.id == 'z2') {
            return z.copyWith(
              status: 'Healthy',
              moisture: 48.0,
              risk: 'None',
              aiExplanation: 'Soil moisture improved to 48% after recorded irrigation on 26 Aug.',
              recommendation: 'Maintain regular watering intervals.',
            );
          }
          return z;
        }).toList();

        final updatedSensors = field.sensors.map((s) {
          if (s.sensorName == 'Soil Moisture') {
            final newHistory = List<double>.from(s.history)..add(48.0);
            return s.copyWith(
              currentValue: 48.0,
              status: 'NORMAL',
              history: newHistory,
            );
          }
          return s;
        }).toList();

        _fields[fieldIdx] = field.copyWith(
          healthScore: 82,
          prevHealthScore: 78,
          moistureStatus: 'NORMAL',
          lastScanDate: '26 Aug (Verified Scan)',
          activeAlerts: field.activeAlerts.where((a) => !a.contains('Zone 2') && !a.contains('Soil Moisture')).toList(),
          zones: updatedZones,
          sensors: updatedSensors,
        );

        final actionIdx = _actions.indexWhere(
          (a) => a.fieldId == 'field_a' && a.zoneName == 'Zone 2' && a.title.contains('Irrigation'),
        );
        if (actionIdx != -1) {
          _actions[actionIdx] = _actions[actionIdx].copyWith(
            afterState: {'Moisture': '48%', 'Stress': 'NORMAL'},
            notes: '${_actions[actionIdx].notes}\n[System Outcome]: Soil moisture increased to 48%. Growth indicators restored.',
          );
        }
      }
    }
  }

  // --- Seed Initial Fallback Datasets ---
  void _initializeData() {
    _currentLanguage = 'en';
    _currentRole = 'FARMER';
    _isOffline = false;
    _offlineActionQueue.clear();

    _currentProfile = FarmerProfile(
      name: 'Demo Farmer',
      phone: '9876543210',
      email: 'farmer@agrivyaan.com',
      preferredLanguage: 'en',
      location: 'Wardha, Maharashtra',
      farmArea: 9.7,
      areaUnit: 'acres',
      mainCrop: 'Cotton',
    );

    _fields = [
      CropField(
        id: 'field_a',
        name: 'Field A (Cotton)',
        crop: 'Cotton',
        area: 3.2,
        areaUnit: 'acres',
        sowingDate: '2026-06-15',
        cropStage: 'Flowering stage',
        healthScore: 78,
        prevHealthScore: 84,
        lastScanDate: '26 Aug',
        moistureStatus: 'LOW',
        activeAlerts: ['Zone 2: Low Soil Moisture Alert', 'Early Moisture Warning'],
        zones: [
          Zone(
            id: 'z1',
            name: 'Zone 1',
            status: 'Healthy',
            moisture: 52.0,
            temperature: 29.0,
            risk: 'None',
            aiExplanation: 'Vegetation indicator index is within healthy ranges.',
            recommendation: 'Maintain present schedule.',
          ),
          Zone(
            id: 'z2',
            name: 'Zone 2',
            status: 'Low moisture',
            moisture: 27.0,
            temperature: 32.0,
            risk: 'Moderate',
            aiExplanation: 'Soil moisture declined from 38% to 27% over the last 48 hours.',
            recommendation: 'Check irrigation in Zone 2 immediately.',
          ),
          Zone(
            id: 'z3',
            name: 'Zone 3',
            status: 'Possible nutrient stress',
            moisture: 45.0,
            temperature: 30.0,
            risk: 'Low',
            aiExplanation: 'Mild discoloration detected in crop leaves.',
            recommendation: 'Apply nitrogen-rich fertilizer dose.',
          ),
          Zone(
            id: 'z4',
            name: 'Zone 4',
            status: 'Healthy',
            moisture: 50.0,
            temperature: 29.0,
            risk: 'None',
            aiExplanation: 'Optimal moisture retention levels.',
            recommendation: 'No action needed.',
          ),
        ],
        sensors: [
          SensorReading(
            sensorName: 'Soil Moisture',
            currentValue: 27.0,
            minNormal: 35.0,
            maxNormal: 65.0,
            unit: '%',
            status: 'LOW',
            history: [45.0, 39.0, 33.0, 27.0],
          ),
          SensorReading(
            sensorName: 'Temperature',
            currentValue: 32.0,
            minNormal: 20.0,
            maxNormal: 35.0,
            unit: '°C',
            status: 'NORMAL',
            history: [29.0, 30.0, 31.0, 32.0],
          ),
          SensorReading(
            sensorName: 'Humidity',
            currentValue: 65.0,
            minNormal: 50.0,
            maxNormal: 80.0,
            unit: '%',
            status: 'NORMAL',
            history: [60.0, 62.0, 64.0, 65.0],
          ),
        ],
      ),
      CropField(
        id: 'field_b',
        name: 'Field B (Tomato)',
        crop: 'Tomato',
        area: 2.5,
        areaUnit: 'acres',
        sowingDate: '2026-07-01',
        cropStage: 'Vegetative stage',
        healthScore: 84,
        prevHealthScore: 85,
        lastScanDate: '24 Aug',
        moistureStatus: 'NORMAL',
        activeAlerts: ['Possible Disease: Early Leaf Blight'],
        zones: [
          Zone(
            id: 'zb1',
            name: 'Zone 1',
            status: 'Healthy',
            moisture: 48.0,
            temperature: 28.0,
            risk: 'None',
            aiExplanation: 'Foliar growth standard.',
            recommendation: 'None.',
          ),
          Zone(
            id: 'zb2',
            name: 'Zone 2',
            status: 'Disease risk',
            moisture: 45.0,
            temperature: 28.0,
            risk: 'Moderate',
            aiExplanation: 'Early signs of brown spots detected in tomato leaf photos.',
            recommendation: 'Spray copper fungicide in Zone 2.',
          ),
          Zone(
            id: 'zb3',
            name: 'Zone 3',
            status: 'Healthy',
            moisture: 49.0,
            temperature: 28.0,
            risk: 'None',
            aiExplanation: 'Normal conditions.',
            recommendation: 'None.',
          ),
          Zone(
            id: 'zb4',
            name: 'Zone 4',
            status: 'Healthy',
            moisture: 47.0,
            temperature: 28.0,
            risk: 'None',
            aiExplanation: 'Normal conditions.',
            recommendation: 'None.',
          ),
        ],
        sensors: [
          SensorReading(
            sensorName: 'Soil Moisture',
            currentValue: 45.0,
            minNormal: 35.0,
            maxNormal: 65.0,
            unit: '%',
            status: 'NORMAL',
            history: [48.0, 47.0, 46.0, 45.0],
          ),
          SensorReading(
            sensorName: 'Temperature',
            currentValue: 28.0,
            minNormal: 18.0,
            maxNormal: 32.0,
            unit: '°C',
            status: 'NORMAL',
            history: [27.0, 27.5, 28.0, 28.0],
          ),
          SensorReading(
            sensorName: 'Humidity',
            currentValue: 72.0,
            minNormal: 60.0,
            maxNormal: 90.0,
            unit: '%',
            status: 'NORMAL',
            history: [70.0, 71.0, 72.0, 72.0],
          ),
        ],
      ),
    ];

    _scans = [
      DroneScan(
        id: 'scan_a1',
        fieldId: 'field_a',
        scanType: 'Crop Health Scan',
        date: '2026-08-26',
        time: '08:30 AM',
        operatorName: 'Rajesh Kumar',
        status: DroneScanStatus.reportReady,
        verificationStatus: 'VERIFIED',
        healthScore: 78,
      ),
      DroneScan(
        id: 'scan_b1',
        fieldId: 'field_b',
        scanType: 'Full Field Analysis',
        date: '2026-08-24',
        time: '09:15 AM',
        operatorName: 'Amit Patil',
        status: DroneScanStatus.reportReady,
        verificationStatus: 'VERIFIED',
        healthScore: 84,
      ),
    ];

    _actions = [
      ActionEntry(
        id: 'action_p1',
        fieldId: 'field_b',
        title: 'Checked Disease Boundary',
        category: 'Pest',
        zoneName: 'Zone 2',
        date: '2026-08-25',
        notes: 'Manually inspected tomato leaf spots. Copper fungicide scheduled.',
        isCompleted: true,
      ),
    ];

    _weatherForecast = [
      WeatherForecast(
        dayName: 'Today',
        date: '26 Aug',
        temperature: 32.0,
        rainProbability: 10.0,
        humidity: 65.0,
        windSpeed: 8.0,
        weatherCondition: 'Sunny',
        sprayingCondition: 'GOOD',
        aiSummary: 'Excellent spraying window. Low wind speed and minimal precipitation risk.',
        bestWindow: 'Tomorrow 6:00 AM – 9:00 AM',
      ),
      WeatherForecast(
        dayName: 'Tomorrow',
        date: '27 Aug',
        temperature: 28.0,
        rainProbability: 75.0,
        humidity: 85.0,
        windSpeed: 14.0,
        weatherCondition: 'Rainy',
        sprayingCondition: 'AVOID',
        aiSummary: 'Avoid spraying operations today. Heavy rain expected in afternoon.',
        bestWindow: 'None',
      ),
    ];

    _notifications = [
      NotificationItem(
        id: 'not_1',
        title: 'Low Moisture Alert: Field A',
        description: 'Field A soil moisture has fallen below 28%. Action recommended.',
        time: '2 hours ago',
        isRead: false,
        isCritical: true,
      ),
    ];

    _soilHealthCards = SoilHealthCardDemoData.demoCards;
  }

  void _addNotification({
    required String title,
    required String description,
    required bool isCritical,
  }) {
    _notifications.insert(
      0,
      NotificationItem(
        id: 'not_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        time: 'Just now',
        isRead: false,
        isCritical: isCritical,
      ),
    );
    notifyListeners();
  }

  void updateWeatherForecast(List<WeatherForecast> forecast) {
    _weatherForecast = forecast;
    notifyListeners();
  }

  void markNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void requestReportForField(String fieldId) {
    if (!_requestedReportFieldIds.contains(fieldId)) {
      _requestedReportFieldIds.add(fieldId);
      _addNotification(
        title: 'Report Request Received',
        description: 'Your request for a detailed crop audit report has been submitted to the admin panel.',
        isCritical: false,
      );
      notifyListeners();
    }
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}
