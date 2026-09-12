import React, { useState } from 'react';
import type { FieldAsset } from '../../types';
import { MapLibreSpatialMap } from '../gis/MapLibreSpatialMap';
import { ChevronRight, MapPin } from 'lucide-react';

interface FieldsViewProps {
  fields: FieldAsset[];
  onSelectField: (fieldId: string) => void;
  searchQuery: string;
  onSaveFieldAsset?: (newField: FieldAsset) => void;
}

export const FieldsView: React.FC<FieldsViewProps> = ({
  fields,
  onSelectField,
  searchQuery,
  onSaveFieldAsset
}) => {
  const [selectedFieldId, setSelectedFieldId] = useState<string>(fields[0]?.id || 'FIELD-A');

  const filteredFields = fields.filter(f => 
    f.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.farmerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.crop.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.location.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const activeSelectedField = fields.find(f => f.id === selectedFieldId) || fields[0];

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Top Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
            Geographic Field Assets & Satellite Boundary Planner
          </h1>
          <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
            Draw boundaries on satellite imagery, measure area & perimeter with Turf.js, and export KML for Pixhawk Mission Planner.
          </p>
        </div>
      </div>

      {/* Main Interactive Satellite GIS Map */}
      <div style={{ borderRadius: '8px', overflow: 'hidden', boxShadow: '0 4px 16px rgba(0,0,0,0.08)' }}>
        <MapLibreSpatialMap
          fields={fields}
          selectedFieldId={selectedFieldId}
          onSelectField={(f) => {
            setSelectedFieldId(f.id);
            onSelectField(f.id);
          }}
          onSaveFieldAsset={(newAsset) => {
            if (onSaveFieldAsset) onSaveFieldAsset(newAsset);
            setSelectedFieldId(newAsset.id);
          }}
          zones={activeSelectedField?.zones || []}
          height="540px"
          allowDrawing={true}
        />
      </div>

      {/* Fields List Section Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '8px' }}>
        <h2 style={{ fontSize: '18px', fontWeight: 700, color: '#20231F', margin: 0 }}>
          Registered Field Assets ({filteredFields.length})
        </h2>
        <span style={{ fontSize: '12px', color: '#6B7068' }}>
          Select a field to highlight its satellite boundary on the map above
        </span>
      </div>

      {/* Fields Hybrid Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '16px' }}>
        {filteredFields.map(field => {
          const isSelected = field.id === selectedFieldId;

          return (
            <div
              key={field.id}
              onClick={() => setSelectedFieldId(field.id)}
              style={{
                backgroundColor: isSelected ? '#F4F7F2' : '#FFFFFF',
                border: isSelected ? '2px solid #4F6848' : '1px solid #DDDED7',
                borderRadius: '6px',
                padding: '16px',
                cursor: 'pointer',
                transition: 'all 0.15s ease',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
                boxShadow: isSelected ? '0 4px 12px rgba(79,104,72,0.15)' : 'none'
              }}
              onMouseEnter={(e) => {
                if (!isSelected) e.currentTarget.style.borderColor = '#4F6848';
              }}
              onMouseLeave={(e) => {
                if (!isSelected) e.currentTarget.style.borderColor = '#DDDED7';
              }}
            >
              <div>
                {/* Header */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
                  <div>
                    <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#20231F', margin: 0 }}>
                      {field.name}
                    </h2>
                    <div style={{ fontSize: '12px', color: '#6B7068', display: 'flex', alignItems: 'center', gap: 4, marginTop: 2 }}>
                      <MapPin size={12} color="#4F6848" />
                      {field.farmerName} · {field.location}
                    </div>
                  </div>
                  <span className={`badge badge-${field.status === 'Attention Required' ? 'critical' : 'success'}`}>
                    {field.status}
                  </span>
                </div>

                {/* Key Metrics */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', fontSize: '12px', color: '#6B7068', marginTop: 12 }}>
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
                    <span>Boundary: </span>
                    <strong style={{ color: '#00838F' }}>
                      {field.boundaryPolygon ? `${field.boundaryPolygon.length} Nodes` : 'Preset'}
                    </strong>
                  </div>
                </div>
              </div>

              {/* Bottom Footer */}
              <div 
                onClick={(e) => {
                  e.stopPropagation();
                  onSelectField(field.id);
                }}
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
                <span>Open Spatial Workspace</span>
                <ChevronRight size={14} />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
