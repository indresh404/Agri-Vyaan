import 'package:flutter/material.dart';
import '../models/models.dart';
import 'localization.dart';

class AppState extends ChangeNotifier {
  // Authentication & Onboarding
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  FarmerProfile? _currentProfile;
  FarmerProfile? get currentProfile => _currentProfile;

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

  AppState() {
    _initializeData();
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
      // Sync queue
      for (var action in _offlineActionQueue) {
        _actions.insert(0, action);
        _addNotification(
          title: 'Action Synced Successfully',
          description: 'Your offline action "${action.title} on ${action.zoneName}" has been synchronized with the cloud database.',
          isCritical: false,
        );
      }
      _offlineActionQueue.clear();
    }
    notifyListeners();
  }

  // --- Onboarding Flow ---
  void completeOnboarding(FarmerProfile profile) {
    _currentProfile = profile;
    _isLoggedIn = true;

    // Automatically seed user's first field if name not empty
    if (profile.mainCrop.isNotEmpty) {
      final newField = CropField(
        id: 'field_user',
        name: 'My Sown ${profile.mainCrop} Field',
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
      );
      _fields.add(newField);
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _initializeData();
    notifyListeners();
  }

  // --- Field Management ---
  void addField(CropField field) {
    _fields.add(field);
    _addNotification(
      title: 'New Field Registered',
      description: 'Field "${field.name}" was successfully registered under monitoring.',
      isCritical: false,
    );
    notifyListeners();
  }

  void editField(CropField updatedField) {
    final idx = _fields.indexWhere((f) => f.id == updatedField.id);
    if (idx != -1) {
      _fields[idx] = updatedField;
      notifyListeners();
    }
  }

  void deleteField(String fieldId) {
    _fields.removeWhere((f) => f.id == fieldId);
    _scans.removeWhere((s) => s.fieldId == fieldId);
    _actions.removeWhere((a) => a.fieldId == fieldId);
    notifyListeners();
  }

  // --- Drone Scan Bookings & Lifecycle ---
  void requestDroneScan({
    required String fieldId,
    required String scanType,
    required String date,
    required String time,
  }) {
    final field = _fields.firstWhere((f) => f.id == fieldId);
    final newScan = DroneScan(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      fieldId: fieldId,
      scanType: scanType,
      date: date,
      time: time,
      operatorName: 'Pending Assignment',
      status: DroneScanStatus.requested,
      verificationStatus: 'PENDING',
    );
    _scans.insert(0, newScan);
    _addNotification(
      title: 'Drone Scan Requested',
      description: 'A $scanType scan has been requested for ${field.name} on $date.',
      isCritical: false,
    );
    notifyListeners();
  }

  // Operator Actions
  void operatorAcceptScan(String scanId, String operatorName) {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.droneAssigned,
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

  void operatorStartScan(String scanId) {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.inProgress,
      );
      notifyListeners();
    }
  }

  void operatorCompleteScan(String scanId) {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.processing,
      );
      // Simulate quick processing and AI Analysis pipeline automatically
      Future.delayed(const Duration(seconds: 1), () {
        final scanIdx = _scans.indexWhere((s) => s.id == scanId);
        if (scanIdx != -1) {
          _scans[scanIdx] = _scans[scanIdx].copyWith(
            status: DroneScanStatus.aiAnalysis,
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
  void adminVerifyReport(String scanId, String verificationStatus, {int? healthScore}) {
    final idx = _scans.indexWhere((s) => s.id == scanId);
    if (idx != -1) {
      final finalHealth = healthScore ?? _scans[idx].healthScore;
      
      _scans[idx] = _scans[idx].copyWith(
        status: DroneScanStatus.reportReady,
        verificationStatus: verificationStatus,
        healthScore: finalHealth,
      );

      // Notify Farmer
      _addNotification(
        title: 'Field Intelligence Report Ready',
        description: 'Verification complete ($verificationStatus) for scan on ${_scans[idx].date}. Health: $finalHealth/100.',
        isCritical: true,
      );

      // If the scan was on Field A, and we had recorded action "Irrigated Zone 2", we trigger the IMPROVEMENT lifecycle!
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

  // --- Demo Scenario: Before -> Action -> After Verification loop ---
  void _applyIrrigationOutcome() {
    // Check if the user irrigated Zone 2 of Field A
    final hasIrrigatedZone2 = _actions.any(
      (a) => a.fieldId == 'field_a' && a.zoneName == 'Zone 2' && a.title.contains('Irrigation')
    );

    if (hasIrrigatedZone2) {
      final fieldIdx = _fields.indexWhere((f) => f.id == 'field_a');
      if (fieldIdx != -1) {
        final field = _fields[fieldIdx];
        
        // Update Zone 2 stats
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

        // Update Soil Moisture Sensor
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

        // Update Field Metrics
        _fields[fieldIdx] = field.copyWith(
          healthScore: 82,
          prevHealthScore: 78,
          moistureStatus: 'NORMAL',
          lastScanDate: '26 Aug (Verified Scan)',
          activeAlerts: field.activeAlerts.where((a) => !a.contains('Zone 2') && !a.contains('Soil Moisture')).toList(),
          zones: updatedZones,
          sensors: updatedSensors,
        );

        // Update the Action outcome mapping
        final actionIdx = _actions.indexWhere(
          (a) => a.fieldId == 'field_a' && a.zoneName == 'Zone 2' && a.title.contains('Irrigation')
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

  // --- Seed Initial Datasets ---
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

    // 1. Fields
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
      CropField(
        id: 'field_c',
        name: 'Field C (Wheat)',
        crop: 'Wheat',
        area: 4.0,
        areaUnit: 'acres',
        sowingDate: '2026-08-10',
        cropStage: 'Germination stage',
        healthScore: 91,
        prevHealthScore: 89,
        lastScanDate: '25 Aug',
        moistureStatus: 'NORMAL',
        activeAlerts: [],
        zones: [
          Zone(
            id: 'zc1',
            name: 'Zone 1',
            status: 'Healthy',
            moisture: 55.0,
            temperature: 26.0,
            risk: 'None',
            aiExplanation: 'Germination sprouting evenly distributed.',
            recommendation: 'Maintain irrigation cycle.',
          ),
          Zone(
            id: 'zc2',
            name: 'Zone 2',
            status: 'Healthy',
            moisture: 55.0,
            temperature: 26.0,
            risk: 'None',
            aiExplanation: 'Sprouting healthy.',
            recommendation: 'Maintain cycle.',
          ),
        ],
        sensors: [
          SensorReading(
            sensorName: 'Soil Moisture',
            currentValue: 55.0,
            minNormal: 40.0,
            maxNormal: 70.0,
            unit: '%',
            status: 'NORMAL',
            history: [52.0, 53.0, 54.0, 55.0],
          ),
        ],
      )
    ];

    // 2. Drone Scans
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
      DroneScan(
        id: 'scan_c1',
        fieldId: 'field_c',
        scanType: 'Moisture/Soil Scan',
        date: '2026-08-25',
        time: '07:45 AM',
        operatorName: 'Amit Patil',
        status: DroneScanStatus.reportReady,
        verificationStatus: 'VERIFIED',
        healthScore: 91,
      ),
    ];

    // 3. Actions
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
      ActionEntry(
        id: 'action_p2',
        fieldId: 'field_a',
        title: 'Nitrogen Applicator',
        category: 'Nutrient',
        zoneName: 'Zone 3',
        date: '2026-08-22',
        notes: 'Hand spread urea mixture to counter discoloration.',
        isCompleted: true,
      ),
    ];

    // 4. Weather
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
        aiSummary: 'Excellent spraying window. The low wind speed and minimal precipitation risk prevent drift and product wash-off.',
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
        aiSummary: 'Avoid spraying operations today. Heavy rain showers expected in the afternoon will wash away inputs.',
        bestWindow: 'None',
      ),
      WeatherForecast(
        dayName: 'Fri',
        date: '28 Aug',
        temperature: 29.0,
        rainProbability: 45.0,
        humidity: 78.0,
        windSpeed: 12.0,
        weatherCondition: 'Cloudy',
        sprayingCondition: 'MODERATE',
        aiSummary: 'Moderate condition. Rain probability is high in evening. Use rain-fastness adjuvant if urgent spray is needed.',
        bestWindow: '06:00 AM - 09:00 AM',
      ),
      WeatherForecast(
        dayName: 'Sat',
        date: '29 Aug',
        temperature: 31.0,
        rainProbability: 15.0,
        humidity: 62.0,
        windSpeed: 9.0,
        weatherCondition: 'Sunny',
        sprayingCondition: 'GOOD',
        aiSummary: 'Weather returns to dry and clear. Spraying conditions are good.',
        bestWindow: '07:00 AM - 10:30 AM',
      ),
      WeatherForecast(
        dayName: 'Sun',
        date: '30 Aug',
        temperature: 33.0,
        rainProbability: 5.0,
        humidity: 55.0,
        windSpeed: 7.0,
        weatherCondition: 'Sunny',
        sprayingCondition: 'GOOD',
        aiSummary: 'Low humidity and calm wind speeds create optimal spraying conditions.',
        bestWindow: '06:00 AM - 10:00 AM',
      ),
      WeatherForecast(
        dayName: 'Mon',
        date: '31 Aug',
        temperature: 32.0,
        rainProbability: 20.0,
        humidity: 68.0,
        windSpeed: 10.0,
        weatherCondition: 'Cloudy',
        sprayingCondition: 'GOOD',
        aiSummary: 'Overcast skies and pleasant winds offer comfortable application window.',
        bestWindow: '08:00 AM - 11:00 AM',
      ),
    ];

    // 5. Library Items
    _libraryCrops = [
      LibraryItem(
        id: 'lc_1',
        type: 'Crop',
        name: 'Cotton',
        description: 'Cotton is a soft, fluffy staple fiber that grows in a boll, or protective case, around the seeds of the cotton plants of the genus Gossypium.',
        details: [
          'Optimal Temperature: 21°C to 30°C',
          'Sowing Period: May - June',
          'Irrigation Requirement: Moderate (sensitive to waterlogging)',
          'Fertilization: High requirements of Nitrogen and Potassium during flowering stage.',
          'Growth Stages: Germination, Vegetative, Squaring, Flowering, Boll Development, Harvest.'
        ],
        affectedCrops: ['Cotton'],
      ),
      LibraryItem(
        id: 'lc_2',
        type: 'Crop',
        name: 'Tomato',
        description: 'Tomatoes are warm-season crops that require ample sunlight and well-draining organic soil to flourish.',
        details: [
          'Optimal Temperature: 18°C to 27°C',
          'Sowing Period: June - July / Nov - Dec',
          'Growth Stages: Seedling, Vegetative, Flowering, Fruit set, Ripening.'
        ],
        affectedCrops: ['Tomato'],
      ),
      LibraryItem(
        id: 'lc_3',
        type: 'Crop',
        name: 'Wheat',
        description: 'Wheat is a cereal grain, originally from the Levant region of the Near East but now cultivated worldwide.',
        details: [
          'Optimal Temperature: 12°C to 25°C',
          'Sowing Period: October - December',
          'Growth Stages: Germination, Tillering, Jointing, Heading, Milking, Ripening.'
        ],
        affectedCrops: ['Wheat'],
      ),
    ];

    _libraryPests = [
      LibraryItem(
        id: 'lp_1',
        type: 'Pest',
        name: 'Pink Bollworm',
        description: 'The pink bollworm is an insect known for being a pest in cotton farming.',
        details: [
          'Symptoms: Double flowers, boll boring holes, stained lint production.',
          'Prevention: Crop rotation, pheromone traps installation.',
          'Management: Apply Neem oil sprays, release parasitoid Trichogramma, or localized insecticide applications strictly based on labels.'
        ],
        affectedCrops: ['Cotton'],
      ),
      LibraryItem(
        id: 'lp_2',
        type: 'Pest',
        name: 'Tomato Fruit Borer',
        description: 'A major insect pest feeding inside tomato fruits, rendering them unmarketable.',
        details: [
          'Symptoms: Circular boring holes on fruits, internal pulp rot.',
          'Management: Hand-picking infected fruits, installing pheromone lures.'
        ],
        affectedCrops: ['Tomato'],
      ),
    ];

    _libraryDiseases = [
      LibraryItem(
        id: 'ld_1',
        type: 'Disease',
        name: 'Early Blight',
        description: 'Early Blight is a common fungal disease of tomato plants caused by Alternaria solani.',
        details: [
          'Symptoms: Concentric dark brown circles resembling targets on leaves and stems.',
          'Prevention: Crop rotation, drip irrigation to keep foliage dry, clear plant residues.',
          'Management: Apply copper-based organic fungicides early during vegetative stages. Follow product labeling.'
        ],
        affectedCrops: ['Tomato'],
      ),
      LibraryItem(
        id: 'ld_2',
        type: 'Disease',
        name: 'Cotton Leaf Curl Virus',
        description: 'A destructive viral infection transmitted by whiteflies leading to leaf deformation.',
        details: [
          'Symptoms: Upward curling of leaf margins, leaf thickening, stunted growth.',
          'Prevention: Plant resistant varieties, manage vector whitefly populations.'
        ],
        affectedCrops: ['Cotton'],
      ),
    ];

    // 6. Notifications
    _notifications = [
      NotificationItem(
        id: 'not_1',
        title: 'Action Item: Check Zone 2 Irrigation',
        description: 'Field A soil moisture has fallen below 28%. Action is recommended.',
        time: '2 hours ago',
        isRead: false,
        isCritical: true,
      ),
      NotificationItem(
        id: 'not_2',
        title: 'Drone Report Verified',
        description: 'Expert Rajesh verified Field B Tomato report. Condition: Moderate.',
        time: '1 day ago',
        isRead: true,
        isCritical: false,
      ),
      NotificationItem(
        id: 'not_3',
        title: 'Weather Warning: High Rain Risk',
        description: 'Heavy precipitation forecast for tomorrow (75% probability). Avoid spraying.',
        time: '1 day ago',
        isRead: false,
        isCritical: true,
      ),
    ];
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

  void updateWeatherForecast(List<WeatherForecast> forecast) {
    _weatherForecast = forecast;
    notifyListeners();
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
