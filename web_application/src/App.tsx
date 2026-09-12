import { useState, useEffect } from 'react';
import type {
  NavTab,
  FarmerRequest,
  FieldAsset,
  DroneOperation,
  CropFinding,
  AssessmentReport,
  ActivityItem,
  WeatherForecast,
  LibraryItem
} from './types';
import {
  MOCK_REQUESTS,
  MOCK_FIELDS,
  MOCK_OPERATIONS,
  MOCK_FINDINGS,
  MOCK_REPORTS,
  MOCK_ACTIVITIES,
  MOCK_WEATHER,
  MOCK_LIBRARY
} from './data/mockData';
import {
  subscribeToRealtimeTelemetry,
  fetchAllBookings,
  fetchAllFields,
  fetchAllUsers,
  updateBookingStatus,
  subscribeToBookings
} from './lib/supabase';
import { Sidebar } from './components/layout/Sidebar';
import { Header } from './components/layout/Header';
import { DashboardView } from './components/views/DashboardView';
import { RequestsView } from './components/views/RequestsView';
import { FieldsView } from './components/views/FieldsView';
import { FieldDetailsView } from './components/views/FieldDetailsView';
import { OperationsView } from './components/views/OperationsView';
import { OperationDetailsView } from './components/views/OperationDetailsView';
import { ValidationView } from './components/views/ValidationView';
import { ReportsView } from './components/views/ReportsView';
import { AnalyticsView } from './components/views/AnalyticsView';
import { ActivityView } from './components/views/ActivityView';
import { SettingsView } from './components/views/SettingsView';
import { WeatherView } from './components/views/WeatherView';
import { LibraryView } from './components/views/LibraryView';

const LOCAL_STORAGE_FIELDS_KEY = 'agriswarm_custom_fields';

function loadInitialFields(): FieldAsset[] {
  try {
    const saved = localStorage.getItem(LOCAL_STORAGE_FIELDS_KEY);
    if (saved) {
      const parsed: FieldAsset[] = JSON.parse(saved);
      if (Array.isArray(parsed) && parsed.length > 0) {
        const existingIds = new Set(parsed.map(f => f.id));
        const filteredMock = MOCK_FIELDS.filter(f => !existingIds.has(f.id));
        return [...parsed, ...filteredMock];
      }
    }
  } catch (err) {
    console.warn('Error reading custom fields from localStorage:', err);
  }
  return MOCK_FIELDS;
}

export function App() {
  const [activeTab, setActiveTab] = useState<NavTab>('requests');
  const [searchQuery, setSearchQuery] = useState<string>('');

  // State management for operational items
  const [requests, setRequests] = useState<FarmerRequest[]>(MOCK_REQUESTS);
  const [fields, setFields] = useState<FieldAsset[]>(loadInitialFields);

  // Fetch live Supabase DB Data & map to application types
  const loadDbData = async () => {
    try {
      const [dbBookings, dbFields, dbUsers] = await Promise.all([
        fetchAllBookings(),
        fetchAllFields(),
        fetchAllUsers(),
      ]);

      const userMap = new Map(dbUsers.map(u => [u.fid, u]));
      const fieldMap = new Map(dbFields.map(f => [f.fieldid, f]));

      if (dbFields && dbFields.length > 0) {
        const mappedFields: FieldAsset[] = dbFields.map((f, idx) => {
          const lat = f.latitude || 19.2842;
          const lng = f.longitude || 72.8715;
          const dLat = 0.0015;
          const dLng = 0.0015;

          const boundaryPolygon: [number, number][] = [
            [lat - dLat, lng - dLng],
            [lat - dLat, lng + dLng],
            [lat + dLat, lng + dLng],
            [lat + dLat, lng - dLng],
          ];

          return {
            id: f.fieldid,
            name: f.field_name || `Field #${f.field_number || idx + 1}`,
            farmerName: f.user_name || userMap.get(f.fid)?.name || 'Farmer',
            location: `${lat.toFixed(4)}° N, ${lng.toFixed(4)}° E`,
            crop: f.crop_name || userMap.get(f.fid)?.main_crop || 'Wheat',
            areaHa: f.area || 2.5,
            boundaryPolygon,
            status: 'Normal',
            healthScore: 88,
            lastScan: 'Recent',
            zones: [
              {
                id: `Zone-${f.fieldid}-1`,
                zoneNumber: 1,
                gridRow: 1,
                gridCol: 1,
                status: 'Healthy',
                soilMoisture: 24,
                gpsCoords: `${lat.toFixed(4)}, ${lng.toFixed(4)}`,
                lastScanned: 'Today',
              }
            ]
          };
        });
        setFields(mappedFields);
      }

      if (dbBookings && dbBookings.length > 0) {
        const mappedRequests: FarmerRequest[] = dbBookings.map((b) => {
          const field = fieldMap.get(b.fieldid);
          const user = userMap.get(b.fid);

          const rawStatus = (b.status || 'Pending').trim();
          const status =
            rawStatus.toLowerCase() === 'pending' ? 'Pending' :
            rawStatus.toLowerCase() === 'accepted' ? 'Accepted' :
            rawStatus.toLowerCase() === 'scheduled' ? 'Scheduled' :
            rawStatus.toLowerCase() === 'in progress' ? 'In Progress' :
            rawStatus.toLowerCase() === 'completed' ? 'Completed' :
            rawStatus.toLowerCase() === 'rejected' ? 'Rejected' : 'Pending';

          const dateStr = b.booking_datetime
            ? b.booking_datetime.includes('T')
              ? b.booking_datetime.split('T')[0]
              : b.booking_datetime.split(' ')[0]
            : '2026-09-15';

          const timeStr = b.booking_datetime && b.booking_datetime.includes(' ')
            ? b.booking_datetime.split(' ')[1]
            : '10:00 AM';

          return {
            id: b.booking_id,
            farmerName: user?.name || field?.user_name || 'Farmer',
            fieldId: b.fieldid,
            fieldName: b.field_name || field?.field_name || 'Target Field',
            location: user?.location || (field ? `${field.latitude.toFixed(4)}° N, ${field.longitude.toFixed(4)}° E` : 'Maharashtra, India'),
            requestedDate: dateStr,
            requestedTime: timeStr,
            scanType: 'Crop Health Scan',
            priority: status === 'Pending' ? 'High' : 'Medium',
            status,
            notes: `Scan requested by ${user?.name || 'Farmer'} for ${field?.crop_name || 'crop'} field.`,
            areaHa: field?.area || 2.5,
            crop: field?.crop_name || user?.main_crop || 'Wheat',
            previousOperationsCount: 1,
          };
        });
        setRequests(mappedRequests);
      }
    } catch (err) {
      console.warn('[Supabase] Initial load error:', err);
    }
  };

  useEffect(() => {
    loadDbData();
    // Realtime listener for incoming bookings from mobile app
    const unsubBookings = subscribeToBookings(() => {
      loadDbData();
    });
    return () => unsubBookings();
  }, []);

  const handleSaveFieldAsset = (newField: FieldAsset) => {
    setFields(prev => {
      const updated = [newField, ...prev];
      try {
        const customFields = updated.filter(f => !MOCK_FIELDS.some(m => m.id === f.id));
        localStorage.setItem(LOCAL_STORAGE_FIELDS_KEY, JSON.stringify(customFields));
      } catch (e) {
        console.warn('Could not save custom field to localStorage:', e);
      }
      return updated;
    });

    setActivities(prev => [
      {
        id: `ACT-${Date.now().toString().slice(-3)}`,
        timestamp: 'Just now',
        title: `Field Asset "${newField.name}" created`,
        description: `New agricultural field mapped: ${newField.areaHa} ha in ${newField.location}.`,
        category: 'system'
      },
      ...prev
    ]);
  };
  const [operations, setOperations] = useState<DroneOperation[]>(MOCK_OPERATIONS);
  const [findings, setFindings] = useState<CropFinding[]>(MOCK_FINDINGS);
  const [reports] = useState<AssessmentReport[]>(MOCK_REPORTS);
  const [activities, setActivities] = useState<ActivityItem[]>(MOCK_ACTIVITIES);
  const [weather] = useState<WeatherForecast[]>(MOCK_WEATHER);
  const [library] = useState<LibraryItem[]>(MOCK_LIBRARY);

  // Setup Supabase Realtime telemetry subscription listener
  useEffect(() => {
    const unsubscribe = subscribeToRealtimeTelemetry(
      (updatedOp) => {
        if (updatedOp.id) {
          setOperations(prev => prev.map(op => op.id === updatedOp.id ? { ...op, ...updatedOp } : op));
        }
      },
      (newFinding) => {
        if (newFinding.id) {
          setFindings(prev => [newFinding as CropFinding, ...prev]);
        }
      }
    );
    return () => unsubscribe();
  }, []);

  // Selected item IDs for detail views
  const [selectedFieldId, setSelectedFieldId] = useState<string>('FIELD-A');
  const [selectedOpId, setSelectedOpId] = useState<string>('OP-0142');

  // Operational State Handlers
  const handleAcceptRequest = (reqId: string) => {
    setRequests(prev => prev.map(r => r.id === reqId ? { ...r, status: 'Accepted' } : r));
    updateBookingStatus(reqId, 'Accepted');
    setActivities(prev => [
      {
        id: `ACT-${Date.now().toString().slice(-3)}`,
        timestamp: 'Just now',
        title: `Request ${reqId} accepted`,
        description: `Operator Vikram Sharma accepted service request ${reqId}.`,
        category: 'request'
      },
      ...prev
    ]);
  };

  const handleRejectRequest = (reqId: string) => {
    setRequests(prev => prev.map(r => r.id === reqId ? { ...r, status: 'Rejected' } : r));
    updateBookingStatus(reqId, 'Rejected');
    setActivities(prev => [
      {
        id: `ACT-${Date.now().toString().slice(-3)}`,
        timestamp: 'Just now',
        title: `Request ${reqId} rejected`,
        description: `Service request ${reqId} declined due to operational constraints.`,
        category: 'request'
      },
      ...prev
    ]);
  };

  const handleScheduleOperation = (req: FarmerRequest, droneId: string, startTime: string) => {
    const newOpId = `OP-0${143 + operations.length}`;
    const newOp: DroneOperation = {
      id: newOpId,
      requestId: req.id,
      farmerName: req.farmerName,
      fieldName: req.fieldName,
      droneId,
      scanType: req.scanType,
      operatorName: 'Vikram Sharma',
      startTime: `Today, ${startTime}`,
      progressPercent: 0,
      status: 'Planned',
      scanLifecycleStatus: 'REQUESTED',
      verificationStatus: 'PENDING',
      batteryLevel: 100,
      altitudeMeters: 45,
      speedMs: 4.5,
      totalAreaScannedHa: req.areaHa,
      timeline: [
        { stage: 'REQUESTED', timestamp: req.requestedDate, completed: true, current: false },
        { stage: 'DRONE ASSIGNED', timestamp: 'Today', completed: true, current: false },
        { stage: 'IN PROGRESS', timestamp: `Today ${startTime}`, completed: false, current: true },
        { stage: 'PROCESSING', timestamp: '--:--', completed: false, current: false },
        { stage: 'AI ANALYSIS', timestamp: '--:--', completed: false, current: false },
        { stage: 'VERIFICATION', timestamp: '--:--', completed: false, current: false },
        { stage: 'REPORT READY', timestamp: '--:--', completed: false, current: false }
      ]
    };

    setOperations(prev => [newOp, ...prev]);
    setRequests(prev => prev.map(r => r.id === req.id ? { ...r, status: 'Scheduled' } : r));
    setActivities(prev => [
      {
        id: `ACT-${Date.now().toString().slice(-3)}`,
        timestamp: 'Just now',
        title: `Operation ${newOpId} scheduled`,
        description: `Assigned ${droneId} for mission ${newOpId} over ${req.fieldName} at ${startTime}.`,
        category: 'operation'
      },
      ...prev
    ]);
  };

  const handleConfirmFinding = (findingId: string) => {
    setFindings(prev => prev.map(f => f.id === findingId ? { ...f, status: 'Confirmed' } : f));
    setActivities(prev => [
      {
        id: `ACT-${Date.now().toString().slice(-3)}`,
        timestamp: 'Just now',
        title: `Finding ${findingId} confirmed`,
        description: `Operator confirmed visible crop stress finding ${findingId} for report inclusion.`,
        category: 'validation'
      },
      ...prev
    ]);
  };

  const handleRejectFinding = (findingId: string) => {
    setFindings(prev => prev.map(f => f.id === findingId ? { ...f, status: 'Rejected' } : f));
    setActivities(prev => [
      {
        id: `ACT-${Date.now().toString().slice(-3)}`,
        timestamp: 'Just now',
        title: `Finding ${findingId} rejected`,
        description: `Finding ${findingId} flagged as spectral false positive and removed from report queue.`,
        category: 'validation'
      },
      ...prev
    ]);
  };

  // Helper navigation handlers
  const handleSelectField = (fieldId: string) => {
    setSelectedFieldId(fieldId);
    setActiveTab('field-details');
  };

  const handleSelectOperation = (opId: string) => {
    setSelectedOpId(opId);
    setActiveTab('operation-details');
  };

  const selectedField = fields.find(f => f.id === selectedFieldId) || fields[0];
  const selectedOperation = operations.find(o => o.id === selectedOpId) || operations[0];

  const pendingValidationsCount = findings.filter(f => f.status === 'Pending Validation').length;
  const pendingRequestsCount = requests.filter(r => r.status === 'Pending').length;

  return (
    <div style={{ display: 'flex', width: '100vw', height: '100vh', overflow: 'hidden', backgroundColor: '#F6F6F2' }}>
      {/* Persistent Left Sidebar */}
      <Sidebar
        activeTab={activeTab}
        onNavigate={(tab) => setActiveTab(tab)}
        pendingValidationCount={pendingValidationsCount}
        pendingRequestsCount={pendingRequestsCount}
      />

      {/* Main Workspace Area */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', height: '100%', minWidth: 0, overflow: 'hidden' }}>
        {/* Compact Top Navigation Bar */}
        <Header
          activeTab={activeTab}
          onNavigate={(tab) => setActiveTab(tab)}
          searchQuery={searchQuery}
          onSearchChange={(q) => setSearchQuery(q)}
          selectedFieldId={selectedField?.name}
          selectedOpId={selectedOperation?.id}
        />

        {/* Scrollable View Content */}
        <main style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden' }}>
          {activeTab === 'dashboard' && (
            <DashboardView
              operations={operations}
              requests={requests}
              findings={findings}
              zones={selectedField.zones}
              activities={activities}
              onNavigate={(tab) => setActiveTab(tab)}
              onSelectOperation={handleSelectOperation}
              onSelectField={handleSelectField}
            />
          )}

          {activeTab === 'requests' && (
            <RequestsView
              requests={requests}
              fields={fields}
              onAcceptRequest={handleAcceptRequest}
              onRejectRequest={handleRejectRequest}
              onScheduleOperation={handleScheduleOperation}
              onNavigateToField={handleSelectField}
              searchQuery={searchQuery}
            />
          )}

          {activeTab === 'fields' && (
            <FieldsView
              fields={fields}
              onSelectField={handleSelectField}
              searchQuery={searchQuery}
              onSaveFieldAsset={handleSaveFieldAsset}
            />
          )}

          {activeTab === 'field-details' && (
            <FieldDetailsView
              field={selectedField}
              onNavigateBack={() => setActiveTab('fields')}
              onNavigateToValidation={() => setActiveTab('validation')}
              onNavigateToOperation={handleSelectOperation}
            />
          )}

          {activeTab === 'operations' && (
            <OperationsView
              operations={operations}
              onSelectOperation={handleSelectOperation}
              searchQuery={searchQuery}
            />
          )}

          {activeTab === 'operation-details' && (
            <OperationDetailsView
              operation={selectedOperation}
              zones={selectedField.zones}
              onNavigateBack={() => setActiveTab('operations')}
              onNavigateToValidation={() => setActiveTab('validation')}
            />
          )}

          {activeTab === 'validation' && (
            <ValidationView
              findings={findings}
              onConfirmFinding={handleConfirmFinding}
              onRejectFinding={handleRejectFinding}
              onNavigateToReport={() => setActiveTab('reports')}
            />
          )}

          {activeTab === 'reports' && (
            <ReportsView
              reports={reports}
              onNavigate={setActiveTab}
            />
          )}

          {activeTab === 'analytics' && <AnalyticsView />}

          {activeTab === 'weather' && <WeatherView weather={weather} />}

          {activeTab === 'library' && <LibraryView library={library} />}

          {activeTab === 'activity' && <ActivityView activities={activities} />}

          {activeTab === 'settings' && <SettingsView />}
        </main>
      </div>
    </div>
  );
}

export default App;
