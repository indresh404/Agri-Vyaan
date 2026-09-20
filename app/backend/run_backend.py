import uvicorn
import os

if __name__ == "__main__":
    print("Starting Agrivyaan Sarvam AI Backend Server on http://localhost:8000 ...")
    uvicorn.run("sarvam_api_server:app", host="0.0.0.0", port=8000, reload=True)
