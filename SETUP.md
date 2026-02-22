# Okto iOS App - Complete Setup Guide

This guide will walk you through setting up the complete Okto system: FastAPI backend + iOS SwiftUI app.

## Prerequisites

- **macOS 12.0+** (for iOS development)
- **Xcode 14.0+**
- **Python 3.9+**
- **Git** (optional)
- **NewsAPI Key** (free: https://newsapi.org)

## Step 1: Get NewsAPI Key (2 minutes)

1. Go to https://newsapi.org
2. Click "Register"
3. Sign up with email
4. You'll get a free API key immediately
5. Save it for later

## Step 2: Set Up Backend (5-10 minutes)

### 2.1 Navigate to Backend Directory
```bash
cd backend
```

### 2.2 Create Python Virtual Environment
```bash
# Create venv
python3 -m venv venv

# Activate it
source venv/bin/activate
# On Windows:
# venv\Scripts\activate
```

You should see `(venv)` in your terminal prompt.

### 2.3 Install Dependencies
```bash
pip install -r requirements.txt
```

Wait for all packages to install (~2-3 minutes).

### 2.4 Configure Environment Variables
```bash
# Edit the .env file in the backend directory
# Add your NewsAPI key:
NEWSAPI_KEY=your-actual-newsapi-key-here
```

Keep other values as default for local development.

### 2.5 Start the Backend Server
```bash
python -m uvicorn main:app --reload
```

You should see:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
```

### 2.6 Test Backend (Optional)
Open in browser: http://localhost:8000/docs

You'll see the Swagger UI with all available API endpoints.

**Leave this terminal running.** Open a new terminal for iOS setup.

## Step 3: Create iOS Project in Xcode (10 minutes)

### 3.1 Create New Xcode Project
1. Open Xcode
2. File → New → Project
3. Select "iOS" → "App"
4. Click Next
5. Fill in:
   - **Product Name**: Okto
   - **Organization Identifier**: com.okto (or your domain)
   - **Interface**: SwiftUI
   - **Language**: Swift
6. Click Create
7. Choose a location to save (Desktop is fine)

### 3.2 Add Swift Files to Project

1. In Xcode, create folders:
   - Right-click project → New Group → "Models"
   - Right-click project → New Group → "Services"
   - Right-click project → New Group → "ViewModels"
   - Right-click project → New Group → "Views"

2. Copy Swift files:
   - Drag `DataModels.swift` to Models folder
   - Drag `APIService.swift` to Services folder
   - Drag `AuthViewModel.swift` and `FeedViewModel.swift` to ViewModels folder
   - Drag all `.swift` view files to Views folder

3. In the file dialog:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
   - Select your project target
   - Click "Finish"

### 3.3 Update Default View
Replace the content of `ContentView.swift` or `OktoApp.swift` with:

```swift
@main
struct OktoApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                FeedContainerView()
                    .environmentObject(authViewModel)
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
```

### 3.4 Update API Base URL

In `Services/APIService.swift`, find this line:
```swift
private let baseURL = "http://localhost:8000"
```

If running on simulator from your Mac, this will work as-is.

If running on a physical iPhone, change it to your Mac's IP:
```swift
private let baseURL = "http://192.168.1.100:8000"  // Replace with your IP
```

To find your IP:
```bash
# In terminal
ifconfig | grep inet
```

## Step 4: Build and Run iOS App (5 minutes)

### 4.1 Select Simulator
In Xcode, top toolbar:
- Scheme: "Okto"
- Destination: "iPhone 15 Pro" (or any simulator)

### 4.2 Build the Project
```
⌘ + B  (or Product → Build)
```

Wait for build to complete (check that there are no red errors).

### 4.3 Run the App
```
⌘ + R  (or Product → Run)
```

The simulator should launch and show the Okto welcome screen.

## Step 5: Test the Full Flow (10 minutes)

### 5.1 Signup
1. In the app, tap "Opret konto"
2. Fill in:
   - First Name: John
   - Last Name: Doe
   - Email: john@example.com
   - Password: password123
3. Tap "Opret konto"

Watch the terminal - you should see:
```
INFO:     POST /auth/signup HTTP/1.1" 200
```

### 5.2 Complete Profile Setup
1. You'll see "Om dig" (Step 1)
2. Adjust sliders and select options:
   - Age: 30
   - Region: Hovedstaden
   - Employment: Lønmodtager
   - Income: 450.000
3. Tap "Næste"
4. Repeat for steps 2, 3, and 4
5. Tap "Færdig - opret min profil"

The backend will save all this data to the database.

### 5.3 View News Feed
1. Once onboarding is complete, you'll see the News Feed
2. You should see financial news articles
3. Try refreshing (pull down)
4. Try clicking different category pills (Bolig, Lån, etc.)

### 5.4 Test Profile & Logout
1. Tap the "Profil" tab
2. See your user info displayed
3. Tap "Log ud"
4. You should return to Welcome screen

### 5.5 Test Login
1. Tap "Log ind"
2. Enter your email: john@example.com
3. Enter password: password123
4. Tap "Log ind"
5. You should go straight to the news feed

## Troubleshooting

### Backend Won't Start
```bash
# Check if port 8000 is in use
lsof -i :8000

# If yes, use different port
python -m uvicorn main:app --reload --port 8001

# Then update iOS: private let baseURL = "http://localhost:8001"
```

### iOS Can't Connect to Backend
```bash
# Test from simulator's perspective
# In simulator, open Safari and go to:
http://localhost:8000/docs

# If that fails, use your Mac's IP instead
# Find it:
ifconfig | grep "inet " | grep -v 127.0.0.1

# Use that IP in APIService.swift:
private let baseURL = "http://YOUR.IP:8000"
```

### Build Errors
```
# Clean and rebuild
⌘ + Shift + K  (Clean Build Folder)
⌘ + B          (Build)
```

### No News Articles Showing
1. Check that NEWSAPI_KEY is set in `backend/.env`
2. Check backend logs for errors
3. Manually test endpoint:
   ```bash
   curl http://localhost:8000/news/sources
   ```

### Database Errors in Backend
```bash
# Delete and recreate database
cd backend
rm okto.db
python -m uvicorn main:app --reload
```

## What's Next?

### Customize the App
1. **Change colors**: Edit Color RGB values in Views
2. **Change text**: All strings are hardcoded (add localization later)
3. **Add features**: Implement Explore and Insights tabs

### Deploy to Device
1. Connect iPhone via USB
2. In Xcode, change Destination to your iPhone
3. ⌘ + R to build and run

### Deploy to TestFlight
1. Create Apple Developer Account ($99/year)
2. Create App ID in Developer Portal
3. Create TestFlight record in App Store Connect
4. Archive app: Product → Archive
5. Upload via Xcode Organizer

### Deploy to Production
1. Submit for App Store Review
2. Apple approves (usually 1-3 days)
3. App goes live

## File Checklist

Make sure you have these files:

**Backend:**
- [ ] `backend/main.py`
- [ ] `backend/models.py`
- [ ] `backend/auth.py`
- [ ] `backend/news.py`
- [ ] `backend/config.py`
- [ ] `backend/requirements.txt`
- [ ] `backend/.env`

**iOS:**
- [ ] `ios/OktoApp.swift`
- [ ] `ios/Models/DataModels.swift`
- [ ] `ios/Services/APIService.swift`
- [ ] `ios/ViewModels/AuthViewModel.swift`
- [ ] `ios/ViewModels/FeedViewModel.swift`
- [ ] `ios/Views/WelcomeView.swift`
- [ ] `ios/Views/SignupView.swift`
- [ ] `ios/Views/ProfileSetupView.swift`
- [ ] `ios/Views/FeedView.swift`
- [ ] `ios/Views/FeedContainerView.swift`

## Performance Tips

### Make Backend Faster
```python
# In main.py, add response headers
from fastapi.middleware import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Make iOS App Faster
1. Use `.onAppear` to load data once
2. Cache images locally
3. Use lazy loading for lists

## Next Steps

1. ✅ You have a working iOS app connected to backend
2. 🎨 Customize the UI colors and fonts
3. 📱 Test on different device sizes
4. 🚀 Deploy to App Store
5. 📊 Monitor usage and optimize

## Getting Help

1. **Backend Issues**: Check `backend/README.md`
2. **iOS Issues**: Check `ios/README.md`
3. **API Issues**: Visit `http://localhost:8000/docs`
4. **NewsAPI Issues**: https://newsapi.org/docs

## Summary

You now have:
- ✅ FastAPI backend running on localhost:8000
- ✅ iOS app connecting to backend
- ✅ Full authentication flow
- ✅ Profile setup onboarding
- ✅ News feed with personalization
- ✅ User logout functionality

**Congratulations! 🎉 Your Okto app is ready to use.**

---

**Having issues?**
- Check terminal for error messages
- Use Xcode's debugging tools
- Test API endpoints in `http://localhost:8000/docs`
