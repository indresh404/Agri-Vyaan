# AgriSwarm Operator Platform — Complete Build Documentation

> **Generated:** September 7, 2026 · Repository: `d:\SIH2026`
> This document captures every file, component, data structure, service, and feature that exists in the web application as of this date. Nothing is omitted.

---

## 1. Project Overview

**AgriSwarm** is a full-stack operator-facing web application built for **SIH 2026** (Smart India Hackathon). It is a **drone swarm agricultural crop intelligence platform** designed for drone operators who manage multiple farmers' field scan requests across the Thane/Kalyan/Pune belt of Maharashtra, India.

The system models the complete lifecycle of a drone-based crop health assessment:

```
Farmer Request → Operator Acceptance → Drone Mission Scheduling →
In-Flight Telemetry Tracking → AI Anomaly Detection (Two-Stage) →
Human Validation → Crop Intelligence Report → PDF Export
```

The platform is specifically designed around **potato crop** (Solanum tuberosum) as the primary crop focus for SIH 2026, with the field area modelled on **Ambegaon, Pune District** potato farming.

---

## 2. Repository Structure

```
d:\SIH2026\
├── README.md
├── web application/          ← React/TypeScript SPA (main focus)
├── app/                      ← Flutter mobile app (skeleton only)
├── docs/
│   ├── About Project.md      ← Empty placeholder
│   └── BUILT_SO_FAR.md       ← This file
├── drone/
│   └── About Drone.md        ← Drone hardware documentation stub
└── edge AI/
    └── About Edge computation.md  ← Edge AI documentation stub
```

---

## 3. Web Application — Technical Stack

**Location:** `d:\SIH2026\web application\`

| Item | Technology |
|---|---|
| Framework | React 19.2.8 |
| Language | TypeScript 6.0 |
| Build Tool | Vite 8.2.2 |
| CSS Framework | TailwindCSS 4.3.3 (via `@tailwindcss/vite` plugin) |
| Icon Library | Lucide React 1.34.0 |
| GIS Mapping | Leaflet 1.9.4 (dynamically imported) |
| Map Tiles | Google Satellite / Street tiles via Leaflet TileLayer |
| Spatial Analysis | Turf.js 7.4.0 |
| Backend/Realtime | Supabase JS Client 2.112.4 |
| PDF Generation | jsPDF 4.2.1 (lazy imported on export) |
| PWA | vite-plugin-pwa 1.3.0 |
| Linting | ESLint 10.9.0 + typescript-eslint + react-hooks plugin |

### Vite Config (`vite.config.ts`)
- Plugins: `@vitejs/plugin-react`, `@tailwindcss/vite`, `VitePWA`
- Path alias: `@` → `./src`
- PWA manifest: App name `AgriSwarm Operator Platform`, theme color `#30432E`, display `standalone`, background `#F6F6F2`
- PWA icons: `pwa-192x192.png`, `pwa-512x512.png`
- Workbox caches: `**/*.{js,css,html,ico,png,svg}`

### Scripts
- `npm run dev` → Vite dev server
- `npm run build` → `tsc -b && vite build`
- `npm run preview` → Vite preview
- `npm run lint` → ESLint

---

## 4. Source File Tree

```
src/
├── main.tsx                     ← React root mount
├── App.tsx                      ← Root component, state management, routing
├── App.css                      ← Component-scoped styles (minimal)
├── index.css                    ← Global design system CSS
├── assets/                      ← Static assets
├── types/
│   └── index.ts                 ← All TypeScript type definitions
├── data/
│   └── mockData.ts              ← All mock data (588 lines)
├── lib/
│   ├── supabase.ts              ← Supabase client + auth + realtime + storage
│   └── reportlabPdfService.ts  ← jsPDF PDF export service (314 lines)
└── components/
    ├── layout/
    │   ├── Sidebar.tsx          ← Left navigation sidebar
    │   └── Header.tsx           ← Top breadcrumb + search + notifications bar
    ├── views/
    │   ├── DashboardView.tsx    ← Main dashboard (328 lines)
    │   ├── RequestsView.tsx     ← Farmer requests management (384 lines)
    │   ├── FieldsView.tsx       ← Field assets grid (162 lines)
    │   ├── FieldDetailsView.tsx ← Field deep-dive workspace (388 lines)
    │   ├── OperationsView.tsx   ← Drone operations list (114 lines)
    │   ├── OperationDetailsView.tsx ← Mission detail + timeline (220 lines)
    │   ├── ValidationView.tsx   ← AI anomaly validation workspace (510 lines)
    │   ├── ReportsView.tsx      ← Crop intelligence reports (465 lines)
    │   ├── AnalyticsView.tsx    ← KPI analytics dashboard (174 lines)
    │   ├── WeatherView.tsx      ← Weather & spraying conditions (236 lines)
    │   ├── LibraryView.tsx      ← Agricultural knowledge library (265 lines)
    │   ├── ActivityView.tsx     ← System audit log (53 lines)
    │   └── SettingsView.tsx     ← System settings panel (95 lines)
    └── gis/
        ├── MapLibreSpatialMap.tsx ← Main interactive map (423 lines)
        └── FieldMap.tsx         ← Alternate/legacy field map (15 KB)
```

---

## 5. Type System (`src/types/index.ts`)

Every data shape in the application is typed. All types are defined in a single file and exported:

### Navigation
```typescript
type NavTab = 'dashboard' | 'requests' | 'fields' | 'field-details' |
              'operations' | 'operation-details' | 'validation' |
              'reports' | 'analytics' | 'weather' | 'library' |
              'activity' | 'settings'
```

### Status Enumerations
| Type | Values |
|---|---|
| `PriorityLevel` | `'High' \| 'Medium' \| 'Low'` |
| `RequestStatus` | `'Pending' \| 'Accepted' \| 'Scheduled' \| 'In Progress' \| 'Completed' \| 'Rejected'` |
| `OperationStatus` | `'Planned' \| 'In Progress' \| 'Completed' \| 'Failed'` |
| `DroneScanStatus` | `'REQUESTED' \| 'SCHEDULED' \| 'DRONE ASSIGNED' \| 'IN PROGRESS' \| 'PROCESSING' \| 'AI ANALYSIS' \| 'VERIFICATION' \| 'REPORT READY'` |
| `VerificationStatus` | `'PENDING' \| 'UNDER REVIEW' \| 'VERIFIED' \| 'REQUIRES REVIEW'` |
| `ZoneHealthStatus` | `'Healthy' \| 'Warning' \| 'High Priority' \| 'Low moisture' \| 'Possible nutrient stress' \| 'Disease risk'` |
| `FindingStatus` | `'Pending Validation' \| 'Confirmed' \| 'Rejected' \| 'Inspection Scheduled'` |

### Data Interfaces

**`FarmerRequest`** — Represents a service request from a farmer:
- `id`, `farmerName`, `fieldId`, `fieldName`, `location`, `requestedDate`
- `priority: PriorityLevel`
- `status: RequestStatus`
- `notes: string` (farmer-provided description)
- `areaHa: number`, `crop: string`, `previousOperationsCount: number`

**`SensorReading`** — Ground sensor telemetry reading:
- `sensorName`, `currentValue`, `minNormal`, `maxNormal`, `unit`
- `status: 'LOW' | 'NORMAL' | 'HIGH'`
- `history: number[]` (last 4 readings)

**`ZoneData`** — Represents a single spatial zone within a field (6×6 grid):
- `id`, `zoneNumber`, `gridRow`, `gridCol`
- `status: ZoneHealthStatus`
- `soilMoisture: number`, `temperature?: number`
- `stressType?: string`, `confidence?: number`
- `gpsCoords: string` (e.g. `"19.2184, 72.9781"`)
- `lastScanned: string`
- `recommendedAction?: string`, `aiExplanation?: string`

**`ActionEntry`** — A recorded field intervention:
- `id`, `fieldId`, `title`, `category: 'Water' | 'Pest' | 'Nutrient' | 'General'`
- `zoneName`, `date`, `notes`, `isCompleted`
- `beforeState?: Record<string, string>`, `afterState?: Record<string, string>`

**`FieldAsset`** — A registered agricultural field:
- `id`, `name`, `farmerName`, `location`, `crop`, `areaHa`
- `sowingDate?: string`, `cropStage?: string`
- `status: 'Normal' | 'Attention Required' | 'Scanning' | 'Pending Baseline'`
- `healthScore: number`, `prevHealthScore?: number`
- `lastScan: string`, `moistureStatus?: 'LOW' | 'NORMAL' | 'HIGH'`
- `activeAlerts?: string[]`
- `zones: ZoneData[]`, `sensors?: SensorReading[]`

**`DroneOperation`** — A drone scan mission:
- `id`, `requestId`, `farmerName`, `fieldName`, `droneId`
- `scanType: 'Crop Health Scan' | 'Moisture/Soil Scan' | 'Full Field Analysis'`
- `operatorName`, `startTime`, `progressPercent: number`
- `status: OperationStatus`, `scanLifecycleStatus: DroneScanStatus`
- `verificationStatus: VerificationStatus`
- `batteryLevel?: number`, `altitudeMeters?: number`, `speedMs?: number`
- `totalAreaScannedHa?: number`
- `timeline: { stage, timestamp, completed, current }[]` — 7-stage lifecycle

**`CropFinding`** — An AI-detected crop anomaly:
- `id`, `fieldId`, `fieldName`, `zoneId`, `status: FindingStatus`
- `findingType: string`, `confidencePercent: number`, `gpsCoords: string`
- `timestamp`, `operationId`, `farmerName`
- `soilMoisturePercent: number`, `notes: string`, `recommendedAction: string`
- `rgbImageUrl?: string`, `multispectralUrl?: string`
- `probabilities?: { disease, waterStress, nutrient, healthy }` — 4-class probability
- `stageAI?: 'Stage 1 (Quick Scan)' | 'Stage 2 (Rescan Close-Up)'`
- `inspectionReductionPercent?: number`

**`AssessmentReport`** — A completed crop intelligence report:
- `id`, `requestId`, `operationId`, `farmerName`, `fieldName`
- `generatedDate`, `status: 'Ready' | 'Sent' | 'Draft'`
- `healthIndexScore: number`, `priorityRecommendations: string[]`

**`WeatherForecast`** — A single day weather forecast:
- `dayName`, `date`, `temperature`, `rainProbability`, `humidity`, `windSpeed`
- `weatherCondition: 'Sunny' | 'Rainy' | 'Cloudy' | 'Overcast'`
- `sprayingCondition: 'GOOD' | 'MODERATE' | 'AVOID'`
- `aiSummary: string`, `bestWindow: string`

**`LibraryItem`** — A knowledge library entry:
- `id`, `type: 'Crop' | 'Pest' | 'Disease'`, `name`, `description`
- `details: string[]`, `symptoms?: string`, `prevention?: string`, `management?: string`
- `affectedCrops: string[]`

**`ActivityItem`** — An audit log entry:
- `id`, `timestamp`, `title`, `description`
- `category: 'request' | 'operation' | 'validation' | 'report' | 'system' | 'action'`

---

## 6. Mock Data (`src/data/mockData.ts`) — 588 Lines

All application data is seeded from this single file. It exports:

### `MOCK_REQUESTS` — 5 Farmer Requests
| ID | Farmer | Field | Crop | Area | Priority | Status |
|---|---|---|---|---|---|---|
| REQ-1024 | Ramesh Kumar | Field A | Potato | 4.8 ha | High | In Progress |
| REQ-1025 | Suresh Patil | Field B | Potato | 6.2 ha | Medium | Completed |
| REQ-1026 | Anil Deshmukh | Field C | Potato | 3.5 ha | Low | Completed |
| REQ-1027 | Sunita Jadhav | Field D | Potato | 5.1 ha | High | Pending |
| REQ-1028 | Prakash Shinde | Field E | Potato | 7.0 ha | Medium | Scheduled |

Notes include realistic agronomic descriptions: Late Blight symptoms, Early Blight lesions, Black Scurf suspicion, NDVI baseline requests.

### `MOCK_FIELDS` — 4 Field Assets (FIELD-A to FIELD-D)
Each field uses a `generateZones()` helper that creates a **6×6 = 36 zone grid** spanning GPS coordinates across the Ambegaon potato field (`19.0537–19.0549°N`, `73.8812–73.8827°E`). Zone overrides inject specific stress conditions:

- **FIELD-A** (4.8 ha, Ramesh Kumar, Thane):
  - Zone 2 override: `Low moisture` (27%), confidence 91%, stress type: *tuber stress risk*
  - Zone 3 override: `Possible nutrient stress` (45% moisture), confidence 78%
  - Zone 27 override: `High Priority` (23% moisture), Late Blight Phytophthora infestans, confidence 91%
  - Sensors: Soil Moisture LOW (27%), Temperature NORMAL (32°C), Humidity NORMAL (65%)
  - Health Score: 78, Previous: 84

- **FIELD-B** (6.2 ha, Suresh Patil, Kalyan):
  - Zone 2 override: `Disease risk`, Early Blight Alternaria solani, confidence 82%
  - Sensors: NORMAL across all three sensors
  - Health Score: 84

- **FIELD-C** (3.5 ha, Anil Deshmukh, Bhiwandi):
  - No overrides — all 36 zones are `Healthy`
  - Health Score: 91

- **FIELD-D** (5.1 ha, Sunita Jadhav, Panvel):
  - Zone 8 override: `Warning`, Black Scurf Rhizoctonia solani, confidence 86%, moisture 18%
  - Health Score: 68

### `MOCK_OPERATIONS` — 4 Drone Operations
| ID | Farmer | Field | Drone | Scan Type | Progress | Status |
|---|---|---|---|---|---|---|
| OP-0142 | Ramesh Kumar | Field A | Drone-01 | Crop Health Scan | 68% | In Progress |
| OP-0141 | Suresh Patil | Field B | Drone-02 | Full Field Analysis | 100% | Completed |
| OP-0140 | Anil Deshmukh | Field C | Drone-03 | Moisture/Soil Scan | 100% | Completed |
| OP-0139 | Sunita Jadhav | Field D | Drone-01 | Crop Health Scan | 0% | Planned |

OP-0142 has full 7-stage timeline: `REQUESTED → DRONE ASSIGNED → IN PROGRESS` (current) → `PROCESSING → AI ANALYSIS → VERIFICATION → REPORT READY`.

### `MOCK_FINDINGS` — 3 AI Crop Findings
| ID | Field | Zone | Finding Type | Confidence | Status |
|---|---|---|---|---|---|
| FND-027 | Field A | Zone 2 | Potato tuber stress — Low moisture / Irrigation deficit | 91% | Pending Validation |
| FND-014 | Field A | Zone 27 | Late Blight (Phytophthora infestans) — Critical Risk | 78% | Pending Validation |
| FND-008 | Field D | Zone 8 | Black Scurf (Rhizoctonia solani) — Suspected perimeter stress | 86% | Pending Validation |

All findings include 4-class probability breakdown (disease, waterStress, nutrient, healthy), Stage 2 Rescan label, and `inspectionReductionPercent` metric.

### `MOCK_REPORTS` — 3 Assessment Reports
| ID | Field | Health Score | Status |
|---|---|---|---|
| REP-904 | Field A (Ramesh Kumar) | 78 | Draft |
| REP-903 | Field B (Suresh Patil) | 84 | Ready |
| REP-902 | Field C (Anil Deshmukh) | 91 | Sent |

### `MOCK_WEATHER` — 6-Day Forecast (27 Aug – 01 Sep 2026)
Thane, Maharashtra weather data with spraying condition advice:
- **Today (27 Aug):** 32°C, Sunny, Rain 10%, GOOD spray window, best: 6–9 AM
- **Tomorrow (28 Aug):** 28°C, Rainy, Rain 75%, AVOID spraying
- **Fri (29 Aug):** 29°C, Cloudy, Rain 45%, MODERATE
- **Sat–Mon:** Sunny/Cloudy, GOOD conditions

### `MOCK_LIBRARY` — 7 Knowledge Library Entries
- **Crops:** Kufri Jyoti, Kufri Pukhraj, Kufri Bahar (all Potato varieties)
- **Diseases:** Late Blight (Phytophthora infestans), Early Blight (Alternaria solani), Black Scurf & Rhizoctonia Stem Canker
- **Pests:** Potato Aphids (Myzus persicae)

Each entry includes description, details array, symptoms, prevention, management text, and affected crops list.

### `MOCK_ACTIVITIES` — 7 Activity Log Entries
Chronological audit trail from 09:15 AM to 11:20 AM covering: request acceptance, operation launch, processing completion, validation queue updates, finding logs, report generation, action sync.

### `MOCK_ACTIONS` — 2 Field Action Records
- `action_p1`: Potato disease boundary check in Field B, Zone 2 (completed)
- `action_p2`: NPK applicator in Field A, Zone 3 (completed)

---

## 7. Global CSS Design System (`src/index.css`) — 301 Lines

The entire visual design system is defined in CSS custom properties (`--var`):

### Color Tokens
```css
--bg-app: #F5F6F2           /* Off-white application background */
--bg-surface: #FFFFFF        /* White surface/card background */
--text-primary: #1C201A      /* Near-black primary text */
--text-secondary: #5F645D    /* Muted green-grey secondary text */
--text-muted: #8A9087        /* Disabled/placeholder text */
--border-color: #D8D9D2      /* Main border color */
--border-subtle: #E8E9E3     /* Light inner border */
--green-primary: #435C3C     /* Primary brand green */
--green-dark: #2A3B27        /* Dark hover green */
--green-light: #E7EFE5       /* Light green background tint */
--green-hover: #384E32       /* Hover state */
--warning-gold: #B07E28      /* Warning/amber color */
--warning-light: #FBF4E6     /* Warning background */
--critical-red: #AF413A      /* Error/alert red */
--critical-light: #FAF0EC    /* Error background tint */
--info-blue: #4B6B80         /* Info blue */
--info-light: #EBF1F5        /* Info background tint */
--success-green: #4A6944     /* Success state */
--hover-bg: #EEF0EA          /* Hover state background */
```

### Typography
- `--font-sans`: Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial
- `--font-mono`: JetBrains Mono, SFMono-Regular, Consolas, Liberation Mono, Menlo
- Base font size: 13px, line-height: 1.5

### Radius & Shadow Tokens
- `--radius-sm: 4px`, `--radius-md: 6px`, `--radius-lg: 8px`
- `--shadow-xs`, `--shadow-sm`, `--shadow-md`

### Component CSS Classes
All reusable CSS classes are defined as utility classes (not component-scoped):

**Badges:**
- `.badge` — base badge layout
- `.badge-in-progress` / `.badge-running` — blue
- `.badge-completed` / `.badge-success` — green
- `.badge-pending` / `.badge-planned` — amber
- `.badge-validation` / `.badge-critical` / `.badge-failed` — red
- `.badge-neutral` — grey

**Tables:**
- `.op-table-container` — white bordered container with overflow-x
- `.op-table` — full-width borderless table with striping on hover
- `.op-table tr.selected td` — green-tinted selected row

**Form Controls:**
- `.op-input` — white bordered input with green focus ring
- `.op-select` — matching styled dropdown

**Buttons:**
- `.op-btn` — base button (flex, gap, padding)
- `.op-btn-primary` — green background, white text
- `.op-btn-secondary` — white background, grey border
- `.op-btn-danger` — red background
- `.op-btn-sm` — smaller padding variant

**Cards:**
- `.op-card` — white card with hover border-color transition

**Animation:**
- `.pulse-dot` — animated green pulsing dot for live operational status indicator

---

## 8. Application Root (`src/App.tsx`) — 307 Lines

The single root component that owns **all application state** and **all navigation routing**.

### State Managed
```typescript
activeTab: NavTab            // Current view ("dashboard", "requests", etc.)
searchQuery: string          // Global search string (threaded to relevant views)
requests: FarmerRequest[]    // All farmer requests (initialized from MOCK_REQUESTS)
fields: FieldAsset[]         // All field assets (initialized from MOCK_FIELDS)
operations: DroneOperation[] // All drone operations (initialized from MOCK_OPERATIONS)
findings: CropFinding[]      // All AI findings (initialized from MOCK_FINDINGS)
reports: AssessmentReport[]  // All reports (initialized from MOCK_REPORTS)
activities: ActivityItem[]   // Audit log (initialized from MOCK_ACTIVITIES)
weather: WeatherForecast[]   // 6-day weather (initialized from MOCK_WEATHER)
library: LibraryItem[]       // Knowledge library (initialized from MOCK_LIBRARY)
selectedFieldId: string      // Currently selected field (default: 'FIELD-A')
selectedOpId: string         // Currently selected operation (default: 'OP-0142')
```

### Supabase Realtime Subscription
On mount, `useEffect` calls `subscribeToRealtimeTelemetry()`:
- Listens to `UPDATE` events on `operations` table → merges `updatedOp` into `operations` state
- Listens to `INSERT` events on `findings` table → prepends `newFinding` to `findings` state
- Cleans up on unmount via returned unsubscribe function

### Handler Functions (All Mutate State + Append Activity Log)

**`handleAcceptRequest(reqId)`** — Sets request status to `'Accepted'`, logs activity

**`handleRejectRequest(reqId)`** — Sets request status to `'Rejected'`, logs activity

**`handleScheduleOperation(req, droneId, startTime)`** — Creates a new `DroneOperation` with:
- Auto-generated ID (`OP-0{143 + operations.length}`)
- Full 7-stage timeline pre-populated
- Sets linked request status to `'Scheduled'`
- Prepends new operation to operations list
- Logs scheduling activity

**`handleConfirmFinding(findingId)`** — Sets finding status to `'Confirmed'`, logs validation activity

**`handleRejectFinding(findingId)`** — Sets finding status to `'Rejected'`, logs false-positive activity

**`handleSelectField(fieldId)`** — Sets `selectedFieldId`, navigates to `'field-details'`

**`handleSelectOperation(opId)`** — Sets `selectedOpId`, navigates to `'operation-details'`

### Computed Values
```typescript
selectedField = fields.find(f => f.id === selectedFieldId) || fields[0]
selectedOperation = operations.find(o => o.id === selectedOpId) || operations[0]
pendingValidationsCount = findings.filter(f => f.status === 'Pending Validation').length
pendingRequestsCount = requests.filter(r => r.status === 'Pending').length
```

### Layout Structure
```
<div style="display:flex; width:100vw; height:100vh; overflow:hidden; backgroundColor:#F6F6F2">
  <Sidebar />          ← Fixed 230px wide left column
  <div flex:1>
    <Header />         ← 48px fixed top bar
    <main>             ← Scrollable content area
      {activeTab === 'dashboard' && <DashboardView />}
      {activeTab === 'requests' && <RequestsView />}
      ... (13 views total)
    </main>
  </div>
</div>
```

---

## 9. Layout Components

### Sidebar (`src/components/layout/Sidebar.tsx`) — 209 Lines

Fixed left-side navigation panel (230px wide). Receives `activeTab`, `onNavigate`, `pendingValidationCount`, `pendingRequestsCount`.

**Navigation Sections (3 groups):**

**OPERATIONS:**
- Dashboard (`LayoutDashboard` icon)
- Requests (`FileText` icon) — shows `pendingRequestsCount` badge
- Fields (`Map` icon) — also highlights when on `field-details`
- Operations (`Radio` icon) — also highlights when on `operation-details`
- Validation (`CheckCircle2` icon) — shows `pendingValidationsCount` badge

**INSIGHTS:**
- Reports (`FileCheck` icon)
- Analytics (`BarChart3` icon)
- Weather (`Cloud` icon)
- Library (`BookOpen` icon)

**SYSTEM:**
- Activity (`Activity` icon)
- Settings (`Settings` icon)

Active state: green-tinted left border (`3px solid #4F6848`), `#EBF0E9` background, `#20231F` text.

**Brand Header:** "AS" monogram block (`#30432E` background), "AgriSwarm" bold, "OPERATOR PLATFORM" subtitle.

**Bottom Status Bar:** Animated green pulse dot + "System Operational" text + `ShieldCheck` icon.

### Header (`src/components/layout/Header.tsx`) — 258 Lines

Top 48px fixed navigation bar. Receives `activeTab`, `onNavigate`, `searchQuery`, `onSearchChange`, `selectedFieldId`, `selectedOpId`.

**Breadcrumb Trail:** Dynamically computed from `activeTab`. Shows `AgriSwarm › [Section] › [Item]` with `ChevronRight` separators. Includes animated `.pulse-dot` live connection indicator.

**Global Search Bar:** 260px input with placeholder "Search REQ-1024, Field A, OP-0142...". Shows `/` keyboard shortcut badge when empty, `X` clear button when has value.

**Notifications Popover:**
- Bell icon with red dot badge (unread count indicator)
- Clicking opens dropdown with 3 hardcoded notifications:
  1. "Validation Required" (critical/red) → navigates to validation
  2. "Operation Update" (info) → navigates to operations
  3. "New Request Received" (warning) → navigates to requests

**Date Display:** Static "Thu, Aug 27, 2026"

---

## 10. Views — Feature Screens

### Dashboard View (`src/components/views/DashboardView.tsx`) — 328 Lines

The main landing screen. Props: `operations`, `requests`, `findings`, `zones`, `activities`, `onNavigate`, `onSelectOperation`, `onSelectField`.

**Header Row:**
- "Good morning, Operator" heading
- Date/fleet status subtitle
- "New Operation Schedule" button → navigates to requests
- "Review AI Detections (N)" button → navigates to validation

**Operational Status Strip:**
Horizontal bar with 6 metrics separated by vertical dividers:
- Total Requests: 18
- Pending: `pendingRequests` count (amber)
- In Progress: `inProgressOps` count (blue)
- Validation Required: `pendingValidations` count (red)
- Reports Ready: 2 Ready (green)
- Completed: 4 Completed (dark green)
- "View Fleet Telemetry" link → analytics

**Main Two-Column Grid:**

Left column — "TODAY'S FIELD OPERATIONS":
- `MapLibreSpatialMap` at 380px height with `selectedZoneId="Zone 27"` and `showFlightPath={true}`
- Clicking map zone navigates to field details
- Below map: "Active Drone Missions" quick-switcher
  - One card per operation with status badge and progress bar (In Progress ops show blue progress bar)
  - Clicking any card opens operation details

Right column:
- **ATTENTION REQUIRED panel** (3 items):
  1. "3 Findings Require Validation" (red) → validation view
  2. "2 Urgent Farmer Requests" (amber) → requests view
  3. "1 Ground Inspection Recommended" (grey) → field details
- **Recent Audit Timeline**: Last 5 activities with timestamp (monospace) + title + description

---

### Requests View (`src/components/views/RequestsView.tsx`) — 384 Lines

Manages farmer service requests. Props: `requests`, `onAcceptRequest`, `onRejectRequest`, `onScheduleOperation`, `onNavigateToField`, `searchQuery`.

**Filters:**
- Status filter dropdown (All/Pending/Accepted/Scheduled/In Progress/Completed)
- Priority filter dropdown (All/High/Medium/Low)

**Left Side — Filterable Table:**
Columns: Request ID | Farmer Name | Field Asset | Location | Crop & Area | Requested Date | Priority | Status | Action

- Clicking a row selects it (highlights green)
- Field name is a clickable link → navigates to field details
- Priority is color-coded (High=red, Medium=amber, Low=grey)
- Status shows badge
- "Details" button selects row

**Right Side — Request Detail Drawer (380px):**
Opens when a request is selected. Shows:
- Service Request ID + status badge
- Farmer Name, Location, Target Field (link), Requested Date, Historical Scan count
- Farmer Notes box (quoted text)
- **Target Spatial Boundary mini-map** (`MapLibreSpatialMap` at 160px height, no flight path)

Action buttons (context-aware by status):
- Pending → "Reject Request" + "Accept Request" (accepting opens Schedule Modal)
- Accepted/In Progress/Scheduled → "Schedule Drone Mission"

**Schedule Drone Mission Modal:**
Fixed overlay modal (440px wide). Contains:
- Target Field display (read-only)
- Drone selection dropdown: Drone-01 (Quad-Multispectral), Drone-02 (Hexa-RGB), Drone-03 (Thermal Spectral)
- Planned Start Time text input
- Flight altitude/pattern display: "45 meters AGL · Grid Lawn-mower scan (75% overlap)"
- Cancel + "Confirm & Dispatch Mission" buttons
- Dispatching calls `onScheduleOperation(request, drone, time)` in App.tsx

---

### Fields View (`src/components/views/FieldsView.tsx`) — 162 Lines

Displays all registered field assets as cards. Props: `fields`, `onSelectField`, `searchQuery`.

**Search:** Filters by field name, farmer name, crop, or location.

**Card Grid (auto-fill, min 320px):** Each card shows:
- Field name + farmer + location
- Status badge (critical/success)
- **SVG Mini Spatial Preview** (dark green background, polygon outline, red/amber dots for High Priority/Warning zones)
- Metrics grid: Crop, Area, Health Index, Last Scan
- Hover: border turns green (`#4F6848`)
- "View Full Field Details" footer link with `ChevronRight`

---

### Field Details View (`src/components/views/FieldDetailsView.tsx`) — 388 Lines

Deep-dive workspace for a single field. Props: `field`, `onNavigateBack`, `onNavigateToValidation`, `onNavigateToOperation`.

**Header:**
- "← Back to Field Assets List" link
- Field name + status badge
- Crop, area, location, farmer, last scan sub-header
- "View Active Mission (OP-0142)" button
- "Validate Zone 27 Findings" button

**Sub-navigation Tabs (4):**
1. **Spatial Overview & GIS Map** (default)
2. **Geographic Zones (36)** 
3. **Related Operations (OP-0142)**
4. **Field Intelligence Reports**

**Tab 1 — Spatial Overview (two-column):**

Left: `MapLibreSpatialMap` at 450px height. Clicking a zone updates the right drawer. Zone tooltip shows moisture, stress type, confidence, GPS.

Right Drawer: "ZONE SPATIAL TELEMETRY" panel for the selected zone:
- Detection Status, Detection Confidence (if present)
- Soil Moisture Level (color-coded: amber if < 25%, green if normal)
- GPS Centroid (monospace)
- Last Scan Time
- Recommended Action box (red background if stress present)
- AI detection disclaimer note
- "Create Ground Inspection Task" primary button
- "Open Human Validation Workspace" secondary button (only if High Priority zone)

**Tab 2 — Zones Table:**
All 36 zones listed: Zone ID | Grid Position | Status badge | Soil Moisture | Stress Detection | Confidence | GPS Coordinates | "Select on Map" action

**Ground Inspection Modal:**
Fixed overlay modal triggered by "Create Ground Inspection Task". Shows:
- Target Coordinates (from selected zone)
- Inspection Instructions textarea (pre-filled)
- Cancel + "Dispatch Field Inspector" buttons
- On dispatch: shows success state with `CheckCircle2` icon, "Ground Inspection Dispatch Created" message

---

### Operations View (`src/components/views/OperationsView.tsx`) — 114 Lines

Table of all drone missions. Props: `operations`, `onSelectOperation`, `searchQuery`.

**Filter:** Status dropdown (All/In Progress/Planned/Completed/Failed)

**Table columns:** Operation ID | Farmer | Target Field | Assigned Drone | Start Time | Progress (bar + %) | Status badge | "View Mission Workspace" action

---

### Operation Details View (`src/components/views/OperationDetailsView.tsx`) — 220 Lines

Mission detail workspace. Props: `operation`, `zones`, `onNavigateBack`, `onNavigateToValidation`.

**Header:** Operation ID (monospace), status badge with progress %, farmer/field/drone/start details. "Open AI Validation Workspace" button.

**Two-column layout (320px + flex):**

**Left — Mission Workflow Progression Timeline:**
Vertical step timeline with 7 stages. Each step has:
- Connector line (green if completed, blue if current, grey if future)
- Icon: `CheckCircle2` (completed), animated dot (current), `Circle` (future)
- Stage label (bold if current, medium if completed, grey if future)
- Timestamp (monospace)

Bottom: **Drone Fleet Telemetry box:**
- Battery %, Altitude (m AGL), Speed (m/s), Scanned area (ha)

**Right — Flight Path & Spatial Scan Map:**
`MapLibreSpatialMap` at 460px with `selectedZoneId="Zone 27"` and flight path overlay. "LIVE PROGRESS: N%" label.

---

### Validation View (`src/components/views/ValidationView.tsx`) — 510 Lines

AI anomaly human validation workspace — the most complex view. Props: `findings`, `onConfirmFinding`, `onRejectFinding`, `onNavigateToReport`.

**Header:** "AI Anomaly Human Validation Engine" + "View Compiled Intelligence Reports" button.

**3-Step Workflow Guidance Bar:**
- Step 1: "AI Detection Flagged" (dark green circle)
- Step 2: "Spectral Imagery Audit" (active, medium green)
- Step 3: "Operator Sign-Off" (grey, not yet active)
- Protocol banner: "Human verification required prior to issuing farmer directives"

**3-Column Workspace:**

**Left (280px) — Validation Queue List:**
Each finding card shows:
- Finding ID (monospace), status badge (Pending Validation=red, others=green)
- Field name + Zone ID
- Finding type + confidence % (red if >85%, amber otherwise)
- Clicking selects that finding and clears decision feedback

**Middle (flex) — Canopy Spectral Audit Viewer:**
Toolbar: "MicaSense RedEdge-P 5-Band Sensor · 3.2 cm/pixel · Sun-angle calibrated"

View mode toggle (3 buttons):
- **Dual View** (default): NDVI + RGB side by side
- **NDVI Spectrum**: Full-width NDVI image
- **TrueColor RGB**: Full-width RGB image

**NDVI Panel** (340px height):
- Image: `/assets/potato_ndvi.png`
- HUD overlay top-left: "🌿 NDVI MULTISPECTRAL HEATMAP"
- HUD top-right: "GSD: 0.8 cm/px"
- **AI Detection Bounding Box**: Red dashed rectangle (25-75% of image) with red label "NDVI ANOMALY: 0.32 (CRITICAL CANOPY STRESS)"

**RGB Panel** (340px height):
- Image: `/assets/potato_rgb.png`
- HUD overlay top-left: "📷 HIGH-RES TRUECOLOR RGB"
- HUD top-right: "ALT: 15 m"
- **AI Leaf Lesion Bounding Box**: Yellow solid rectangle with label "POTATO LEAF LESION DETECTED (91% CONFIDENCE)"

**Spectral Reflectance Readout bar:**
- Red (668nm): 0.18
- Red-Edge (705nm): 0.34 (amber)
- NIR (842nm): 0.48 Low (red)

**Right (360px) — Finding Metadata + Decision Panel:**

**AUDIT DIAGNOSTIC METRICS section:**
- Finding Anomaly (red text)
- Model Confidence (colored badge pill: red if >85%, amber otherwise)
- Target Field + Zone
- Farmer name
- GPS Centroid (monospace)
- Soil Moisture Level (color-coded)

**AI Probability Distribution:**
4-class bar chart with labeled horizontal bars:
- Crop Disease Risk % (red bar)
- Water Stress / Moisture Deficit % (amber bar)
- Nutrient Deficiency % (blue bar)
- Healthy Canopy Baseline % (green bar)

**Two-Stage Edge Pass badge:**
"Manual Effort Saved: 91.6% (3 / 36 Zones Inspected)" green box

**Decision Control:**
- If no decision made yet: "Confirm Anomaly for Report" (green) + "Reject (False Positive)" (secondary) buttons
- After decision: Feedback message in green box ("Finding FND-027 CONFIRMED by Human Operator..." or "REJECTED... Logged as spectral false positive")

---

### Reports View (`src/components/views/ReportsView.tsx`) — 465 Lines

Crop intelligence audit reports viewer with full PDF export. Props: `reports`, `onNavigate`.

**Header:** "AgriSwarm Crop Intelligence Audits" + "Export PDF" button (triggers `reportlabPdfService.exportReportLabPdf`)

**Two-column layout (280px + flex):**

**Left — Report List:**
Cards for each report showing: Report ID (monospace), status badge, field name, farmer, health score (green if ≥80, red otherwise), generated date. Selected report highlighted with green border.

**Right — Full Report Document (the in-browser report viewer):**
Renders a detailed professional report layout with these sections:

1. **Report Header:** "AGRISWARM CROP INTELLIGENCE REPORT" (green), date, field, green rule divider
2. **Field Specifications table:** Crop Cultivar (Potato Kufri Jyoti), Field Area (ha + acres), Sowing Date, Growth Stage
3. **Dual KPI Cards:** Crop Health Score (green-bordered, large number) + Soil Moisture Status (blue-bordered)
4. **Audit Findings Alert Banner:** Red-bordered banner listing all detected issues
5. **Zone Condition Analysis table:** Zone, Status (color-coded), Moisture, Temperature, Risk — 4 zones
6. **Sensor Telemetry Readings table:** Soil Moisture (LOW/red), Temperature (NORMAL/green), Humidity (NORMAL/green)
7. **Drone Imagery Survey Logs table:** 4 zone scan labels with vegetation assessments
8. **Telemetry Index Trend Lines table:** Crop Health Score and Soil Moisture across 4 scan history points
9. **Historical Analytics Trend Progress (Visual Charts):** 2 `MiniBarChart` components (health index + soil moisture across 4 scans)
10. **Expert Recommendation & Crop Solutions:** 4 recommendation cards (one per zone) with Problem, AI Assessment, Action Plan
11. **Footer:** "Authorised Agritech Lead Signature: Dr. S. K. Sharma"

**Inline helper components:**
- `SectionHeader` — green uppercase bold section title with bottom border
- `ProgressBar` — colored horizontal progress bar
- `MiniBarChart` — bar chart using flex + dynamic heights

**Hardcoded report content (ZONE_DATA, SENSOR_DATA, DRONE_IMAGERY, TELEMETRY_TREND, RECOMMENDATIONS):**
The detailed data for the report body: Late Blight Risk, Low Moisture Stress, Nutrient Deficiency, Early Blight Risk across 4 zones.

---

### Analytics View (`src/components/views/AnalyticsView.tsx`) — 174 Lines

Operational KPIs and agronomic intelligence metrics. No props (displays hardcoded data).

**Header:** "Operational Analytics & Agronomic Intelligence" + Region badge: "Thane & Kalyan Sectors"

**4 KPI Highlight Cards:**
1. **Manual Effort Saved:** `91.6%` — "3 of 36 zones inspected (88.4% reduction)" | `Zap` icon
2. **Stage 1 Quick Pass:** `4.2 mins` — "Full 5 ha field edge scan time" | `Activity` icon
3. **Model Precision:** `91.4%` — "Confirmed vs ground soil probe" | `ShieldCheck` icon
4. **Monitored Area:** `124.6 ha` — "18 farmer fields registered" | `BarChart2` icon

**2-column Analytics Grid:**

Card 1 — **Regional Spatial Zone Health Distribution:**
3 progress bars:
- Healthy Canopy (NDVI > 0.65): 112 Zones (77.7%) — green
- Warning / Moisture Deficit (NDVI 0.40–0.60): 24 Zones (16.6%) — amber
- High Priority Anomaly (Zone 27, Zone 08): 8 Zones (5.5%) — red

Card 2 — **Mission Execution & Operator Review Throughput:**
2×2 metric grid:
- Avg Flight Time: 18 mins (per 5.0 ha parcel)
- Validation Turnaround: 8 mins (operator human sign-off)
- Two-Stage Rescan Ratio: 8.4% (only flagged zones rescanned)
- Total Service Requests: 18

---

### Weather View (`src/components/views/WeatherView.tsx`) — 236 Lines

6-day operational weather forecast with spray window advisory. Props: `weather: WeatherForecast[]`.

**Header:** "Weather & Spraying Conditions" + "Thane, Maharashtra · 27 Aug 2026 · 05:30 IST"

**Today's Summary Strip (3 cards):**
1. Temperature card: large number °C + weather condition + wind speed
2. Spray Window Condition card: color-coded by GOOD/MODERATE/AVOID + best window time
3. Humidity & Rainfall Risk card: humidity % + rain probability % (red if >50%)

**6-Day Forecast Strip:**
Horizontal strip of 6 date buttons. Each shows: day name, date, weather emoji (☀/🌧/☁), temperature, spray condition badge. Clicking selects a day.

**Selected Day Detail (2-column):**
- Left: Conditions card — Temperature, Rain Probability, Humidity, Wind Speed, Weather, Best Spray Window
- Right: Operational Advisory — spray condition badge, AI summary text, cultivation tips (nitrogen split doses, drip irrigation, crop rotation)

**Spray color scheme:**
- GOOD → green (`#EBF0E9`, `#30432E`)
- MODERATE → amber (`#FEF5E4`, `#B8862D`)
- AVOID → red (`#FAEAE9`, `#B64A43`)

---

### Library View (`src/components/views/LibraryView.tsx`) — 265 Lines

Agricultural knowledge base. Props: `library: LibraryItem[]`.

**Header:** "Agricultural Knowledge Library" + search input (220px)

**Tab Bar:** Crops (N) | Pests (N) | Diseases (N) — each with count badge. Filtered by type.

**Card Grid (auto-fill, min 280px):**
Each card shows: item name + type badge, description (2-line clamp), affected crops list, first detail item as key fact. Hover: border turns green. Clicking opens detail view.

**Detail View (on item select):**
- Back button, item name + type badge, affected crops
- Left: Description panel + Growing Conditions/Key Facts bullets list
- Right: Symptoms (red background), Prevention (green background), Management (white card)

---

### Activity View (`src/components/views/ActivityView.tsx`) — 53 Lines

System audit log. Props: `activities: ActivityItem[]`.

**Table:** Timestamp (monospace) | Log Event Title | Operational Details | Category (badge) | Audit ID

Category badges: `validation`=red, `operation`=blue, others=green.

---

### Settings View (`src/components/views/SettingsView.tsx`) — 95 Lines

System configuration panel. No props.

**Two-column grid (2 sections):**

**Edge AI Hardware & Drone Telemetry Node:**
- Target Crop Focus: "Potato (Solanum tuberosum)" (read-only)
- Edge Hardware Unit: "AgriSwarm-Edge-v2.4 (NVIDIA Jetson Orin Nano)" (read-only)
- Telemetry Data Frequency: dropdown (1000ms/2000ms/5000ms), default 2000ms
- Drone Communication Channel: "MAVLink v2.0 / 2.4 GHz Encrypted Radio Telemetry" (read-only)

**AI Model Thresholds & Database Configuration:**
- Potato Anomaly Confidence Cutoff: dropdown (70%/75%/85%), default 75%
- Multispectral Index Band: dropdown (NDVI/NDRE/RGB), default NDVI
- Supabase Cloud Endpoint: "https://agriswarm-platform.supabase.co (PostgreSQL v15)" (read-only)

---

## 11. GIS Mapping System (`src/components/gis/`)

### MapLibreSpatialMap (`MapLibreSpatialMap.tsx`) — 423 Lines

The interactive farm map component. Used in: Dashboard (380px), Requests detail drawer (160px), Field Details (450px), Operation Details (460px).

**Props:** `zones: ZoneData[]`, `selectedZoneId?: string`, `onSelectZone?: (zone) => void`, `showFlightPath?: boolean`, `height?: string`

**Underlying Technology:**
- Uses **Leaflet 1.9.4** (dynamically imported via `import('leaflet')`)
- Leaflet CSS loaded dynamically via `<link>` injection into `document.head`
- Google Satellite tile: `https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}`
- Google Streets tile: `https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}`
- **Turf.js** used for field area calculation and centroid computation

**Farm Coordinates:**
- Centre: `[19.0542, 73.8820]` (Ambegaon, Pune District)
- Field boundary: 5-point polygon around `19.0536–19.0550°N, 73.8808–73.8832°E`
- Zoom level: 17 (default), 18 (on zone selection)

**Map Features:**
1. **Satellite/NDVI/Streets layer toggle** — top-left HUD button group (dark glassmorphic panel)
2. **Turf.js stats badge** — top-right: "📐 N.NN ha | Turf.js Calculated" + centroid coordinates
3. **Field boundary polygon** — cyan (`#00E5FF`) dashed polygon with field name/area/stage tooltip
4. **Drone marker** — animated `agri-drone-ring` pulsing ring animation with ✈ icon + popup (battery, altitude, speed, stage)
5. **Flight path polyline** — blue (`#42A5F5`) dashed line
6. **Zone polygons** — small squares (~55m side) around each zone's GPS coords:
   - Color by status: High Priority=`#EF5350`, Warning=`#FF9800`, Nutrient stress=`#FFD600`, Disease=`#AB47BC`, Healthy=`#66BB6A`
   - Selected zone: white border, 55% fill opacity; unselected: dashed, 28% fill opacity
7. **Zone label markers** — monospace text labels above each zone polygon
8. **Click handlers** — click zone polygon or label → calls `onSelectZone(zone)` + `map.flyTo(coords, 18)`
9. **Hover tooltips** — zone ID, status, soil moisture, stress type, confidence, GPS
10. **Selected zone HUD** — bottom-right: "📍 Viewing: Zone X · Moisture: N% · Status"
11. **NDVI false-colour overlay** — CSS gradient overlay when NDVI layer is active
12. **Zone colour legend** — bottom-left: coloured dots for High Priority, Low Moisture, Warning, Healthy, Drone, Field Boundary

**Animations (CSS in `<style>` tag):**
- `agriPulseRing` — 1.8s pulse animation for zone markers
- `agriDroneRing` — 1.5s ring animation for drone marker

**Map Lifecycle:**
- Map initialized on CSS load (first `useEffect`)
- Zone polygons re-rendered when `zones` or `selectedZoneId` change (second `useEffect`)
- Map flies to selected zone when `selectedZoneId` changes (third `useEffect`)
- Tile layer swapped when `activeLayer` changes (fourth `useEffect`)
- Cleanup: `map.remove()` on unmount

---

## 12. Backend Services (`src/lib/`)

### Supabase Service (`src/lib/supabase.ts`) — 78 Lines

**Client Setup:**
```typescript
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://agriswarm-platform.supabase.co'
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || '[fallback JWT]'
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
```
Falls back to hardcoded URL/key for offline prototype mode.

**`supabaseAuthService`:**
- `getSessionUser()` → returns session user or fallback object: `{ id: 'op-04', email: 'operator.vikram@agriswarm.in', name: 'Vikram Sharma', role: 'Operator Supervisor', badge: 'Operator #04' }`
- `signIn(email)` → OTP magic link via Supabase Auth
- `signOut()` → Supabase sign out

**`subscribeToRealtimeTelemetry(onOperationUpdate, onFindingUpdate)`:**
Creates Supabase realtime channel `'agriswarm-operations-realtime'`:
- Subscribes to `UPDATE` on table `operations` → calls `onOperationUpdate(payload.new)`
- Subscribes to `INSERT` on table `findings` → calls `onFindingUpdate(payload.new)`
- Returns unsubscribe function → `supabase.removeChannel(channel)`

**`supabaseStorageService`:**
- `uploadReportPdf(reportId, pdfBlob)` → uploads to bucket `'agriswarm-reports'` at `reports/{reportId}.pdf`
- `getPublicUrl(path)` → returns public URL from storage

### PDF Export Service (`src/lib/reportlabPdfService.ts`) — 314 Lines

**`buildReportLabPayload(report, field, findings)`** — Returns metadata object for the report.

**`exportReportLabPdf(report, field, _findings)`** — Generates and downloads a jsPDF A4 PDF:
- Dynamically imports `jsPDF` on call
- A4 portrait, 16mm margins, content width: 178mm

**PDF Contents (in order):**
1. **Main header:** "AgriSwarm Crop Intelligence Audit" in green bold, thin green rule, report date/field
2. **Meta info grid (2 columns):** Crop Type, Field Area, Sowing Date, Growth Stage
3. **Dual metric cards:** Crop Health Score (green rounded rect) + Soil Moisture Status (blue rounded rect)
4. **Alert box:** Red rounded rect with blight/moisture findings text
5. **Zone Condition Analysis table:** Zone | Status | Moisture | Temperature | Risk (4 rows, red highlight for Zone 2)
6. **Sensor Telemetry Readings table:** Sensor | Current Value | Normal Range | Status (3 rows)
7. **Expert Agronomist Advice:** Text paragraph about Zone 2 irrigation
8. **Footer rule + signature:** "Authorized Agritech Lead: Dr. S. K. Sharma" (centered)

Output: `agriswarm_report_{fieldName}.pdf` downloaded via `doc.save(filename)`.

---

## 13. PWA Configuration

The app is configured as a **Progressive Web App**:
- Registers with `autoUpdate`
- App manifest: name "AgriSwarm Operator Platform", short name "AgriSwarm"
- Theme color: `#30432E` (dark green)
- Background color: `#F6F6F2`
- Display mode: `standalone` (installable)
- Workbox caches all `js, css, html, ico, png, svg` files

---

## 14. Design Language Summary

The application uses a **restrained, professional operator dashboard** aesthetic — deliberately not consumer-facing. Design choices:

- **Color palette:** Muted greens (`#30432E`, `#435C3C`, `#4F6848`), off-whites (`#F5F6F2`), warm greys (`#5F645D`), amber warning (`#B07E28`), muted red (`#AF413A`)
- **Typography:** Inter for UI text, JetBrains Mono for IDs, coordinates, telemetry values
- **Layout:** Fixed sidebar + fixed header + scrollable content. No modals for routing — all navigation via `NavTab` state
- **Tables:** Preferred for list data (requests, operations, zones, activities)
- **Cards:** For field assets, reports, library items
- **No third-party component library** — everything is vanilla CSS + inline styles
- **Inline styles** dominate individual component styling; global CSS classes for reusable patterns
- **Font-size:** 13px base (dense professional data display)

---

## 15. Application Workflow — End-to-End

1. **Operator opens Dashboard** → sees fleet status, live GIS map (Field A, Zone 27 highlighted), attention items, recent activity
2. **New request arrives** (Pending badge on sidebar) → operator goes to Requests → selects request → views map preview → Accepts → Schedule modal opens → selects drone + time → dispatches
3. **Operation begins** → Operations list shows progress bar → operator drills into Operation Details → sees 7-stage lifecycle timeline + real-time map
4. **Supabase realtime** pushes telemetry updates → operations state auto-merges updates
5. **AI analysis completes** → CropFinding inserted in Supabase → finding appears in Validation queue (badge updates)
6. **Operator validates** → Validation View opens → sees NDVI + RGB imagery side-by-side → inspects bounding boxes → reviews probability bars → Confirms or Rejects
7. **Report compilation** → Reports View shows draft report → full document preview → operator clicks Export PDF → jsPDF generates and downloads A4 report
8. **Analytics** → Operator reviews KPIs (91.6% manual effort saved, 4.2 min scan time, 91.4% model precision, 124.6 ha monitored)
9. **Weather** → checks 6-day forecast + spray window advisory before scheduling operations
10. **Library** → references crop/pest/disease database for agronomic decisions
11. **Activity Log** → full chronological audit trail of all system events

---

## 16. File Sizes Reference

| File | Lines | Bytes |
|---|---|---|
| `mockData.ts` | 588 | 27,762 |
| `ValidationView.tsx` | 510 | 25,173 |
| `ReportsView.tsx` | 465 | 23,054 |
| `MapLibreSpatialMap.tsx` | 423 | 17,504 |
| `FieldMap.tsx` | ~380 | 15,297 |
| `FieldDetailsView.tsx` | 388 | 16,186 |
| `RequestsView.tsx` | 384 | 16,593 |
| `reportlabPdfService.ts` | 314 | 12,191 |
| `DashboardView.tsx` | 328 | 14,513 |
| `App.tsx` | 307 | 11,067 |
| `index.css` | 301 | 6,135 |
| `LibraryView.tsx` | 265 | 11,073 |
| `WeatherView.tsx` | 236 | 10,029 |
| `OperationDetailsView.tsx` | 220 | 8,425 |
| `Sidebar.tsx` | 209 | 6,338 |
| `Header.tsx` | 258 | 8,828 |
| `AnalyticsView.tsx` | 174 | 10,050 |
| `FieldsView.tsx` | 162 | 6,319 |
| `OperationsView.tsx` | 114 | 4,251 |
| `SettingsView.tsx` | 95 | 5,340 |
| `supabase.ts` | 78 | 2,623 |
| `types/index.ts` | 193 | 5,100 |
| `ActivityView.tsx` | 53 | 1,913 |
| `App.css` | — | 3,075 |
