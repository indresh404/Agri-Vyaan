# AgriSwarm / Agrivyaan Web Operator Dashboard (SIH 2026)

> **Agent-to-Agent Handoff Document**: This README summarizes all architectural decisions, database integrations, GIS mapping capabilities, and file exports implemented to date. Use this file as context when continuing development with Antigravity AI or any coding assistant.

---

## 📌 Project Overview & Tech Stack

The **AgriSwarm Web Dashboard** is a enterprise-grade GIS operator portal built for scheduling, tracking, and analyzing autonomous drone scan missions across agricultural fields.

* **Frontend Architecture**: React 18 + TypeScript + Vite
* **Styling System**: CSS Modules / Custom Design System + Lucide React Icons
* **GIS & Spatial Mapping**: Leaflet.js + Turf.js (Geospatial calculations)
* **Backend & Database**: Supabase (PostgreSQL, Realtime Subscriptions, Row Level Security)
* **UAV Mission Export**: QGroundControl / Mission Planner `.waypoints` (WPL 110 format) & KML format

---

## 🗄️ Database & Supabase Integration

### Credentials & Project Config
* **Supabase Project URL**: `https://zxclczrpyrslkmoqmwhg.supabase.co`
* **Anon Key**: Configured in `src/lib/supabase.ts` (with fallback to `.env` variables `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`).

### Primary Database Schemas Integrated
1. **`bookings`**: `booking_id` (UUID), `fid` (Farmer ID), `fieldid` (Field ID), `field_name`, `booking_datetime`, `status` (`Pending`, `Accepted`, `Scheduled`, `In Progress`, `Completed`, `Rejected`).
2. **`fields`**: `fieldid`, `fid`, `user_name`, `field_name`, `field_number`, `crop_name`, `area` (ha), `latitude`, `longitude`.
3. **`users`**: `fid`, `name`, `phone`, `location`, `email`, `main_crop`.

### Synchronization Strategy
* **Parallel Data Loading**: Initial mount performs `Promise.all` across `bookings`, `fields`, and `users` tables (`src/lib/supabase.ts`).
* **Realtime Listener**: `subscribeToBookings()` sets up a live WebSocket channel (`agrivyaan-bookings-realtime`) listening for `INSERT` and `UPDATE` events on the `bookings` table. Bookings submitted by farmers via mobile app appear live without manual refreshes.
* **Optimistic UI Updates**: Status changes (Accept / Reject) immediately update React local state synchronously, followed by an async `updateBookingStatus()` write to Supabase.

---

## 🛰️ GIS Mapping & Spatial Boundary Planner (`MapLibreSpatialMap.tsx`)

* **Multi-Layer Satellite Support**: Supports Esri World Imagery (Nadir), Google Hybrid, Google Satellite, and Google Streets.
* **Live Turf.js Area & Perimeter**: Real-time metric calculation ($m^2$, ha, perimeter meters, and centroid coordinates).
* **Dual-Engine Geocoding Search**:
  * Direct coordinate parsing (`lat, lng` or `lat lng`).
  * Primary: Nominatim OpenStreetMap API with custom headers.
  * Fallback: Photon Komoot API for fallback geocoding.
  * Search results place a cyan glowing Leaflet marker with place popup and smooth `flyTo` animation.
* **Automatic Map Auto-Zoom**: When selecting a field or booking, `useEffect` triggers `map.fitBounds()` over the target polygon boundary coordinates.
* **Conditional HUD Panel**: The black measurement HUD panel ("Path or polygon") only renders when `allowDrawing={true}`. In request preview drawers (`allowDrawing={false}`), it is hidden for a clean satellite view.

---

## 🚁 Mission Planner `.waypoints` Export (`waypointsExport.ts`)

* **WPL 110 Protocol**: Converts polygon field boundaries into standard Mission Planner / QGroundControl survey waypoints format.
* **Format Structure**:
  * `0`: Home position (ground level 0m).
  * `1..N`: Mission survey waypoints at relative target altitude (default: 45m).
* **Export Action**: Integrated directly into map control panels (**Export .WAYPOINTS for Mission Planner**).

---

## 📋 Requests View (`RequestsView.tsx`)

* **Formatted UI Table**:
  * **Request ID**: Truncated monospace code badge (`5539589f...`) with full UUID tooltip on hover.
  * **Scan Type**: Clean `white-space: nowrap` pill badges (`🌿 Crop Health Scan`, `💧 Moisture/Soil Scan`, `🛰 Full Field Analysis`).
  * **Boundary Planner Navigation**: Action button **"Open in Mission Boundary Planner"** and field links (`DY ↗`) navigate to the `fields` GIS workspace with the field pre-selected.

---

## 📂 Key Source Files & Responsibilities

| File Path | Description |
| :--- | :--- |
| `src/lib/supabase.ts` | Supabase JS client, database queries, status update helpers, and realtime subscriptions. |
| `src/lib/waypointsExport.ts` | Mission Planner WPL 110 `.waypoints` file generator and trigger download utility. |
| `src/lib/kmlExport.ts` | Legacy KML polygon export utility for Google Earth. |
| `src/components/gis/MapLibreSpatialMap.tsx` | Leaflet GIS interactive satellite map, drawing tools, geocoding search, and auto-zoom. |
| `src/components/views/RequestsView.tsx` | Farmer scan request queue table, detail drawer preview map, and status workflows. |
| `src/components/views/FieldsView.tsx` | Field Assets grid and full-screen GIS boundary planner workspace. |
| `src/App.tsx` | Top-level state management, navigation routing, and Supabase data orchestration. |

---

## 🚀 Running & Building

### Development Mode
```bash
npm run dev
```

### Production Build
```bash
npm run build
```
*(Runs `tsc -b && vite build` — verified zero errors).*

---

## 🧭 Roadmap & Next Steps for AI Agent
1. **Multi-Drone Swarm Route Allocation**: Add auto-grid survey route generation inside the polygon boundary.
2. **Offline Caching**: Enhance service worker precaching for field telemetry offline mode.
3. **Automated Mission Upload**: Direct MAVLink / Web serial connection to drone telemetry radio.
