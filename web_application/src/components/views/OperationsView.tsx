import React, { useState } from 'react';
import type { DroneOperation } from '../../types';

interface OperationsViewProps {
  operations: DroneOperation[];
  onSelectOperation: (opId: string) => void;
  searchQuery: string;
}

export const OperationsView: React.FC<OperationsViewProps> = ({
  operations,
  onSelectOperation,
  searchQuery
}) => {
  const [statusFilter, setStatusFilter] = useState<string>('ALL');

  const filteredOperations = operations.filter(op => {
    const matchesSearch = 
      op.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      op.farmerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      op.fieldName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      op.droneId.toLowerCase().includes(searchQuery.toLowerCase());
    
    const matchesStatus = statusFilter === 'ALL' || op.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Title */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
            Drone Mission Operations
          </h1>
          <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
            Active, planned, and completed multispectral aerial mapping flights.
          </p>
        </div>
        <select 
          className="op-select"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
        >
          <option value="ALL">All Mission Statuses</option>
          <option value="In Progress">In Progress</option>
          <option value="Planned">Planned</option>
          <option value="Completed">Completed</option>
          <option value="Failed">Failed</option>
        </select>
      </div>

      {/* Operations Table */}
      <div className="op-table-container">
        <table className="op-table">
          <thead>
            <tr>
              <th>Operation ID</th>
              <th>Farmer</th>
              <th>Target Field</th>
              <th>Assigned Drone</th>
              <th>Start Time</th>
              <th>Progress</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {filteredOperations.map(op => (
              <tr key={op.id}>
                <td style={{ fontWeight: 600, fontFamily: 'monospace' }}>{op.id}</td>
                <td>{op.farmerName}</td>
                <td>
                  <strong style={{ color: '#4F6848' }}>{op.fieldName}</strong>
                </td>
                <td style={{ fontFamily: 'monospace' }}>{op.droneId}</td>
                <td style={{ color: '#6B7068', fontSize: '12px' }}>{op.startTime}</td>
                <td style={{ width: '160px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <div style={{ flex: 1, backgroundColor: '#DDDED7', height: '6px', borderRadius: '3px', overflow: 'hidden' }}>
                      <div 
                        style={{ 
                          width: `${op.progressPercent}%`, 
                          backgroundColor: op.status === 'Completed' ? '#4F6848' : '#55758A', 
                          height: '100%' 
                        }} 
                      />
                    </div>
                    <span style={{ fontSize: '11px', fontWeight: 600, width: '32px' }}>{op.progressPercent}%</span>
                  </div>
                </td>
                <td>
                  <span className={`badge badge-${op.status.toLowerCase().replace(' ', '-')}`}>
                    {op.status}
                  </span>
                </td>
                <td>
                  <button 
                    className="op-btn op-btn-secondary op-btn-sm"
                    onClick={() => onSelectOperation(op.id)}
                  >
                    View Mission Workspace
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
