export type NavTab = 
  | 'dashboard'
  | 'requests'
  | 'fields'
  | 'field-details'
  | 'operations'
  | 'operation-details'
  | 'validation'
  | 'reports'
  | 'analytics'
  | 'weather'
  | 'library'
  | 'activity'
  | 'settings';

export type PriorityLevel = 'High' | 'Medium' | 'Low';
export type RequestStatus = 'Pending' | 'Accepted' | 'Scheduled' | 'In Progress' | 'Completed' | 'Rejected';
export type OperationStatus = 'Planned' | 'In Progress' | 'Completed' | 'Failed';
export type DroneScanStatus = 'REQUESTED' | 'SCHEDULED' | 'DRONE ASSIGNED' | 'IN PROGRESS' | 'PROCESSING' | 'AI ANALYSIS' | 'VERIFICATION' | 'REPORT READY';
export type VerificationStatus = 'PENDING' | 'UNDER REVIEW' | 'VERIFIED' | 'REQUIRES REVIEW';
export type ZoneHealthStatus = 'Healthy' | 'Warning' | 'High Priority' | 'Low moisture' | 'Possible nutrient stress' | 'Disease risk';
export type FindingStatus = 'Pending Validation' | 'Confirmed' | 'Rejected' | 'Inspection Scheduled';

export interface FarmerRequest {
  id: string; // e.g. REQ-1024
  farmerName: string;
  fieldId: string;
  fieldName: string;
  location: string;
  requestedDate: string;
  priority: PriorityLevel;
  status: RequestStatus;
  notes: string;
  areaHa: number;
  crop: string;
  previousOperationsCount: number;
}

export interface SensorReading {
  sensorName: string; // Soil Moisture, Temperature, Humidity
  currentValue: number;
  minNormal: number;
  maxNormal: number;
  unit: string;
  status: 'LOW' | 'NORMAL' | 'HIGH';
  history: number[];
}

export interface ZoneData {
  id: string; // e.g. Zone 27
  zoneNumber: number;
  gridRow: number;
  gridCol: number;
  status: ZoneHealthStatus;
  soilMoisture: number; // e.g. 23%
  temperature?: number; // °C
  stressType?: string; // e.g. "Visible crop stress / yellowing"
  confidence?: number; // e.g. 91
  gpsCoords: string; // e.g. "19.2184, 72.9781"
  lastScanned: string;
  recommendedAction?: string;
  aiExplanation?: string;
}

export interface ActionEntry {
  id: string;
  fieldId: string;
  title: string; // e.g. Irrigation, Treatment, Fertilization
  category: 'Water' | 'Pest' | 'Nutrient' | 'General';
  zoneName: string;
  date: string;
  notes: string;
  isCompleted: boolean;
  beforeState?: Record<string, string>;
  afterState?: Record<string, string>;
}

export interface FieldAsset {
  id: string;
  name: string; // Field A
  farmerName: string;
  location: string;
  crop: string;
  areaHa: number;
  sowingDate?: string;
  cropStage?: string;
  status: 'Normal' | 'Attention Required' | 'Scanning' | 'Pending Baseline';
  healthScore: number; // e.g. 78%
  prevHealthScore?: number;
  lastScan: string;
  moistureStatus?: 'LOW' | 'NORMAL' | 'HIGH';
  activeAlerts?: string[];
  zones: ZoneData[];
  sensors?: SensorReading[];
}

export interface DroneOperation {
  id: string; // e.g. OP-0142
  requestId: string;
  farmerName: string;
  fieldName: string;
  droneId: string; // e.g. Drone-01
  scanType: 'Crop Health Scan' | 'Moisture/Soil Scan' | 'Full Field Analysis';
  operatorName: string;
  startTime: string;
  progressPercent: number; // 0 - 100
  status: OperationStatus;
  scanLifecycleStatus: DroneScanStatus;
  verificationStatus: VerificationStatus;
  batteryLevel?: number;
  altitudeMeters?: number;
  speedMs?: number;
  totalAreaScannedHa?: number;
  timeline: {
    stage: string;
    timestamp: string;
    completed: boolean;
    current: boolean;
  }[];
}

export interface CropFinding {
  id: string; // FND-027
  fieldId: string;
  fieldName: string;
  zoneId: string;
  status: FindingStatus;
  findingType: string;
  confidencePercent: number;
  gpsCoords: string;
  timestamp: string;
  operationId: string;
  farmerName: string;
  soilMoisturePercent: number;
  notes: string;
  recommendedAction: string;
  rgbImageUrl?: string;
  multispectralUrl?: string;
  probabilities?: {
    disease: number;
    waterStress: number;
    nutrient: number;
    healthy: number;
  };
  stageAI?: 'Stage 1 (Quick Scan)' | 'Stage 2 (Rescan Close-Up)';
  inspectionReductionPercent?: number;
}

export interface AssessmentReport {
  id: string; // REP-904
  requestId: string;
  operationId: string;
  farmerName: string;
  fieldName: string;
  generatedDate: string;
  status: 'Ready' | 'Sent' | 'Draft';
  healthIndexScore: number; // 78%
  priorityRecommendations: string[];
}

export interface WeatherForecast {
  dayName: string;
  date: string;
  temperature: number;
  rainProbability: number;
  humidity: number;
  windSpeed: number;
  weatherCondition: 'Sunny' | 'Rainy' | 'Cloudy' | 'Overcast';
  sprayingCondition: 'GOOD' | 'MODERATE' | 'AVOID';
  aiSummary: string;
  bestWindow: string;
}

export interface LibraryItem {
  id: string;
  type: 'Crop' | 'Pest' | 'Disease';
  name: string;
  description: string;
  details: string[];
  symptoms?: string;
  prevention?: string;
  management?: string;
  affectedCrops: string[];
}

export interface ActivityItem {
  id: string;
  timestamp: string;
  title: string;
  description: string;
  category: 'request' | 'operation' | 'validation' | 'report' | 'system' | 'action';
}
