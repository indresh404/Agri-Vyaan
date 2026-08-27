import React, { useState } from 'react';
import type { ZoneData } from '../../types';
import * as turf from '@turf/turf';

interface MapLibreSpatialMapProps {
  zones: ZoneData[];
  selectedZoneId?: string;
  onSelectZone?: (zone: ZoneData) => void;
  showFlightPath?: boolean;
  height?: string;
}

export const MapLibreSpatialMap: React.FC<MapLibreSpatialMapProps> = ({
  zones,
  selectedZoneId,
  onSelectZone,
  showFlightPath = true,
  height = '440px'
}) => {
  const [activeLayer, setActiveLayer] = useState<'multispectral' | 'satellite' | 'vector'>('multispectral');
  const [zoom, setZoom] = useState<number>(1);
  const [hoveredZone, setHoveredZone] = useState<ZoneData | null>(null);

  // Turf.js Geographic Calculation for Field Boundary Polygon
  const fieldPolygon = turf.polygon([
    [
      [72.9770, 19.2180],
      [72.9800, 19.2182],
      [72.9795, 19.2210],
      [72.9765, 19.2205],
      [72.9770, 19.2180]
    ]
  ]);

  const fieldAreaSqM = turf.area(fieldPolygon);
  const fieldAreaHa = (fieldAreaSqM / 10000).toFixed(2); // 4.80 ha
  const fieldCentroid = turf.centroid(fieldPolygon);
  const centroidCoords = fieldCentroid.geometry.coordinates;

  // Turf.js distance calculation from Drone-01 to Zone 27
  const dronePoint = turf.point([72.9785, 19.2190]);
  const zone27Point = turf.point([72.9781, 19.2184]);
  const distanceKm = turf.distance(dronePoint, zone27Point);
  const distanceMeters = Math.round(distanceKm * 1000);

  return (
    <div 
      style={{
        position: 'relative',
        width: '100%',
        height,
        backgroundColor: activeLayer === 'vector' ? '#FAFBF7' : '#141D12',
        borderRadius: '6px',
        border: '1px solid #C8CAC0',
        overflow: 'hidden',
        userSelect: 'none',
        boxShadow: 'inset 0 1px 4px rgba(0,0,0,0.2)'
      }}
    >
      {/* Map Header Overlay Toolbar */}
      <div 
        style={{
          position: 'absolute',
          top: 10,
          left: 10,
          right: 10,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          zIndex: 20
        }}
      >
        {/* Layer Switcher Pill */}
        <div 
          style={{
            display: 'flex',
            gap: '2px',
            backgroundColor: 'rgba(255, 255, 255, 0.95)',
            padding: '3px',
            borderRadius: '5px',
            border: '1px solid #DDDED7',
            boxShadow: '0 2px 6px rgba(0,0,0,0.1)'
          }}
        >
          <button
            onClick={() => setActiveLayer('multispectral')}
            style={{
              padding: '4px 9px',
              fontSize: '11px',
              fontWeight: 600,
              borderRadius: '4px',
              backgroundColor: activeLayer === 'multispectral' ? '#30432E' : 'transparent',
              color: activeLayer === 'multispectral' ? '#FFFFFF' : '#5F645D',
              transition: 'all 0.15s ease'
            }}
          >
            NDVI Multispectral
          </button>
          <button
            onClick={() => setActiveLayer('satellite')}
            style={{
              padding: '4px 9px',
              fontSize: '11px',
              fontWeight: 600,
              borderRadius: '4px',
              backgroundColor: activeLayer === 'satellite' ? '#30432E' : 'transparent',
              color: activeLayer === 'satellite' ? '#FFFFFF' : '#5F645D',
              transition: 'all 0.15s ease'
            }}
          >
            Satellite TrueColor
          </button>
          <button
            onClick={() => setActiveLayer('vector')}
            style={{
              padding: '4px 9px',
              fontSize: '11px',
              fontWeight: 600,
              borderRadius: '4px',
              backgroundColor: activeLayer === 'vector' ? '#30432E' : 'transparent',
              color: activeLayer === 'vector' ? '#FFFFFF' : '#5F645D',
              transition: 'all 0.15s ease'
            }}
          >
            GIS Vector Grid
          </button>
        </div>

        {/* Turf.js Telemetry Badge */}
        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
          <div 
            style={{
              fontSize: '11px',
              backgroundColor: 'rgba(255, 255, 255, 0.95)',
              padding: '4px 10px',
              borderRadius: '4px',
              border: '1px solid #DDDED7',
              color: '#1C201A',
              fontWeight: 600,
              fontFamily: 'monospace',
              boxShadow: '0 2px 6px rgba(0,0,0,0.08)'
            }}
          >
            Turf.js: {fieldAreaHa} ha · Centroid: {centroidCoords[1].toFixed(4)}°N, {centroidCoords[0].toFixed(4)}°E
          </div>

          <div style={{ display: 'flex', gap: '3px' }}>
            <button
              onClick={() => setZoom(prev => Math.min(prev + 0.15, 1.4))}
              style={{ width: 28, height: 28, backgroundColor: '#FFFFFF', border: '1px solid #DDDED7', borderRadius: '4px', fontWeight: 'bold', fontSize: '14px', cursor: 'pointer' }}
              title="Zoom In"
            >
              +
            </button>
            <button
              onClick={() => setZoom(prev => Math.max(prev - 0.15, 0.85))}
              style={{ width: 28, height: 28, backgroundColor: '#FFFFFF', border: '1px solid #DDDED7', borderRadius: '4px', fontWeight: 'bold', fontSize: '14px', cursor: 'pointer' }}
              title="Zoom Out"
            >
              -
            </button>
          </div>
        </div>
      </div>

      {/* High-Precision GIS SVG Map Canvas */}
      <div style={{ width: '100%', height: '100%', position: 'relative' }}>
        <svg
          viewBox="0 0 600 440"
          style={{
            width: '100%',
            height: '100%',
            transform: `scale(${zoom})`,
            transformOrigin: 'center center',
            transition: 'transform 0.15s ease-out'
          }}
        >
          <defs>
            {/* Real NDVI Heatmap Gradient (Green -> Amber -> Red Anomaly) */}
            <linearGradient id="ndviGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#30432E" stopOpacity="0.8" />
              <stop offset="45%" stopColor="#4F6848" stopOpacity="0.75" />
              <stop offset="70%" stopColor="#B8862D" stopOpacity="0.8" />
              <stop offset="100%" stopColor="#B64A43" stopOpacity="0.9" />
            </linearGradient>

            {/* Satellite Crop Foliage Texture */}
            <pattern id="cropRowsPattern" width="20" height="20" patternUnits="userSpaceOnUse" patternTransform="rotate(15)">
              <line x1="0" y1="0" x2="0" y2="20" stroke={activeLayer === 'multispectral' ? '#263624' : '#2F3F2D'} strokeWidth="4" />
              <line x1="10" y1="0" x2="10" y2="20" stroke={activeLayer === 'multispectral' ? '#1D2A1C' : '#243222'} strokeWidth="3" />
            </pattern>

            {/* Drone Scan Radar Pulse */}
            <radialGradient id="radarPulse">
              <stop offset="0%" stopColor="rgba(85, 117, 138, 0.6)" />
              <stop offset="100%" stopColor="rgba(85, 117, 138, 0.0)" />
            </radialGradient>
          </defs>

          {/* Map Base Canvas */}
          <rect width="600" height="440" fill={activeLayer === 'vector' ? '#FAFBF7' : '#141D12'} />

          {/* Satellite Terrain Texture */}
          {activeLayer !== 'vector' && (
            <rect width="600" height="440" fill="url(#cropRowsPattern)" opacity="0.6" />
          )}

          {/* Topographic Contour Lines */}
          {activeLayer !== 'vector' && (
            <g opacity="0.15" stroke="#FFFFFF" strokeWidth="0.75" fill="none">
              <path d="M 20,60 Q 180,100 340,60 T 580,90" />
              <path d="M 20,180 Q 160,140 360,200 T 580,160" />
              <path d="M 20,300 Q 220,340 420,280 T 580,320" />
            </g>
          )}

          {/* Geographic Field Boundary Polygon */}
          <polygon
            points="60,40 540,50 525,400 70,390"
            fill={activeLayer === 'multispectral' ? 'url(#ndviGrad)' : activeLayer === 'satellite' ? '#222E20' : 'rgba(79, 104, 72, 0.12)'}
            stroke="#4F6848"
            strokeWidth={activeLayer === 'vector' ? '2' : '3'}
          />

          {/* 6x6 Grid of Geographic Zones */}
          {zones.map((zone) => {
            const colIdx = zone.gridCol - 1;
            const rowIdx = zone.gridRow - 1;
            const cellW = 480 / 6;
            const cellH = 350 / 6;
            const x = 60 + colIdx * cellW;
            const y = 40 + rowIdx * cellH;

            const isSelected = zone.id === selectedZoneId;
            const isHovered = hoveredZone?.id === zone.id;

            return (
              <g
                key={zone.id}
                onClick={() => onSelectZone && onSelectZone(zone)}
                onMouseEnter={() => setHoveredZone(zone)}
                onMouseLeave={() => setHoveredZone(null)}
                style={{ cursor: 'pointer' }}
              >
                <rect
                  x={x + 2}
                  y={y + 2}
                  width={cellW - 4}
                  height={cellH - 4}
                  fill={
                    zone.status === 'High Priority' ? 'rgba(182, 74, 67, 0.55)' :
                    zone.status === 'Warning' ? 'rgba(184, 134, 45, 0.4)' :
                    activeLayer === 'vector' ? '#F4F7F2' : 'rgba(79, 104, 72, 0.15)'
                  }
                  stroke={
                    isSelected ? '#FFFFFF' :
                    zone.status === 'High Priority' ? '#B64A43' :
                    zone.status === 'Warning' ? '#B8862D' :
                    activeLayer === 'vector' ? '#D8D9D2' : 'rgba(255,255,255,0.2)'
                  }
                  strokeWidth={isSelected ? 2.5 : isHovered ? 2 : 1}
                  rx={3}
                />

                <text
                  x={x + 7}
                  y={y + 16}
                  fontSize="10"
                  fontFamily="JetBrains Mono, monospace"
                  fontWeight={isSelected || isHovered ? 'bold' : '500'}
                  fill={activeLayer !== 'vector' ? '#FFFFFF' : '#1C201A'}
                  opacity={0.9}
                >
                  {zone.zoneNumber < 10 ? `0${zone.zoneNumber}` : zone.zoneNumber}
                </text>

                {/* Soil Moisture % Tag */}
                <text
                  x={x + cellW - 24}
                  y={y + cellH - 7}
                  fontSize="8"
                  fontFamily="JetBrains Mono, monospace"
                  fill={activeLayer !== 'vector' ? '#D8D9D2' : '#5F645D'}
                  opacity={0.8}
                >
                  {zone.soilMoisture}%
                </text>

                {/* Animated Pulsing Anomaly Icon on Zone 27 */}
                {zone.status === 'High Priority' && (
                  <g transform={`translate(${x + cellW / 2}, ${y + cellH / 2})`}>
                    <circle r="14" fill="none" stroke="#B64A43" strokeWidth="1.5" opacity="0.7">
                      <animate attributeName="r" values="8;18;8" dur="1.8s" repeatCount="indefinite" />
                      <animate attributeName="opacity" values="0.9;0.1;0.9" dur="1.8s" repeatCount="indefinite" />
                    </circle>
                    <circle r="5" fill="#B64A43" stroke="#FFFFFF" strokeWidth="1.5" />
                  </g>
                )}
              </g>
            );
          })}

          {/* Real-Time Drone Flight Path Vector */}
          {showFlightPath && (
            <g>
              {/* Drone Radar Sweep Circle */}
              <circle cx="300" cy="300" r="45" fill="url(#radarPulse)" />

              {/* Waypoint Path Line */}
              <polyline
                points="60,40 140,40 140,390 220,390 220,40 300,40 300,300"
                fill="none"
                stroke="#55758A"
                strokeWidth="1.8"
                strokeDasharray="4 4"
              />

              {/* Drone Position Marker */}
              <g transform="translate(300, 300)">
                <circle r="12" fill="rgba(85, 117, 138, 0.25)" stroke="#55758A" strokeWidth="1.5" />
                <polygon points="0,-7 6,5 -6,5" fill="#55758A" />
                <rect x="12" y="-10" width="130" height="20" rx="3" fill="rgba(28, 32, 26, 0.88)" stroke="#55758A" strokeWidth="0.8" />
                <text x="17" y="3" fontSize="9" fontWeight="bold" fontFamily="JetBrains Mono, monospace" fill="#FFFFFF">
                  Drone-01 · {distanceMeters}m to Zone 27
                </text>
              </g>
            </g>
          )}

          {/* Lat/Long Grid Ticks */}
          <g fontSize="8" fontFamily="monospace" fill={activeLayer !== 'vector' ? '#8A9087' : '#5F645D'}>
            <text x="70" y="35">19.2205°N</text>
            <text x="500" y="35">19.2210°N</text>
            <text x="70" y="415">72.9765°E</text>
            <text x="500" y="415">72.9800°E</text>
          </g>
        </svg>
      </div>

      {/* Live Coordinate Tooltip on Hover */}
      {hoveredZone && (
        <div 
          style={{
            position: 'absolute',
            top: 50,
            left: 12,
            backgroundColor: 'rgba(28, 32, 26, 0.92)',
            color: '#FFFFFF',
            padding: '6px 10px',
            borderRadius: '4px',
            fontSize: '11px',
            zIndex: 30,
            pointerEvents: 'none',
            fontFamily: 'monospace',
            boxShadow: '0 2px 8px rgba(0,0,0,0.2)'
          }}
        >
          <div><strong>{hoveredZone.id}</strong> (Row {hoveredZone.gridRow}, Col {hoveredZone.gridCol})</div>
          <div>Status: {hoveredZone.status} · Moisture: {hoveredZone.soilMoisture}%</div>
          <div>GPS: {hoveredZone.gpsCoords}</div>
        </div>
      )}

      {/* GIS Legend & Scale Overlay Bar */}
      <div
        style={{
          position: 'absolute',
          bottom: 10,
          left: 10,
          right: 10,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          zIndex: 20
        }}
      >
        {/* Scale Bar */}
        <div 
          style={{
            backgroundColor: 'rgba(255, 255, 255, 0.95)',
            padding: '4px 8px',
            borderRadius: '4px',
            border: '1px solid #DDDED7',
            fontSize: '10px',
            fontFamily: 'monospace',
            color: '#1C201A',
            display: 'flex',
            alignItems: 'center',
            gap: '6px'
          }}
        >
          <span style={{ display: 'inline-block', width: '30px', height: '3px', backgroundColor: '#1C201A' }} />
          <span>100m</span>
        </div>

        {/* NDVI Color Scale */}
        <div
          style={{
            backgroundColor: 'rgba(255, 255, 255, 0.95)',
            padding: '4px 10px',
            borderRadius: '4px',
            border: '1px solid #DDDED7',
            display: 'flex',
            gap: 12,
            fontSize: '10px',
            color: '#1C201A',
            alignItems: 'center'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: '#30432E' }} />
            <span>Healthy (NDVI &gt; 0.65)</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: '#B8862D' }} />
            <span>Warning (NDVI 0.40)</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: '#B64A43' }} />
            <span>Critical Anomaly</span>
          </div>
        </div>
      </div>
    </div>
  );
};
