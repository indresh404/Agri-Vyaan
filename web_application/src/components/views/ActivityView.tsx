import React from 'react';
import type { ActivityItem } from '../../types';

interface ActivityViewProps {
  activities: ActivityItem[];
}

export const ActivityView: React.FC<ActivityViewProps> = ({ activities }) => {
  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Title */}
      <div>
        <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
          System Operational Audit Log
        </h1>
        <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
          Chronological audit trail of all operator actions, drone state transitions, and validation logs.
        </p>
      </div>

      {/* Audit Log Table */}
      <div className="op-table-container">
        <table className="op-table">
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>Log Event Title</th>
              <th>Operational Details</th>
              <th>Category</th>
              <th>Audit ID</th>
            </tr>
          </thead>
          <tbody>
            {activities.map(act => (
              <tr key={act.id}>
                <td style={{ fontFamily: 'monospace', fontWeight: 600, color: '#20231F' }}>{act.timestamp}</td>
                <td style={{ fontWeight: 600, color: '#20231F' }}>{act.title}</td>
                <td style={{ color: '#6B7068' }}>{act.description}</td>
                <td>
                  <span className={`badge badge-${act.category === 'validation' ? 'critical' : act.category === 'operation' ? 'in-progress' : 'completed'}`}>
                    {act.category.toUpperCase()}
                  </span>
                </td>
                <td style={{ fontFamily: 'monospace', fontSize: '11px', color: '#6B7068' }}>{act.id}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
