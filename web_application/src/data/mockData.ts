import type { FarmerRequest, FieldAsset, DroneOperation, CropFinding, AssessmentReport, ActivityItem, ZoneData, SensorReading, WeatherForecast, LibraryItem, ActionEntry } from '../types';

// ─── Helper: generate 6x6 zone grid for a field ───────────────────────────────
// GPS coords are spread across the Ambegaon potato field (19.0536–19.0550°N, 73.8810–73.8830°E)
const generateZones = (overrides: Record<number, Partial<ZoneData>> = {}): ZoneData[] => {
  const zones: ZoneData[] = [];
  let count = 1;
  // Field boundary spans roughly 0.0014° lat × 0.0020° lng → 6 cells each
  const LAT_START = 19.0537;
  const LNG_START = 73.8812;
  const LAT_STEP  = 0.0002;   // ~22m per row
  const LNG_STEP  = 0.0003;   // ~27m per col
  for (let r = 1; r <= 6; r++) {
    for (let c = 1; c <= 6; c++) {
      const override = overrides[count] || {};
      const lat = (LAT_START + (r - 1) * LAT_STEP).toFixed(4);
      const lng = (LNG_START + (c - 1) * LNG_STEP).toFixed(4);
      zones.push({
        id: `Zone ${count}`,
        zoneNumber: count,
        gridRow: r,
        gridCol: c,
        status: 'Healthy',
        soilMoisture: 50 + ((count * 3) % 12),
        temperature: 29,
        gpsCoords: `${lat}, ${lng}`,
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
    fieldName: 'Field A (Potato)',
    location: 'Thane, Maharashtra',
    requestedDate: '2026-08-26',
    requestedTime: '08:30 AM',
    scanType: 'Crop Health Scan',
    priority: 'High',
    status: 'In Progress',
    notes: 'Visible late blight symptoms on potato foliage in northern parcel. Zone 2 moisture dropped from 38% to 27% over 48 hours. Requesting multispectral analysis.',
    areaHa: 4.8,
    crop: 'Potato',
    sowingDate: '2026-06-15',
    cropStage: 'Flowering stage',
    previousOperationsCount: 3
  },
  {
    id: 'REQ-1025',
    farmerName: 'Suresh Patil',
    fieldId: 'FIELD-B',
    fieldName: 'Field B (Potato)',
    location: 'Kalyan, Maharashtra',
    requestedDate: '2026-08-24',
    requestedTime: '10:00 AM',
    scanType: 'Full Field Analysis',
    priority: 'Medium',
    status: 'Completed',
    notes: 'Brown/dark lesions appearing on potato leaves in Zone 2. Possible Early Blight (Alternaria solani). Requesting full field analysis.',
    areaHa: 6.2,
    crop: 'Potato',
    sowingDate: '2026-07-01',
    cropStage: 'Vegetative stage',
    previousOperationsCount: 5
  },
  {
    id: 'REQ-1026',
    farmerName: 'Anil Deshmukh',
    fieldId: 'FIELD-C',
    fieldName: 'Field C (Potato)',
    location: 'Bhiwandi, Maharashtra',
    requestedDate: '2026-08-25',
    requestedTime: '07:45 AM',
    scanType: 'Moisture/Soil Scan',
    priority: 'Low',
    status: 'Completed',
    notes: 'Moisture/soil scan for tuber-bulking stage potato field. Uniform canopy check requested.',
    areaHa: 3.5,
    crop: 'Potato',
    sowingDate: '2026-08-10',
    cropStage: 'Germination stage',
    previousOperationsCount: 2
  },
  {
    id: 'REQ-1027',
    farmerName: 'Sunita Jadhav',
    fieldId: 'FIELD-D',
    fieldName: 'Field D (Potato)',
    location: 'Panvel, Maharashtra',
    requestedDate: '2026-08-24',
    requestedTime: '14:00 PM',
    scanType: 'Crop Health Scan',
    priority: 'High',
    status: 'Pending',
    notes: 'Suspected Black Scurf (Rhizoctonia solani) damage along field perimeter zones. Needs emergency multispectral evaluation.',
    areaHa: 5.1,
    crop: 'Potato',
    sowingDate: '2026-06-20',
    cropStage: 'Tuber initiation',
    previousOperationsCount: 1
  },
  {
    id: 'REQ-1028',
    farmerName: 'Prakash Shinde',
    fieldId: 'FIELD-E',
    fieldName: 'Field E (Potato)',
    location: 'Vasai, Maharashtra',
    requestedDate: '2026-08-24',
    requestedTime: '09:00 AM',
    scanType: 'Full Field Analysis',
    priority: 'Medium',
    status: 'Scheduled',
    notes: 'Baseline NDVI mapping for upcoming potato planting season planning.',
    areaHa: 7.0,
    crop: 'Potato',
    sowingDate: '2026-07-15',
    cropStage: 'Vegetative stage',
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
    name: 'Shree LR Tiwari College Field',
    farmerName: 'Campus Operations',
    location: 'Mira Road, Thane, Maharashtra',
    crop: 'Experimental Parcel',
    areaHa: 0.793,
    boundaryPolygon: [
      [19.28455, 72.87125],
      [19.28475, 72.87190],
      [19.28420, 72.87215],
      [19.28400, 72.87150]
    ],
    sowingDate: '2026-06-15',
    cropStage: 'Tuber bulking stage',
    status: 'Attention Required',
    healthScore: 78,
    prevHealthScore: 84,
    lastScan: 'Today, 10:42 AM',
    moistureStatus: 'LOW',
    activeAlerts: ['Zone 2: Low Soil Moisture Alert — Potato Tuber Stress Risk', 'Zone 27: Late Blight Canopy Warning'],
    sensors: fieldASensors,
    zones: generateZones({
      2:  { status: 'Low moisture',           soilMoisture: 27, temperature: 32, stressType: 'Low moisture (27%) — Potato tuber stress risk', confidence: 91, recommendedAction: 'Check irrigation in Zone 2 immediately. Potatoes need ≥35% moisture during bulking.', aiExplanation: 'Soil moisture declined from 38% to 27% over 48 hrs — critical during tuber formation.', gpsCoords: '19.2184, 72.9781' },
      3:  { status: 'Possible nutrient stress', soilMoisture: 45, temperature: 30, stressType: 'Possible potassium / nitrogen deficiency', confidence: 78, recommendedAction: 'Apply balanced NPK fertilizer. Potatoes are heavy potassium feeders.', aiExplanation: 'Mild interveinal chlorosis on lower leaves consistent with K deficiency.' },
      27: { status: 'High Priority',            soilMoisture: 23, temperature: 33, stressType: 'Late Blight (Phytophthora infestans) — High Risk', confidence: 91, recommendedAction: 'Immediate fungicide application (Metalaxyl / Mancozeb) in Zone 27. Isolate perimeter.', aiExplanation: 'Dark water-soaked lesions on foliage detected by multispectral anomaly. Classic Late Blight signature.', gpsCoords: '19.2184, 72.9781' }
    })
  },
  {
    id: 'FIELD-B',
    name: 'Field B (Potato)',
    farmerName: 'Suresh Patil',
    location: 'Kalyan, Maharashtra',
    crop: 'Potato',
    areaHa: 6.2,
    boundaryPolygon: [
      [19.0570, 73.8850],
      [19.0575, 73.8875],
      [19.0590, 73.8870],
      [19.0585, 73.8845]
    ],
    sowingDate: '2026-07-01',
    cropStage: 'Vegetative / Haulm growth stage',
    status: 'Attention Required',
    healthScore: 84,
    prevHealthScore: 85,
    lastScan: 'Today, 08:45 AM',
    moistureStatus: 'NORMAL',
    activeAlerts: ['Zone 2: Early Blight (Alternaria solani) Detected'],
    sensors: fieldBSensors,
    zones: generateZones({
      2: { status: 'Disease risk', soilMoisture: 45, stressType: 'Early Blight — Alternaria solani lesions', confidence: 82, recommendedAction: 'Spray Chlorothalonil or Mancozeb fungicide across Zone 2.', aiExplanation: 'Concentric ringed brown lesions detected on older potato foliage — classic Early Blight pattern.' }
    })
  },
  {
    id: 'FIELD-C',
    name: 'Field C (Potato)',
    farmerName: 'Anil Deshmukh',
    location: 'Bhiwandi, Maharashtra',
    crop: 'Potato',
    areaHa: 3.5,
    boundaryPolygon: [
      [19.0510, 73.8780],
      [19.0515, 73.8800],
      [19.0525, 73.8795],
      [19.0520, 73.8775]
    ],
    sowingDate: '2026-08-10',
    cropStage: 'Emergence / Early vegetative stage',
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
    name: 'Field D (Potato)',
    farmerName: 'Sunita Jadhav',
    location: 'Panvel, Maharashtra',
    crop: 'Potato',
    areaHa: 5.1,
    boundaryPolygon: [
      [19.1120, 73.0125],
      [19.1125, 73.0150],
      [19.1140, 73.0145],
      [19.1135, 73.0120]
    ],
    status: 'Attention Required',
    healthScore: 68,
    lastScan: '3 days ago',
    activeAlerts: ['Black Scurf (Rhizoctonia solani) Suspected — Perimeter Zones'],
    zones: generateZones({
      8: { status: 'Warning', soilMoisture: 18, stressType: 'Black Scurf / stem canker stress pattern', confidence: 86, recommendedAction: 'Verify irrigation, consider Thiabendazole soil drench in Zone 8.', gpsCoords: '19.1120, 73.0125' }
    })
  }
];

// ─── DRONE OPERATIONS ─────────────────────────────────────────────────────────
export const MOCK_OPERATIONS: DroneOperation[] = [
  {
    id: 'OP-0142',
    requestId: 'REQ-1024',
    farmerName: 'Ramesh Kumar',
    fieldName: 'Field A (Potato)',
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
    fieldName: 'Field B (Potato)',
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
    fieldName: 'Field C (Potato)',
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
    fieldName: 'Field D (Potato)',
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
    fieldName: 'Field A (Potato)',
    zoneId: 'Zone 2',
    status: 'Pending Validation',
    findingType: 'Potato tuber stress — Low moisture / Irrigation deficit',
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
    fieldName: 'Field A (Potato)',
    zoneId: 'Zone 27',
    status: 'Pending Validation',
    findingType: 'Late Blight (Phytophthora infestans) — Critical Risk',
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
    fieldName: 'Field D (Potato)',
    zoneId: 'Zone 8',
    status: 'Pending Validation',
    findingType: 'Black Scurf (Rhizoctonia solani) — Suspected perimeter stress',
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
    fieldName: 'Field A (Potato)',
    generatedDate: '2026-08-26 (Draft)',
    status: 'Draft',
    healthIndexScore: 78,
    priorityRecommendations: [
      'Zone 2: Low soil moisture (27%) — Potato tuber stress risk. Increase irrigation immediately.',
      'Zone 27: Late Blight (Phytophthora infestans) detected at 91% confidence. Apply Metalaxyl + Mancozeb immediately.',
      'Schedule follow-up multispectral scan in 5 days to evaluate Late Blight progression.',
      'Maintain standard irrigation schedule for healthy southern quadrants. Monitor for spread.'
    ]
  },
  {
    id: 'REP-903',
    requestId: 'REQ-1025',
    operationId: 'OP-0141',
    farmerName: 'Suresh Patil',
    fieldName: 'Field B (Potato)',
    generatedDate: '2026-08-24',
    status: 'Ready',
    healthIndexScore: 84,
    priorityRecommendations: [
      'Zone 2: Early Blight (Alternaria solani) detected. Spray Chlorothalonil fungicide immediately.',
      'Potato canopy health remains acceptable. No broad irrigation concerns at this stage.'
    ]
  },
  {
    id: 'REP-902',
    requestId: 'REQ-1026',
    operationId: 'OP-0140',
    farmerName: 'Anil Deshmukh',
    fieldName: 'Field C (Potato)',
    generatedDate: '2026-08-25',
    status: 'Sent',
    healthIndexScore: 91,
    priorityRecommendations: [
      'Potato emergence is uniform and healthy. Canopy NDVI at 0.72 — excellent early vegetative baseline.',
      'Maintain standard irrigation cycle. No disease or stress treatment required.'
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

// ─── KNOWLEDGE LIBRARY (POTATO CROP FOCUS) ────────────────────────────────────
export const MOCK_LIBRARY: LibraryItem[] = [
  {
    id: 'crop_potato_jyoti',
    type: 'Crop',
    name: 'Potato (Kufri Jyoti)',
    description: 'Kufri Jyoti is the dominant high-yielding table potato variety cultivated across Maharashtra (Ambegaon/Pune & Satara belts). Resilient with wide adaptability.',
    details: [
      'Optimal Temperature: 15°C to 24°C (tuber initiation slows above 26°C)',
      'Sowing Period: Oct – Nov (Rabi) / Jun – Jul (Kharif)',
      'Tuber Duration: 90 – 100 days to maturity',
      'Irrigation Requirement: Critical during tuber initiation and bulking — target 35–65% soil moisture',
      'Yield Potential: 250 – 300 q/ha with recommended NPK fertility'
    ],
    symptoms: 'Foliar dark lesions under Late Blight pressure, leaf yellowing under potassium deficit.',
    prevention: 'Maintain soil moisture above 35%. Use certified disease-free seed tubers.',
    management: 'Regular multispectral scouting; apply Metalaxyl + Mancozeb for Late Blight.',
    affectedCrops: ['Potato']
  },
  {
    id: 'crop_potato_pukhraj',
    type: 'Crop',
    name: 'Potato (Kufri Pukhraj)',
    description: 'Kufri Pukhraj is an early-maturing, high-yielding potato variety with large yellow oval tubers and smooth skin. Excellent early harvest window.',
    details: [
      'Optimal Temperature: 18°C to 26°C',
      'Sowing Period: September – October',
      'Tuber Duration: 70 – 80 days (early maturing)',
      'Irrigation: Requires uniform light irrigation during early bulking',
      'Yield Potential: 300 – 350 q/ha'
    ],
    symptoms: 'Susceptible to Late Blight under damp cool weather.',
    prevention: 'Avoid excessive nitrogen fertilization. Space hills at 60cm x 20cm.',
    management: 'Preventive Mancozeb 2.5 g/l spray prior to canopy closure.',
    affectedCrops: ['Potato']
  },
  {
    id: 'crop_potato_bahar',
    type: 'Crop',
    name: 'Potato (Kufri Bahar)',
    description: 'Kufri Bahar is a medium-duration potato variety producing large round white tubers with pale yellow flesh. Popular in commercial potato farming.',
    details: [
      'Optimal Temperature: 16°C to 25°C',
      'Sowing Period: October – November',
      'Tuber Duration: 100 – 110 days',
      'Soil: Well-drained sandy loam rich in organic matter',
      'Yield Potential: 280 – 320 q/ha'
    ],
    symptoms: 'Early leaf spots under Alternaria solani pressure.',
    prevention: 'Maintain adequate soil potassium and avoid moisture stress during tuberization.',
    management: 'Spray Chlorothalonil @ 2 g/l for Early Blight prevention.',
    affectedCrops: ['Potato']
  },
  {
    id: 'disease_late_blight',
    type: 'Disease',
    name: 'Potato Late Blight (Phytophthora infestans)',
    description: 'The most destructive potato disease worldwide. Oomycete pathogen causing rapid dark water-soaked lesions on foliage and tuber rot.',
    details: [
      'Pathogen: Phytophthora infestans',
      'Favored by: High relative humidity (>90%) and cool temperatures (15–22°C)',
      'Can destroy an entire potato crop canopy within 7–10 days if unmanaged'
    ],
    symptoms: 'Water-soaked dark lesions on leaf tips and margins, white mildew growth on underside in humid conditions, tuber brown rot.',
    prevention: 'Crop rotation. Plant certified resistant varieties (e.g. Kufri Jyoti). Avoid high canopy humidity.',
    management: 'Immediate preventive/curative spray of Metalaxyl-M + Mancozeb (2.5 g/l) or Cymoxanil at first detection.',
    affectedCrops: ['Potato']
  },
  {
    id: 'disease_early_blight',
    type: 'Disease',
    name: 'Potato Early Blight (Alternaria solani)',
    description: 'Common fungal pathogen affecting older potato foliage, creating distinctive target-board concentric ring brown spots.',
    details: [
      'Pathogen: Alternaria solani',
      'Favored by: Alternating wet and dry weather, temperature 24–30°C',
      'Causes premature defoliation and tuber size reduction'
    ],
    symptoms: 'Small dark brown/black spots with yellow halo and target-like concentric rings on lower mature potato leaves.',
    prevention: 'Maintain adequate nitrogen and potassium fertility. Avoid plant water stress.',
    management: 'Apply Chlorothalonil @ 2 g/l or Mancozeb 2.5 g/l spray at 10-day intervals.',
    affectedCrops: ['Potato']
  },
  {
    id: 'pest_potato_aphids',
    type: 'Pest',
    name: 'Potato Aphids (Myzus persicae)',
    description: 'Green peach aphids and potato aphids that suck sap from new potato foliage and act as vectors for Potato Virus Y (PVY) and PLRV.',
    details: [
      'Species: Myzus persicae / Macrosiphum euphorbiae',
      'Vector of major potato viral degeneration diseases',
      'Peak activity: Nov – Jan in Maharashtra Rabi crop'
    ],
    symptoms: 'Curled leaves, sticky honeydew, stunted growth, transmission of leafroll virus.',
    prevention: 'Yellow sticky traps at 20/ha. Use aphid-free certified seed potatoes.',
    management: 'Foliar spray of Imidacloprid 17.8 SL @ 0.3 ml/l or Thiamethoxam 25 WG @ 0.2 g/l.',
    affectedCrops: ['Potato']
  },
  {
    id: 'disease_black_scurf',
    type: 'Disease',
    name: 'Black Scurf & Rhizoctonia Stem Canker',
    description: 'Soil-borne fungal disease causing black sclerotia on potato tuber skins and sunken brown cankers on subterranean stolons.',
    details: [
      'Pathogen: Rhizoctonia solani',
      'Favored by: Cold damp soils during emergence',
      'Reduces tuber marketability and sprout vigor'
    ],
    symptoms: 'Black dirt-like sclerotia on tubers that do not wash off; aerial tubers; stem cankers.',
    prevention: 'Plant in warm, dry seedbeds. Tuber seed treatment with Trichoderma viride.',
    management: 'Seed tuber treatment with Azoxystrobin or Thiabendazole prior to planting.',
    affectedCrops: ['Potato']
  }
];

// ─── RECORDED FIELD ACTIONS ───────────────────────────────────────────────────
export const MOCK_ACTIONS: ActionEntry[] = [
  {
    id: 'action_p1',
    fieldId: 'FIELD-B',
    title: 'Checked Potato Disease Boundary',
    category: 'Pest',
    zoneName: 'Zone 2',
    date: '2026-08-25',
    notes: 'Manually inspected potato leaf lesions. Chlorothalonil fungicide scheduled.',
    isCompleted: true
  },
  {
    id: 'action_p2',
    fieldId: 'FIELD-A',
    title: 'Potassium / NPK Applicator',
    category: 'Nutrient',
    zoneName: 'Zone 3',
    date: '2026-08-22',
    notes: 'Hand spread K2O mixture to support potato tuber bulking.',
    isCompleted: true
  }
];

// ─── ACTIVITY LOG ─────────────────────────────────────────────────────────────
export const MOCK_ACTIVITIES: ActivityItem[] = [
  { id: 'ACT-110', timestamp: '11:20 AM', title: 'Action synced', description: 'NPK applicator action on Field A (Potato) Zone 3 logged by operator.', category: 'action' },
  { id: 'ACT-106', timestamp: '11:10 AM', title: 'Draft report generated', description: 'Draft field intelligence report REP-904 generated for Field A (Potato).', category: 'report' },
  { id: 'ACT-105', timestamp: '11:03 AM', title: 'Finding FND-027 logged', description: 'AI detection pipeline flagged low moisture / tuber stress in Zone 2 (91% confidence).', category: 'validation' },
  { id: 'ACT-104', timestamp: '10:55 AM', title: 'Validation queue updated', description: '2 findings sent to operator validation queue for Field A (Potato).', category: 'validation' },
  { id: 'ACT-103', timestamp: '10:50 AM', title: 'Processing completed', description: 'Multispectral imagery stitched and calibrated for OP-0142 (Potato Field A).', category: 'operation' },
  { id: 'ACT-102', timestamp: '10:15 AM', title: 'Operation OP-0142 started', description: 'Drone-01 launched mission OP-0142 over Potato Field A (Ambegaon).', category: 'operation' },
  { id: 'ACT-101', timestamp: '09:15 AM', title: 'Request REQ-1024 accepted', description: 'Accepted scan request for Potato Field A from farmer Ramesh Kumar.', category: 'request' }
];
