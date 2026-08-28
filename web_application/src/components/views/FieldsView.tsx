import React from 'react';
import type { FieldAsset } from '../../types';
import { ChevronRight } from 'lucide-react';

interface FieldsViewProps {
  fields: FieldAsset[];
  onSelectField: (fieldId: string) => void;
  searchQuery: string;
}

export const FieldsView: React.FC<FieldsViewProps> = ({
  fields,
  onSelectField,
  searchQuery
}) => {
  const filteredFields = fields.filter(f => 
    f.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.farmerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.crop.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.location.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Bar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
            Geographic Field Assets
          </h1>
          <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
            Registered agricultural parcels mapped with spatial boundaries and zone grids.
          </p>
        </div>
        <button 
          className="op-btn op-btn-primary"
          onClick={() => onSelectField('FIELD-A')}
        >
          Open Field A Spatial Workspace
        </button>
      </div>

      {/* Fields Hybrid Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '16px' }}>
        {filteredFields.map(field => {
          const highPriorityCount = field.zones.filter(z => z.status === 'High Priority').length;
          const warningCount = field.zones.filter(z => z.status === 'Warning').length;

          return (
            <div
              key={field.id}
              onClick={() => onSelectField(field.id)}
              style={{
                backgroundColor: '#FFFFFF',
                border: '1px solid #DDDED7',
                borderRadius: '4px',
                padding: '16px',
                cursor: 'pointer',
                transition: 'border-color 0.15s ease',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between'
              }}
              onMouseEnter={(e) => e.currentTarget.style.borderColor = '#4F6848'}
              onMouseLeave={(e) => e.currentTarget.style.borderColor = '#DDDED7'}
            >
              <div>
                {/* Header */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
                  <div>
                    <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#20231F', margin: 0 }}>
                      {field.name}
                    </h2>
                    <div style={{ fontSize: '12px', color: '#6B7068' }}>
                      {field.farmerName} · {field.location}
                    </div>
                  </div>
                  <span className={`badge badge-${field.status === 'Attention Required' ? 'critical' : 'success'}`}>
                    {field.status}
                  </span>
                </div>

                {/* SVG Mini Spatial Preview */}
                <div 
                  style={{
                    height: '110px',
                    backgroundColor: '#252F22',
                    borderRadius: '3px',
                    border: '1px solid #DDDED7',
                    marginBottom: '12px',
                    position: 'relative',
                    overflow: 'hidden',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}
                >
                  <svg width="100%" height="100%" viewBox="0 0 300 110">
                    <polygon 
                      points="30,15 270,20 250,95 40,90" 
                      fill="rgba(79, 104, 72, 0.4)" 
                      stroke="#4F6848" 
                      strokeWidth="2" 
                    />
                    {highPriorityCount > 0 && (
                      <circle cx="210" cy="70" r="8" fill="#B64A43" opacity="0.8" />
                    )}
                    {warningCount > 0 && (
                      <circle cx="120" cy="40" r="6" fill="#B8862D" opacity="0.8" />
                    )}
                  </svg>
                  <div style={{ position: 'absolute', bottom: 6, left: 8, fontSize: '10px', color: '#FFFFFF', opacity: 0.9 }}>
                    Spatial Grid (6x6 Zones)
                  </div>
                </div>

                {/* Key Metrics */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', fontSize: '12px', color: '#6B7068' }}>
                  <div>
                    <span>Crop: </span>
                    <strong style={{ color: '#20231F' }}>{field.crop}</strong>
                  </div>
                  <div>
                    <span>Area: </span>
                    <strong style={{ color: '#20231F' }}>{field.areaHa} ha</strong>
                  </div>
                  <div>
                    <span>Health Index: </span>
                    <strong style={{ color: field.healthScore < 80 ? '#B8862D' : '#4F6848' }}>{field.healthScore}%</strong>
                  </div>
                  <div>
                    <span>Last Scan: </span>
                    <strong style={{ color: '#20231F' }}>{field.lastScan}</strong>
                  </div>
                </div>
              </div>

              {/* Bottom Footer */}
              <div 
                style={{
                  marginTop: '14px',
                  paddingTop: '10px',
                  borderTop: '1px solid #EBECE6',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  fontSize: '12px',
                  color: '#4F6848',
                  fontWeight: 600
                }}
              >
                <span>View Full Field Details</span>
                <ChevronRight size={14} />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
