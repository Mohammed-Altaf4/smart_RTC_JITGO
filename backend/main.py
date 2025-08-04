from fastapi import FastAPI, HTTPException, Query, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, EmailStr
from passlib.hash import bcrypt
from jose import jwt, JWTError
from dotenv import load_dotenv
import sqlite3
import os
import requests

# ----------------------------
# Load environment variables
# ----------------------------
load_dotenv()
ORS_API_KEY = os.getenv("ORS_API_KEY")
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your_fallback_secret_key")
ALGORITHM = "HS256"

# ----------------------------
# FastAPI App Initialization
# ----------------------------
app = FastAPI()

# ----------------------------
# Enable CORS for Flutter
# ----------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ----------------------------
# OAuth2 Dependency
# ----------------------------
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# ----------------------------
# Database Utilities
# ----------------------------
def get_db():
    # ✅ FIXED: Prevent "database is locked" error
    conn = sqlite3.connect("users.db", check_same_thread=False, timeout=10)
    conn.row_factory = sqlite3.Row
    return conn

def create_users_table():
    db = get_db()
    db.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
        )
    """)
    db.commit()
    db.close()

create_users_table()

# ----------------------------
# Models
# ----------------------------
class UserRegister(BaseModel):
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

# ----------------------------
# Register User
# ----------------------------
@app.post("/register")
def register(user: UserRegister):
    if not user.email or not user.password:
        raise HTTPException(status_code=400, detail="Email and password required")

    hashed_password = bcrypt.hash(user.password)

    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("INSERT INTO users (email, password) VALUES (?, ?)", (user.email, hashed_password))
        db.commit()
        db.close()
        return {"message": "User registered successfully"}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="User already exists")
    except Exception as e:
        print(f"❌ Registration error: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

# ----------------------------
# Login Endpoint
# ----------------------------
@app.post("/login", response_model=Token)
def login(user: UserLogin):
    db = get_db()
    record = db.execute("SELECT * FROM users WHERE email = ?", (user.email,)).fetchone()
    db.close()

    if not record or not bcrypt.verify(user.password, record["password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    payload = {"sub": user.email}
    token = jwt.encode(payload, JWT_SECRET_KEY, algorithm=ALGORITHM)
    return {"access_token": token, "token_type": "bearer"}

# ----------------------------
# Auth Check Dependency
# ----------------------------
def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return email
    except JWTError:
        raise HTTPException(status_code=401, detail="Token invalid or expired")

# ----------------------------
# Protected API Route
# ----------------------------
@app.get("/protected")
def protected_route(current_user: str = Depends(get_current_user)):
    return {"message": f"Hello {current_user}, this is a protected route."}

# ----------------------------
# Root Endpoint
# ----------------------------
@app.get("/")
def root():
    return {"message": "Smart RTC Backend is running!"}

# ----------------------------
# Geocoding & Routing
# ----------------------------
NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"

@app.get("/geocode/")
def geocode_location(location: str):
    params = {'q': location, 'format': 'json'}
    response = requests.get(NOMINATIM_URL, params=params, headers={'User-Agent': 'smart-rtc-app'})
    return response.json()

@app.get("/route/")
def get_route(start: str = Query(...), end: str = Query(...)):
    start_coords = get_coordinates(start)
    end_coords = get_coordinates(end)

    if not start_coords or not end_coords:
        return {"error": "Unable to get coordinates"}

    payload = {
        "coordinates": [
            [start_coords["lon"], start_coords["lat"]],
            [end_coords["lon"], end_coords["lat"]]
        ]
    }

    headers = {
        'Authorization': ORS_API_KEY,
        'Content-Type': 'application/json'
    }

    ors_url = "https://api.openrouteservice.org/v2/directions/driving-car/geojson"
    response = requests.post(ors_url, json=payload, headers=headers)

    try:
        return response.json()
    except Exception as e:
        return {"error": f"Invalid response from ORS: {str(e)}"}

def get_coordinates(location):
    res = requests.get(NOMINATIM_URL, params={'q': location, 'format': 'json'}, headers={'User-Agent': 'smart-rtc-app'})
    data = res.json()
    if data:
        return {"lat": float(data[0]["lat"]), "lon": float(data[0]["lon"])}
    return None
