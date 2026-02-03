# backend/middleware.py
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request
import time

# Middleware Custom: Mencatat Waktu Proses (Process Time)
class ProcessTimeMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        response = await call_next(request)
        process_time = time.time() - start_time
        response.headers["X-Process-Time"] = str(process_time)
        return response

def setup_middleware(app):
    # 1. CORS (Wajib untuk Flutter/Web)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # 2. Custom Logger
    app.add_middleware(ProcessTimeMiddleware)
    
    # 3. Security Headers (Opsional)
    # app.add_middleware(TrustedHostMiddleware, allowed_hosts=["example.com", "*.example.com"])