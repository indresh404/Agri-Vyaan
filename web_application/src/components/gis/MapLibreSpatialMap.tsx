import React, { useEffect, useRef, useState } from 'react';
import type { ZoneData } from '../../types';
import * as turf from '@turf/turf';

const LEAFLET_CSS = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';

interface MapLibreSpatialMapProps {
  zones: ZoneData[];
  selectedZoneId?: string;
  onSelectZone?: (zone: ZoneData) => void;
  showFlightPath?: boolean;
  height?: string;
}

// Ambegaon Potato Farm — field boundary centre
const FARM_LAT = 19.0542;
const FARM_LNG = 73.8820;

const FIELD_BOUNDARY: [number, number][] = [
  [19.0536, 73.8810],
  [19.0538, 73.8832],
  [19.0550, 73.8830],
  [19.0548, 73.8808],
  [19.0536, 73.8810],
];

const FLIGHT_PATH: [number, number][] = [
  [19.0537, 73.8811],
  [19.0540, 73.8816],
  [19.0544, 73.8822],
  [19.0548, 73.8828],
];

// ── Parse "lat, lng" string from ZoneData.gpsCoords ────────────────────────
function parseCoords(gpsCoords: string): [number, number] | null {
  const parts = gpsCoords.split(',').map(s => parseFloat(s.trim()));
  if (parts.length === 2 && !isNaN(parts[0]) && !isNaN(parts[1])) {
    return [parts[0], parts[1]];
  }
  return null;
}

// Build a small square polygon (±0.0005° ≈ 55m side) around a GPS point
function buildZonePolygon(lat: number, lng: number, delta = 0.0006): [number, number][] {
  return [
    [lat - delta, lng - delta],
    [lat - delta, lng + delta],
    [lat + delta, lng + delta],
    [lat + delta, lng - delta],
    [lat - delta, lng - delta],
  ];
}

// Zone status → polygon colour map
function zoneColor(status: string): string {
  if (status === 'High Priority') return '#EF5350';
  if (status === 'Warning' || status === 'Low moisture') return '#FF9800';
  if (status === 'Possible nutrient stress') return '#FFD600';
  if (status === 'Disease risk') return '#AB47BC';
  return '#66BB6A'; // Healthy
}

export const MapLibreSpatialMap: React.FC<MapLibreSpatialMapProps> = ({
  zones = [],
  selectedZoneId,
  onSelectZone,
  showFlightPath = true,
  height = '440px',
}) => {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<import('leaflet').Map | null>(null);
  const baseTileRef = useRef<import('leaflet').TileLayer | null>(null);
  // Keep refs to zone polygons & markers so we can update styles on selection change
  const zoneLayerGroupRef = useRef<import('leaflet').LayerGroup | null>(null);
  const [activeLayer, setActiveLayer] = useState<'satellite' | 'ndvi' | 'streets'>('satellite');
  const [cssLoaded, setCssLoaded] = useState(false);

  // Turf.js farm area calculation
  const turfPolygon = turf.polygon([[
    [73.8810, 19.0536],
    [73.8832, 19.0538],
    [73.8830, 19.0550],
    [73.8808, 19.0548],
    [73.8810, 19.0536],
  ]]);
  const fieldAreaHa = (turf.area(turfPolygon) / 10000).toFixed(2);
  const centroid = turf.centroid(turfPolygon).geometry.coordinates;

  // ── Inject Leaflet CSS ──────────────────────────────────────────────────────
  useEffect(() => {
    if (document.querySelector(`link[href="${LEAFLET_CSS}"]`)) {
      setCssLoaded(true);
      return;
    }
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = LEAFLET_CSS;
    link.onload = () => setCssLoaded(true);
    document.head.appendChild(link);
  }, []);

  // ── Initialize Map ──────────────────────────────────────────────────────────
  useEffect(() => {
    if (!cssLoaded || !mapContainerRef.current || mapInstanceRef.current) return;

    import('leaflet').then((L) => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      delete (L.Icon.Default.prototype as any)._getIconUrl;
      L.Icon.Default.mergeOptions({
        iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
        iconUrl:       'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
        shadowUrl:     'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
      });

      const map = L.map(mapContainerRef.current!, {
        center: [FARM_LAT, FARM_LNG],
        zoom: 17,
        zoomControl: false,
        attributionControl: false,
      });
      L.control.zoom({ position: 'bottomright' }).addTo(map);

      // Satellite tile
      const googleSat = L.tileLayer(
        'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
        { attribution: 'Satellite © Google', maxZoom: 20, maxNativeZoom: 18, tileSize: 256 }
      );
      googleSat.addTo(map);
      baseTileRef.current = googleSat;

      // Field boundary polygon
      L.polygon(FIELD_BOUNDARY, {
        color: '#00E5FF', weight: 2.5,
        fillColor: '#00E5FF', fillOpacity: 0.06, dashArray: '8 5',
      })
        .addTo(map)
        .bindTooltip(
          `<div style="font-family:monospace;font-size:12px">
            <b>Field A — Potato (Solanum tuberosum)</b><br/>
            Area: ${fieldAreaHa} ha &nbsp;|&nbsp; ${centroid[1].toFixed(4)}°N, ${centroid[0].toFixed(4)}°E<br/>
            Stage: Tuber Bulking &nbsp;|&nbsp; Ambegaon, Pune District
          </div>`,
          { sticky: true, className: 'agri-field-tip' }
        );

      // Drone marker + flight path
      if (showFlightPath) {
        const droneIcon = L.divIcon({
          className: '',
          html: `<div class="agri-drone-marker">
            <div class="agri-drone-ring"></div>
            <div class="agri-drone-icon">✈</div>
          </div>`,
          iconSize: [32, 32], iconAnchor: [16, 16],
        });
        L.marker([FARM_LAT, FARM_LNG], { icon: droneIcon })
          .addTo(map)
          .bindPopup(
            `<div style="font-family:monospace;line-height:1.6">
              <b style="color:#42A5F5">Drone-01 — AgriSwarm</b><br/>
              Altitude: 45 m &nbsp;|&nbsp; Speed: 4.2 m/s<br/>
              Battery: 62% &nbsp;|&nbsp; Stage: Active Scan<br/>
              Scanning: Field A (Potato) — Zone 27
            </div>`,
            { maxWidth: 240 }
          );
        L.polyline(FLIGHT_PATH, { color: '#42A5F5', weight: 2.5, dashArray: '6 5', opacity: 0.85 }).addTo(map);
      }

      // Zone layer group (will be populated/updated separately)
      const zoneGroup = L.layerGroup().addTo(map);
      zoneLayerGroupRef.current = zoneGroup;

      mapInstanceRef.current = map;
    });

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
        zoneLayerGroupRef.current = null;
      }
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cssLoaded]);

  // ── Render Zone Polygons whenever zones list changes ────────────────────────
  useEffect(() => {
    if (!mapInstanceRef.current || !zoneLayerGroupRef.current) return;

    import('leaflet').then((L) => {
      const group = zoneLayerGroupRef.current!;
      group.clearLayers();

      zones.forEach((zone) => {
        const coords = parseCoords(zone.gpsCoords);
        if (!coords) return;
        const [lat, lng] = coords;
        const isSelected = zone.id === selectedZoneId;
        const color = zoneColor(zone.status);

        // Zone polygon
        const poly = L.polygon(buildZonePolygon(lat, lng), {
          color: isSelected ? '#FFFFFF' : color,
          weight: isSelected ? 2.5 : 1.5,
          fillColor: color,
          fillOpacity: isSelected ? 0.55 : 0.28,
          dashArray: isSelected ? undefined : '5 4',
        });

        // Zone label marker
        const labelIcon = L.divIcon({
          className: '',
          html: `<div style="
            background:${isSelected ? color : 'rgba(20,25,20,0.80)'};
            color:${isSelected ? '#fff' : color};
            border:${isSelected ? '2px solid #fff' : '1.5px solid ' + color};
            padding:2px 6px; border-radius:3px;
            font-size:10px; font-weight:700; font-family:monospace;
            white-space:nowrap; box-shadow:0 2px 6px rgba(0,0,0,0.5);
            pointer-events:none;
          ">${zone.id}</div>`,
          iconAnchor: [24, 10],
        });
        const label = L.marker([lat, lng], { icon: labelIcon, zIndexOffset: 100 });

        // Click handlers — select zone AND fly to it
        const handleClick = () => {
          if (onSelectZone) onSelectZone(zone);
          mapInstanceRef.current?.flyTo([lat, lng], 18, { duration: 0.8 });
        };
        poly.on('click', handleClick);
        label.on('click', handleClick);

        // Tooltip on hover
        poly.bindTooltip(
          `<div style="font-family:monospace;font-size:12px;line-height:1.6">
            <b>${zone.id}</b> — ${zone.status}<br/>
            Soil Moisture: <b>${zone.soilMoisture}%</b><br/>
            ${zone.stressType ? `Stress: ${zone.stressType}<br/>` : ''}
            ${zone.confidence ? `AI Confidence: ${zone.confidence}%<br/>` : ''}
            GPS: ${zone.gpsCoords}
          </div>`,
          { sticky: true }
        );

        group.addLayer(poly);
        group.addLayer(label);
      });
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [zones, selectedZoneId]);

  // ── Fly to selected zone on selection change ───────────────────────────────
  useEffect(() => {
    if (!mapInstanceRef.current || !selectedZoneId) return;
    const zone = zones.find(z => z.id === selectedZoneId);
    if (!zone) return;
    const coords = parseCoords(zone.gpsCoords);
    if (!coords) return;
    mapInstanceRef.current.flyTo(coords, 18, { duration: 0.9 });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedZoneId]);

  // ── Tile layer switching ───────────────────────────────────────────────────
  useEffect(() => {
    const map = mapInstanceRef.current;
    if (!map) return;
    import('leaflet').then((L) => {
      if (baseTileRef.current) map.removeLayer(baseTileRef.current);
      const urls: Record<string, { url: string; attr: string }> = {
        satellite: { url: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', attr: 'Satellite © Google' },
        ndvi:      { url: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', attr: 'NDVI overlay © Google' },
        streets:   { url: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', attr: 'Map © Google' },
      };
      const chosen = urls[activeLayer];
      const newTile = L.tileLayer(chosen.url, { attribution: chosen.attr, maxZoom: 20, maxNativeZoom: 18, tileSize: 256 });
      newTile.addTo(map);
      baseTileRef.current = newTile;
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeLayer]);

  // ─── Render ────────────────────────────────────────────────────────────────
  return (
    <div style={{ position: 'relative', width: '100%', height, borderRadius: '8px', border: '1px solid #B0B3AC', overflow: 'hidden' }}>

      {/* Layer Toggle Bar */}
      <div style={{
        position: 'absolute', top: 12, left: 12, zIndex: 999,
        display: 'flex', gap: '2px',
        background: 'rgba(15,20,15,0.82)', backdropFilter: 'blur(8px)',
        padding: '4px', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.12)',
        boxShadow: '0 4px 12px rgba(0,0,0,0.35)',
      }}>
        {(['satellite', 'ndvi', 'streets'] as const).map((layer) => (
          <button key={layer} onClick={() => setActiveLayer(layer)} style={{
            padding: '4px 11px', fontSize: '11px', fontWeight: 700,
            borderRadius: '4px', border: 'none', cursor: 'pointer',
            background: activeLayer === layer ? '#30432E' : 'transparent',
            color: activeLayer === layer ? '#A8D5A2' : 'rgba(255,255,255,0.6)',
            transition: 'all 0.15s', textTransform: 'uppercase', letterSpacing: '0.5px',
          }}>
            {layer === 'satellite' ? '🛰 Satellite' : layer === 'ndvi' ? '🌿 NDVI' : '🗺 Streets'}
          </button>
        ))}
      </div>

      {/* Turf.js Stats Badge */}
      <div style={{
        position: 'absolute', top: 12, right: 12, zIndex: 999,
        background: 'rgba(15,20,15,0.82)', backdropFilter: 'blur(8px)',
        padding: '6px 12px', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.12)',
        fontSize: '11px', fontFamily: 'monospace', fontWeight: 600, color: '#A8D5A2',
        boxShadow: '0 4px 12px rgba(0,0,0,0.3)', lineHeight: 1.5,
      }}>
        <div>📐 {fieldAreaHa} ha &nbsp;|&nbsp; Turf.js Calculated</div>
        <div style={{ color: 'rgba(255,255,255,0.55)', fontSize: '10px' }}>{centroid[1].toFixed(4)}°N · {centroid[0].toFixed(4)}°E · Ambegaon</div>
      </div>

      {/* Selected Zone HUD Badge */}
      {selectedZoneId && (
        <div style={{
          position: 'absolute', bottom: 55, right: 12, zIndex: 999,
          background: 'rgba(15,20,15,0.90)', backdropFilter: 'blur(8px)',
          padding: '6px 12px', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.15)',
          fontSize: '11px', fontFamily: 'monospace', color: '#FFD600',
          boxShadow: '0 4px 12px rgba(0,0,0,0.4)', lineHeight: 1.6,
        }}>
          📍 Viewing: <strong>{selectedZoneId}</strong>
          {(() => {
            const z = zones.find(x => x.id === selectedZoneId);
            return z ? <><br/>Moisture: {z.soilMoisture}% · {z.status}</> : null;
          })()}
        </div>
      )}

      {/* NDVI false-colour overlay */}
      {activeLayer === 'ndvi' && (
        <div style={{
          position: 'absolute', inset: 0, zIndex: 400, pointerEvents: 'none',
          background: 'linear-gradient(135deg, rgba(30,60,20,0.5) 0%, rgba(180,130,30,0.4) 65%, rgba(180,60,50,0.55) 100%)',
        }} />
      )}

      {/* Legend Bar */}
      <div style={{
        position: 'absolute', bottom: 30, left: 12, zIndex: 999,
        background: 'rgba(15,20,15,0.82)', backdropFilter: 'blur(8px)',
        padding: '6px 12px', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.1)',
        display: 'flex', gap: 14, alignItems: 'center', fontSize: '10px', fontWeight: 600, color: '#E0E1D8',
        boxShadow: '0 4px 12px rgba(0,0,0,0.3)',
      }}>
        <LegendDot color="#EF5350" label="High Priority" />
        <LegendDot color="#FF9800" label="Low Moisture" />
        <LegendDot color="#FFD600" label="Warning" />
        <LegendDot color="#66BB6A" label="Healthy" />
        <LegendDot color="#42A5F5" label="Drone-01" isDash />
        <LegendLine color="#00E5FF" label="Field Boundary" />
      </div>

      {/* Leaflet map container */}
      <div ref={mapContainerRef} style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }} />

      {/* CSS injection */}
      <style>{`
        .agri-field-tip { font-family: monospace; }

        .agri-pulse-marker { position: relative; width: 28px; height: 28px; }
        .agri-pulse-ring {
          position: absolute; inset: 0; border-radius: 50%;
          border: 2px solid var(--pulse-color);
          animation: agriPulseRing 1.8s ease-out infinite;
        }
        .agri-pulse-dot {
          position: absolute; top: 6px; left: 6px;
          width: 16px; height: 16px; border-radius: 50%;
          background: var(--pulse-color); border: 2px solid #fff;
          box-shadow: 0 2px 6px rgba(0,0,0,0.4);
        }
        @keyframes agriPulseRing {
          0%   { transform: scale(0.6); opacity: 1; }
          80%  { transform: scale(2.2); opacity: 0; }
          100% { transform: scale(2.2); opacity: 0; }
        }

        .agri-drone-marker { position: relative; width: 32px; height: 32px; }
        .agri-drone-ring {
          position: absolute; inset: 0; border-radius: 50%;
          background: rgba(66,165,245,0.2); border: 2px solid rgba(66,165,245,0.9);
          animation: agriDroneRing 1.5s ease-out infinite;
        }
        .agri-drone-icon {
          position: absolute; top: 6px; left: 6px;
          width: 20px; height: 20px; border-radius: 50%;
          background: #1565C0; border: 2px solid #fff;
          display: flex; align-items: center; justify-content: center;
          font-size: 10px; color: #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.5);
        }
        @keyframes agriDroneRing {
          0%   { transform: scale(1); opacity: 0.8; }
          100% { transform: scale(2.5); opacity: 0; }
        }
      `}</style>
    </div>
  );
};

// Helper Components
const LegendDot: React.FC<{ color: string; label: string; isDash?: boolean }> = ({ color, label }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
    <span style={{ width: 9, height: 9, borderRadius: '50%', backgroundColor: color, display: 'inline-block', flexShrink: 0 }} />
    <span>{label}</span>
  </div>
);

const LegendLine: React.FC<{ color: string; label: string }> = ({ color, label }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
    <span style={{ width: 14, height: 2.5, backgroundColor: color, display: 'inline-block', flexShrink: 0 }} />
    <span>{label}</span>
  </div>
);
