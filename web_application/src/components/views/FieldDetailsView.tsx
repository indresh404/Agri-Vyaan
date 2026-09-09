import React, { useState } from 'react';
import type { FieldAsset, ZoneData } from '../../types';
import { MapLibreSpatialMap } from '../gis/MapLibreSpatialMap';
import { ChevronLeft, CheckCircle2 } from 'lucide-react';

interface FieldDetailsViewProps {
  field: FieldAsset;
  onNavigateBack: () => void;
  onNavigateToValidation: (findingId: string) => void;
  onNavigateToOperation: (opId: string) => void;
}

export const FieldDetailsView: React.FC<FieldDetailsViewProps> = ({
  field,
  onNavigateBack,
  onNavigateToValidation,
  onNavigateToOperation
}) => {
  const [activeSubTab, setActiveSubTab] = useState<'overview' | 'zones' | 'operations' | 'reports'>('overview');
  const [selectedZone, setSelectedZone] = useState<ZoneData>(
    field.zones.find(z => z.id === 'Zone 27') || field.zones[0]
  );
  const [showInspectionModal, setShowInspectionModal] = useState<boolean>(false);
  const [inspectionNotes, setInspectionNotes] = useState<string>('Targeted soil core sampling for moisture & EC analysis in Zone 27.');
  const [inspectionSuccessMessage, setInspectionSuccessMessage] = useState<boolean>(false);

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Back & Header */}
      <div>
        <button
          onClick={onNavigateBack}
          style={{
            fontSize: '12px',
            color: '#6B7068',
            display: 'inline-flex',
            alignItems: 'center',
            gap: '4px',
            marginBottom: '8px'
          }}
        >
          <ChevronLeft size={14} /> Back to Field Assets List
        </button>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <h1 style={{ fontSize: '24px', fontWeight: 700, color: '#20231F', margin: 0 }}>
                {field.name}
              </h1>
              <span className={`badge badge-${field.status === 'Attention Required' ? 'critical' : 'success'}`}>
                {field.status}
              </span>
            </div>
            <div style={{ fontSize: '13px', color: '#6B7068', marginTop: '4px' }}>
              {field.crop} · {field.areaHa} ha · {field.location} · Farmer: <strong>{field.farmerName}</strong> · Last Scan: {field.lastScan}
            </div>
          </div>

          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              className="op-btn op-btn-secondary"
              onClick={() => onNavigateToOperation('OP-0142')}
            >
              View Active Mission (OP-0142)
            </button>
            <button
              className="op-btn op-btn-primary"
              onClick={() => onNavigateToValidation('FND-027')}
            >
              Validate Zone 27 Findings
            </button>
          </div>
        </div>

        {/* Navigation Sub-Tabs */}
        <div
          style={{
            display: 'flex',
            gap: '16px',
            borderBottom: '1px solid #DDDED7',
            marginTop: '16px',
            fontSize: '13px'
          }}
        >
          {[
            { id: 'overview', label: 'Spatial Overview & GIS Map' },
            { id: 'zones', label: `Geographic Zones (${field.zones.length})` },
            { id: 'operations', label: 'Related Operations (OP-0142)' },
            { id: 'reports', label: 'Field Intelligence Reports' }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveSubTab(tab.id as any)}
              style={{
                padding: '8px 4px',
                fontWeight: activeSubTab === tab.id ? 600 : 400,
                color: activeSubTab === tab.id ? '#20231F' : '#6B7068',
                borderBottom: activeSubTab === tab.id ? '2px solid #4F6848' : '2px solid transparent',
                marginBottom: '-1px'
              }}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Main Tab Content */}
      {activeSubTab === 'overview' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1fr) 380px', gap: '20px', width: '100%' }}>
          {/* Main Dominant GIS Field Map */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div
              style={{
                backgroundColor: '#FFFFFF',
                border: '1px solid #D8D9D2',
                borderRadius: '6px',
                padding: '14px',
                boxShadow: '0 1px 3px rgba(0,0,0,0.06)'
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                <span style={{ fontSize: '12px', fontWeight: 600, color: '#1C201A' }}>
                  FIELD BOUNDARY & ZONE GRID (INTERACTIVE GIS MAP)
                </span>
                <span style={{ fontSize: '11px', color: '#5F645D' }}>
                  Click any zone cell to view environmental telemetry
                </span>
              </div>

              <MapLibreSpatialMap
                zones={field.zones}
                selectedZoneId={selectedZone?.id}
                onSelectZone={(z) => setSelectedZone(z)}
                showFlightPath={true}
                height="450px"
              />
            </div>
          </div>

          {/* Right Side Information Drawer (Restrained, Professional) */}
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
              {/* Drawer Title */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', borderBottom: '1px solid #EBECE6', paddingBottom: '10px', marginBottom: '14px' }}>
                <div>
                  <div style={{ fontSize: '11px', color: '#6B7068', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                    ZONE SPATIAL TELEMETRY
                  </div>
                  <h2 style={{ fontSize: '18px', fontWeight: 700, color: '#20231F', margin: 0, fontFamily: 'monospace' }}>
                    {selectedZone.id}
                  </h2>
                </div>
                <span className={`badge badge-${selectedZone.status === 'High Priority' ? 'critical' : selectedZone.status === 'Warning' ? 'pending' : 'success'}`}>
                  {selectedZone.status.toUpperCase()}
                </span>
              </div>

              {/* Data Pairs */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '13px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#6B7068' }}>Detection Status</span>
                  <span style={{ fontWeight: 600, color: selectedZone.status === 'High Priority' ? '#B64A43' : '#20231F' }}>
                    {selectedZone.stressType || 'Normal crop vigor'}
                  </span>
                </div>

                {selectedZone.confidence && (
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: '#6B7068' }}>Detection Confidence</span>
                    <span style={{ fontWeight: 600, color: '#20231F' }}>{selectedZone.confidence}%</span>
                  </div>
                )}

                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#6B7068' }}>Soil Moisture Level</span>
                  <span style={{ fontWeight: 600, color: selectedZone.soilMoisture < 25 ? '#B8862D' : '#30432E' }}>
                    {selectedZone.soilMoisture}%
                  </span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#6B7068' }}>GPS Centroid</span>
                  <span style={{ fontFamily: 'monospace', fontSize: '12px' }}>{selectedZone.gpsCoords}</span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: '#6B7068' }}>Last Scan Time</span>
                  <span>{selectedZone.lastScanned}</span>
                </div>

                {/* Recommended Action Notice Box */}
                {selectedZone.recommendedAction && (
                  <div style={{ marginTop: '8px' }}>
                    <div style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase', marginBottom: '4px' }}>
                      Recommended Action
                    </div>
                    <div style={{ padding: '10px', backgroundColor: '#FAF0E6', border: '1px solid rgba(182, 74, 67, 0.3)', borderRadius: '3px', color: '#B64A43', fontSize: '12px', lineHeight: 1.4 }}>
                      "{selectedZone.recommendedAction}"
                    </div>
                    <div style={{ fontSize: '11px', color: '#6B7068', marginTop: '6px', fontStyle: 'italic' }}>
                      Note: AI detection identifies visible spectral anomalies; ground sampling is required prior to fertilizer application.
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Actions */}
            <div style={{ borderTop: '1px solid #EBECE6', paddingTop: '14px', marginTop: '16px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <button
                className="op-btn op-btn-primary"
                style={{ width: '100%' }}
                onClick={() => setShowInspectionModal(true)}
              >
                Create Ground Inspection Task
              </button>

              {selectedZone.status === 'High Priority' && (
                <button
                  className="op-btn op-btn-secondary"
                  style={{ width: '100%' }}
                  onClick={() => onNavigateToValidation('FND-027')}
                >
                  Open Human Validation Workspace
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Zones Grid Table View */}
      {activeSubTab === 'zones' && (
        <div className="op-table-container">
          <table className="op-table">
            <thead>
              <tr>
                <th>Zone ID</th>
                <th>Grid Position</th>
                <th>Status</th>
                <th>Soil Moisture</th>
                <th>Stress Detection</th>
                <th>Confidence</th>
                <th>GPS Coordinates</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {field.zones.map(z => (
                <tr key={z.id}>
                  <td style={{ fontWeight: 600, fontFamily: 'monospace' }}>{z.id}</td>
                  <td>Row {z.gridRow}, Col {z.gridCol}</td>
                  <td>
                    <span className={`badge badge-${z.status === 'High Priority' ? 'critical' : z.status === 'Warning' ? 'pending' : 'success'}`}>
                      {z.status}
                    </span>
                  </td>
                  <td>{z.soilMoisture}%</td>
                  <td style={{ color: z.stressType ? '#B64A43' : '#6B7068' }}>
                    {z.stressType || 'Normal'}
                  </td>
                  <td>{z.confidence ? `${z.confidence}%` : '--'}</td>
                  <td style={{ fontFamily: 'monospace', fontSize: '12px' }}>{z.gpsCoords}</td>
                  <td>
                    <button
                      className="op-btn op-btn-secondary op-btn-sm"
                      onClick={() => {
                        setSelectedZone(z);
                        setActiveSubTab('overview');
                      }}
                    >
                      Select on Map
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Create Ground Inspection Modal */}
      {showInspectionModal && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            backgroundColor: 'rgba(32, 35, 31, 0.5)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 200
          }}
        >
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #DDDED7',
              borderRadius: '4px',
              padding: '20px',
              width: '420px',
              boxShadow: '0 8px 24px rgba(0,0,0,0.15)'
            }}
          >
            <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#20231F', margin: 0, borderBottom: '1px solid #EBECE6', paddingBottom: '8px' }}>
              Create Ground Inspection Task for {selectedZone.id}
            </h2>

            {inspectionSuccessMessage ? (
              <div style={{ padding: '20px 0', textAlign: 'center' }}>
                <CheckCircle2 size={36} color="#587451" style={{ margin: '0 auto 10px' }} />
                <div style={{ fontSize: '14px', fontWeight: 600, color: '#20231F' }}>
                  Ground Inspection Dispatch Created
                </div>
                <div style={{ fontSize: '12px', color: '#6B7068', marginTop: '4px' }}>
                  Task assigned to field agent for GPS location 19.2184, 72.9781.
                </div>
                <button
                  className="op-btn op-btn-primary"
                  style={{ marginTop: '16px' }}
                  onClick={() => {
                    setInspectionSuccessMessage(false);
                    setShowInspectionModal(false);
                  }}
                >
                  Done
                </button>
              </div>
            ) : (
              <>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '14px' }}>
                  <div>
                    <label style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase' }}>Target Coordinates</label>
                    <div style={{ fontSize: '13px', fontFamily: 'monospace', fontWeight: 600, color: '#20231F' }}>
                      {selectedZone.gpsCoords} ({selectedZone.id}, {field.name})
                    </div>
                  </div>

                  <div>
                    <label style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase' }}>Inspection Instructions</label>
                    <textarea
                      className="op-input"
                      rows={3}
                      style={{ width: '100%', marginTop: '4px', resize: 'none' }}
                      value={inspectionNotes}
                      onChange={(e) => setInspectionNotes(e.target.value)}
                    />
                  </div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '20px', borderTop: '1px solid #EBECE6', paddingTop: '12px' }}>
                  <button
                    className="op-btn op-btn-secondary"
                    onClick={() => setShowInspectionModal(false)}
                  >
                    Cancel
                  </button>
                  <button
                    className="op-btn op-btn-primary"
                    onClick={() => setInspectionSuccessMessage(true)}
                  >
                    Dispatch Field Inspector
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
