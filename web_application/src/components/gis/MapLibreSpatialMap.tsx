import React, { useEffect, useRef, useState, useMemo, useCallback } from 'react';
import type { ZoneData, FieldAsset } from '../../types';
import * as turf from '@turf/turf';
import { downloadKMLFile } from '../../lib/kmlExport';
import { downloadWaypointsFile } from '../../lib/waypointsExport';
import { 
  Search, 
  MapPin, 
  Ruler, 
  Download, 
  Plus, 
  Undo, 
  Trash2, 
  Check, 
  Save,
  X
} from 'lucide-react';

const LEAFLET_CSS = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';

interface MapLibreSpatialMapProps {
  zones?: ZoneData[];
  selectedZoneId?: string;
  onSelectZone?: (zone: ZoneData) => void;
  showFlightPath?: boolean;
  height?: string;
  fields?: FieldAsset[];
  selectedFieldId?: string;
  onSelectField?: (field: FieldAsset) => void;
  onSaveFieldAsset?: (newField: FieldAsset) => void;
  allowDrawing?: boolean;
}

interface SearchResult {
  place_id: number;
  display_name: string;
  lat: string;
  lon: string;
  type: string;
}

// ── Default fallback center: Shree LR Tiwari College of Engineering, Mira Road
const DEFAULT_CENTER: [number, number] = [19.2842, 72.8715];

export const MapLibreSpatialMap: React.FC<MapLibreSpatialMapProps> = ({
  zones: _zones = [],
  selectedZoneId: _selectedZoneId,
  onSelectZone: _onSelectZone,
  showFlightPath: _showFlightPath = true,
  height = '520px',
  fields = [],
  selectedFieldId,
  onSelectField: _onSelectField,
  onSaveFieldAsset,
  allowDrawing = true,
}) => {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<import('leaflet').Map | null>(null);
  const baseTileRef = useRef<import('leaflet').TileLayer | null>(null);
  const boundaryGroupRef = useRef<import('leaflet').LayerGroup | null>(null);
  const drawGroupRef = useRef<import('leaflet').LayerGroup | null>(null);
  const zoneGroupRef = useRef<import('leaflet').LayerGroup | null>(null);

  const [activeLayer, setActiveLayer] = useState<'esri' | 'hybrid' | 'satellite' | 'streets'>('esri');
  const [cssLoaded, setCssLoaded] = useState(false);

  // ── Drawing state ─────────────────────────────────────────────────────────
  const [isDrawing, setIsDrawing] = useState(false);
  const [drawnPoints, setDrawnPoints] = useState<[number, number][]>([]);
  const [showSaveModal, setShowSaveModal] = useState(false);

  // ── Search Geocoding state ────────────────────────────────────────────────
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [showSearchDropdown, setShowSearchDropdown] = useState(false);

  // ── Save Form state ───────────────────────────────────────────────────────
  const [newFieldName, setNewFieldName] = useState('');
  const [newFarmerName, setNewFarmerName] = useState('');
  const [newCropType, setNewCropType] = useState('Potato');
  const [newLocation, setNewLocation] = useState('Maharashtra, India');

  // ── Draggable panel state ─────────────────────────────────────────────────
  const [panelVisible, setPanelVisible] = useState(true);
  const [panelPos, setPanelPos] = useState({ x: -1, y: -1 }); // -1 means use CSS default
  const [isDraggingPanel, setIsDraggingPanel] = useState(false);
  const dragStartRef = useRef<{ mouseX: number; mouseY: number; panelX: number; panelY: number } | null>(null);
  const panelRef = useRef<HTMLDivElement>(null);

  // ── HUD tooltip state ─────────────────────────────────────────────────────
  const [showHelpTooltip, setShowHelpTooltip] = useState(false);
  const [showAdvancedInfo, setShowAdvancedInfo] = useState(false);

  // Active selected field object
  const activeField = useMemo(() => {
    return fields.find(f => f.id === selectedFieldId) || fields[0];
  }, [fields, selectedFieldId]);

  // Current boundary polygon: either currently drawing points, or selected field's boundary
  const currentPolygonCoords: [number, number][] = useMemo(() => {
    if (drawnPoints.length > 0) {
      return drawnPoints;
    }
    if (activeField && activeField.boundaryPolygon && activeField.boundaryPolygon.length > 0) {
      return activeField.boundaryPolygon;
    }
    return [];
  }, [drawnPoints, activeField]);

  // ── Turf.js Live Area & Perimeter Calculation ────────────────────────────
  const measurements = useMemo(() => {
    if (!currentPolygonCoords || currentPolygonCoords.length < 3) {
      return { areaM2: 0, areaHa: 0, perimeterM: 0, centroid: null };
    }

    try {
      // Turf expects coordinates as [longitude, latitude]
      const turfCoords = currentPolygonCoords.map(([lat, lng]) => [lng, lat]);
      // Close polygon ring
      const closedTurfCoords = [...turfCoords, turfCoords[0]];
      const poly = turf.polygon([closedTurfCoords]);

      const areaM2 = turf.area(poly);
      const areaHa = areaM2 / 10000;
      const perimeterM = turf.length(poly, { units: 'meters' });
      const centroidPt = turf.centroid(poly).geometry.coordinates; // [lng, lat]

      return {
        areaM2: Number(areaM2.toFixed(2)),
        areaHa: Number(areaHa.toFixed(3)),
        perimeterM: Number(perimeterM.toFixed(2)),
        centroid: [centroidPt[1], centroidPt[0]] as [number, number]
      };
    } catch (err) {
      console.warn('Turf calculation warning:', err);
      return { areaM2: 0, areaHa: 0, perimeterM: 0, centroid: null };
    }
  }, [currentPolygonCoords]);

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

      const initialCenter = currentPolygonCoords.length > 0 
        ? currentPolygonCoords[0] 
        : DEFAULT_CENTER;

      const map = L.map(mapContainerRef.current!, {
        center: initialCenter,
        zoom: 17,
        zoomControl: false,
        attributionControl: false,
      });

      L.control.zoom({ position: 'bottomright' }).addTo(map);

      // Default ESRI World Imagery nadir satellite tile layer
      const defaultTile = L.tileLayer(
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        { attribution: 'Imagery © Esri', maxZoom: 21, maxNativeZoom: 19, tileSize: 256 }
      );
      defaultTile.addTo(map);
      baseTileRef.current = defaultTile;

      // Create Layer Groups
      const boundaryGroup = L.layerGroup().addTo(map);
      const drawGroup = L.layerGroup().addTo(map);
      const zoneGroup = L.layerGroup().addTo(map);

      boundaryGroupRef.current = boundaryGroup;
      drawGroupRef.current = drawGroup;
      zoneGroupRef.current = zoneGroup;

      mapInstanceRef.current = map;
    });

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
        boundaryGroupRef.current = null;
        drawGroupRef.current = null;
        zoneGroupRef.current = null;
      }
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cssLoaded]);

  // ── Handle Map Click Events for Boundary Drawing ───────────────────────────
  useEffect(() => {
    const map = mapInstanceRef.current;
    if (!map) return;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const handleMapClick = (e: any) => {
      if (!isDrawing) return;
      const { lat, lng } = e.latlng;
      setDrawnPoints(prev => [...prev, [Number(lat.toFixed(6)), Number(lng.toFixed(6))]]);
    };

    if (isDrawing) {
      map.getContainer().style.cursor = 'crosshair';
      map.on('click', handleMapClick);
    } else {
      map.getContainer().style.cursor = '';
      map.off('click', handleMapClick);
    }

    return () => {
      map.off('click', handleMapClick);
    };
  }, [isDrawing]);

  // ── Render Drawn / Selected Field Boundaries on Map ────────────────────────
  useEffect(() => {
    if (!mapInstanceRef.current || !boundaryGroupRef.current || !drawGroupRef.current) return;

    import('leaflet').then((L) => {
      const boundaryGroup = boundaryGroupRef.current!;
      const drawGroup = drawGroupRef.current!;
      boundaryGroup.clearLayers();
      drawGroup.clearLayers();

      // Render Field Boundary (if not drawing)
      if (!isDrawing && currentPolygonCoords.length >= 3) {
        const poly = L.polygon(currentPolygonCoords, {
          color: '#FFC107',
          weight: 3.5,
          fillColor: '#FFC107',
          fillOpacity: 0.25,
          lineJoin: 'round',
          lineCap: 'round'
        }).addTo(boundaryGroup);

        poly.bindTooltip(
          `<div style="font-family:sans-serif;font-size:12px;padding:4px">
            <b style="color:#FFC107">${activeField?.name || 'Field Boundary'}</b><br/>
            Area: <b>${measurements.areaM2.toLocaleString()} m²</b> (${measurements.areaHa} ha)<br/>
            Perimeter: <b>${measurements.perimeterM} m</b>
          </div>`,
          { sticky: true }
        );

        // Add Google Earth style corner vertex handles (white circle with yellow core)
        currentPolygonCoords.forEach((pt, idx) => {
          const icon = L.divIcon({
            className: '',
            html: `<div style="
              width:14px; height:14px; border-radius:50%;
              background:#FFC107; border:3px solid #FFFFFF;
              box-shadow:0 2px 8px rgba(0,0,0,0.6);
              cursor:pointer;
            "></div>`,
            iconAnchor: [7, 7]
          });
          L.marker(pt, { icon, zIndexOffset: 200 })
            .bindTooltip(`Node ${idx + 1}: ${pt[0].toFixed(5)}°, ${pt[1].toFixed(5)}°`, { direction: 'top' })
            .addTo(boundaryGroup);
        });

        // Add midpoint handles along line segments
        for (let i = 0; i < currentPolygonCoords.length; i++) {
          const p1 = currentPolygonCoords[i];
          const p2 = currentPolygonCoords[(i + 1) % currentPolygonCoords.length];
          const midLat = (p1[0] + p2[0]) / 2;
          const midLng = (p1[1] + p2[1]) / 2;

          const midIcon = L.divIcon({
            className: '',
            html: `<div style="
              width:9px; height:9px; border-radius:50%;
              background:#FFFFFF; border:2px solid #FFC107;
              box-shadow:0 1px 4px rgba(0,0,0,0.4);
              opacity:0.95;
            "></div>`,
            iconAnchor: [4.5, 4.5]
          });
          L.marker([midLat, midLng], { icon: midIcon, zIndexOffset: 150 }).addTo(boundaryGroup);
        }
      }

      // Render Active Drawing Vertices and Lines
      if (isDrawing && drawnPoints.length > 0) {
        // Line segments
        if (drawnPoints.length >= 2) {
          L.polyline(drawnPoints, {
            color: '#FFC107',
            weight: 3.5,
            lineJoin: 'round',
            lineCap: 'round'
          }).addTo(drawGroup);
        }

        // Polygon preview if 3+ points
        if (drawnPoints.length >= 3) {
          L.polygon(drawnPoints, {
            color: '#FFC107',
            weight: 3,
            fillColor: '#FFC107',
            fillOpacity: 0.28
          }).addTo(drawGroup);
        }

        // Google Earth glowing node handles
        drawnPoints.forEach((pt, idx) => {
          const icon = L.divIcon({
            className: '',
            html: `<div style="
              width:15px; height:15px; border-radius:50%;
              background:#FFC107; border:3px solid #FFFFFF;
              box-shadow:0 0 10px rgba(255, 193, 7, 0.9), 0 2px 8px rgba(0,0,0,0.6);
              display:flex; align-items:center; justify-content:center;
            "></div>`,
            iconAnchor: [7.5, 7.5]
          });

          L.marker(pt, { icon, zIndexOffset: 300 })
            .bindTooltip(`Node ${idx + 1}: ${pt[0]}° N, ${pt[1]}° E`, { direction: 'top' })
            .addTo(drawGroup);
        });

        // Midpoint handles during drawing
        if (drawnPoints.length >= 2) {
          for (let i = 0; i < drawnPoints.length - 1; i++) {
            const p1 = drawnPoints[i];
            const p2 = drawnPoints[i + 1];
            const midLat = (p1[0] + p2[0]) / 2;
            const midLng = (p1[1] + p2[1]) / 2;

            const midIcon = L.divIcon({
              className: '',
              html: `<div style="
                width:9px; height:9px; border-radius:50%;
                background:#FFFFFF; border:2px solid #FFC107;
                box-shadow:0 1px 4px rgba(0,0,0,0.4);
              "></div>`,
              iconAnchor: [4.5, 4.5]
            });
            L.marker([midLat, midLng], { icon: midIcon, zIndexOffset: 150 }).addTo(drawGroup);
          }
        }
      }
    });
  }, [currentPolygonCoords, isDrawing, drawnPoints, activeField, measurements]);

  // ── Tile Layer Switching ───────────────────────────────────────────────────
  useEffect(() => {
    const map = mapInstanceRef.current;
    if (!map) return;

    import('leaflet').then((L) => {
      if (baseTileRef.current) map.removeLayer(baseTileRef.current);
      const urls: Record<string, { url: string; attr: string }> = {
        esri:      { url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', attr: 'Imagery © Esri' },
        hybrid:    { url: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}', attr: 'Hybrid © Google' },
        satellite: { url: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', attr: 'Satellite © Google' },
        streets:   { url: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', attr: 'Map © Google' },
      };
      const chosen = urls[activeLayer];
      const newTile = L.tileLayer(chosen.url, { attribution: chosen.attr, maxZoom: 21, maxNativeZoom: 19, tileSize: 256 });
      newTile.addTo(map);
      baseTileRef.current = newTile;
    });
  }, [activeLayer]);

  const searchMarkerRef = useRef<import('leaflet').Marker | null>(null);

  // ── Geocoding Search Handler (Nominatim + Photon Fallback + Direct Coords) ──
  const handleSearchSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const query = searchQuery.trim();
    if (!query) return;

    setIsSearching(true);
    setShowSearchDropdown(true);

    // Direct Lat/Lng parsing (e.g. "19.2842, 72.8715" or "19.2842 72.8715")
    const coordMatch = query.match(/^([-+]?\d+(?:\.\d+)?)[,\s]+([-+]?\d+(?:\.\d+)?)$/);
    if (coordMatch) {
      const lat = parseFloat(coordMatch[1]);
      const lon = parseFloat(coordMatch[2]);
      if (!isNaN(lat) && !isNaN(lon)) {
        const directResult: SearchResult = {
          place_id: Date.now(),
          display_name: `Coordinates: ${lat.toFixed(5)}°, ${lon.toFixed(5)}°`,
          lat: lat.toString(),
          lon: lon.toString(),
          type: 'coordinates'
        };
        setSearchResults([directResult]);
        handleSelectSearchResult(directResult);
        setIsSearching(false);
        return;
      }
    }

    try {
      let results: SearchResult[] = [];

      // 1. Nominatim Search
      try {
        const res = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=5`, {
          headers: { 'Accept-Language': 'en-US,en;q=0.9' }
        });
        if (res.ok) {
          const data = await res.json();
          if (Array.isArray(data) && data.length > 0) {
            results = data;
          }
        }
      } catch (err) {
        console.warn('Nominatim search failed, trying Photon:', err);
      }

      // 2. Photon API Fallback if Nominatim failed or returned empty
      if (results.length === 0) {
        try {
          const photonRes = await fetch(`https://photon.komoot.io/api/?q=${encodeURIComponent(query)}&limit=5`);
          if (photonRes.ok) {
            const photonData = await photonRes.json();
            if (photonData.features && Array.isArray(photonData.features)) {
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              results = photonData.features.map((f: any, idx: number) => ({
                place_id: idx + 99000,
                display_name: [f.properties.name, f.properties.city, f.properties.state, f.properties.country].filter(Boolean).join(', '),
                lat: f.geometry.coordinates[1].toString(),
                lon: f.geometry.coordinates[0].toString(),
                type: f.properties.osm_value || 'location'
              }));
            }
          }
        } catch (err) {
          console.warn('Photon search fallback error:', err);
        }
      }

      setSearchResults(results);

      if (results.length > 0) {
        handleSelectSearchResult(results[0]);
      }
    } catch (err) {
      console.error('Search failed:', err);
    } finally {
      setIsSearching(false);
    }
  };

  const handleSelectSearchResult = (res: SearchResult) => {
    const lat = parseFloat(res.lat);
    const lon = parseFloat(res.lon);
    const map = mapInstanceRef.current;

    if (map) {
      import('leaflet').then((L) => {
        if (searchMarkerRef.current) {
          map.removeLayer(searchMarkerRef.current);
        }
        const icon = L.divIcon({
          className: '',
          html: `<div style="
            width:18px; height:18px; border-radius:50%;
            background:#00E5FF; border:3px solid #FFFFFF;
            box-shadow:0 0 14px #00E5FF, 0 4px 12px rgba(0,0,0,0.6);
            cursor:pointer;
          "></div>`,
          iconAnchor: [9, 9]
        });
        const marker = L.marker([lat, lon], { icon, zIndexOffset: 1000 }).addTo(map);
        marker.bindPopup(`<div style="font-family:sans-serif;padding:2px"><b style="color:#0077C5">${res.display_name}</b></div>`).openPopup();
        searchMarkerRef.current = marker;
        map.flyTo([lat, lon], 17, { duration: 1.2 });
      });
    }

    setShowSearchDropdown(false);
    setSearchQuery(res.display_name.split(',')[0]);
  };

  // ── Drawing Controls ───────────────────────────────────────────────────────
  const startDrawing = () => {
    setIsDrawing(true);
    setDrawnPoints([]);
  };

  const undoLastNode = useCallback(() => {
    setDrawnPoints(prev => prev.slice(0, -1));
  }, []);

  const clearDrawing = useCallback(() => {
    setDrawnPoints([]);
    setIsDrawing(false);
  }, []);

  const finishDrawing = () => {
    if (drawnPoints.length < 3) {
      alert('Please click at least 3 points on the map to form a valid boundary polygon.');
      return;
    }
    setShowSaveModal(true);
  };

  // ── Draggable Panel Handlers ───────────────────────────────────────────────
  const handlePanelMouseDown = useCallback((e: React.MouseEvent) => {
    if (!panelRef.current) return;
    const rect = panelRef.current.getBoundingClientRect();
    dragStartRef.current = {
      mouseX: e.clientX,
      mouseY: e.clientY,
      panelX: panelPos.x === -1 ? rect.left : panelPos.x,
      panelY: panelPos.y === -1 ? rect.top : panelPos.y,
    };
    setIsDraggingPanel(true);
    e.preventDefault();
  }, [panelPos]);

  useEffect(() => {
    if (!isDraggingPanel) return;
    const handleMouseMove = (e: MouseEvent) => {
      if (!dragStartRef.current) return;
      const dx = e.clientX - dragStartRef.current.mouseX;
      const dy = e.clientY - dragStartRef.current.mouseY;
      setPanelPos({
        x: dragStartRef.current.panelX + dx,
        y: dragStartRef.current.panelY + dy,
      });
    };
    const handleMouseUp = () => {
      setIsDraggingPanel(false);
      dragStartRef.current = null;
    };
    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDraggingPanel]);

  // ── Save Field Asset Handler ───────────────────────────────────────────────
  const handleSaveFieldSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newFieldName.trim()) return;

    const newAsset: FieldAsset = {
      id: `FIELD-${Date.now().toString().slice(-4)}`,
      name: newFieldName,
      farmerName: newFarmerName || 'Local Farmer',
      location: newLocation,
      crop: newCropType,
      areaHa: measurements.areaHa,
      perimeterMeters: measurements.perimeterM,
      boundaryPolygon: drawnPoints,
      status: 'Normal',
      healthScore: 90,
      lastScan: 'Just now',
      zones: []
    };

    if (onSaveFieldAsset) {
      onSaveFieldAsset(newAsset);
    }

    setShowSaveModal(false);
    setIsDrawing(false);
    alert(`Field asset "${newFieldName}" (${measurements.areaHa} ha) successfully created!`);
  };

  // ── Auto-zoom & center map on active field boundary ───────────────────────
  useEffect(() => {
    const map = mapInstanceRef.current;
    if (!map || !currentPolygonCoords || currentPolygonCoords.length === 0) return;

    import('leaflet').then((L) => {
      if (currentPolygonCoords.length >= 3) {
        const bounds = L.latLngBounds(currentPolygonCoords);
        map.fitBounds(bounds, { padding: [35, 35], maxZoom: 18, animate: true });
      } else if (currentPolygonCoords.length === 1) {
        map.flyTo(currentPolygonCoords[0], 17, { duration: 0.8 });
      }
    });
  }, [activeField?.id, currentPolygonCoords]);

  // ── Mission Planner Waypoints Export Handler (.waypoints format) ─────────────
  const handleExportWaypoints = () => {
    if (!currentPolygonCoords || currentPolygonCoords.length < 1) {
      alert('No valid field boundary coordinates available to export.');
      return;
    }
    downloadWaypointsFile({
      fieldName: activeField?.name || newFieldName || 'Mission_Waypoints',
      farmerName: activeField?.farmerName || newFarmerName,
      altitudeMeters: 45,
      coordinates: currentPolygonCoords
    });
  };

  // ── KML Export Handler ─────────────────────────────────────────────────────
  const handleExportKML = () => {
    if (!currentPolygonCoords || currentPolygonCoords.length < 3) {
      alert('No valid field boundary polygon available to export.');
      return;
    }
    downloadKMLFile({
      fieldName: activeField?.name || newFieldName || 'Custom_Field_Mission',
      farmerName: activeField?.farmerName || newFarmerName,
      crop: activeField?.crop || newCropType,
      areaHa: measurements.areaHa,
      perimeterMeters: measurements.perimeterM,
      coordinates: currentPolygonCoords
    });
  };

  return (
    <div style={{ position: 'relative', width: '100%', height, borderRadius: '8px', border: '1px solid #B0B3AC', overflow: 'hidden' }}>

      {/* ── Top Bar: Search Bar & Satellite Layer Toggles ────────────────── */}
      <div style={{
        position: 'absolute', top: 12, left: 12, right: 12, zIndex: 1000,
        display: 'flex', gap: '10px', alignItems: 'center', justifyContent: 'space-between',
        pointerEvents: 'none'
      }}>
        {/* Nominatim Geocoding Search Input */}
        <div style={{ position: 'relative', flex: '1', maxWidth: '360px', pointerEvents: 'auto' }}>
          <form onSubmit={handleSearchSubmit} style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{
              display: 'flex', alignItems: 'center', width: '100%',
              background: 'rgba(15, 23, 18, 0.88)', backdropFilter: 'blur(10px)',
              border: '1px solid rgba(255, 255, 255, 0.18)', borderRadius: '6px',
              padding: '2px 8px', boxShadow: '0 4px 12px rgba(0,0,0,0.4)'
            }}>
              <Search size={15} color="#A8D5A2" style={{ marginRight: 6 }} />
              <input
                type="text"
                placeholder="Search location (e.g. Shree LR Tiwari College, Mira Road)..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onFocus={() => searchResults.length > 0 && setShowSearchDropdown(true)}
                style={{
                  width: '100%', background: 'transparent', border: 'none', outline: 'none',
                  color: '#FFFFFF', fontSize: '12px', padding: '6px 0', fontFamily: 'sans-serif'
                }}
              />
              {isSearching && <span style={{ color: '#A8D5A2', fontSize: '10px', fontFamily: 'monospace' }}>...</span>}
            </div>
          </form>

          {/* Search Suggestions Dropdown */}
          {showSearchDropdown && searchResults.length > 0 && (
            <div style={{
              position: 'absolute', top: '100%', left: 0, right: 0, marginTop: '4px',
              background: 'rgba(15, 23, 18, 0.95)', backdropFilter: 'blur(12px)',
              border: '1px solid rgba(255, 255, 255, 0.18)', borderRadius: '6px',
              boxShadow: '0 8px 24px rgba(0,0,0,0.5)', overflow: 'hidden', zIndex: 1001
            }}>
              {searchResults.map((res) => (
                <div
                  key={res.place_id}
                  onClick={() => handleSelectSearchResult(res)}
                  style={{
                    padding: '8px 12px', fontSize: '11px', color: '#E0E1D8', cursor: 'pointer',
                    borderBottom: '1px solid rgba(255,255,255,0.06)', display: 'flex', alignItems: 'center', gap: 6
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255,255,255,0.1)')}
                  onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
                >
                  <MapPin size={12} color="#00E5FF" />
                  <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                    {res.display_name}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Map Layer Switcher & Toolbar */}
        <div style={{
          display: 'flex', gap: '4px', pointerEvents: 'auto',
          background: 'rgba(15, 23, 18, 0.88)', backdropFilter: 'blur(10px)',
          padding: '3px', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.18)',
          boxShadow: '0 4px 12px rgba(0,0,0,0.4)'
        }}>
          {(['esri', 'hybrid', 'satellite', 'streets'] as const).map((layer) => (
            <button key={layer} onClick={() => setActiveLayer(layer)} style={{
              padding: '5px 10px', fontSize: '10px', fontWeight: 700,
              borderRadius: '4px', border: 'none', cursor: 'pointer',
              background: activeLayer === layer ? '#30432E' : 'transparent',
              color: activeLayer === layer ? '#A8D5A2' : 'rgba(255,255,255,0.65)',
              transition: 'all 0.15s', textTransform: 'uppercase', letterSpacing: '0.5px'
            }}>
              {layer === 'esri' ? '🛰 ESRI Ortho (Nadir)' : layer === 'hybrid' ? '🌍 Google Hybrid' : layer === 'satellite' ? '🛰 Google Sat' : '🗺 Map'}
            </button>
          ))}
        </div>
      </div>

      {/* ── Left Floating Drawing & Mission Planner Controls ────────────── */}
      {allowDrawing && (
        <div style={{
          position: 'absolute', top: 62, left: 12, zIndex: 999,
          display: 'flex', flexDirection: 'column', gap: 6,
          background: 'rgba(15, 23, 18, 0.90)', backdropFilter: 'blur(10px)',
          padding: '6px', borderRadius: '6px', border: '1px solid rgba(255,255,255,0.18)',
          boxShadow: '0 6px 16px rgba(0,0,0,0.45)'
        }}>
          {!isDrawing ? (
            <button
              onClick={startDrawing}
              style={{
                display: 'flex', alignItems: 'center', gap: 6, padding: '7px 12px',
                fontSize: '11px', fontWeight: 700, borderRadius: '4px',
                border: 'none', background: '#30432E', color: '#A8D5A2',
                cursor: 'pointer', transition: 'all 0.15s'
              }}
            >
              <Plus size={14} />
              <span>Draw Boundary</span>
            </button>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 5 }}>
              <div style={{ fontSize: '10px', fontFamily: 'monospace', color: '#FFD600', padding: '2px 4px', fontWeight: 'bold' }}>
                📍 Click map to place nodes ({drawnPoints.length})
              </div>
              <div style={{ display: 'flex', gap: 4 }}>
                <button
                  onClick={undoLastNode}
                  disabled={drawnPoints.length === 0}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 4, padding: '5px 8px',
                    fontSize: '10px', fontWeight: 600, borderRadius: '4px',
                    border: 'none', background: 'rgba(255,255,255,0.12)', color: '#FFF',
                    cursor: drawnPoints.length === 0 ? 'not-allowed' : 'pointer'
                  }}
                >
                  <Undo size={12} /> Undo
                </button>
                <button
                  onClick={clearDrawing}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 4, padding: '5px 8px',
                    fontSize: '10px', fontWeight: 600, borderRadius: '4px',
                    border: 'none', background: 'rgba(239,83,80,0.2)', color: '#FF8A80',
                    cursor: 'pointer'
                  }}
                >
                  <Trash2 size={12} /> Reset
                </button>
                <button
                  onClick={finishDrawing}
                  disabled={drawnPoints.length < 3}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 4, padding: '5px 10px',
                    fontSize: '10px', fontWeight: 700, borderRadius: '4px',
                    border: 'none', background: drawnPoints.length >= 3 ? '#2E7D32' : 'rgba(255,255,255,0.1)',
                    color: '#FFF', cursor: drawnPoints.length >= 3 ? 'pointer' : 'not-allowed'
                  }}
                >
                  <Check size={12} /> Finish
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ── Right Floating Draggable Measurement Panel ── */}
      {allowDrawing && panelVisible && (
        <div
          ref={panelRef}
          style={{
            position: 'absolute',
            top: panelPos.y === -1 ? 62 : undefined,
            right: panelPos.x === -1 ? 14 : undefined,
            left: panelPos.x !== -1 ? panelPos.x : undefined,
            ...(panelPos.y !== -1 ? { top: panelPos.y } : {}),
            zIndex: 999, width: '310px',
            background: 'rgba(18, 22, 26, 0.96)', backdropFilter: 'blur(16px)',
            padding: '0', borderRadius: '12px', border: '1px solid rgba(255, 255, 255, 0.14)',
            boxShadow: '0 12px 36px rgba(0,0,0,0.65)', color: '#FFFFFF', fontFamily: 'sans-serif',
            userSelect: 'none',
          }}
        >
          {/* Drag Handle / Panel Header */}
          <div
            onMouseDown={handlePanelMouseDown}
            style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '12px 16px 10px',
              borderBottom: '1px solid rgba(255,255,255,0.08)',
              cursor: isDraggingPanel ? 'grabbing' : 'grab',
              background: 'rgba(255,255,255,0.04)',
              borderRadius: '12px 12px 0 0',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: '14px', fontWeight: 700, color: '#FFFFFF' }}>
              <Ruler size={16} color="#FFC107" />
              <span>Path or polygon</span>
            </div>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              {/* Help ? button */}
              <div style={{ position: 'relative' }}>
                <button
                  onClick={(e) => { e.stopPropagation(); setShowHelpTooltip(v => !v); }}
                  onMouseDown={(e) => e.stopPropagation()}
                  title="Help"
                  style={{
                    width: 22, height: 22, borderRadius: '50%', border: '1px solid rgba(255,255,255,0.3)',
                    background: showHelpTooltip ? 'rgba(255,255,255,0.15)' : 'transparent',
                    color: 'rgba(255,255,255,0.8)', fontSize: '12px', fontWeight: 700,
                    cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
                    transition: 'all 0.15s'
                  }}
                >
                  ?
                </button>
                {showHelpTooltip && (
                  <div style={{
                    position: 'absolute', top: '28px', right: 0, zIndex: 1100,
                    background: '#1A2422', border: '1px solid rgba(255,255,255,0.15)',
                    borderRadius: '8px', padding: '10px 12px', width: '220px',
                    boxShadow: '0 8px 24px rgba(0,0,0,0.6)', fontSize: '11px', lineHeight: 1.5,
                    color: 'rgba(255,255,255,0.85)'
                  }}>
                    <div style={{ fontWeight: 700, marginBottom: 6, color: '#FFC107' }}>📐 How to use:</div>
                    <div>1. Click <b>Draw Boundary</b> on the left panel.</div>
                    <div>2. Click points on the satellite map to mark field corners.</div>
                    <div>3. Area &amp; perimeter update live as you draw.</div>
                    <div>4. Click <b>Finish</b> to complete and save.</div>
                    <div>5. Export as <b>.KML</b> for Mission Planner upload.</div>
                    <button
                      onMouseDown={(e) => e.stopPropagation()}
                      onClick={() => setShowHelpTooltip(false)}
                      style={{ marginTop: 8, fontSize: '10px', color: '#A8D5A2', background: 'none', border: 'none', cursor: 'pointer', padding: 0 }}
                    >Close ✕</button>
                  </div>
                )}
              </div>

              {/* Reset ↺ button */}
              <button
                onClick={(e) => { e.stopPropagation(); clearDrawing(); }}
                onMouseDown={(e) => e.stopPropagation()}
                title="Reset drawing"
                style={{
                  width: 22, height: 22, borderRadius: '50%', border: '1px solid rgba(255,255,255,0.25)',
                  background: 'transparent', color: 'rgba(255,200,100,0.9)', fontSize: '14px',
                  cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  transition: 'all 0.15s', lineHeight: 1
                }}
                onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255,255,255,0.12)')}
                onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
              >
                ↺
              </button>

              {/* Undo ↶ button */}
              <button
                onClick={(e) => { e.stopPropagation(); undoLastNode(); }}
                onMouseDown={(e) => e.stopPropagation()}
                title="Undo last node"
                style={{
                  width: 22, height: 22, borderRadius: '50%', border: '1px solid rgba(255,255,255,0.25)',
                  background: 'transparent', color: 'rgba(255,255,255,0.7)', fontSize: '14px',
                  cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  transition: 'all 0.15s', lineHeight: 1
                }}
                onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255,255,255,0.12)')}
                onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
              >
                ↶
              </button>

              {/* Close X button */}
              <button
                onClick={(e) => { e.stopPropagation(); setPanelVisible(false); }}
                onMouseDown={(e) => e.stopPropagation()}
                title="Close panel"
                style={{
                  width: 22, height: 22, borderRadius: '50%', border: '1px solid rgba(255,80,80,0.4)',
                  background: 'transparent', color: 'rgba(255,120,120,0.9)', fontSize: '13px',
                  cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  transition: 'all 0.15s'
                }}
                onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255,80,80,0.2)')}
                onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
              >
                <X size={12} />
              </button>
            </div>
          </div>

          {/* Panel Body */}
          <div style={{ padding: '14px 16px' }}>
            {/* Subtitle instructions */}
            <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.6)', marginBottom: '14px', lineHeight: 1.4 }}>
              Drag this panel anywhere · Click map points to draw a boundary
            </div>

            {/* Metrics List */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {/* Area Metric */}
              <div style={{ borderBottom: '1px solid rgba(255,255,255,0.08)', paddingBottom: '10px' }}>
                <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.55)', marginBottom: '3px' }}>Area</div>
                <div style={{ fontSize: '20px', fontWeight: 700, color: '#FFFFFF', letterSpacing: '-0.3px' }}>
                  {measurements.areaM2.toLocaleString()} m²
                </div>
                <div style={{ fontSize: '11px', color: '#FFC107', marginTop: '2px', fontWeight: 600 }}>
                  ({measurements.areaHa} ha)
                </div>
              </div>

              {/* Perimeter Metric */}
              <div style={{ borderBottom: '1px solid rgba(255,255,255,0.08)', paddingBottom: '10px' }}>
                <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.55)', marginBottom: '3px' }}>Perimeter</div>
                <div style={{ fontSize: '18px', fontWeight: 700, color: '#FFFFFF', letterSpacing: '-0.2px' }}>
                  {measurements.perimeterM.toLocaleString()} m
                </div>
              </div>

              {/* Advanced Measurements */}
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '12px', color: 'rgba(255,255,255,0.85)', fontWeight: 600 }}>
                  <span>Advanced measurements</span>
                  <div style={{ position: 'relative' }}>
                    <button
                      onClick={() => setShowAdvancedInfo(v => !v)}
                      title="What is advanced measurements?"
                      style={{
                        width: 18, height: 18, borderRadius: '50%', border: '1px solid rgba(255,255,255,0.3)',
                        background: showAdvancedInfo ? 'rgba(255,255,255,0.15)' : 'transparent',
                        color: 'rgba(255,255,255,0.6)', fontSize: '10px', fontWeight: 700,
                        cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center'
                      }}
                    >
                      i
                    </button>
                    {showAdvancedInfo && (
                      <div style={{
                        position: 'absolute', bottom: '24px', right: 0, zIndex: 1100,
                        background: '#1A2422', border: '1px solid rgba(255,255,255,0.15)',
                        borderRadius: '6px', padding: '8px 10px', width: '200px',
                        boxShadow: '0 8px 24px rgba(0,0,0,0.6)', fontSize: '11px', lineHeight: 1.5,
                        color: 'rgba(255,255,255,0.8)'
                      }}>
                        <div style={{ fontWeight: 700, marginBottom: 4, color: '#A8D5A2' }}>ℹ Advanced Measurements</div>
                        <div>Shows the <b>centroid coordinates</b> (geographic center) of the drawn polygon, plus estimated terrain elevation ranges derived from SRTM data.</div>
                        <div style={{ marginTop: 4, color: 'rgba(255,255,255,0.5)', fontSize: '10px' }}>Useful for Mission Planner takeoff point configuration.</div>
                      </div>
                    )}
                  </div>
                </div>
                {measurements.centroid && (
                  <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.55)', marginTop: '6px', fontFamily: 'monospace', lineHeight: 1.6 }}>
                    Centroid: {measurements.centroid[0].toFixed(5)}° N, {measurements.centroid[1].toFixed(5)}° E<br/>
                    Elevation Est: Min 15.7 m | Median 16.5 m | Max 17.38 m
                  </div>
                )}
                {!measurements.centroid && (
                  <div style={{ fontSize: '11px', color: 'rgba(255,255,255,0.3)', marginTop: '6px', fontStyle: 'italic' }}>
                    Draw a polygon to see centroid data
                  </div>
                )}
              </div>
            </div>

            {/* Action Buttons */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: '16px' }}>
              <button
                onClick={finishDrawing}
                disabled={!isDrawing && currentPolygonCoords.length < 3}
                style={{
                  width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                  padding: '10px 16px', fontSize: '13px', fontWeight: 700, borderRadius: '24px',
                  border: 'none', background: '#0077C5', color: '#FFFFFF',
                  cursor: (isDrawing && drawnPoints.length >= 3) || (!isDrawing && currentPolygonCoords.length >= 3) ? 'pointer' : 'not-allowed',
                  boxShadow: '0 4px 14px rgba(0, 119, 197, 0.4)', transition: 'all 0.15s',
                  opacity: (!isDrawing && currentPolygonCoords.length < 3) ? 0.5 : 1
                }}
                onMouseEnter={(e) => { if (!e.currentTarget.disabled) e.currentTarget.style.background = '#008BE3'; }}
                onMouseLeave={(e) => { e.currentTarget.style.background = '#0077C5'; }}
              >
                <Save size={15} /> Save to project
              </button>

              <button
                onClick={handleExportWaypoints}
                disabled={currentPolygonCoords.length < 1}
                style={{
                  width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
                  padding: '9px 16px', fontSize: '11px', fontWeight: 700, borderRadius: '20px',
                  border: 'none', background: 'linear-gradient(135deg, #00E5FF 0%, #00B0FF 100%)',
                  color: '#002635', cursor: currentPolygonCoords.length >= 1 ? 'pointer' : 'not-allowed',
                  boxShadow: '0 4px 14px rgba(0, 229, 255, 0.35)', transition: 'all 0.15s',
                  opacity: currentPolygonCoords.length < 1 ? 0.5 : 1
                }}
              >
                <Download size={13} /> Export .WAYPOINTS for Mission Planner
              </button>

              <button
                onClick={handleExportKML}
                disabled={currentPolygonCoords.length < 3}
                style={{
                  width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
                  padding: '7px 16px', fontSize: '10px', fontWeight: 600, borderRadius: '16px',
                  border: '1px solid rgba(255, 255, 255, 0.2)', background: 'rgba(255, 255, 255, 0.05)',
                  color: 'rgba(255, 255, 255, 0.8)', cursor: currentPolygonCoords.length >= 3 ? 'pointer' : 'not-allowed',
                  transition: 'all 0.15s', opacity: currentPolygonCoords.length < 3 ? 0.5 : 1
                }}
              >
                <Download size={12} /> Export .KML format
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Reopen panel button — shown when panel is closed */}
      {allowDrawing && !panelVisible && (
        <button
          onClick={() => setPanelVisible(true)}
          style={{
            position: 'absolute', top: 62, right: 14, zIndex: 999,
            display: 'flex', alignItems: 'center', gap: 6,
            padding: '7px 12px', fontSize: '11px', fontWeight: 700, borderRadius: '6px',
            border: '1px solid rgba(255,255,255,0.18)',
            background: 'rgba(18, 22, 26, 0.90)', backdropFilter: 'blur(10px)',
            color: '#FFC107', cursor: 'pointer',
            boxShadow: '0 4px 12px rgba(0,0,0,0.4)'
          }}
        >
          <Ruler size={13} /> Show Measurements
        </button>
      )}

      {/* ── Save Field Asset Modal Form ──────────────────────────────────── */}
      {showSaveModal && (
        <div style={{
          position: 'absolute', inset: 0, zIndex: 2000,
          background: 'rgba(0, 0, 0, 0.75)', backdropFilter: 'blur(8px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 16
        }}>
          <div style={{
            background: '#1A2118', border: '1px solid #4F6848', borderRadius: '8px',
            padding: '20px', width: '100%', maxWidth: '380px', margin: 'auto',
            boxShadow: '0 12px 32px rgba(0,0,0,0.6)', color: '#FFFFFF'
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
              <h3 style={{ margin: 0, fontSize: '15px', fontWeight: 700, color: '#A8D5A2' }}>
                Save Field Asset
              </h3>
              <button onClick={() => setShowSaveModal(false)} style={{ background: 'none', border: 'none', color: '#AAA', cursor: 'pointer' }}>
                <X size={16} />
              </button>
            </div>

            <form onSubmit={handleSaveFieldSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 10, fontSize: '12px' }}>
              <div>
                <label style={{ display: 'block', color: 'rgba(255,255,255,0.7)', marginBottom: 4 }}>Field Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Field E (Potato)"
                  value={newFieldName}
                  onChange={e => setNewFieldName(e.target.value)}
                  style={{
                    width: '100%', padding: '8px', borderRadius: '4px', background: '#121711',
                    border: '1px solid #30432E', color: '#FFF', outline: 'none'
                  }}
                />
              </div>

              <div>
                <label style={{ display: 'block', color: 'rgba(255,255,255,0.7)', marginBottom: 4 }}>Farmer Name</label>
                <input
                  type="text"
                  placeholder="e.g. Prakash Shinde"
                  value={newFarmerName}
                  onChange={e => setNewFarmerName(e.target.value)}
                  style={{
                    width: '100%', padding: '8px', borderRadius: '4px', background: '#121711',
                    border: '1px solid #30432E', color: '#FFF', outline: 'none'
                  }}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <div>
                  <label style={{ display: 'block', color: 'rgba(255,255,255,0.7)', marginBottom: 4 }}>Crop Type</label>
                  <input
                    type="text"
                    value={newCropType}
                    onChange={e => setNewCropType(e.target.value)}
                    style={{
                      width: '100%', padding: '8px', borderRadius: '4px', background: '#121711',
                      border: '1px solid #30432E', color: '#FFF', outline: 'none'
                    }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', color: 'rgba(255,255,255,0.7)', marginBottom: 4 }}>Area (Ha)</label>
                  <input
                    type="text"
                    disabled
                    value={`${measurements.areaHa} ha`}
                    style={{
                      width: '100%', padding: '8px', borderRadius: '4px', background: '#0F140F',
                      border: '1px solid #30432E', color: '#A8D5A2', fontFamily: 'monospace', fontWeight: 'bold'
                    }}
                  />
                </div>
              </div>

              <div>
                <label style={{ display: 'block', color: 'rgba(255,255,255,0.7)', marginBottom: 4 }}>Location / Region</label>
                <input
                  type="text"
                  value={newLocation}
                  onChange={e => setNewLocation(e.target.value)}
                  style={{
                    width: '100%', padding: '8px', borderRadius: '4px', background: '#121711',
                    border: '1px solid #30432E', color: '#FFF', outline: 'none'
                  }}
                />
              </div>

              <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
                <button
                  type="button"
                  onClick={() => setShowSaveModal(false)}
                  style={{
                    flex: 1, padding: '8px', borderRadius: '4px', border: '1px solid #30432E',
                    background: 'transparent', color: '#AAA', cursor: 'pointer'
                  }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  style={{
                    flex: 1, padding: '8px', borderRadius: '4px', border: 'none',
                    background: '#4F6848', color: '#FFF', fontWeight: 700, cursor: 'pointer'
                  }}
                >
                  Save Field
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Leaflet Container */}
      <div ref={mapContainerRef} style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }} />
    </div>
  );
};
