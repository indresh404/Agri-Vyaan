import React, { useState } from 'react';
import type { FarmerRequest } from '../../types';
import { CalendarCheck } from 'lucide-react';
import { MapLibreSpatialMap } from '../gis/MapLibreSpatialMap';
import { MOCK_FIELDS } from '../../data/mockData';

interface RequestsViewProps {
  requests: FarmerRequest[];
  onAcceptRequest: (reqId: string) => void;
  onRejectRequest: (reqId: string) => void;
  onScheduleOperation: (req: FarmerRequest, droneId: string, startTime: string) => void;
  onNavigateToField: (fieldId: string) => void;
  searchQuery: string;
}

export const RequestsView: React.FC<RequestsViewProps> = ({
  requests,
  onAcceptRequest,
  onRejectRequest,
  onScheduleOperation,
  onNavigateToField,
  searchQuery
}) => {
  const [selectedRequestId, setSelectedRequestId] = useState<string | null>('REQ-1024');
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
  const targetField = MOCK_FIELDS.find(f => f.id === selectedRequest?.fieldId || f.name.includes(selectedRequest?.crop || '')) || MOCK_FIELDS[0];

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Title & Filters */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#1C201A', margin: 0 }}>
            Farmer Service Requests
          </h1>
          <p style={{ fontSize: '13px', color: '#5F645D', marginTop: '2px' }}>
            Manage and schedule agricultural drone scan requests submitted by regional farmers.
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

      {/* Grid Layout: Minmax track ensures left table scales without cutting off right drawer */}
      <div style={{ display: 'grid', gridTemplateColumns: selectedRequest ? 'minmax(0, 1fr) 380px' : '1fr', gap: '20px', width: '100%' }}>
        {/* Table Container with Overflow Protection */}
        <div className="op-table-container">
          <table className="op-table">
            <thead>
              <tr>
                <th>Request ID</th>
                <th>Farmer Name</th>
                <th>Field Asset</th>
                <th>Location</th>
                <th>Crop & Area</th>
                <th>Requested Date</th>
                <th>Priority</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredRequests.map(req => {
                const isSelected = req.id === selectedRequestId;
                return (
                  <tr 
                    key={req.id} 
                    className={isSelected ? 'selected' : ''}
                    onClick={() => setSelectedRequestId(req.id)}
                    style={{ cursor: 'pointer' }}
                  >
                    <td style={{ fontWeight: 600, fontFamily: 'monospace' }}>{req.id}</td>
                    <td style={{ fontWeight: 500 }}>{req.farmerName}</td>
                    <td>
                      <span 
                        style={{ color: '#435C3C', fontWeight: 600 }}
                        onClick={(e) => {
                          e.stopPropagation();
                          onNavigateToField(req.fieldId);
                        }}
                      >
                        {req.fieldName}
                      </span>
                    </td>
                    <td style={{ color: '#5F645D' }}>{req.location}</td>
                    <td>{req.crop} · {req.areaHa} ha</td>
                    <td style={{ color: '#5F645D', fontSize: '12px' }}>{req.requestedDate}</td>
                    <td>
                      <span 
                        style={{
                          fontSize: '11px',
                          fontWeight: 600,
                          color: req.priority === 'High' ? '#AF413A' : req.priority === 'Medium' ? '#B07E28' : '#5F645D'
                        }}
                      >
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

        {/* Selected Request Detail Drawer (Box Lines Fully Protected) */}
        {selectedRequest && (
          <div 
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #D8D9D2',
              borderRadius: '6px',
              padding: '16px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              boxSizing: 'border-box',
              width: '100%',
              boxShadow: '0 1px 3px rgba(0,0,0,0.06)'
            }}
          >
            <div>
              {/* Drawer Header */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', borderBottom: '1px solid #E8E9E3', paddingBottom: '12px', marginBottom: '14px' }}>
                <div>
                  <div style={{ fontSize: '11px', color: '#5F645D', textTransform: 'uppercase', letterSpacing: '0.5px', fontWeight: 600 }}>
                    SERVICE REQUEST DETAILS
                  </div>
                  <h2 style={{ fontSize: '18px', fontWeight: 700, color: '#1C201A', margin: 0, fontFamily: 'monospace' }}>
                    {selectedRequest.id}
                  </h2>
                </div>
                <span className={`badge badge-${selectedRequest.status.toLowerCase().replace(' ', '-')}`}>
                  {selectedRequest.status}
                </span>
              </div>

              {/* Data Pairs */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', fontSize: '13px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#5F645D' }}>Farmer Name</span>
                  <span style={{ fontWeight: 600, color: '#1C201A' }}>{selectedRequest.farmerName}</span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#5F645D' }}>Location</span>
                  <span style={{ color: '#1C201A' }}>{selectedRequest.location}</span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#5F645D' }}>Target Field</span>
                  <button 
                    onClick={() => onNavigateToField(selectedRequest.fieldId)}
                    style={{ color: '#435C3C', fontWeight: 600, textDecoration: 'underline' }}
                  >
                    {selectedRequest.fieldName} ({selectedRequest.areaHa} ha, {selectedRequest.crop})
                  </button>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#5F645D' }}>Requested Date</span>
                  <span>{selectedRequest.requestedDate}</span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#5F645D' }}>Historical Scans</span>
                  <span>{selectedRequest.previousOperationsCount} previous operations</span>
                </div>

                {/* Farmer Notes Box */}
                <div style={{ marginTop: '4px' }}>
                  <div style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase', marginBottom: '4px' }}>
                    Farmer Notes & Request Description
                  </div>
                  <div style={{ padding: '10px', backgroundColor: '#F5F6F2', border: '1px solid #D8D9D2', borderRadius: '4px', color: '#1C201A', lineHeight: 1.4, fontSize: '12px' }}>
                    "{selectedRequest.notes}"
                  </div>
                </div>

                {/* Target Spatial Boundary GIS Map Preview */}
                <div style={{ marginTop: '6px' }}>
                  <div style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase', marginBottom: '6px' }}>
                    Target Spatial Boundary
                  </div>
                  <MapLibreSpatialMap 
                    zones={targetField.zones}
                    selectedZoneId="Zone 27"
                    showFlightPath={false}
                    height="160px"
                  />
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div style={{ borderTop: '1px solid #E8E9E3', paddingTop: '14px', marginTop: '16px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
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
                    Accept Request
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
              borderRadius: '6px',
              padding: '20px',
              width: '440px',
              boxShadow: '0 8px 32px rgba(0,0,0,0.18)'
            }}
          >
            <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#1C201A', margin: 0, borderBottom: '1px solid #E8E9E3', paddingBottom: '10px' }}>
              Schedule Drone Operation for {selectedRequest.id}
            </h2>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '14px' }}>
              <div>
                <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Target Field</label>
                <div style={{ fontSize: '13px', fontWeight: 600, color: '#1C201A', marginTop: '2px' }}>
                  {selectedRequest.fieldName} ({selectedRequest.farmerName}, {selectedRequest.location})
                </div>
              </div>

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
                <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Flight Altitude & Pattern</label>
                <div style={{ fontSize: '12px', color: '#5F645D', marginTop: '2px' }}>
                  45 meters AGL · Grid Lawn-mower scan (75% overlap)
                </div>
              </div>
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
