# Okto iOS App

A native iOS app for personalized financial news, built with SwiftUI.

## Overview

This is a SwiftUI-based iOS application that connects to the Okto FastAPI backend to deliver personalized financial news and insights to users.

## Project Structure

```
ios/
├── OktoApp.swift              # App entry point
├── Models/
│   └── DataModels.swift       # All data models (User, News, Profile, etc.)
├── Services/
│   └── APIService.swift       # Backend API client
├── ViewModels/
│   ├── AuthViewModel.swift    # Authentication state management
│   └── FeedViewModel.swift    # News feed state management
├── Views/
│   ├── WelcomeView.swift      # Welcome/splash screen
│   ├── SignupView.swift       # Signup and login forms
│   ├── ProfileSetupView.swift # 4-step onboarding
│   ├── FeedView.swift         # News feed screen
│   └── FeedContainerView.swift # Main app with tabs
└── README.md                   # This file
```

## Getting Started

### Requirements

- Xcode 14.0+
- iOS 15.0+
- macOS 12.0+ (for development)

### Setup

1. **Open in Xcode**
   ```
   open ios/OktoApp.swift
   ```
   Or create a new Xcode project and add the Swift files to it.

2. **Create Xcode Project Structure**

   If starting from scratch:
   - Create a new iOS App in Xcode
   - Copy the Swift files into the project
   - Keep the folder structure as shown above

3. **Update API Base URL**

   In `Services/APIService.swift`, update the `baseURL` to match your backend:

   ```swift
   private let baseURL = "http://localhost:8000"  // Change for production
   ```

4. **Build and Run**
   ```
   ⌘ + R  (or Product → Run)
   ```

## Features

### ✅ Implemented

- **Authentication**: Signup and login with JWT
- **Profile Setup**: 4-step onboarding with profile data collection
- **News Feed**: Personalized financial news with filters
- **User Profile**: View and manage account settings
- **Navigation**: Tab-based navigation with 4 main screens
- **Offline Support**: Basic caching (can be enhanced)

### 🚀 Coming Soon

- Detailed insights and analytics
- Advanced news filtering
- Push notifications
- Dark mode optimizations
- Offline mode improvements

## Configuration

### Backend URL

By default, the app connects to `http://localhost:8000`. For different environments:

```swift
// Development
private let baseURL = "http://localhost:8000"

// Staging
private let baseURL = "https://api-staging.okto.app"

// Production
private let baseURL = "https://api.okto.app"
```

### API Key Management

The app stores the JWT token in `UserDefaults`:

```swift
UserDefaults.standard.set(response.access_token, forKey: "authToken")
```

For production, consider using the Keychain for secure token storage.

## Architecture

### MVVM Pattern

The app follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: `DataModels.swift` - Data structures
- **Views**: SwiftUI views for UI
- **ViewModels**: `AuthViewModel`, `FeedViewModel` - State management
- **Services**: `APIService` - API communication

### State Management

- `@StateObject` for view-level state
- `@EnvironmentObject` for app-wide state
- `@Published` properties for reactivity
- Combine framework for async operations

## API Integration

The app communicates with the FastAPI backend using:

- `URLSession` for HTTP requests
- `async/await` for asynchronous operations
- `Codable` for JSON encoding/decoding

### Available Endpoints

- `POST /auth/signup` - Create account
- `POST /auth/login` - Login
- `GET /users/me` - Get current user
- `GET /users/{id}/profile` - Get user profile
- `PUT /users/{id}/profile` - Update profile
- `GET /news/feed` - Get news feed
- `GET /insights/{id}` - Get insights

## Error Handling

The app includes comprehensive error handling:

```swift
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(String)
    case unauthorized
    case notFound
    case serverError
    case unknownError
    case networkError(String)
}
```

Errors are displayed to the user via the `errorMessage` property in ViewModels.

## Testing

### Manual Testing Checklist

1. **Authentication**
   - [ ] Signup with new email
   - [ ] Login with existing credentials
   - [ ] Logout functionality

2. **Profile Setup**
   - [ ] Complete all 4 steps
   - [ ] Values persist correctly
   - [ ] Error handling for incomplete forms

3. **News Feed**
   - [ ] News articles load
   - [ ] Category filtering works
   - [ ] Pull-to-refresh functionality

4. **Error Handling**
   - [ ] Network errors display properly
   - [ ] 401 errors trigger logout
   - [ ] 404 errors show not found message

### Unit Testing

To add unit tests:

1. Create `OktoTests` target in Xcode
2. Add tests for ViewModels:
   ```swift
   import XCTest
   @testable import Okto

   class AuthViewModelTests: XCTestCase {
       // Add test methods
   }
   ```

## Performance Optimization

### Image Caching

Consider adding image caching for news article images:

```swift
import SDWebImageSwiftUI

AsyncImage(url: imageURL) { image in
    image.resizable()
}
```

### Pagination

Implement pagination for the news feed to improve performance:

```swift
@State private var currentPage = 1
@State private var isLoadingMore = false

func loadMoreNews() {
    currentPage += 1
    // Load next page
}
```

### Network Optimization

- Implement request throttling
- Cache recent news articles
- Use conditional requests (If-Modified-Since)

## Deployment

### Testflight (Beta Testing)

1. Create an App ID in Apple Developer
2. Create an App Record in App Store Connect
3. Upload build via Xcode Organizer
4. Invite testers via TestFlight

### App Store Release

1. Prepare app for submission
2. Add required app icon, screenshots, description
3. Set pricing and availability
4. Submit for review

## Troubleshooting

### Common Issues

**Issue**: "Cannot connect to localhost API"
- **Solution**: Use your Mac's IP address instead of localhost on device
  ```swift
  private let baseURL = "http://192.168.1.100:8000"
  ```

**Issue**: JWT token expires
- **Solution**: Implement token refresh:
  ```swift
  if error == .unauthorized {
      // Attempt to refresh token
      // If fails, logout user
  }
  ```

**Issue**: Images not loading
- **Solution**: Check image URLs in API response
- Use `AsyncImage` with fallback placeholder

## Security Considerations

1. **Never hardcode credentials**
2. **Use HTTPS in production**
3. **Store sensitive data in Keychain** (not UserDefaults)
4. **Validate SSL certificates**
5. **Implement certificate pinning** for production

## Contributing

To contribute to the iOS app:

1. Follow SwiftUI best practices
2. Use MVVM architecture
3. Add comments for complex logic
4. Test on multiple devices
5. Follow Apple's Human Interface Guidelines

## Resources

- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [Combine Framework Guide](https://developer.apple.com/documentation/combine)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/)
- [URLSession Guide](https://developer.apple.com/documentation/foundation/urlsession)

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review error logs in Xcode console
3. Contact the development team
