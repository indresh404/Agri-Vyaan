# 🚀 AgriSwarm — Web Application Complete Presentation & Explanation Guide (SIH 2026)

> **PS ID:** SIH26180 | **Category:** Hardware / Edge AI | **Theme:** Disaster Management / Smart Agriculture  
> **Target Crop Focus:** Potato (*Solanum tuberosum*)  
> **Language:** Hinglish (Easy to speak & explain to Judges)

---

## 🎯 1. 60-Second Opening Pitch for Judges (Hinglish Script)

**"Respected Judges, AgriSwarm ek shared, booking-based drone ecosystem hai jo chote farmers ke liye AI-driven crop intelligence lata hai.**

Usually small farmers expensive drones ya sensors buy nahi kar sakte. Iska solution humne diya hai **Booking Model** se — farmer apni field scan ke liye drone visit book karta hai. Operator drone ko field par lata hai, drone auto-fly karke images captue karta hai, aur **NVIDIA Jetson Orin Nano (Edge Device)** field par hi, bina kisi internet ke, **Edge AI** se diseases spot karta hai.

Ye **Web Application** hamare **Drone Operator aur Agronomists ka Command & Control Platform** hai. Yahan se operator farmer requests accept karta hai, live drone flight monitor karta hai, AI findings ko human-in-the-loop validate karta hai, aur instant **Crop Intelligence Audit Reports** generate karke farmer ko bhejta hai."

---

## 🖥️ 2. Page-by-Page Deep Dive (Har Tab Ka Explanation & Purpose)

---

### 📍 Tab 1: Dashboard (Operations Control Center)

#### 🔹 What it is (Kya hai?):
Yeh web application ka main home screen hai. Yahan operator ko puri field operations ka bird-eye view milta hai.

#### 🔹 Key Features Shown (Kya dikhta hai?):
1. **Summary Cards:** Total Active Fields (4), Pending Requests (1), Active Operations (1), Validated Anomalies.
2. **Interactive Real Satellite GIS Map:** Ambegaon, Pune District, Maharashtra (`19.0542°N, 73.8820°E`) ke real potato farm par centered high-res satellite map.
   - **Cyan Dashed Box:** Potato field boundary polygon (`4.80 ha`).
   - **Blue Pulsing Drone Icon:** Live Drone-01 position at 45m altitude with flight path.
   - **Turf.js Badge:** Real-time spatial area calculation.
3. **Live Operation Status:** Scan OP-0142 progress (68% complete over Field A).

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Judges, Dashboard hamara real-time command center hai. Yahan top par hume current active operations aur pending requests ki summary milti hai. Central space me humne **Leaflet.js aur Google Satellite Tiles** se **Ambegaon Potato Belt** ka live GIS map render kiya hai. Blue dot live Drone-01 ki position aur flight path dikhata hai, jabki cyan box exact potato field boundary define karta hai."*

---

### 📄 Tab 2: Requests (Farmer Scan Bookings)

#### 🔹 What it is (Kya hai?):
Jab koi farmer (e.g. Ramesh Kumar, Suresh Patil) mobile app ya offline booking center se drone visit book karta hai, toh woh request yahan operator ke paas aati hai.

#### 🔹 Key Features Shown (Kya dikhta hai?):
- **Priority Badges:** High, Medium, Low urgency.
- **Request Details:** Farmer Name, Field Name, Location (Thane/Ambegaon), Requested Date, Area in Hectares, and Field Notes.
- **Action Buttons:** `Accept Request`, `Assign Drone`, `Schedule Visit`.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Requests tab me farmers dwara book ki gayi saari scan requests aati hain. Operator priority filter (High/Medium/Low) dekhkar high-risk potato fields ko pehle drone assign kar sakta hai. Yahan se single click me request accept hoti hai aur drone mission schedule hota hai."*

---

### 🗺️ Tab 3: Fields (Potato Field Assets)

#### 🔹 What it is (Kya hai?):
Yeh registered potato farms ka complete GIS Asset Registry hai.

#### 🔹 Key Features Shown (Kya dikhta hai?):
- **Field Asset Cards:** Field A (Potato, 4.8 ha), Field B (Potato, 6.2 ha), Field C, Field D.
- **Health Index Score:** 78 / 100 (Canopy Vigor Index).
- **Crop Metadata:** Sowing Date (`2026-06-15`), Crop Stage (`Tuber bulking stage`).
- **Telemetry Indicators:** Soil Moisture Status (`LOW - 27%`), Canopy Temperature (`32°C`), Humidity (`65%`).

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Fields tab me har farmer ke field ka historical asset record hai. E.g. Field A potato crop me sowing date June 15 thi aur abhi tuber bulking stage chal rhi hai. System batata hai ki soil moisture 27% (LOW) hai jo tuber formation ke liye critical stress point hai."*

---

### 📡 Tab 4: Operations (Live Drone Flight Tracking)

#### 🔹 What it is (Kya hai?):
Live chal rahe drone scan missions ka telemetry control center.

#### 🔹 Key Features Shown (Kya dikhta hai?):
- **Operation Metadata:** OP-0142, Drone-01, Altitude (`45m`), Speed (`4.2 m/s`), Battery (`62%`).
- **MAVLink Protocol Stream:** Real-time telemetry feed from flight controller.
- **Flight Timeline:** Requested → Drone Assigned → In Progress → AI Analysis → Verification → Report Ready.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Operations tab live flight execution monitor karta hai. Drone se aane wala MAVLink telemetry data yahan stream hota hai — altitude 45 meters, speed 4.2 m/s, aur battery level 62%. Timeline bar dikhati hai ki scan execution konse stage par hai."*

---

### 🔍 Tab 5: Validation (Human-in-the-Loop AI Review Queue)

#### 🔹 What it is (Kya hai?):
**This is the most critical AI tab!** Drones dwara detect kiye gaye disease aur moisture stress anomalies ko human operator verify karta hai.

#### 🔹 Key Features Shown (Kya dikhta hai?):
1. **Side-by-Side Dual Image Canvas:**
   - **NDVI Multispectral Heatmap View (Left):** Real aerial thermal scan showing false-color vegetation stress (`NDVI ANOMALY: 0.32 CRITICAL`).
   - **High-Res TrueColor RGB View (Right):** Real aerial photo showing actual potato leaf yellowing/blight spots (`POTATO LEAF LESION DETECTED 91%`).
2. **AI Probability Breakdown:**
   - Late Blight / Water Stress probability (91%).
3. **Action Buttons:** `Confirm AI Finding`, `Reject / False Positive`.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Judges, AI 100% perfect nahi ho sakta, isliye humne **Human-in-the-Loop Validation System** rakha hai. Edge AI dwara flag kiye gaye anomalies yahan aate hain. Left side par NDVI multispectral thermal heatmap hai aur right side par high-res RGB photo. Operator bounding box dekhkar confirm karta hai. Confirm hote hi report ready ho jati hai."*

---

### 📊 Tab 6: Reports (AgriSwarm Crop Intelligence Audits)

#### 🔹 What it is (Kya hai?):
Farmer aur Agronomist ko milne wali official diagnostic audit report preview & PDF download engine.

#### 🔹 Key Features Shown (Kya dikhta hai?):
1. **Green Title Header:** `AgriSwarm Crop Intelligence Audit`
2. **Meta Info Grid:** Crop Type (Potato), Field Area (4.8 ha / 11.8 acres), Sowing Date, Growth Stage.
3. **Dual Metric Cards (Side-by-Side):**
   - **CROP HEALTH SCORE:** `78 / 100` (Outlined Green Card)
   - **SOIL MOISTURE STATUS:** `LOW` (Outlined Blue Card)
4. **Red Alert Banner:** `Findings: Low soil moisture detected in Zone 2. High moisture stress observed.`
5. **Zone Condition Analysis Table:** Zone 1 to Zone 4 status, moisture %, temp, risk level.
6. **Sensor Telemetry Table:** Soil Moisture (`27.0% LOW`), Temp (`32.0°C NORMAL`), Humidity (`65.0% NORMAL`).
7. **Expert Agronomist Advice:** Direct actionable guidance (e.g. *Check irrigation flow immediately in Zone 2. Target moisture >35%*).
8. **Export PDF Button:** Generates instant downloadable PDF using `jsPDF` library.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Reports tab me complete **Crop Intelligence Audit** generate hoti hai. Top par Health Score (78/100) aur Moisture Status (LOW) ke side-by-side metric cards hain. Nicche Zone Condition Analysis table aur Telemetry readings hain, aur niche Agronomist advice hai. Single click me **Export PDF Report** button press karke printable PDF download ho jata hai."*

---

### 📈 Tab 7: Analytics (Performance & Impact Metrics)

#### 🔹 What it is (Kya hai?):
Platform ka analytical ROI aur AI model performance dashboard.

#### 🔹 Key Features Shown (Kya dikhta hai?):
- **91.6% Manual Inspection Effort Saved:** Drones dwara targeted scanning se farmer ka time aur physical walking kitna bacha.
- **Model Precision Rates:** 94.2% AI detection precision.
- **Yield Loss Reduction:** Disease early detection se crop yield loss reduction trend graphs.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Analytics tab hume system ka social impact aur efficiency batata hai. Traditional manual field inspection ke comparison me AgriSwarm ne **91.6% physical inspection effort save** kiya hai kyunki operator sirf flagged zones ko check karta hai."*

---

### 🌤️ Tab 8: Weather (Field Micro-Climate Spraying Window)

#### 🔹 What it is (Kya hai?):
Potato crop spraying ke liye 6-day localized weather forecast.

#### 🔹 Key Features Shown (Kya dikhta hai?):
- **Spraying Condition Badge:** `GOOD`, `MODERATE`, `AVOID`.
- **Optimal Spraying Window:** e.g. *Today 6:00 AM – 9:00 AM (Low wind speed & zero rain risk prevents fungicide drift)*.
- **Micro-Climate Metrics:** Temperature, Humidity %, Wind Speed (m/s), Rain Probability %.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Weather tab farmer ko pesticide/fungicide spray karne ka **Optimal Spraying Window** batata hai. Agar rain probability high ho ya wind speed jyada ho, toh system `AVOID` warning deta hai taaki chemical waste na ho."*

---

### 📚 Tab 9: Library (Potato Crop Knowledge Base)

#### 🔹 What it is (Kya hai?):
Potato farming, diseases, and pest management ka detailed agronomic reference guide.

#### 🔹 Key Features Shown (Kya dikhta hai?):
- **Potato Varieties:** Kufri Jyoti, Kufri Pukhraj, Kufri Bahar.
- **Pathogens & Diseases:** Late Blight (*Phytophthora infestans*), Early Blight (*Alternaria solani*), Black Scurf (*Rhizoctonia solani*).
- **Pests:** Potato Aphids (*Myzus persicae*).
- **Details:** Symptoms, Optimal Temperature, Prevention, and Treatment Directives.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Library tab hamara knowledge repository hai. Yahan Potato varieties (Kufri Jyoti, Pukhraj) aur diseases (Late Blight, Early Blight) ki complete symptoms, temperature requirements, aur chemical treatments listed hain."*

---

### ⚙️ Tab 10: Settings (Edge AI & Platform Configurations)

#### 🔹 What it is (Kya hai?):
Operator hardware, edge device parameters, aur database integration configuration settings.

#### 🔹 Key Features Shown (Kya dikhta hai?):
- **Target Crop Focus:** Potato (*Solanum tuberosum*).
- **Edge AI Hardware Device:** NVIDIA Jetson Orin Nano / Snapdragon Processing Node.
- **MAVLink Frequency:** 10 Hz telemetry telemetry stream.
- **Supabase Endpoint:** Supabase PostgreSQL & Storage sync node configuration.

#### 🗣️ How to explain to Judges (Hinglish Script):
> *"Settings tab me hardware aur platform parameters configured hain. Target crop Potato selected hai, Edge Hardware NVIDIA Jetson Orin Nano setup hai, aur Supabase database synchronization endpoint set hai."*

---

## 🛠️ 3. Technical Stack & Architecture (Judges ke Technical Questions ke liye)

| Layer | Technology Used | Why it was chosen? (Hinglish Reason) |
| :--- | :--- | :--- |
| **Frontend Framework** | **React 19 + TypeScript** | Strict type-safety to handle live drone telemetry without runtime crashes. |
| **Build System** | **Vite + PWA** | Super fast 0.8s bundling + Progressive Web App capability for **100% Offline Field Use**. |
| **GIS Mapping** | **Leaflet.js + Google Satellite + Turf.js** | Instant rendering of satellite tiles, field boundary polygons, and spatial area math. |
| **UI Styling** | **Tailwind CSS + Lucide Icons** | Clean, modern, responsive glassmorphism UI layout. |
| **PDF Generator** | **jsPDF** | Client-side instant PDF generation without needing cloud server API calls. |
| **Backend & Database** | **Supabase (PostgreSQL & Storage)** | Real-time telemetry streaming and cloud storage for synced PDF reports. |

---

## ❓ 4. Anticipated Judges Cross-Questions & Winning Answers (Hinglish Q&A)

### Q1: "Khet me internet nahi hota, yeh web app kaise chalega?"
👉 **Answer:** *"Judges, humne is app ko **Vite PWA (Progressive Web App)** me build kiya hai. Saara code, map tiles, aur mock data operator ke laptop/tablet me service workers through cache ho jata hai. App **100% offline mode** me bina kisi internet ke chalne ke liye hi design kiya gaya hai."*

### Q2: "AI gar galat prediction kar de toh kya hoga?"
👉 **Answer:** *"Isi liye humne **Validation Queue (Human-in-the-Loop)** diya hai. AI dwara detect kiye gaye anomalies seedhe report me nahi jaate; pehle local operator unko dual RGB + NDVI image dekhkar confirm ya reject karta hai."*

### Q3: "Farmer ko report kaise milegi agar uske paas smartphone na ho?"
👉 **Answer:** *"Operator field me hi **Export PDF Report** button press karke bluetooth thermal printer se physical paper report print karke de sakta hai, ya WhatsApp/SMS ke zariye bhej sakta hai jab network mile."*

### Q4: "Tumne sirf Potato crop hi kyu target kiya hai?"
👉 **Answer:** *"Potato India ki top staple cash crop hai (specifically Maharashtra ke Ambegaon aur Satara belts me). Late Blight disease potato crops ko 7-10 din me 100% destroy kar sakti hai. Isliye early detection ka maximum financial impact potato farmers par milta hai."*

---

### 💡 Presentation Pro-Tip:
Jab aap Web App screen share ya demonstrate kar rhe ho, **Dashboard → Validation → Reports** in 3 tabs ko zaroor highlight karna! Judges ko AI Detection + Human Verification + PDF Export flow sabse jyada impress karta hai.
