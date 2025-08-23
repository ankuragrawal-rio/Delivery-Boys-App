# Rio Delivery App - Setup Instructions

## Prerequisites

### 1. Install Flutter
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# For macOS:
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip
unzip flutter_macos_3.16.0-stable.zip

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:`pwd`/flutter/bin"

# Reload shell
source ~/.zshrc

# Verify installation
flutter doctor
```

### 2. Install Android Studio
- Download from https://developer.android.com/studio
- Install Flutter and Dart plugins
- Set up Android SDK

### 3. Install Xcode (macOS only)
- Install from App Store
- Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

## Project Setup

### 1. Navigate to Project Directory
```bash
cd /Users/ankuragrawal/Code/projects/Delivery-Boys-App
```

### 2. Get Flutter Dependencies
```bash
flutter pub get
```

### 3. Generate Code (for Hive models)
```bash
flutter packages pub run build_runner build
```

### 4. Run the App
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# For specific device
flutter devices  # List available devices
flutter run -d <device_id>
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── app.dart                # Main app widget
│   ├── router/
│   │   └── app_router.dart     # Navigation configuration
│   ├── services/
│   │   ├── auth_service.dart   # Authentication service
│   │   └── notification_service.dart # Push notifications
│   └── theme/
│       └── app_theme.dart      # App theme configuration
├── data/
│   ├── models/
│   │   ├── user_model.dart     # User data model
│   │   ├── order_model.dart    # Order data model
│   │   └── *.g.dart           # Generated Hive adapters
│   └── mock_services/
│       ├── mock_order_service.dart    # Mock order data
│       ├── mock_earnings_service.dart # Mock earnings data
│       ├── mock_cash_service.dart     # Mock cash data
│       └── mock_qr_service.dart       # Mock QR data
└── presentation/
    └── screens/
        ├── auth/               # Login & OTP screens
        ├── home/               # Dashboard & main navigation
        ├── orders/             # Order management
        ├── earnings/           # Earnings tracking
        ├── cash/               # Cash management
        ├── profile/            # User profile
        ├── qr/                 # QR scanner
        └── splash/             # Splash screen
```

## Features Implemented

### ✅ Authentication System
- Phone number based login
- OTP verification (accepts any 6-digit code for testing)
- Session management with SharedPreferences
- Auto-logout after inactivity

### ✅ Order Management
- View active, completed, and all orders
- Accept/reject orders with reasons
- Order details with customer info and items
- Order status tracking with timeline
- Mock data with 5 sample orders

### ✅ QR Scanner
- Camera-based QR code scanning
- Manual location code entry
- Location verification
- Order pickup confirmation
- Mock pickup locations (A1, A2, B1, B2, C3)

### ✅ Cash Management
- Real-time cash balance tracking
- Cash collection from orders
- Deposit functionality
- End-of-day reconciliation
- Transaction history
- Cash limit alerts

### ✅ Earnings Dashboard
- Today's earnings breakdown
- Performance metrics
- Weekly and monthly views
- Incentives and penalties tracking

### ✅ Profile Management
- Personal information display
- Vehicle details
- Document management
- Bank account details

## Testing the App

### 1. Login Flow
- Enter any 10-digit phone number
- Enter any 6-digit OTP (e.g., 123456)
- App will automatically log you in

### 2. Order Management
- View orders in different tabs (Active, Completed, All)
- Tap on orders to see details
- Accept/reject assigned orders
- Use QR scanner to simulate pickup

### 3. QR Scanner Testing
- Use manual entry with codes: A1, A2, B1, B2, or C3
- Scanner will show orders at that location
- Confirm pickup to update order status

### 4. Cash Management
- View current balance (starts at ₹890)
- Add cash collections
- Make deposits
- View transaction history
- Perform end-of-day reconciliation

## Mock Data

The app includes comprehensive mock data:
- **5 sample orders** with different statuses
- **5 pickup locations** with QR codes
- **Cash transactions** with running balance
- **Earnings data** for 30 days
- **User profile** with sample information

## Troubleshooting

### Common Issues

1. **Flutter not found**
   ```bash
   export PATH="$PATH:/path/to/flutter/bin"
   source ~/.zshrc
   ```

2. **Dependencies not found**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build errors**
   ```bash
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Android build issues**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

### Performance Tips
- Use Flutter DevTools for debugging
- Enable hot reload for faster development
- Use `flutter run --release` for production testing

## Next Steps

### Phase 2 - Backend Integration
1. Replace mock services with real API calls
2. Implement WebSocket for real-time updates
3. Add Firebase Cloud Messaging for push notifications
4. Integrate with actual QR code system

### Phase 3 - Advanced Features
1. Add navigation and maps integration
2. Implement customer signature capture
3. Add Hindi language support
4. Include gamification elements

## Support

For technical issues or questions:
- Check Flutter documentation: https://flutter.dev/docs
- Review the PRD document for feature specifications
- Test with mock data before backend integration

## Development Commands

```bash
# Hot reload during development
r

# Hot restart
R

# Quit
q

# Take screenshot
s

# List connected devices
flutter devices

# Install on specific device
flutter install -d <device_id>

# Build APK
flutter build apk

# Build for iOS
flutter build ios
```
