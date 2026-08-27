import type { FarmerRequest, FieldAsset, DroneOperation, CropFinding, AssessmentReport, ActivityItem, ZoneData, SensorReading, WeatherForecast, LibraryItem, ActionEntry } from '../types';

// ─── Helper: generate 6x6 zone grid for a field ───────────────────────────────
const generateZones = (overrides: Record<number, Partial<ZoneData>> = {}): ZoneData[] => {
  const zones: ZoneData[] = [];
  let count = 1;
  for (let r = 1; r <= 6; r++) {
    for (let c = 1; c <= 6; c++) {
      const override = overrides[count] || {};
      zones.push({
        id: `Zone ${count}`,
        zoneNumber: count,
        gridRow: r,
        gridCol: c,
        status: 'Healthy',
        soilMoisture: 50 + ((count * 3) % 12),
        temperature: 29,
        gpsCoords: `19.${2180 + count}, 72.${9770 + count}`,
        lastScanned: 'Today, 10:42 AM',
        ...override
      });
      count++;
    }
  }
  return zones;
};

// ─── FARMER REQUESTS ──────────────────────────────────────────────────────────
export const MOCK_REQUESTS: FarmerRequest[] = [
  {
    id: 'REQ-1024',
    farmerName: 'Ramesh Kumar',
    fieldId: 'FIELD-A',
    fieldName: 'Field A (Cotton)',
    location: 'Thane, Maharashtra',
    requestedDate: '2026-08-26',
    priority: 'High',
    status: 'In Progress',
    notes: 'Visible leaf discoloration in northern parcel. Zone 2 moisture dropped from 38% to 27% over 48 hours. Requesting multispectral analysis.',
    areaHa: 4.8,
    crop: 'Cotton',
    previousOperationsCount: 3
  },
  {
    id: 'REQ-1025',
    farmerName: 'Suresh Patil',
    fieldId: 'FIELD-B',
    fieldName: 'Field B (Tomato)',
    location: 'Kalyan, Maharashtra',
    requestedDate: '2026-08-24',
    priority: 'Medium',
    status: 'Completed',
    notes: 'Brown spots appearing on tomato leaves in Zone 2. Possible Early Leaf Blight. Requesting full field analysis.',
    areaHa: 6.2,
    crop: 'Tomato',
    previousOperationsCount: 5
  },
  {
    id: 'REQ-1026',
    farmerName: 'Anil Deshmukh',
    fieldId: 'FIELD-C',
    fieldName: 'Field C (Wheat)',
    location: 'Bhiwandi, Maharashtra',
    requestedDate: '2026-08-25',
    priority: 'Low',
    status: 'Completed',
    notes: 'Moisture/soil scan for germination-stage wheat field. Even sprouting check.',
    areaHa: 3.5,
    crop: 'Wheat',
    previousOperationsCount: 2
  },
  {
    id: 'REQ-1027',
    farmerName: 'Sunita Jadhav',
    fieldId: 'FIELD-D',
    fieldName: 'Field D (Soybean)',
    location: 'Panvel, Maharashtra',
    requestedDate: '2026-08-24',
    priority: 'High',
    status: 'Pending',
    notes: 'Suspected pest damage along field perimeter. Needs emergency evaluation.',
    areaHa: 5.1,
    crop: 'Soybean',
    previousOperationsCount: 1
  },
  {
    id: 'REQ-1028',
    farmerName: 'Prakash Shinde',
    fieldId: 'FIELD-E',
    fieldName: 'Field E (Sugarcane)',
    location: 'Vasai, Maharashtra',
    requestedDate: '2026-08-24',
    priority: 'Medium',
    status: 'Scheduled',
    notes: 'Baseline mapping for upcoming season planning.',
    areaHa: 7.0,
    crop: 'Sugarcane',
    previousOperationsCount: 4
  }
];

// ─── SENSOR READINGS ──────────────────────────────────────────────────────────
const fieldASensors: SensorReading[] = [
  { sensorName: 'Soil Moisture', currentValue: 27.0, minNormal: 35.0, maxNormal: 65.0, unit: '%', status: 'LOW', history: [45, 39, 33, 27] },
  { sensorName: 'Temperature',   currentValue: 32.0, minNormal: 20.0, maxNormal: 35.0, unit: '°C', status: 'NORMAL', history: [29, 30, 31, 32] },
  { sensorName: 'Humidity',      currentValue: 65.0, minNormal: 50.0, maxNormal: 80.0, unit: '%', status: 'NORMAL', history: [60, 62, 64, 65] }
];

const fieldBSensors: SensorReading[] = [
  { sensorName: 'Soil Moisture', currentValue: 45.0, minNormal: 35.0, maxNormal: 65.0, unit: '%', status: 'NORMAL', history: [48, 47, 46, 45] },
  { sensorName: 'Temperature',   currentValue: 28.0, minNormal: 18.0, maxNormal: 32.0, unit: '°C', status: 'NORMAL', history: [27, 27.5, 28, 28] },
  { sensorName: 'Humidity',      currentValue: 72.0, minNormal: 60.0, maxNormal: 90.0, unit: '%', status: 'NORMAL', history: [70, 71, 72, 72] }
];

const fieldCSensors: SensorReading[] = [
  { sensorName: 'Soil Moisture', currentValue: 55.0, minNormal: 40.0, maxNormal: 70.0, unit: '%', status: 'NORMAL', history: [52, 53, 54, 55] },
  { sensorName: 'Temperature',   currentValue: 26.0, minNormal: 15.0, maxNormal: 32.0, unit: '°C', status: 'NORMAL', history: [26, 26, 26, 26] }
];

// ─── FIELDS ───────────────────────────────────────────────────────────────────
export const MOCK_FIELDS: FieldAsset[] = [
  {
    id: 'FIELD-A',
    name: 'Field A (Cotton)',
    farmerName: 'Ramesh Kumar',
    location: 'Thane, Maharashtra',
    crop: 'Cotton',
    areaHa: 4.8,
    sowingDate: '2026-06-15',
    cropStage: 'Flowering stage',
    status: 'Attention Required',
    healthScore: 78,
    prevHealthScore: 84,
    lastScan: 'Today, 10:42 AM',
    moistureStatus: 'LOW',
    activeAlerts: ['Zone 2: Low Soil Moisture Alert', 'Early Moisture Warning — Potential Stress'],
    sensors: fieldASensors,
    zones: generateZones({
      2:  { status: 'Low moisture',           soilMoisture: 27, temperature: 32, stressType: 'Low moisture (27%)', confidence: 91, recommendedAction: 'Check irrigation in Zone 2 immediately.', aiExplanation: 'Soil moisture declined from 38% to 27% over the last 48 hours.', gpsCoords: '19.2184, 72.9781' },
      3:  { status: 'Possible nutrient stress', soilMoisture: 45, temperature: 30, stressType: 'Possible nutrient stress', confidence: 78, recommendedAction: 'Apply nitrogen-rich fertilizer dose.', aiExplanation: 'Mild discoloration detected in crop leaves.' },
      27: { status: 'High Priority',            soilMoisture: 23, temperature: 33, stressType: 'Visible crop stress / yellowing', confidence: 91, recommendedAction: 'Prioritize this zone for targeted soil inspection due to detected visible crop stress.', aiExplanation: 'Chlorophyll reflectance anomaly detected across 0.4 ha area.', gpsCoords: '19.2184, 72.9781' }
    })
  },
  {
    id: 'FIELD-B',
    name: 'Field B (Tomato)',
    farmerName: 'Suresh Patil',
    location: 'Kalyan, Maharashtra',
    crop: 'Tomato',
    areaHa: 6.2,
    sowingDate: '2026-07-01',
    cropStage: 'Vegetative stage',
    status: 'Attention Required',
    healthScore: 84,
    prevHealthScore: 85,
    lastScan: 'Today, 08:45 AM',
    moistureStatus: 'NORMAL',
    activeAlerts: ['Possible Disease: Early Leaf Blight in Zone 2'],
    sensors: fieldBSensors,
    zones: generateZones({
      2: { status: 'Disease risk', soilMoisture: 45, stressType: 'Disease risk — Early Leaf Blight', confidence: 82, recommendedAction: 'Spray copper fungicide in Zone 2.', aiExplanation: 'Early signs of brown spots detected in tomato leaf photos.' }
    })
  },
  {
    id: 'FIELD-C',
    name: 'Field C (Wheat)',
    farmerName: 'Anil Deshmukh',
    location: 'Bhiwandi, Maharashtra',
    crop: 'Wheat',
    areaHa: 3.5,
    sowingDate: '2026-08-10',
    cropStage: 'Germination stage',
    status: 'Normal',
    healthScore: 91,
    prevHealthScore: 89,
    lastScan: 'Yesterday, 04:15 PM',
    moistureStatus: 'NORMAL',
    activeAlerts: [],
    sensors: fieldCSensors,
    zones: generateZones()
  },
  {
    id: 'FIELD-D',
    name: 'Field D (Soybean)',
    farmerName: 'Sunita Jadhav',
    location: 'Panvel, Maharashtra',
    crop: 'Soybean',
    areaHa: 5.1,
    status: 'Attention Required',
    healthScore: 68,
    lastScan: '3 days ago',
    activeAlerts: ['Suspected Pest Damage — Perimeter Zones'],
    zones: generateZones({
      8: { status: 'Warning', soilMoisture: 18, stressType: 'Water stress pattern', confidence: 86, recommendedAction: 'Verify irrigation channel flow.', gpsCoords: '19.1120, 73.0125' }
    })
  }
];

// ─── DRONE OPERATIONS ─────────────────────────────────────────────────────────
export const MOCK_OPERATIONS: DroneOperation[] = [
  {
    id: 'OP-0142',
    requestId: 'REQ-1024',
    farmerName: 'Ramesh Kumar',
    fieldName: 'Field A (Cotton)',
    droneId: 'Drone-01',
    scanType: 'Crop Health Scan',
    operatorName: 'Rajesh Kumar',
    startTime: '10:15 AM',
    progressPercent: 68,
    status: 'In Progress',
    scanLifecycleStatus: 'IN PROGRESS',
    verificationStatus: 'PENDING',
    batteryLevel: 62,
    altitudeMeters: 45,
    speedMs: 4.2,
    totalAreaScannedHa: 3.2,
    timeline: [
      { stage: 'REQUESTED',     timestamp: '08:30 AM', completed: true,  current: false },
      { stage: 'DRONE ASSIGNED',timestamp: '09:15 AM', completed: true,  current: false },
      { stage: 'IN PROGRESS',   timestamp: '10:15 AM', completed: false, current: true  },
      { stage: 'PROCESSING',    timestamp: '--:--',    completed: false, current: false },
      { stage: 'AI ANALYSIS',   timestamp: '--:--',    completed: false, current: false },
      { stage: 'VERIFICATION',  timestamp: '--:--',    completed: false, current: false },
      { stage: 'REPORT READY',  timestamp: '--:--',    completed: false, current: false }
    ]
  },
  {
    id: 'OP-0141',
    requestId: 'REQ-1025',
    farmerName: 'Suresh Patil',
    fieldName: 'Field B (Tomato)',
    droneId: 'Drone-02',
    scanType: 'Full Field Analysis',
    operatorName: 'Amit Patil',
    startTime: '08:45 AM',
    progressPercent: 100,
    status: 'Completed',
    scanLifecycleStatus: 'REPORT READY',
    verificationStatus: 'VERIFIED',
    batteryLevel: 94,
    altitudeMeters: 50,
    speedMs: 5.0,
    totalAreaScannedHa: 6.2,
    timeline: [
      { stage: 'REQUESTED',     timestamp: '07:10 AM', completed: true, current: false },
      { stage: 'DRONE ASSIGNED',timestamp: '07:30 AM', completed: true, current: false },
      { stage: 'IN PROGRESS',   timestamp: '08:45 AM', completed: true, current: false },
      { stage: 'PROCESSING',    timestamp: '09:30 AM', completed: true, current: false },
      { stage: 'AI ANALYSIS',   timestamp: '09:45 AM', completed: true, current: false },
      { stage: 'VERIFICATION',  timestamp: '09:55 AM', completed: true, current: false },
      { stage: 'REPORT READY',  timestamp: '10:00 AM', completed: true, current: false }
    ]
  },
  {
    id: 'OP-0140',
    requestId: 'REQ-1026',
    farmerName: 'Anil Deshmukh',
    fieldName: 'Field C (Wheat)',
    droneId: 'Drone-03',
    scanType: 'Moisture/Soil Scan',
    operatorName: 'Amit Patil',
    startTime: 'Yesterday, 03:00 PM',
    progressPercent: 100,
    status: 'Completed',
    scanLifecycleStatus: 'REPORT READY',
    verificationStatus: 'VERIFIED',
    batteryLevel: 88,
    altitudeMeters: 45,
    speedMs: 4.0,
    totalAreaScannedHa: 3.5,
    timeline: [
      { stage: 'REQUESTED',    timestamp: 'Yesterday', completed: true, current: false },
      { stage: 'REPORT READY', timestamp: 'Yesterday', completed: true, current: false }
    ]
  },
  {
    id: 'OP-0139',
    requestId: 'REQ-1027',
    farmerName: 'Sunita Jadhav',
    fieldName: 'Field D (Soybean)',
    droneId: 'Drone-01',
    scanType: 'Crop Health Scan',
    operatorName: 'Pending Assignment',
    startTime: 'Scheduled 02:00 PM',
    progressPercent: 0,
    status: 'Planned',
    scanLifecycleStatus: 'REQUESTED',
    verificationStatus: 'PENDING',
    timeline: [
      { stage: 'REQUESTED',    timestamp: 'Aug 24',   completed: true,  current: false },
      { stage: 'DRONE ASSIGNED',timestamp: 'Today',   completed: false, current: true  }
    ]
  }
];

export const MOCK_FINDINGS: CropFinding[] = [
  {
    id: 'FND-027',
    fieldId: 'FIELD-A',
    fieldName: 'Field A (Cotton)',
    zoneId: 'Zone 2',
    status: 'Pending Validation',
    findingType: 'Low moisture / Water stress',
    confidencePercent: 91,
    gpsCoords: '19.2184, 72.9781',
    timestamp: '10:42 AM',
    operationId: 'OP-0142',
    farmerName: 'Ramesh Kumar',
    soilMoisturePercent: 27,
    notes: 'Soil moisture declined from 38% to 27% over last 48 hours. Stage 1 quick pass flagged Zone 2 for rescan.',
    recommendedAction: 'Check irrigation in Zone 2 immediately. Target moisture above 35%.',
    probabilities: {
      waterStress: 84,
      disease: 11,
      nutrient: 3,
      healthy: 2
    },
    stageAI: 'Stage 2 (Rescan Close-Up)',
    inspectionReductionPercent: 91.6
  },
  {
    id: 'FND-014',
    fieldId: 'FIELD-A',
    fieldName: 'Field A (Cotton)',
    zoneId: 'Zone 27',
    status: 'Pending Validation',
    findingType: 'Visible crop stress / yellowing',
    confidencePercent: 78,
    gpsCoords: '19.2200, 72.9789',
    timestamp: '10:38 AM',
    operationId: 'OP-0142',
    farmerName: 'Ramesh Kumar',
    soilMoisturePercent: 23,
    notes: 'Chlorophyll reflectance anomaly detected across 0.4 ha area. Stage 2 deep check confirmed leaf yellowing.',
    recommendedAction: 'Prioritize this zone for targeted soil inspection due to detected visible crop stress.',
    probabilities: {
      disease: 72,
      waterStress: 18,
      nutrient: 7,
      healthy: 3
    },
    stageAI: 'Stage 2 (Rescan Close-Up)',
    inspectionReductionPercent: 91.6
  },
  {
    id: 'FND-008',
    fieldId: 'FIELD-D',
    fieldName: 'Field D (Soybean)',
    zoneId: 'Zone 8',
    status: 'Pending Validation',
    findingType: 'Water stress pattern',
    confidencePercent: 86,
    gpsCoords: '19.1120, 73.0125',
    timestamp: '3 days ago',
    operationId: 'OP-0138',
    farmerName: 'Sunita Jadhav',
    soilMoisturePercent: 18,
    notes: 'Low moisture signature along eastern border. Handheld soil moisture probe confirmation pending.',
    recommendedAction: 'Verify irrigation channel flow.',
    probabilities: {
      waterStress: 86,
      disease: 8,
      nutrient: 4,
      healthy: 2
    },
    stageAI: 'Stage 2 (Rescan Close-Up)',
    inspectionReductionPercent: 94.4
  }
];

// ─── REPORTS ──────────────────────────────────────────────────────────────────
export const MOCK_REPORTS: AssessmentReport[] = [
  {
    id: 'REP-904',
    requestId: 'REQ-1024',
    operationId: 'OP-0142',
    farmerName: 'Ramesh Kumar',
    fieldName: 'Field A (Cotton)',
    generatedDate: '2026-08-26 (Draft)',
    status: 'Draft',
    healthIndexScore: 78,
    priorityRecommendations: [
      'Zone 2: Low soil moisture (27%) detected. Check irrigation channel flow immediately.',
      'Zone 27: Visible crop stress detected (91% confidence). Prioritize soil inspection.',
      'Schedule follow-up multispectral scan in 7 days to evaluate stress progression.',
      'Maintain standard irrigation schedule for healthy southern quadrants.'
    ]
  },
  {
    id: 'REP-903',
    requestId: 'REQ-1025',
    operationId: 'OP-0141',
    farmerName: 'Suresh Patil',
    fieldName: 'Field B (Tomato)',
    generatedDate: '2026-08-24',
    status: 'Ready',
    healthIndexScore: 84,
    priorityRecommendations: [
      'Zone 2: Early Leaf Blight signs detected. Spray copper fungicide immediately.',
      'Field health remains acceptable. No broad irrigation concerns at this stage.'
    ]
  },
  {
    id: 'REP-902',
    requestId: 'REQ-1026',
    operationId: 'OP-0140',
    farmerName: 'Anil Deshmukh',
    fieldName: 'Field C (Wheat)',
    generatedDate: '2026-08-25',
    status: 'Sent',
    healthIndexScore: 91,
    priorityRecommendations: [
      'Germination sprouting evenly distributed. Field health at 91/100.',
      'Maintain standard irrigation cycle. No treatment required.'
    ]
  }
];

// ─── WEATHER FORECAST ─────────────────────────────────────────────────────────
export const MOCK_WEATHER: WeatherForecast[] = [
  { dayName: 'Today',     date: '27 Aug', temperature: 32, rainProbability: 10, humidity: 65, windSpeed: 8,  weatherCondition: 'Sunny',   sprayingCondition: 'GOOD',     aiSummary: 'Excellent spraying window. Low wind speed and minimal precipitation risk prevent drift and product wash-off.', bestWindow: 'Today 6:00 AM – 9:00 AM' },
  { dayName: 'Tomorrow',  date: '28 Aug', temperature: 28, rainProbability: 75, humidity: 85, windSpeed: 14, weatherCondition: 'Rainy',   sprayingCondition: 'AVOID',    aiSummary: 'Avoid spraying. Heavy rain showers expected in the afternoon will wash away inputs.', bestWindow: 'None' },
  { dayName: 'Fri',       date: '29 Aug', temperature: 29, rainProbability: 45, humidity: 78, windSpeed: 12, weatherCondition: 'Cloudy',  sprayingCondition: 'MODERATE', aiSummary: 'Moderate condition. High evening rain probability. Use rain-fastness adjuvant if urgent spray is needed.', bestWindow: '06:00 AM - 09:00 AM' },
  { dayName: 'Sat',       date: '30 Aug', temperature: 31, rainProbability: 15, humidity: 62, windSpeed: 9,  weatherCondition: 'Sunny',   sprayingCondition: 'GOOD',     aiSummary: 'Weather returns to dry and clear. Spraying conditions are good.', bestWindow: '07:00 AM - 10:30 AM' },
  { dayName: 'Sun',       date: '31 Aug', temperature: 33, rainProbability: 5,  humidity: 55, windSpeed: 7,  weatherCondition: 'Sunny',   sprayingCondition: 'GOOD',     aiSummary: 'Low humidity and calm wind speeds create optimal spraying conditions.', bestWindow: '06:00 AM - 10:00 AM' },
  { dayName: 'Mon',       date: '01 Sep', temperature: 32, rainProbability: 20, humidity: 68, windSpeed: 10, weatherCondition: 'Cloudy',  sprayingCondition: 'GOOD',     aiSummary: 'Overcast skies and pleasant winds offer comfortable application window.', bestWindow: '08:00 AM - 11:00 AM' }
];

// ─── KNOWLEDGE LIBRARY ────────────────────────────────────────────────────────
export const MOCK_LIBRARY: LibraryItem[] = [
  {
    id: 'crop_cotton',
    type: 'Crop',
    name: 'Cotton',
    description: 'Cotton is a soft, fluffy staple fiber that grows in a boll around the seeds of Gossypium plants. It is one of the major cash crops of Maharashtra.',
    details: [
      'Optimal Temperature: 21°C to 30°C',
      'Sowing Period: May – June',
      'Irrigation Requirement: Moderate (sensitive to waterlogging)',
      'Fertilization: High N and K requirements during flowering stage',
      'Growth Stages: Germination → Vegetative → Squaring → Flowering → Boll Development → Harvest'
    ],
    symptoms: 'Leaf curl, yellowing, boll rot, red leaf discoloration.',
    prevention: 'Maintain soil moisture above 35%. Avoid waterlogging.',
    management: 'Regular scouting; apply Imidacloprid for sucking pests.',
    affectedCrops: ['Cotton']
  },
  {
    id: 'crop_tomato',
    type: 'Crop',
    name: 'Tomato',
    description: 'Tomatoes are warm-season crops that require ample sunlight and well-draining organic soil to flourish.',
    details: [
      'Optimal Temperature: 18°C to 27°C',
      'Sowing Period: June – July / Nov – Dec',
      'Irrigation: Drip irrigation preferred — avoid foliar wetting',
      'Growth Stages: Seedling → Vegetative → Flowering → Fruit set → Ripening'
    ],
    symptoms: 'Brown spots, curled leaves, wilting, fruit blossom end rot.',
    prevention: 'Avoid overhead irrigation. Space plants adequately.',
    management: 'Apply copper fungicide for Early Blight. Remove infected leaves.',
    affectedCrops: ['Tomato']
  },
  {
    id: 'crop_wheat',
    type: 'Crop',
    name: 'Wheat',
    description: 'Wheat (Triticum aestivum) is a cereal grain and the most widely cultivated food crop globally. Rabi season crop in India.',
    details: [
      'Optimal Temperature: 15°C to 25°C',
      'Sowing Period: October – November (Rabi)',
      'Water Requirement: 450–650 mm across growth cycle',
      'Growth Stages: Germination → Tillering → Stem Elongation → Heading → Grain Filling → Harvest'
    ],
    symptoms: 'Rust pustules, powdery mildew, root rot.',
    prevention: 'Use certified seed. Balanced N:P:K application.',
    management: 'Propiconazole for leaf rust. Mancozeb for powdery mildew.',
    affectedCrops: ['Wheat']
  },
  {
    id: 'pest_bollworm',
    type: 'Pest',
    name: 'Bollworm (Pink & American)',
    description: 'Major lepidopteran pests that attack cotton bolls, feeding on seeds and fiber, causing direct yield loss.',
    details: [
      'Pink bollworm: Pectinophora gossypiella',
      'American bollworm: Helicoverpa armigera',
      'Peak season: July – September during cotton flowering'
    ],
    symptoms: 'Entry holes in bolls, rosette flowers, caterpillar frass inside bolls.',
    prevention: 'Pheromone traps at 5/ha. Plant Bt cotton varieties.',
    management: 'Emamectin benzoate 5 SG @ 0.4 g/l. Avoid pyrethroid overuse.',
    affectedCrops: ['Cotton']
  },
  {
    id: 'pest_aphids',
    type: 'Pest',
    name: 'Aphids (Cotton & Tomato)',
    description: 'Soft-bodied sucking insects that cluster on new growth and undersides of leaves, transmitting viral diseases.',
    details: [
      'Cotton aphid: Aphis gossypii',
      'Tomato aphid: Macrosiphum euphorbiae',
      'Can cause 30–40% yield loss if uncontrolled'
    ],
    symptoms: 'Curled, yellowing leaves; honeydew deposition; sooty mold growth.',
    prevention: 'Encourage natural predators (ladybird beetles). Avoid excessive nitrogen.',
    management: 'Imidacloprid 0.5 ml/l or Dimethoate 1.5 ml/l spray.',
    affectedCrops: ['Cotton', 'Tomato']
  },
  {
    id: 'disease_leaf_blight',
    type: 'Disease',
    name: 'Early Leaf Blight (Tomato)',
    description: 'Fungal disease caused by Alternaria solani causing circular brown lesions with concentric rings on leaves.',
    details: [
      'Pathogen: Alternaria solani',
      'Favored by: Warm humid conditions (25–30°C, 80%+ RH)',
      'Spreads via infected soil, plant debris, water splash'
    ],
    symptoms: 'Circular brown spots with yellow halos and concentric ring patterns on lower leaves.',
    prevention: 'Crop rotation. Avoid overhead irrigation. Use resistant varieties.',
    management: 'Copper oxychloride @ 3 g/l or Mancozeb 2.5 g/l spray at 10-day intervals.',
    affectedCrops: ['Tomato']
  },
  {
    id: 'disease_powdery_mildew',
    type: 'Disease',
    name: 'Powdery Mildew',
    description: 'Fungal disease creating white powdery coating on leaf surfaces, reducing photosynthesis and yield.',
    details: [
      'Pathogens: Erysiphe and Leveillula species',
      'Favored by: High humidity with dry conditions, 20–27°C',
      'Common on cotton, wheat, and cucurbits'
    ],
    symptoms: 'White or gray powdery patches on upper leaf surfaces.',
    prevention: 'Balanced fertilization. Avoid dense canopies.',
    management: 'Sulphur 80 WP @ 2.5 g/l or Propiconazole 1 ml/l spray.',
    affectedCrops: ['Cotton', 'Wheat']
  }
];

// ─── RECORDED FIELD ACTIONS ───────────────────────────────────────────────────
export const MOCK_ACTIONS: ActionEntry[] = [
  {
    id: 'action_p1',
    fieldId: 'FIELD-B',
    title: 'Checked Disease Boundary',
    category: 'Pest',
    zoneName: 'Zone 2',
    date: '2026-08-25',
    notes: 'Manually inspected tomato leaf spots. Copper fungicide scheduled.',
    isCompleted: true
  },
  {
    id: 'action_p2',
    fieldId: 'FIELD-A',
    title: 'Nitrogen Applicator',
    category: 'Nutrient',
    zoneName: 'Zone 3',
    date: '2026-08-22',
    notes: 'Hand spread urea mixture to counter discoloration.',
    isCompleted: true
  }
];

// ─── ACTIVITY LOG ─────────────────────────────────────────────────────────────
export const MOCK_ACTIVITIES: ActivityItem[] = [
  { id: 'ACT-110', timestamp: '11:20 AM', title: 'Action synced', description: 'Nitrogen applicator action on Field A Zone 3 logged by operator.', category: 'action' },
  { id: 'ACT-106', timestamp: '11:10 AM', title: 'Draft report generated', description: 'Draft field intelligence report REP-904 generated for Field A (Cotton).', category: 'report' },
  { id: 'ACT-105', timestamp: '11:03 AM', title: 'Finding FND-027 logged', description: 'AI detection pipeline flagged low moisture / water stress in Zone 2 (91% confidence).', category: 'validation' },
  { id: 'ACT-104', timestamp: '10:55 AM', title: 'Validation queue updated', description: '2 findings sent to operator validation queue for Field A.', category: 'validation' },
  { id: 'ACT-103', timestamp: '10:50 AM', title: 'Processing completed', description: 'Multispectral imagery stitched and calibrated for OP-0142.', category: 'operation' },
  { id: 'ACT-102', timestamp: '10:15 AM', title: 'Operation OP-0142 started', description: 'Drone-01 (Rajesh Kumar) launched mission OP-0142 over Field A (Thane).', category: 'operation' },
  { id: 'ACT-101', timestamp: '09:15 AM', title: 'Request REQ-1024 accepted', description: 'Operator accepted scan request from farmer Ramesh Kumar.', category: 'request' }
];
