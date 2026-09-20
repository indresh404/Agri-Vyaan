# Agrivyaan Backend Microservices

This folder contains the backend services for **Agrivyaan - Multilingual AI Farm Intelligence System**.

## Structure

```
backend/
├── sarvam_api_server.py    # FastAPI server powering Sarvam STT, TTS, Translation & AI Agronomist
├── run_backend.py          # Python startup runner for the backend server
├── requirements.txt        # Backend python dependencies
└── supabase_schema.sql     # Database schema and RLS policies for Supabase
```

## Setup & Running Backend

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment
Set `SARVAM_API_KEY` in `.env`:
```env
SARVAM_API_KEY=sk_6c3q4w2g_w8zUzcbIoNPO2x6KL2r8snYO
```

### 3. Start API Server
```bash
python run_backend.py
```
Or with Uvicorn directly:
```bash
uvicorn sarvam_api_server:app --reload --port 8000
```

## API Endpoints

- `GET /`: Health check & API status
- `POST /api/tts`: Text-to-Speech audio generation using Sarvam `bulbul:v3`
- `POST /api/stt`: Speech-to-Text voice transcription using Sarvam `saaras:v1`
- `POST /api/translate`: Multilingual translation using Sarvam `mayura:v1`
- `POST /api/chat`: AI Farmer Assistant query response generator
