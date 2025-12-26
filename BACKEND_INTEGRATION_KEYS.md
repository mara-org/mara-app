# Backend Integration - Required Keys & Configuration for Aziz

## 🔑 Firebase Admin SDK Configuration

### Required for Backend Token Verification

The backend needs Firebase Admin SDK credentials to verify Firebase ID tokens sent by the mobile app.

#### 1. Firebase Service Account Key (JSON)

**What it is:**
- A JSON file containing credentials for Firebase Admin SDK
- Allows backend to verify Firebase ID tokens
- Required for `/api/v1/auth/session` and `/api/v1/auth/register` endpoints

**How to get it:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **`mara-6c4f8`**
3. Go to **Project Settings** → **Service Accounts** tab
4. Click **"Generate new private key"**
5. Download the JSON file (e.g., `mara-6c4f8-firebase-adminsdk-xxxxx.json`)

**What to do with it:**
- Store securely on backend server (environment variable or secure vault)
- **DO NOT** commit to git
- Use in backend code to initialize Firebase Admin SDK

**Backend code example:**
```python
import firebase_admin
from firebase_admin import credentials

# Initialize Firebase Admin SDK
cred = credentials.Certificate("path/to/service-account-key.json")
firebase_admin.initialize_app(cred)
```

**Or via environment variable:**
```python
import os
import json
import firebase_admin
from firebase_admin import credentials

# Load from environment variable
firebase_creds = json.loads(os.environ.get('FIREBASE_SERVICE_ACCOUNT_KEY'))
cred = credentials.Certificate(firebase_creds)
firebase_admin.initialize_app(cred)
```

---

## 🔐 Firebase Project Configuration

### Project Details (for reference)

- **Project ID**: `mara-6c4f8`
- **Project Name**: Mara
- **iOS Bundle ID**: `com.iammara.maraApp`
- **Android Package**: (if applicable)

### Firebase Authentication Settings

**Enabled Providers:**
- ✅ Email/Password
- ✅ Google Sign-In
- ✅ Apple Sign-In (iOS)

**Email Verification:**
- ✅ Email Link Verification enabled
- ✅ Action URL: `com.iammara.maraApp://verify-email`
- ✅ Password Reset URL: `com.iammara.maraApp://reset-password`

---

## 🌐 Backend API Endpoints

### Base URL
- **Staging (TestFlight)**: `https://mara-api-uoum.onrender.com`
- **Production**: (TBD)

### Required Endpoints

#### 1. POST `/api/v1/auth/register`
**Purpose**: Register new user after Firebase sign-up

**Request:**
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6...",
  "device_id": "D698E748-FBA2-4C9F-BE54-B486AF70E787",
  "device_name": "iPhone 17 Pro (iPhone)"
}
```

**Backend must:**
1. Verify Firebase ID token using Admin SDK
2. Extract user info: `uid`, `email`, `email_verified`
3. **CRITICAL**: Check `email_verified` claim - must be `true` before creating user
4. Create user in database
5. Return user data

**Response:**
```json
{
  "user": {
    "id": "user-uuid",
    "email": "user@example.com",
    "firebase_uid": "hPk4oXvbkTMHdY5QIPsRwt34vLq2",
    "email_verified": true,
    "created_at": "2025-01-20T10:00:00Z"
  }
}
```

---

#### 2. POST `/api/v1/auth/session`
**Purpose**: Create backend session after Firebase sign-in

**Request Headers:**
```
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "device_id": "D698E748-FBA2-4C9F-BE54-B486AF70E787",
  "device_name": "iPhone 17 Pro (iPhone)"
}
```

**Backend must:**
1. Verify Firebase ID token using Admin SDK
2. Extract user info: `uid`, `email`, `email_verified`
3. **CRITICAL**: Check `email_verified` claim - must be `true` before creating session
4. Check device limits (if applicable)
5. Create/update device record
6. Create session
7. Return session token

**Response:**
```json
{
  "token": "backend_session_token",
  "user": {
    "id": "user-uuid",
    "email": "user@example.com",
    "email_verified": true
  },
  "device": {
    "id": "device-uuid",
    "name": "iPhone 17 Pro (iPhone)"
  }
}
```

**Error Response (500):**
```json
{
  "error": {
    "code": 500,
    "message": "An internal server error occurred",
    "type": "internal_server_error",
    "path": "/api/v1/auth/session",
    "correlation_id": "6b528045-4575-4572-ac31-8482014f8ac6"
  }
}
```

**Note**: If token verification succeeds but backend returns 500, check:
- Database connection
- User record creation/update
- Device registration logic
- Session creation logic

---

#### 3. GET `/api/v1/auth/me`
**Purpose**: Get current user profile and entitlements

**Request Headers:**
```
Authorization: Bearer <backend_session_token>
```

**Response:**
```json
{
  "user": {
    "id": "user-uuid",
    "email": "user@example.com",
    "email_verified": true,
    "plan": "free",
    "created_at": "2025-01-20T10:00:00Z"
  },
  "entitlements": {
    "chat_quota": 10,
    "chat_quota_used": 3,
    "devices_allowed": 1,
    "devices_registered": 1
  }
}
```

---

## 🔒 Security Requirements

### Token Verification

**Backend MUST:**
1. Verify Firebase ID token on EVERY request with `Authorization: Bearer <token>`
2. Check token expiration
3. Verify token issuer: `https://securetoken.google.com/mara-6c4f8`
4. Verify token audience: `mara-6c4f8`
5. **CRITICAL**: Check `email_verified` claim before allowing access

### Email Verification Enforcement

**Backend MUST reject requests if:**
- `email_verified` claim is `false` or missing
- Token is expired
- Token issuer/audience doesn't match

**Example verification code:**
```python
from firebase_admin import auth

def verify_firebase_token(id_token: str):
    try:
        decoded_token = auth.verify_id_token(id_token)
        
        # Extract claims
        uid = decoded_token['uid']
        email = decoded_token.get('email')
        email_verified = decoded_token.get('email_verified', False)
        
        # CRITICAL: Enforce email verification
        if not email_verified:
            raise ValueError("Email not verified")
        
        return {
            'uid': uid,
            'email': email,
            'email_verified': email_verified
        }
    except Exception as e:
        raise ValueError(f"Token verification failed: {str(e)}")
```

---

## 📋 Environment Variables for Backend

### Required

```bash
# Firebase Admin SDK
FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account",...}'  # JSON string
# OR
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/service-account-key.json

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Backend
API_BASE_URL=https://mara-api-uoum.onrender.com
ENVIRONMENT=staging  # or production
```

### Optional

```bash
# Logging
LOG_LEVEL=INFO
ENABLE_REQUEST_LOGGING=true

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS_PER_MINUTE=60
```

---

## 🧪 Testing

### Test Firebase Token

Use this token structure for testing (backend should verify it):

```json
{
  "iss": "https://securetoken.google.com/mara-6c4f8",
  "aud": "mara-6c4f8",
  "sub": "hPk4oXvbkTMHdY5QIPsRwt34vLq2",
  "email": "test@iammara.com",
  "email_verified": true,
  "firebase": {
    "identities": {
      "email": ["test@iammara.com"]
    },
    "sign_in_provider": "password"
  }
}
```

### Test Endpoints

1. **Health Check**: `GET /health` (no auth required)
2. **Register**: `POST /api/v1/auth/register` (with Firebase token)
3. **Session**: `POST /api/v1/auth/session` (with Firebase token)
4. **Get User**: `GET /api/v1/auth/me` (with backend session token)

---

## 📞 Support

If you need:
- Firebase Console access
- Service account key generation help
- Token verification debugging
- Endpoint specification clarification

Contact: [Your contact info]

---

## ✅ Checklist for Backend Setup

- [ ] Firebase Service Account key downloaded
- [ ] Firebase Admin SDK initialized in backend
- [ ] Token verification implemented with email_verified check
- [ ] `/api/v1/auth/register` endpoint implemented
- [ ] `/api/v1/auth/session` endpoint implemented
- [ ] `/api/v1/auth/me` endpoint implemented
- [ ] Error handling with correlation IDs
- [ ] Request logging enabled
- [ ] Database connection configured
- [ ] Environment variables set
- [ ] Health check endpoint working
- [ ] Tested with mobile app

---

**Last Updated**: January 2025
**Version**: 1.0

