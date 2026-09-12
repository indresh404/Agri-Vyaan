import React, { useState } from 'react';
import type { FarmerRequest, FieldAsset } from '../../types';
import { CalendarCheck, MapPin, Scan, Clock, Leaf, BarChart2, FileText, AlertCircle } from 'lucide-react';
import { MapLibreSpatialMap } from '../gis/MapLibreSpatialMap';
import { MOCK_FIELDS } from '../../data/mockData';

interface RequestsViewProps {
  requests: FarmerRequest[];
  fields?: FieldAsset[];
  onAcceptRequest: (reqId: string) => void;
  onRejectRequest: (reqId: string) => void;
  onScheduleOperation: (req: FarmerRequest, droneId: string, startTime: string) => void;
  onNavigateToField: (fieldId: string) => void;
  searchQuery: string;
}

const SCAN_TYPE_COLORS: Record<string, { bg: string; text: string; border: string }> = {
  'Crop Health Scan':    { bg: '#EFF6EE', text: '#2E6B27', border: '#A5D4A0' },
  'Moisture/Soil Scan':  { bg: '#E8F4FB', text: '#1565A0', border: '#90CAF9' },
  'Full Field Analysis': { bg: '#FFF3E0', text: '#BF5200', border: '#FFCC80' },
};

const SCAN_TYPE_ICONS: Record<string, string> = {
  'Crop Health Scan':    '🌿',
  'Moisture/Soil Scan':  '💧',
  'Full Field Analysis': '🛰',
};

export const RequestsView: React.FC<RequestsViewProps> = ({
  requests,
  fields = [],
  onAcceptRequest,
  onRejectRequest,
  onScheduleOperation,
  onNavigateToField,
  searchQuery
}) => {
  const [selectedRequestId, setSelectedRequestId] = useState<string | null>(requests[0]?.id || 'REQ-1024');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [priorityFilter, setPriorityFilter] = useState<string>('ALL');
  const [showScheduleModal, setShowScheduleModal] = useState<boolean>(false);
  const [assignedDrone, setAssignedDrone] = useState<string>('Drone-01');
  const [scheduledTime, setScheduledTime] = useState<string>('14:30');

  const filteredRequests = requests.filter(r => {
    const matchesSearch =
      r.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      r.farmerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      r.fieldName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      r.location.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus = statusFilter === 'ALL' || r.status === statusFilter;
    const matchesPriority = priorityFilter === 'ALL' || r.priority === priorityFilter;

    return matchesSearch && matchesStatus && matchesPriority;
  });

  const selectedRequest = requests.find(r => r.id === selectedRequestId) || requests[0];
  const allAvailableFields = fields.length > 0 ? fields : MOCK_FIELDS;
  const targetField = allAvailableFields.find(f => f.id === selectedRequest?.fieldId || f.name.toLowerCase() === selectedRequest?.fieldName.toLowerCase()) || allAvailableFields[0];

  const scanColors = SCAN_TYPE_COLORS[selectedRequest?.scanType] || SCAN_TYPE_COLORS['Crop Health Scan'];

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Title & Filters */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#1C201A', margin: 0 }}>
            Farmer Scan Requests
          </h1>
          <p style={{ fontSize: '13px', color: '#5F645D', marginTop: '2px' }}>
            Review, accept and schedule drone scan bookings submitted by farmers via the mobile app.
          </p>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <select
            className="op-select"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="ALL">All Statuses</option>
            <option value="Pending">Pending</option>
            <option value="Accepted">Accepted</option>
            <option value="Scheduled">Scheduled</option>
            <option value="In Progress">In Progress</option>
            <option value="Completed">Completed</option>
          </select>

          <select
            className="op-select"
            value={priorityFilter}
            onChange={(e) => setPriorityFilter(e.target.value)}
          >
            <option value="ALL">All Priorities</option>
            <option value="High">High Priority</option>
            <option value="Medium">Medium Priority</option>
            <option value="Low">Low Priority</option>
          </select>
        </div>
      </div>

      {/* Grid Layout */}
      <div style={{ display: 'grid', gridTemplateColumns: selectedRequest ? 'minmax(0, 1fr) 420px' : '1fr', gap: '20px', width: '100%' }}>
        {/* Table */}
        <div className="op-table-container">
          <table className="op-table">
            <thead>
              <tr>
                <th>Request ID</th>
                <th>Farmer</th>
                <th>Field</th>
                <th>Scan Type</th>
                <th>Date & Time</th>
                <th>Crop · Area</th>
                <th>Priority</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredRequests.map(req => {
                const isSelected = req.id === selectedRequestId;
                const sc = SCAN_TYPE_COLORS[req.scanType] || SCAN_TYPE_COLORS['Crop Health Scan'];
                const displayId = req.id.length > 12 ? `${req.id.slice(0, 8)}...` : req.id;
                return (
                  <tr
                    key={req.id}
                    className={isSelected ? 'selected' : ''}
                    onClick={() => setSelectedRequestId(req.id)}
                    style={{ cursor: 'pointer' }}
                  >
                    <td style={{ fontWeight: 600, fontFamily: 'monospace', whiteSpace: 'nowrap' }}>
                      <span title={req.id} style={{ background: '#F1F3EE', padding: '3px 8px', borderRadius: '4px', border: '1px solid #D8D9D2', fontSize: '11px' }}>
                        {displayId}
                      </span>
                    </td>
                    <td style={{ fontWeight: 600, color: '#1C201A', whiteSpace: 'nowrap' }}>{req.farmerName}</td>
                    <td style={{ whiteSpace: 'nowrap' }}>
                      <span
                        style={{ color: '#435C3C', fontWeight: 700, cursor: 'pointer', textDecoration: 'underline dotted' }}
                        onClick={(e) => {
                          e.stopPropagation();
                          onNavigateToField(req.fieldId);
                        }}
                        title="Click to open field boundary planner"
                      >
                        {req.fieldName} ↗
                      </span>
                    </td>
                    <td style={{ whiteSpace: 'nowrap' }}>
                      <span style={{
                        fontSize: '11px', fontWeight: 600, padding: '4px 10px', borderRadius: '12px',
                        background: sc.bg, color: sc.text, border: `1px solid ${sc.border}`,
                        whiteSpace: 'nowrap', display: 'inline-flex', alignItems: 'center', gap: '4px'
                      }}>
                        {SCAN_TYPE_ICONS[req.scanType]} {req.scanType}
                      </span>
                    </td>
                    <td style={{ color: '#5F645D', fontSize: '12px', whiteSpace: 'nowrap' }}>
                      {req.requestedDate}
                      {req.requestedTime && <span style={{ display: 'block', color: '#8B8F88', fontSize: '11px' }}>{req.requestedTime}</span>}
                    </td>
                    <td style={{ whiteSpace: 'nowrap' }}>{req.crop} · {req.areaHa} ha</td>
                    <td>
                      <span style={{
                        fontSize: '11px', fontWeight: 600,
                        color: req.priority === 'High' ? '#AF413A' : req.priority === 'Medium' ? '#B07E28' : '#5F645D'
                      }}>
                        {req.priority}
                      </span>
                    </td>
                    <td>
                      <span className={`badge badge-${req.status.toLowerCase().replace(' ', '-')}`}>
                        {req.status}
                      </span>
                    </td>
                    <td>
                      <button
                        className="op-btn op-btn-secondary op-btn-sm"
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedRequestId(req.id);
                        }}
                      >
                        Details
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Detail Drawer */}
        {selectedRequest && (
          <div style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #D8D9D2',
            borderRadius: '8px',
            padding: '0',
            display: 'flex',
            flexDirection: 'column',
            boxSizing: 'border-box',
            width: '100%',
            boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
            overflow: 'hidden'
          }}>
            {/* Drawer Header — Scan Type Banner */}
            <div style={{
              background: scanColors.bg,
              borderBottom: `2px solid ${scanColors.border}`,
              padding: '14px 18px'
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <div style={{ fontSize: '11px', color: '#5F645D', textTransform: 'uppercase', letterSpacing: '0.5px', fontWeight: 600 }}>
                    BOOKING DETAILS · {selectedRequest.id}
                  </div>
                  <div style={{ fontSize: '18px', fontWeight: 700, color: scanColors.text, marginTop: 2, display: 'flex', alignItems: 'center', gap: 6 }}>
                    <span style={{ fontSize: '20px' }}>{SCAN_TYPE_ICONS[selectedRequest.scanType]}</span>
                    {selectedRequest.scanType}
                  </div>
                </div>
                <span className={`badge badge-${selectedRequest.status.toLowerCase().replace(' ', '-')}`}>
                  {selectedRequest.status}
                </span>
              </div>
            </div>

            {/* Body */}
            <div style={{ padding: '16px 18px', display: 'flex', flexDirection: 'column', gap: '14px', flex: 1 }}>
              {/* Section: Farmer & Field Info */}
              <div>
                <div style={{ fontSize: '10px', fontWeight: 700, color: '#8B8F88', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: 8 }}>
                  Farmer & Field Information
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '13px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D', display: 'flex', alignItems: 'center', gap: 4 }}>
                      👨‍🌾 Farmer Name
                    </span>
                    <span style={{ fontWeight: 600, color: '#1C201A' }}>{selectedRequest.farmerName}</span>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D', display: 'flex', alignItems: 'center', gap: 4 }}>
                      <MapPin size={12} /> Location
                    </span>
                    <span style={{ color: '#1C201A' }}>{selectedRequest.location}</span>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D' }}>Target Field</span>
                    <button
                      onClick={() => onNavigateToField(selectedRequest.fieldId)}
                      style={{ color: '#435C3C', fontWeight: 600, textDecoration: 'underline', background: 'none', border: 'none', cursor: 'pointer', fontSize: '13px', padding: 0 }}
                    >
                      {selectedRequest.fieldName} →
                    </button>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D', display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Leaf size={12} /> Crop
                    </span>
                    <span style={{ fontWeight: 600, color: '#1C201A' }}>{selectedRequest.crop}</span>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D', display: 'flex', alignItems: 'center', gap: 4 }}>
                      <BarChart2 size={12} /> Area
                    </span>
                    <span style={{ fontWeight: 600 }}>{selectedRequest.areaHa} ha</span>
                  </div>
                </div>
              </div>

              {/* Section: Booking Details */}
              <div style={{ borderTop: '1px solid #ECEEE8', paddingTop: 12 }}>
                <div style={{ fontSize: '10px', fontWeight: 700, color: '#8B8F88', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: 8 }}>
                  Scan Booking Details
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '13px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D', display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Scan size={12} /> Scan Type
                    </span>
                    <span style={{
                      fontSize: '11px', fontWeight: 700, padding: '2px 10px', borderRadius: '12px',
                      background: scanColors.bg, color: scanColors.text, border: `1px solid ${scanColors.border}`
                    }}>
                      {SCAN_TYPE_ICONS[selectedRequest.scanType]} {selectedRequest.scanType}
                    </span>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D', display: 'flex', alignItems: 'center', gap: 4 }}>
                      <CalendarCheck size={12} /> Target Date
                    </span>
                    <span style={{ fontWeight: 600 }}>{selectedRequest.requestedDate}</span>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D', display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Clock size={12} /> Target Time
                    </span>
                    <span style={{ fontWeight: 600 }}>{selectedRequest.requestedTime || 'Not specified'}</span>
                  </div>

                  {selectedRequest.sowingDate && (
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ color: '#5F645D' }}>Sowing Date</span>
                      <span>{selectedRequest.sowingDate}</span>
                    </div>
                  )}

                  {selectedRequest.cropStage && (
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ color: '#5F645D' }}>Crop Stage</span>
                      <span style={{ fontWeight: 500 }}>{selectedRequest.cropStage}</span>
                    </div>
                  )}

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D' }}>Historical Scans</span>
                    <span>{selectedRequest.previousOperationsCount} previous operations</span>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ color: '#5F645D' }}>Priority</span>
                    <span style={{
                      fontSize: '11px', fontWeight: 700,
                      padding: '2px 10px', borderRadius: '12px',
                      background: selectedRequest.priority === 'High' ? '#FDECEA' : selectedRequest.priority === 'Medium' ? '#FFF8E1' : '#F1F3EE',
                      color: selectedRequest.priority === 'High' ? '#AF413A' : selectedRequest.priority === 'Medium' ? '#B07E28' : '#5F645D'
                    }}>
                      {selectedRequest.priority === 'High' ? '🔴' : selectedRequest.priority === 'Medium' ? '🟡' : '🟢'} {selectedRequest.priority}
                    </span>
                  </div>
                </div>
              </div>

              {/* Section: Farmer Notes */}
              <div style={{ borderTop: '1px solid #ECEEE8', paddingTop: 12 }}>
                <div style={{ fontSize: '10px', fontWeight: 700, color: '#8B8F88', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: 6, display: 'flex', alignItems: 'center', gap: 4 }}>
                  <FileText size={11} /> Farmer Notes & Request Description
                </div>
                <div style={{ padding: '10px 12px', backgroundColor: '#F8F9F4', border: '1px solid #D8D9D2', borderRadius: '6px', color: '#1C201A', lineHeight: 1.5, fontSize: '12px', fontStyle: 'italic' }}>
                  "{selectedRequest.notes}"
                </div>
              </div>

              {/* Map Preview */}
              <div style={{ borderTop: '1px solid #ECEEE8', paddingTop: 12 }}>
                <div style={{ fontSize: '10px', fontWeight: 700, color: '#8B8F88', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: 6 }}>
                  Target Field Boundary
                </div>
                <div style={{ borderRadius: '6px', overflow: 'hidden', border: '1px solid #D8D9D2' }}>
                  <MapLibreSpatialMap
                    fields={allAvailableFields}
                    selectedFieldId={targetField?.id}
                    zones={targetField?.zones || []}
                    selectedZoneId="Zone 27"
                    showFlightPath={false}
                    height="200px"
                    allowDrawing={false}
                  />
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div style={{ borderTop: '1px solid #E8E9E3', padding: '14px 18px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {selectedRequest.status === 'Pending' && (
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button
                    className="op-btn op-btn-secondary"
                    style={{ flex: 1 }}
                    onClick={() => onRejectRequest(selectedRequest.id)}
                  >
                    Reject Request
                  </button>
                  <button
                    className="op-btn op-btn-primary"
                    style={{ flex: 1 }}
                    onClick={() => {
                      onAcceptRequest(selectedRequest.id);
                      setShowScheduleModal(true);
                    }}
                  >
                    Accept & Schedule
                  </button>
                </div>
              )}

              {(selectedRequest.status === 'Accepted' || selectedRequest.status === 'In Progress' || selectedRequest.status === 'Scheduled') && (
                <button
                  className="op-btn op-btn-primary"
                  style={{ width: '100%' }}
                  onClick={() => setShowScheduleModal(true)}
                >
                  <CalendarCheck size={14} />
                  Schedule Drone Mission
                </button>
              )}

              <button
                className="op-btn op-btn-secondary"
                style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}
                onClick={() => onNavigateToField(selectedRequest.fieldId)}
              >
                <MapPin size={14} color="#435C3C" />
                Open in Mission Boundary Planner
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Schedule Drone Mission Modal */}
      {showScheduleModal && selectedRequest && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            backgroundColor: 'rgba(28, 32, 26, 0.65)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 200
          }}
        >
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #D8D9D2',
              borderRadius: '8px',
              padding: '20px',
              width: '460px',
              boxShadow: '0 8px 32px rgba(0,0,0,0.18)'
            }}
          >
            <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#1C201A', margin: 0, borderBottom: '1px solid #E8E9E3', paddingBottom: '10px', marginBottom: '14px' }}>
              Schedule Drone Operation for {selectedRequest.id}
            </h2>

            {/* Request Summary */}
            <div style={{ background: scanColors.bg, border: `1px solid ${scanColors.border}`, borderRadius: '6px', padding: '10px 14px', marginBottom: 14, fontSize: '12px' }}>
              <div style={{ fontWeight: 700, color: scanColors.text, marginBottom: 4 }}>
                {SCAN_TYPE_ICONS[selectedRequest.scanType]} {selectedRequest.scanType}
              </div>
              <div style={{ color: '#5F645D' }}>
                {selectedRequest.fieldName} · {selectedRequest.farmerName} · {selectedRequest.areaHa} ha · {selectedRequest.location}
              </div>
              <div style={{ color: '#5F645D', marginTop: 2 }}>
                📅 Requested: {selectedRequest.requestedDate} {selectedRequest.requestedTime && `at ${selectedRequest.requestedTime}`}
              </div>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div>
                <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Assign Drone Asset</label>
                <select
                  className="op-select"
                  style={{ width: '100%', marginTop: '4px' }}
                  value={assignedDrone}
                  onChange={(e) => setAssignedDrone(e.target.value)}
                >
                  <option value="Drone-01">Drone-01 (Quad-Multispectral · Battery 100%)</option>
                  <option value="Drone-02">Drone-02 (Hexa-RGB High-Res · Battery 92%)</option>
                  <option value="Drone-03">Drone-03 (Thermal Spectral · Standby)</option>
                </select>
              </div>

              <div>
                <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Planned Start Time</label>
                <input
                  type="text"
                  className="op-input"
                  style={{ width: '100%', marginTop: '4px' }}
                  value={scheduledTime}
                  onChange={(e) => setScheduledTime(e.target.value)}
                  placeholder="e.g. 14:30"
                />
              </div>

              <div>
                <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Flight Parameters</label>
                <div style={{ fontSize: '12px', color: '#5F645D', marginTop: '2px', background: '#F8F9F4', border: '1px solid #D8D9D2', padding: '8px 10px', borderRadius: '4px' }}>
                  <div>✈️ Altitude: 45 meters AGL</div>
                  <div>🔁 Pattern: Grid Lawn-mower scan (75% overlap)</div>
                  <div>📐 Area: {selectedRequest.areaHa} ha · Est. Flight: {Math.ceil(selectedRequest.areaHa * 4)} mins</div>
                </div>
              </div>

              {selectedRequest.priority === 'High' && (
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 10px', background: '#FDECEA', border: '1px solid #F5C6C4', borderRadius: '4px', fontSize: '12px', color: '#AF413A' }}>
                  <AlertCircle size={14} />
                  High priority request — farmer is experiencing active crop stress symptoms.
                </div>
              )}
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '20px', borderTop: '1px solid #E8E9E3', paddingTop: '12px' }}>
              <button
                className="op-btn op-btn-secondary"
                onClick={() => setShowScheduleModal(false)}
              >
                Cancel
              </button>
              <button
                className="op-btn op-btn-primary"
                onClick={() => {
                  onScheduleOperation(selectedRequest, assignedDrone, scheduledTime);
                  setShowScheduleModal(false);
                }}
              >
                Confirm & Dispatch Mission
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
