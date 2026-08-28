import React from 'react';
import type { DroneOperation, ZoneData } from '../../types';
import { MapLibreSpatialMap } from '../gis/MapLibreSpatialMap';
import { ChevronLeft, CheckCircle2, Circle } from 'lucide-react';

interface OperationDetailsViewProps {
  operation: DroneOperation;
  zones: ZoneData[];
  onNavigateBack: () => void;
  onNavigateToValidation: () => void;
}

export const OperationDetailsView: React.FC<OperationDetailsViewProps> = ({
  operation,
  zones,
  onNavigateBack,
  onNavigateToValidation
}) => {
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
          <ChevronLeft size={14} /> Back to Mission Operations List
        </button>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <h1 style={{ fontSize: '24px', fontWeight: 700, color: '#20231F', margin: 0, fontFamily: 'monospace' }}>
                {operation.id}
              </h1>
              <span className={`badge badge-${operation.status.toLowerCase().replace(' ', '-')}`}>
                {operation.status.toUpperCase()} ({operation.progressPercent}%)
              </span>
            </div>
            <div style={{ fontSize: '13px', color: '#6B7068', marginTop: '4px' }}>
              Farmer: <strong>{operation.farmerName}</strong> · Target: <strong>{operation.fieldName}</strong> · Asset: <strong>{operation.droneId}</strong> · Started: {operation.startTime}
            </div>
          </div>

          <button 
            className="op-btn op-btn-primary"
            onClick={onNavigateToValidation}
          >
            Open AI Validation Workspace
          </button>
        </div>
      </div>

      {/* Main Split: Operation Timeline (Left) + GIS Mission Flight Map (Right) */}
      <div style={{ display: 'grid', gridTemplateColumns: '320px 1fr', gap: '20px' }}>
        {/* Left Column: Clear Vertical Operation Timeline */}
        <div 
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #DDDED7',
            borderRadius: '4px',
            padding: '16px',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between'
          }}
        >
          <div style={{ borderBottom: '1px solid #EBECE6', paddingBottom: '8px' }}>
            <h2 style={{ fontSize: '14px', fontWeight: 600, color: '#20231F', margin: 0 }}>
              Mission Workflow Progression
            </h2>
            <div style={{ fontSize: '11px', color: '#6B7068' }}>
              End-to-end operational lifecycle
            </div>
          </div>

          {/* Vertical Step Line */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0px', position: 'relative' }}>
            {operation.timeline.map((item, idx) => {
              const isLast = idx === operation.timeline.length - 1;

              return (
                <div key={idx} style={{ display: 'flex', gap: '12px', minHeight: '44px', position: 'relative' }}>
                  {/* Vertical connecting line */}
                  {!isLast && (
                    <div 
                      style={{
                        position: 'absolute',
                        left: '9px',
                        top: '18px',
                        bottom: '-4px',
                        width: '2px',
                        backgroundColor: item.completed ? '#4F6848' : item.current ? '#55758A' : '#DDDED7'
                      }}
                    />
                  )}

                  {/* Icon Node */}
                  <div style={{ zIndex: 2, backgroundColor: '#FFFFFF', padding: '2px 0' }}>
                    {item.completed ? (
                      <CheckCircle2 size={18} color="#4F6848" />
                    ) : item.current ? (
                      <div 
                        style={{
                          width: '18px',
                          height: '18px',
                          borderRadius: '50%',
                          backgroundColor: '#EEF3F6',
                          border: '2px solid #55758A',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center'
                        }}
                      >
                        <div style={{ width: '6px', height: '6px', borderRadius: '50%', backgroundColor: '#55758A' }} />
                      </div>
                    ) : (
                      <Circle size={18} color="#DDDED7" />
                    )}
                  </div>

                  {/* Text Label */}
                  <div style={{ flex: 1, paddingBottom: '12px' }}>
                    <div 
                      style={{
                        fontSize: '12px',
                        fontWeight: item.current ? 700 : item.completed ? 600 : 400,
                        color: item.current ? '#55758A' : item.completed ? '#20231F' : '#6B7068'
                      }}
                    >
                      {item.stage}
                    </div>
                    <div style={{ fontSize: '11px', color: '#6B7068', fontFamily: 'monospace' }}>
                      {item.timestamp}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Telemetry Box */}
          <div 
            style={{
              backgroundColor: '#FAFBF8',
              border: '1px solid #DDDED7',
              borderRadius: '3px',
              padding: '12px',
              marginTop: 'auto'
            }}
          >
            <div style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase', marginBottom: '8px' }}>
              Drone Fleet Telemetry ({operation.droneId})
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', fontSize: '12px' }}>
              <div>
                <span style={{ color: '#6B7068' }}>Battery: </span>
                <strong style={{ color: '#30432E' }}>{operation.batteryLevel || 62}%</strong>
              </div>
              <div>
                <span style={{ color: '#6B7068' }}>Altitude: </span>
                <strong>{operation.altitudeMeters || 45}m AGL</strong>
              </div>
              <div>
                <span style={{ color: '#6B7068' }}>Speed: </span>
                <strong>{operation.speedMs || 4.2} m/s</strong>
              </div>
              <div>
                <span style={{ color: '#6B7068' }}>Scanned: </span>
                <strong>{operation.totalAreaScannedHa || 3.2} ha</strong>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: Mission GIS Spatial Map */}
        <div 
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #DDDED7',
            borderRadius: '4px',
            padding: '16px',
            display: 'flex',
            flexDirection: 'column',
            gap: '12px'
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h2 style={{ fontSize: '15px', fontWeight: 600, color: '#20231F', margin: 0 }}>
                Flight Path & Spatial Scan Map
              </h2>
              <div style={{ fontSize: '12px', color: '#6B7068' }}>
                Lawn-mower grid flight path overlay · Multispectral NDVI acquisition
              </div>
            </div>
            <span style={{ fontSize: '11px', fontFamily: 'monospace', color: '#55758A', fontWeight: 600 }}>
              LIVE PROGRESS: {operation.progressPercent}%
            </span>
          </div>

          <MapLibreSpatialMap 
            zones={zones}
            selectedZoneId="Zone 27"
            showFlightPath={true}
            height="460px"
          />
        </div>
      </div>
    </div>
  );
};
