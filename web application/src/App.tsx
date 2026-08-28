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
import { subscribeToRealtimeTelemetry } from './lib/supabase';
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

export function App() {
  const [activeTab, setActiveTab] = useState<NavTab>('dashboard');
  const [searchQuery, setSearchQuery] = useState<string>('');

  // State management for operational items
  const [requests, setRequests] = useState<FarmerRequest[]>(MOCK_REQUESTS);
  const [fields] = useState<FieldAsset[]>(MOCK_FIELDS);
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
      scanType: 'Crop Health Scan',
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
