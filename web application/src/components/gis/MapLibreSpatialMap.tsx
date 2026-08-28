import React, { useEffect, useRef, useState } from 'react';
import type { ZoneData } from '../../types';
import * as turf from '@turf/turf';

// Leaflet CSS must be injected globally — we do it here via a style tag approach
// to avoid Vite asset resolution issues
const LEAFLET_CSS = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';

interface MapLibreSpatialMapProps {
  zones: ZoneData[];
  selectedZoneId?: string;
  onSelectZone?: (zone: ZoneData) => void;
  showFlightPath?: boolean;
  height?: string;
}

// Ambegaon Potato Farm coordinates — Shifted North onto green crop field parcel
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

export const MapLibreSpatialMap: React.FC<MapLibreSpatialMapProps> = ({
  showFlightPath = true,
  height = '440px'
}) => {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<import('leaflet').Map | null>(null);
  const baseTileRef = useRef<import('leaflet').TileLayer | null>(null);
  const [activeLayer, setActiveLayer] = useState<'satellite' | 'ndvi' | 'streets'>('satellite');
  const [cssLoaded, setCssLoaded] = useState(false);

  // Inject Leaflet CSS once
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

  // Turf.js calculations for farm field boundary
  const turfPolygon = turf.polygon([[
    [73.8810, 19.0536],
    [73.8832, 19.0538],
    [73.8830, 19.0550],
    [73.8808, 19.0548],
    [73.8810, 19.0536],
  ]]);
  const fieldAreaHa = (turf.area(turfPolygon) / 10000).toFixed(2);
  const centroid = turf.centroid(turfPolygon).geometry.coordinates;

  // Initialize map after CSS loaded
  useEffect(() => {
    if (!cssLoaded) return;
    if (!mapContainerRef.current) return;
    if (mapInstanceRef.current) return;

    import('leaflet').then((L) => {
      // Fix Leaflet marker icon paths (Vite bundler issue)
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      delete (L.Icon.Default.prototype as any)._getIconUrl;
      L.Icon.Default.mergeOptions({
        iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
        iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
        shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
      });

      const map = L.map(mapContainerRef.current!, {
        center: [FARM_LAT, FARM_LNG],
        zoom: 16,
        zoomControl: false, // we'll position it manually
        attributionControl: false,
      });

      // Add zoom control to bottom-right
      L.control.zoom({ position: 'bottomright' }).addTo(map);

      // Google Satellite tile layer with maxNativeZoom to prevent missing tile errors
      const googleSat = L.tileLayer(
        'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
        {
          attribution: 'Satellite © Google / Esri Maxar',
          maxZoom: 19,
          maxNativeZoom: 17,
          tileSize: 256,
        }
      );
      googleSat.addTo(map);
      baseTileRef.current = googleSat;

      // --- Field Boundary Polygon ---
      L.polygon(FIELD_BOUNDARY, {
        color: '#00E5FF',
        weight: 2.5,
        fillColor: '#00E5FF',
        fillOpacity: 0.06,
        dashArray: '8 5',
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

      // --- Drone Marker ---
      if (showFlightPath) {
        const droneIcon = L.divIcon({
          className: '',
          html: `<div class="agri-drone-marker">
            <div class="agri-drone-ring"></div>
            <div class="agri-drone-icon">✈</div>
          </div>`,
          iconSize: [32, 32],
          iconAnchor: [16, 16],
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

        // Flight path
        L.polyline(FLIGHT_PATH, {
          color: '#42A5F5',
          weight: 2.5,
          dashArray: '6 5',
          opacity: 0.85,
        }).addTo(map);
      }

      mapInstanceRef.current = map;
    });

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cssLoaded]);

  // Handle layer switching
  useEffect(() => {
    const map = mapInstanceRef.current;
    if (!map) return;
    import('leaflet').then((L) => {
      if (baseTileRef.current) map.removeLayer(baseTileRef.current);

      const urls: Record<string, { url: string; attr: string }> = {
        satellite: {
          url: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
          attr: 'Satellite © Google / Esri Maxar',
        },
        ndvi: {
          url: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
          attr: 'Satellite © Google | NDVI false-color overlay',
        },
        streets: {
          url: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
          attr: 'Map Data © Google',
        },
      };

      const chosen = urls[activeLayer];
      const newTile = L.tileLayer(chosen.url, {
        attribution: chosen.attr,
        maxZoom: 19,
        maxNativeZoom: 17,
        tileSize: 256,
      });
      newTile.addTo(map);
      baseTileRef.current = newTile;
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeLayer]);

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
            transition: 'all 0.15s',
            textTransform: 'uppercase', letterSpacing: '0.5px',
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
        boxShadow: '0 4px 12px rgba(0,0,0,0.3)',
        lineHeight: 1.5,
      }}>
        <div>📐 {fieldAreaHa} ha &nbsp;|&nbsp; Turf.js Calculated</div>
        <div style={{ color: 'rgba(255,255,255,0.55)', fontSize: '10px' }}>{centroid[1].toFixed(4)}°N · {centroid[0].toFixed(4)}°E · Ambegaon</div>
      </div>

      {/* NDVI false-color overlay */}
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
        <LegendDot color="#EF5350" label="Late Blight" />
        <LegendDot color="#FF9800" label="Low Moisture" />
        <LegendDot color="#FFD600" label="Warning" />
        <LegendDot color="#42A5F5" label="Drone-01" isDash />
        <LegendLine color="#00E5FF" label="Field Boundary" />
      </div>

      {/* Leaflet map container — must be full size with no overflow clipping */}
      <div
        ref={mapContainerRef}
        style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}
      />

      {/* Inject custom marker & map styles */}
      <style>{`
        .agri-field-tip { font-family: monospace; }
        .agri-popup .leaflet-popup-content-wrapper { border-radius: 6px; box-shadow: 0 4px 16px rgba(0,0,0,0.2); }

        .agri-pulse-marker { position: relative; width: 28px; height: 28px; }
        .agri-pulse-ring {
          position: absolute; inset: 0; border-radius: 50%;
          border: 2px solid var(--pulse-color);
          animation: agriPulseRing 1.8s ease-out infinite;
        }
        .agri-pulse-dot {
          position: absolute; top: 6px; left: 6px;
          width: 16px; height: 16px; border-radius: 50%;
          background: var(--pulse-color);
          border: 2px solid #fff;
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
          font-size: 10px; color: #fff;
          box-shadow: 0 2px 8px rgba(0,0,0,0.5);
        }
        @keyframes agriDroneRing {
          0%   { transform: scale(1); opacity: 0.8; }
          100% { transform: scale(2.5); opacity: 0; }
        }
      `}</style>
    </div>
  );
};

// Helper components
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
