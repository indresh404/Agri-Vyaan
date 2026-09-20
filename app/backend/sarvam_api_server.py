import os
import base64
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx
from dotenv import load_dotenv

load_dotenv()

SARVAM_API_KEY = os.getenv("SARVAM_API_KEY", "sk_6c3q4w2g_w8zUzcbIoNPO2x6KL2r8snYO")

app = FastAPI(
    title="Agrivyaan Sarvam AI Agronomist Backend Service",
    description="Multilingual Speech-to-Text, Text-to-Speech & AI Farm Assistant API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TTSRequest(BaseModel):
    text: str
    language_code: str = "hi-IN"
    speaker: str = "ritu"

class TranslateRequest(BaseModel):
    text: str
    source_language_code: str = "en-IN"
    target_language_code: str = "hi-IN"

class ChatRequest(BaseModel):
    query: str
    language_code: str = "hi"
    farmer_name: str = "Farmer"
    crop: str = "Cotton and Tomato"

SARVAM_LANG_MAP = {
    "hi": "hi-IN",
    "mr": "mr-IN",
    "gu": "gu-IN",
    "pa": "pa-IN",
    "kn": "kn-IN",
    "te": "te-IN",
    "en": "en-IN"
}

@app.get("/")
def read_root():
    return {
        "status": "online",
        "service": "Agrivyaan Sarvam AI Backend",
        "version": "1.0.0"
    }

@app.post("/api/tts")
async def text_to_speech(req: TTSRequest):
    """Generate audio speech from text using Sarvam bulbul:v3 API"""
    target_lang = SARVAM_LANG_MAP.get(req.language_code, req.language_code)
    url = "https://api.sarvam.ai/text-to-speech"
    headers = {
        "api-subscription-key": SARVAM_API_KEY,
        "Content-Type": "application/json"
    }
    payload = {
        "inputs": [req.text.strip()],
        "target_language_code": target_lang,
        "speaker": req.speaker,
        "pitch": 0,
        "pace": 1.0,
        "loudness": 1.5,
        "speech_sample_rate": 8000,
        "enable_preprocessing": True,
        "model": "bulbul:v3"
    }
    
    async with httpx.AsyncClient() as client:
        res = await client.post(url, headers=headers, json=payload, timeout=15.0)
        if res.status_code == 200:
            data = res.json()
            audios = data.get("audios", [])
            if audios:
                return {"success": True, "audio_base64": audios[0], "language": target_lang}
        raise HTTPException(status_code=res.status_code, detail=res.text)

@app.post("/api/stt")
async def speech_to_text(
    file: UploadFile = File(...),
    language_code: str = Form("hi-IN")
):
    """Transcribe spoken voice audio using Sarvam saaras:v1 API"""
    target_lang = SARVAM_LANG_MAP.get(language_code, language_code)
    url = "https://api.sarvam.ai/speech-to-text"
    headers = {"api-subscription-key": SARVAM_API_KEY}
    
    content = await file.read()
    files = {"file": (file.filename, content, file.content_type or "audio/wav")}
    data = {
        "language_code": target_lang,
        "model": "saaras:v1"
    }
    
    async with httpx.AsyncClient() as client:
        res = await client.post(url, headers=headers, data=data, files=files, timeout=20.0)
        if res.status_code == 200:
            return res.json()
        raise HTTPException(status_code=res.status_code, detail=res.text)

@app.post("/api/translate")
async def translate_text(req: TranslateRequest):
    """Translate text between Indian languages using Sarvam mayura:v1 API"""
    url = "https://api.sarvam.ai/translate"
    headers = {
        "api-subscription-key": SARVAM_API_KEY,
        "Content-Type": "application/json"
    }
    payload = {
        "input": req.text,
        "source_language_code": req.source_language_code,
        "target_language_code": req.target_language_code,
        "model": "mayura:v1"
    }
    
    async with httpx.AsyncClient() as client:
        res = await client.post(url, headers=headers, json=payload, timeout=15.0)
        if res.status_code == 200:
            return res.json()
        raise HTTPException(status_code=res.status_code, detail=res.text)

@app.post("/api/chat")
async def farmer_ai_chat(req: ChatRequest):
    """AI Agronomist Farmer Guidance API with Multilingual support"""
    query_lower = req.query.lower()
    
    if "health" in query_lower or "field" in query_lower or "decreasing" in query_lower:
        ans_en = f"Namaste {req.farmer_name}! Field A ({req.crop}) health score decreased to 78/100 due to low soil moisture (27%) in Zone 2. Run drip irrigation for 45 minutes."
    elif "weather" in query_lower or "spray" in query_lower or "rain" in query_lower:
        ans_en = "Today's spraying condition is GOOD (wind 8 km/h, 10% rain chance). Avoid spraying tomorrow as rain is expected."
    elif "pest" in query_lower or "blight" in query_lower or "disease" in query_lower:
        ans_en = f"Early leaf blight signs observed in {req.crop}. Recommended treatment: spray copper oxychloride (2g/L) during early morning."
    else:
        ans_en = f"I am your Agrivyaan AI Farm Assistant monitoring your {req.crop} fields. Ask me about weather, spraying windows, irrigation, or crop health!"

    tgt_lang = SARVAM_LANG_MAP.get(req.language_code, "en-IN")
    if tgt_lang == "en-IN":
        translated_ans = ans_en
    else:
        try:
            trans_res = await translate_text(TranslateRequest(
                text=ans_en,
                source_language_code="en-IN",
                target_language_code=tgt_lang
            ))
            translated_ans = trans_res.get("translated_text", ans_en)
        except Exception:
            translated_ans = ans_en

    return {
        "query": req.query,
        "response": translated_ans,
        "language_code": req.language_code,
        "target_lang": tgt_lang
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
