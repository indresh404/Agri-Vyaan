import React, { useState } from 'react';
import type { ZoneData } from '../../types';

interface FieldMapProps {
  zones: ZoneData[];
  selectedZoneId?: string;
  onSelectZone?: (zone: ZoneData) => void;
  showFlightPath?: boolean;
  showDetectionsOnly?: boolean;
  height?: string;
}

export const FieldMap: React.FC<FieldMapProps> = ({
  zones,
  selectedZoneId,
  onSelectZone,
  showFlightPath = false,
  showDetectionsOnly = false,
  height = '420px'
}) => {
  const [mapLayer, setMapLayer] = useState<'satellite' | 'vector' | 'multispectral'>('multispectral');
  const [zoomLevel, setZoomLevel] = useState<number>(1);
  const [hoveredZone, setHoveredZone] = useState<ZoneData | null>(null);

  // SVG grid logic for 6x6 zones inside field boundary
  const gridRows = 6;
  const gridCols = 6;

  // Map canvas bounding dimensions
  const mapWidth = 600;
  const mapHeight = 440;
  const fieldX = 60;
  const fieldY = 40;
  const fieldW = 480;
  const fieldH = 360;

  const cellW = fieldW / gridCols;
  const cellH = fieldH / gridRows;

  // Colors based on map layer
  const getZoneColor = (zone: ZoneData) => {
    if (mapLayer === 'multispectral') {
      if (zone.status === 'High Priority') return 'rgba(182, 74, 67, 0.45)';
      if (zone.status === 'Warning') return 'rgba(184, 134, 45, 0.35)';
      return 'rgba(79, 104, 72, 0.25)';
    } else if (mapLayer === 'satellite') {
      if (zone.status === 'High Priority') return 'rgba(182, 74, 67, 0.35)';
      if (zone.status === 'Warning') return 'rgba(184, 134, 45, 0.25)';
      return 'transparent';
    } else {
      if (zone.status === 'High Priority') return '#FAF0E6';
      if (zone.status === 'Warning') return '#FBF6EB';
      return '#F4F7F2';
    }
  };

  const getZoneBorder = (zone: ZoneData) => {
    if (zone.id === selectedZoneId) return '#30432E';
    if (zone.status === 'High Priority') return '#B64A43';
    if (zone.status === 'Warning') return '#B8862D';
    return '#DDDED7';
  };

  return (
    <div 
      style={{
        position: 'relative',
        width: '100%',
        height,
        backgroundColor: mapLayer === 'satellite' ? '#1E251C' : mapLayer === 'multispectral' ? '#252F22' : '#F6F6F2',
        borderRadius: '4px',
        border: '1px solid #DDDED7',
        overflow: 'hidden',
        userSelect: 'none'
      }}
    >
      {/* Top Map Control Bar */}
      <div 
        style={{
          position: 'absolute',
          top: 10,
          left: 12,
          right: 12,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          zIndex: 10
        }}
      >
        <div 
          style={{
            display: 'flex',
            gap: 2,
            backgroundColor: 'rgba(255, 255, 255, 0.92)',
            padding: '3px',
            borderRadius: '4px',
            border: '1px solid #DDDED7',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)'
          }}
        >
          <button
            onClick={() => setMapLayer('multispectral')}
            style={{
              padding: '3px 8px',
              fontSize: '11px',
              fontWeight: 500,
              borderRadius: '3px',
              backgroundColor: mapLayer === 'multispectral' ? '#4F6848' : 'transparent',
              color: mapLayer === 'multispectral' ? '#FFFFFF' : '#6B7068'
            }}
          >
            Multispectral (NDVI)
          </button>
          <button
            onClick={() => setMapLayer('satellite')}
            style={{
              padding: '3px 8px',
              fontSize: '11px',
              fontWeight: 500,
              borderRadius: '3px',
              backgroundColor: mapLayer === 'satellite' ? '#4F6848' : 'transparent',
              color: mapLayer === 'satellite' ? '#FFFFFF' : '#6B7068'
            }}
          >
            Satellite RGB
          </button>
          <button
            onClick={() => setMapLayer('vector')}
            style={{
              padding: '3px 8px',
              fontSize: '11px',
              fontWeight: 500,
              borderRadius: '3px',
              backgroundColor: mapLayer === 'vector' ? '#4F6848' : 'transparent',
              color: mapLayer === 'vector' ? '#FFFFFF' : '#6B7068'
            }}
          >
            GIS Vector Grid
          </button>
        </div>

        <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
          <span 
            style={{
              fontSize: '11px',
              backgroundColor: 'rgba(255,255,255,0.9)',
              padding: '3px 8px',
              borderRadius: '3px',
              border: '1px solid #DDDED7',
              color: '#30432E',
              fontWeight: 600,
              fontFamily: 'monospace'
            }}
          >
            GPS: 19.2184° N, 72.9781° E
          </span>
          <button
            onClick={() => setZoomLevel(prev => Math.min(prev + 0.2, 1.6))}
            style={{
              width: 26,
              height: 26,
              backgroundColor: '#FFFFFF',
              border: '1px solid #DDDED7',
              borderRadius: '3px',
              fontWeight: 'bold',
              color: '#20231F'
            }}
          >
            +
          </button>
          <button
            onClick={() => setZoomLevel(prev => Math.max(prev - 0.2, 0.8))}
            style={{
              width: 26,
              height: 26,
              backgroundColor: '#FFFFFF',
              border: '1px solid #DDDED7',
              borderRadius: '3px',
              fontWeight: 'bold',
              color: '#20231F'
            }}
          >
            -
          </button>
        </div>
      </div>

      {/* Main Interactive SVG Canvas */}
      <svg
        viewBox={`0 0 ${mapWidth} ${mapHeight}`}
        style={{
          width: '100%',
          height: '100%',
          transform: `scale(${zoomLevel})`,
          transformOrigin: 'center center',
          transition: 'transform 0.2s ease-out'
        }}
      >
        {/* Background Field Textures & Satellite Base */}
        <defs>
          <pattern id="cropPattern" width="20" height="20" patternUnits="userSpaceOnUse">
            <line x1="0" y1="10" x2="20" y2="10" stroke="#4F6848" strokeWidth="0.5" strokeOpacity="0.15" />
          </pattern>
          <linearGradient id="ndviGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#4F6848" stopOpacity="0.4" />
            <stop offset="60%" stopColor="#587451" stopOpacity="0.3" />
            <stop offset="75%" stopColor="#B8862D" stopOpacity="0.5" />
            <stop offset="100%" stopColor="#B64A43" stopOpacity="0.6" />
          </linearGradient>
        </defs>

        {/* Map Base Canvas */}
        <rect width={mapWidth} height={mapHeight} fill={mapLayer === 'vector' ? '#FAFBF8' : '#1A2118'} />

        {/* Simulated Topography / Contour lines */}
        {mapLayer !== 'vector' && (
          <g opacity="0.15" stroke="#FFFFFF" strokeWidth="1" fill="none">
            <path d="M 40,100 Q 150,140 300,100 T 560,120" />
            <path d="M 40,220 Q 180,180 340,240 T 560,200" />
            <path d="M 40,340 Q 200,380 380,320 T 560,360" />
          </g>
        )}

        {/* Field Outer Boundary Polygon (Field A) */}
        <polygon
          points={`${fieldX},${fieldY} ${fieldX + fieldW},${fieldY + 10} ${fieldX + fieldW - 15},${fieldY + fieldH} ${fieldX + 10},${fieldY + fieldH - 10}`}
          fill={mapLayer === 'multispectral' ? 'url(#ndviGradient)' : mapLayer === 'satellite' ? '#2A3526' : 'url(#cropPattern)'}
          stroke="#4F6848"
          strokeWidth={mapLayer === 'vector' ? "2" : "3"}
        />

        {/* 6x6 Grid of Geographic Zones */}
        {zones.map((zone) => {
          const colIdx = zone.gridCol - 1;
          const rowIdx = zone.gridRow - 1;
          const x = fieldX + colIdx * cellW;
          const y = fieldY + rowIdx * cellH;

          const isSelected = zone.id === selectedZoneId;
          const isHovered = hoveredZone?.id === zone.id;

          if (showDetectionsOnly && zone.status === 'Healthy') {
            return null;
          }

          return (
            <g 
              key={zone.id}
              onClick={() => onSelectZone && onSelectZone(zone)}
              onMouseEnter={() => setHoveredZone(zone)}
              onMouseLeave={() => setHoveredZone(null)}
              style={{ cursor: 'pointer' }}
            >
              {/* Zone Cell Rectangle */}
              <rect
                x={x + 2}
                y={y + 2}
                width={cellW - 4}
                height={cellH - 4}
                fill={getZoneColor(zone)}
                stroke={getZoneBorder(zone)}
                strokeWidth={isSelected ? 3 : isHovered ? 2 : 1}
                strokeDasharray={zone.status === 'High Priority' ? 'none' : '2 2'}
                rx={2}
              />

              {/* Zone Number Label */}
              <text
                x={x + 8}
                y={y + 16}
                fontSize="10"
                fontFamily="monospace"
                fontWeight={isSelected || isHovered ? "bold" : "normal"}
                fill={mapLayer !== 'vector' ? '#FFFFFF' : '#20231F'}
                opacity={mapLayer !== 'vector' ? 0.9 : 0.7}
              >
                {zone.zoneNumber < 10 ? `0${zone.zoneNumber}` : zone.zoneNumber}
              </text>

              {/* High Priority Zone Marker (Zone 27) */}
              {zone.status === 'High Priority' && (
                <g transform={`translate(${x + cellW / 2}, ${y + cellH / 2})`}>
                  <circle r="14" fill="none" stroke="#B64A43" strokeWidth="1.5" opacity="0.6">
                    <animate attributeName="r" values="10;18;10" dur="2s" repeatCount="indefinite" />
                    <animate attributeName="opacity" values="0.8;0.2;0.8" dur="2s" repeatCount="indefinite" />
                  </circle>
                  <circle r="6" fill="#B64A43" stroke="#FFFFFF" strokeWidth="1.5" />
                  <text y="15" textAnchor="middle" fontSize="9" fontWeight="bold" fill="#FFFFFF">
                    91% STRESS
                  </text>
                </g>
              )}

              {/* Warning Zone Marker */}
              {zone.status === 'Warning' && (
                <circle
                  cx={x + cellW - 12}
                  cy={y + 12}
                  r="4"
                  fill="#B8862D"
                  stroke="#FFFFFF"
                  strokeWidth="1"
                />
              )}
            </g>
          );
        })}

        {/* Flight Path Vector Overlay (Simulated Drone Scan for OP-0142) */}
        {showFlightPath && (
          <g>
            {/* Lawn-mower scan lines */}
            <polyline
              points={`
                ${fieldX + 20},${fieldY + 30}
                ${fieldX + fieldW - 20},${fieldY + 30}
                ${fieldX + fieldW - 20},${fieldY + 90}
                ${fieldX + 20},${fieldY + 90}
                ${fieldX + 20},${fieldY + 150}
                ${fieldX + fieldW - 20},${fieldY + 150}
                ${fieldX + fieldW - 20},${fieldY + 210}
                ${fieldX + 20},${fieldY + 210}
                ${fieldX + 20},${fieldY + 270}
                ${fieldX + 260},${fieldY + 270}
              `}
              fill="none"
              stroke="#55758A"
              strokeWidth="2"
              strokeDasharray="4 3"
            />

            {/* Drone Position Marker on Zone 27 vicinity */}
            <g transform={`translate(${fieldX + 260}, ${fieldY + 270})`}>
              <circle r="12" fill="rgba(85, 117, 138, 0.25)" stroke="#55758A" strokeWidth="1" />
              <circle r="4" fill="#55758A" />
              {/* Drone Heading Arrow */}
              <polygon points="0,-8 5,4 -5,4" fill="#55758A" />
              <text x="14" y="4" fontSize="10" fontWeight="bold" fill={mapLayer !== 'vector' ? '#FFFFFF' : '#20231F'}>
                Drone-01 (68%)
              </text>
            </g>
          </g>
        )}

        {/* Ground Soil Sampling Points */}
        <g stroke="#30432E" strokeWidth="1" fill="#FFFFFF">
          <rect x={fieldX + 40} y={fieldY + 300} width="6" height="6" />
          <rect x={fieldX + 240} y={fieldY + 180} width="6" height="6" />
          <rect x={fieldX + 420} y={fieldY + 100} width="6" height="6" />
        </g>

        {/* Scale Bar */}
        <g transform={`translate(${fieldX}, ${mapHeight - 20})`}>
          <line x1="0" y1="0" x2="60" y2="0" stroke={mapLayer !== 'vector' ? '#FFFFFF' : '#20231F'} strokeWidth="2" />
          <line x1="0" y1="-3" x2="0" y2="3" stroke={mapLayer !== 'vector' ? '#FFFFFF' : '#20231F'} strokeWidth="2" />
          <line x1="60" y1="-3" x2="60" y2="3" stroke={mapLayer !== 'vector' ? '#FFFFFF' : '#20231F'} strokeWidth="2" />
          <text x="30" y="-5" textAnchor="middle" fontSize="10" fill={mapLayer !== 'vector' ? '#FFFFFF' : '#20231F'}>
            50 meters
          </text>
        </g>
      </svg>

      {/* Map Legend Overlay at Bottom Left */}
      <div
        style={{
          position: 'absolute',
          bottom: 10,
          right: 12,
          backgroundColor: 'rgba(255, 255, 255, 0.92)',
          padding: '6px 10px',
          borderRadius: '4px',
          border: '1px solid #DDDED7',
          display: 'flex',
          gap: 12,
          alignItems: 'center',
          fontSize: '11px',
          color: '#20231F',
          boxShadow: '0 1px 3px rgba(0,0,0,0.05)'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <span style={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: '#587451', display: 'inline-block' }} />
          <span>Healthy Zone</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <span style={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: '#B8862D', display: 'inline-block' }} />
          <span>Warning (78%)</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <span style={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: '#B64A43', display: 'inline-block' }} />
          <span>High Priority (Zone 27)</span>
        </div>
      </div>

      {/* Hover Info Tooltip */}
      {hoveredZone && (
        <div
          style={{
            position: 'absolute',
            bottom: 40,
            left: 12,
            backgroundColor: '#FFFFFF',
            border: '1px solid #DDDED7',
            padding: '6px 10px',
            borderRadius: '4px',
            fontSize: '11px',
            boxShadow: '0 2px 6px rgba(0,0,0,0.1)',
            zIndex: 20
          }}
        >
          <div style={{ fontWeight: 'bold', color: '#20231F' }}>{hoveredZone.id}</div>
          <div style={{ color: '#6B7068' }}>Status: {hoveredZone.status}</div>
          <div style={{ color: '#6B7068' }}>Soil Moisture: {hoveredZone.soilMoisture}%</div>
          {hoveredZone.stressType && (
            <div style={{ color: '#B64A43', fontWeight: 500, marginTop: 2 }}>
              {hoveredZone.stressType} ({hoveredZone.confidence}% conf)
            </div>
          )}
        </div>
      )}
    </div>
  );
};
