# 🌱 AgriVyaan

### AI-Powered Edge Intelligence for Smart Farming

AgriVyaan is an **edge-first AI-powered smart farming system** designed for crop monitoring, disease detection, hotspot identification, targeted rescanning, environmental sensing, and explainable crop-risk assessment.

The system combines **computer vision, deep learning, spatial clustering, environmental sensors, and edge processing** to identify potentially affected crop regions and generate structured field intelligence.

AgriVyaan is designed with an **offline-first approach**, allowing core AI processing to run locally without depending on continuous cloud connectivity.

---

## 🚀 Key Capabilities

* Potato crop disease detection
* RGB image quality assessment
* Vegetation analysis using ExG and VARI
* Vegetation anomaly detection
* YOLO-based disease detection
* Disease hotspot clustering using DBSCAN
* Targeted hotspot rescanning
* Disease validation
* Temperature, humidity, and soil-moisture sensing
* Image + sensor fusion
* Explainable disease-risk assessment
* Local AI REST API
* n8n workflow automation
* SQLite-based local processing
* Edge deployment support
* Offline-friendly operation

---

## 🧠 System Workflow

```text
Field Image
    ↓
Image Quality
    ↓
Vegetation Analysis
    ↓
Disease Detection
    ↓
Hotspot Clustering
    ↓
Targeted Rescan
    ↓
Disease Validation
    ↓
Sensor Fusion
    ↓
Risk Assessment
    ↓
Structured Result
```

The system follows the overall approach:

```text
SCAN → DETECT → FLAG → RESCAN → VALIDATE → ASSESS → EXPLAIN
```

---

# 🔬 AI Methodology

## 1. Image Quality Analysis

Every incoming image is checked before AI processing.

The quality module evaluates:

* Image resolution
* Sharpness
* Image usability

Low-quality images can be rejected before running computationally expensive analysis.

---

## 2. Vegetation Analysis

The system analyzes vegetation using RGB imagery.

### ExG

Excess Green Index is used to estimate vegetation presence:

```text
ExG = 2G - R - B
```

### VARI

Visible Atmospherically Resistant Index:

```text
VARI = (G - R) / (G + R - B)
```

These features help identify vegetation patterns and possible stress regions.

---

## 3. Vegetation Anomaly Detection

The system compares vegetation features to identify unusual regions.

The prototype anomaly score uses:

```text
Anomaly =
0.40 |z(ExG)|
+ 0.30 |z(VARI)|
+ 0.15 Yellow
+ 0.15 Brown
```

The resulting regions can be flagged for further inspection.

---

## 4. Disease Detection

A custom YOLO-based model is used for object-level disease detection.

The model provides:

* Disease class
* Bounding box
* Confidence score
* Detection location

Current prototype models include potato disease classes such as:

* Healthy
* Blackleg
* PVY
* Early Blight
* Late Blight

The exact classes depend on the deployed model version.

---

## 5. Disease Hotspot Clustering

Individual detections are grouped into spatial hotspots using **DBSCAN**.

Prototype configuration:

```text
eps = 15 meters
min_samples = 3
```

A hotspot can contain:

* Cluster ID
* GPS/location information
* Detection count
* Disease candidates
* Average confidence

This allows the system to work with **affected zones rather than isolated detections**.

---

## 6. Targeted Rescan

Once a suspicious hotspot is identified, the system generates a focused region for further analysis.

Instead of repeatedly processing the entire field image:

```text
Full Image
    ↓
Suspicious Region
    ↓
Targeted Crop
    ↓
Detailed Analysis
```

This supports the AgriVyaan concept of **targeted inspection instead of blanket processing**.

---

## 7. Disease Validation

The targeted rescan is used to verify the initial disease candidate.

The validation stage evaluates:

* Disease prediction
* Detection confidence
* Disease count
* Healthy count
* Rescan result

Possible validation states include:

```text
VALIDATED
UNCERTAIN
REJECTED
```

---

## 8. Environmental Sensor Fusion

Visual evidence can be combined with environmental information.

The current prototype supports:

* Temperature
* Humidity
* Soil moisture

Sensor information can provide additional context for disease-risk assessment.

---

## 9. Risk Assessment

The final risk engine combines visual evidence, validation information, and environmental conditions.

The output includes:

* Disease
* Risk score
* Risk level
* Detection confidence
* Sensor values
* Validation status
* Supporting evidence

Prototype risk levels:

```text
LOW
MEDIUM
HIGH
```

Risk thresholds and environmental ranges are currently **prototype logic** and are intended to be calibrated with field data before production agricultural use.

---

# 🌾 Potato Disease Model

AgriVyaan currently focuses on potato crop analysis.

The project contains models for disease classification/detection, including a MobileNetV3-based potato classifier and YOLO-based detection models.

Example model files:

```text
models/
├── best.pt
└── best_mobilenetv3_potato.pth
```

The deployed model determines the active disease classes.

---

# 🖥️ Edge AI Architecture

```text
              Camera / Drone Image
                       │
                       ▼
                Edge AI Device
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
    Computer Vision           Sensor Data
          │                         │
          ▼                         │
    Disease Detection              │
          │                         │
          ▼                         │
    Hotspot Detection              │
          │                         │
          ▼                         │
    Targeted Rescan                │
          │                         │
          ▼                         │
    Disease Validation             │
          └────────────┬────────────┘
                       ▼
                 Risk Engine
                       │
                       ▼
                JSON / Report
```

The architecture is designed to keep the core inference process close to the field data source.

---

# 🚁 Hardware Architecture

The broader AgriVyaan system is designed around a drone-assisted field inspection workflow.

### Flight Platform

* F450 frame
* A2212 motors
* Pixhawk 2.4.8
* ArduPilot
* GPS + compass
* RC controller
* 3S LiPo battery

### Edge Computing

Possible edge platforms:

* Raspberry Pi 5
* Android device

### Imaging

* RGB camera
* USB camera / Pi camera
* OpenCV-based image processing

### Environmental Sensing

* ESP32
* BME280
* Capacitive soil-moisture sensor

### Local Storage

* SQLite
* Local image storage
* USB/MTP transfer

---

# 📡 Communication

The system is designed for low-connectivity environments.

Possible communication paths include:

```text
Drone
  ↓
Flight Controller
  ↓
Edge Device
  ↓
Local Processing
  ↓
Local Database / Report
```

For field operation, the architecture can use:

* USB
* Wi-Fi Direct
* Local hotspot
* Bluetooth
* SMS when network connectivity is available

The core AI pipeline does not require continuous internet access.

---

# ⚙️ Technology Stack

| Category             | Technology                     |
| -------------------- | ------------------------------ |
| Programming          | Python                         |
| Computer Vision      | OpenCV                         |
| Deep Learning        | PyTorch                        |
| Object Detection     | YOLO                           |
| Classification       | MobileNetV3                    |
| Numerical Processing | NumPy                          |
| Data Processing      | Pandas                         |
| Spatial Clustering   | DBSCAN                         |
| API                  | Flask                          |
| Automation           | n8n                            |
| Local Database       | SQLite                         |
| Edge Runtime         | Raspberry Pi / Android         |
| Model Formats        | PyTorch / ONNX / TFLite        |
| Flight Controller    | Pixhawk / ArduPilot            |
| Sensors              | ESP32 / BME280 / Soil Moisture |

---

# 🔌 Local AI API

AgriVyaan exposes the AI engine through a local Flask API.

## Health Check

```http
GET /health
```

Example:

```text
http://127.0.0.1:5001/health
```

Response:

```json
{
  "service": "AgriVyaan AI Engine",
  "status": "ok"
}
```

---

## Process Image

```http
POST /process
```

Example request:

```json
{
  "image_path": "D:/ml/AgriVyaan/input_images/test3.jpg"
}
```

The endpoint executes the AI pipeline and returns structured image, detection, validation, sensor, and risk information.

---

# 🔄 n8n Automation

n8n is used to automate multi-image processing.

Current workflow:

```text
Manual Trigger
      ↓
Read/Write Files from Disk
      ↓
Code
(Run Once for Each Item)
      ↓
HTTP Request
      ↓
AgriVyaan API
      ↓
Result
```

Each image is handled as an individual n8n item.

The Code node generates the image path dynamically:

```javascript
return {
  json: {
    image_path: `D:/ml/AgriVyaan/input_images/${$binary.data.fileName}`
  }
};
```

The HTTP Request sends:

```json
{
  "image_path": "={{ $json.image_path }}"
}
```

This allows multiple images to move through the same processing pipeline without manually entering every filename.

---

# 📊 Example Output

Example structured result:

```json
{
  "image": "D:/ml/AgriVyaan/input_images/test3.jpg",
  "risk": [
    {
      "cluster_id": 0,
      "disease": "Blackleg",
      "validation_status": "VALIDATED",
      "yolo_confidence": 0.4879,
      "temperature": 29.91,
      "humidity": 72.91,
      "soil_moisture": 28.07,
      "risk_score": 64.28,
      "risk_level": "MEDIUM",
      "evidence": [
        "Disease detected",
        "Targeted rescan validated disease",
        "High humidity",
        "Temperature within prototype risk range",
        "Moderate soil moisture"
      ]
    }
  ]
}
```

> Example values represent prototype output and should not be interpreted as scientifically validated agricultural recommendations.

---

# 📁 Project Structure

```text
AgriVyaan/
│
├── input_images/
│
├── affected/
│
├── targeted_rescan/
│
├── output/
│   └── yolo_detections/
│
├── models/
│   ├── best.pt
│   └── best_mobilenetv3_potato.pth
│
├── python_engine/
│   ├── main.py
│   ├── api.py
│   ├── sensor_simulator.py
│   └── requirements.txt
│
├── README.md
└── ...
```

---

# 💻 Quick Start

## 1. Clone Repository

```bash
git clone <repository-url>
cd AgriVyaan
```

---

## 2. Create Python Environment

Windows:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

---

## 3. Install Dependencies

```powershell
cd python_engine
pip install -r requirements.txt
```

---

## 4. Run the AI Pipeline

```powershell
python main.py
```

For a specific image:

```powershell
python main.py "D:\ml\AgriVyaan\input_images\test1.jpg"
```

For JSON output:

```powershell
python main.py "D:\ml\AgriVyaan\input_images\test1.jpg" --json
```

---

# 🌡️ Run Sensor Simulator

For local development/testing:

```powershell
python sensor_simulator.py
```

The simulator provides:

```text
http://127.0.0.1:5000/sensor
```

It can provide prototype:

* Temperature
* Humidity
* Soil moisture

values to the AI pipeline.

---

# 🌐 Run AI API

Start the Flask API:

```powershell
python api.py
```

The API runs on:

```text
http://127.0.0.1:5001
```

Check:

```powershell
Invoke-RestMethod http://127.0.0.1:5001/health
```

---

# 🧪 API Test

PowerShell example:

```powershell
$body = @{
    image_path = "D:\ml\AgriVyaan\input_images\test1.jpg"
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:5001/process" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

---

# 🐳 Docker

The Python AI engine can also be run using Docker.

Example image:

```text
agrivyaan-python:latest
```

Example container:

```text
agrivyaan-python
```

A direct container execution example:

```bash
docker exec -w /app/agrivyaan/python_engine \
agrivyaan-python \
python main.py "/app/agrivyaan/input_images/test3.jpg" --json
```

---

# 📱 Edge Deployment

The AI pipeline is intended to support deployment on edge hardware.

Potential deployment targets include:

### Raspberry Pi

```text
Camera
  ↓
OpenCV
  ↓
ONNX / TFLite / PyTorch
  ↓
AI Pipeline
  ↓
Local Result
```

### Android

The project can use:

* Flutter
* TFLite
* ONNX-based inference
* Local image processing

The objective is to move inference closer to the field instead of requiring every image to be uploaded to a remote cloud service.

---

# 🔋 Offline-First Design

AgriVyaan is designed for agricultural environments where reliable internet access may not be available.

Core processing can operate locally:

```text
Image
  ↓
Edge AI
  ↓
Detection
  ↓
Validation
  ↓
Risk Assessment
  ↓
Local Result
```

Connectivity can be used later for:

* Synchronization
* Reporting
* Remote dashboards
* Additional analytics
* Data backup

---

# 🧪 Current Prototype Scope

The current prototype demonstrates:

* Potato image analysis
* Vegetation analysis
* YOLO disease detection
* Disease hotspot clustering
* Targeted rescanning
* Disease validation
* Sensor integration
* Risk assessment
* Flask API
* n8n automation
* Local/edge-oriented processing

The system is currently a **research/prototype implementation** and requires further field validation before being used for real agricultural treatment decisions.

---

# 🛣️ Future Development

Planned development areas include:

* Larger field datasets
* More potato disease classes
* Improved disease validation
* Real drone image acquisition
* GPS-based hotspot mapping
* Real ESP32 sensor integration
* ONNX/TFLite edge optimization
* Android edge deployment
* Farmer-facing reports
* Historical crop monitoring
* Yield-risk estimation
* Explainable AI improvements
* Larger-scale field validation

---

# 🌱 Vision

AgriVyaan aims to move agricultural monitoring from **whole-field inspection to targeted, evidence-based crop intelligence**.

By combining computer vision, edge AI, spatial analysis, and environmental sensing, the system is designed to identify **where a crop problem may exist, validate the affected region, and provide the supporting evidence required for further action**.

---

## 📚 Documentation

Additional documentation can be added for:

* Architecture
* AI methodology
* Model training
* API reference
* Hardware setup
* Drone integration
* Edge deployment
* Dataset information

---

## ⚠️ Disclaimer

AgriVyaan is a research and prototype system. Disease predictions and risk scores are not a substitute for professional agricultural diagnosis or validated agronomic recommendations. Prototype thresholds and model outputs should be field-validated before operational use.

---

