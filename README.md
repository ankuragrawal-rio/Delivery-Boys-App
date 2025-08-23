# Rio Delivery App

A Flutter application for managing delivery operations for Rio's 15-minute medicine delivery service in Noida, India.

## Prerequisites

### Install Flutter
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract and add to PATH
3. Run `flutter doctor` to verify installation

### Required Tools
- Android Studio or VS Code with Flutter extensions
- Android SDK
- Xcode (for iOS development)

## Project Setup

1. **Create Flutter Project**
   ```bash
   flutter create rio_delivery_app
   cd rio_delivery_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── utils/
│   ├── services/
│   └── theme/
├── data/
│   ├── models/
│   ├── repositories/
│   └── mock_services/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── domain/
    ├── entities/
    └── usecases/
```

## Features

- Authentication with OTP
- Order Management
- QR-based Pickup System
- Cash Management
- Earnings Dashboard
- Real-time Notifications
- Offline Support

## Development Phases

1. **Phase 1**: Flutter app with mock data service
2. **Phase 2**: Backend API integration
3. **Phase 3**: Pilot testing
4. **Phase 4**: Full deployment

## Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: Hive & SharedPreferences
- **HTTP Client**: Dio
- **QR Scanner**: mobile_scanner
- **Push Notifications**: Firebase Cloud Messaging

## Getting Started

After installing Flutter, run:
```bash
flutter create rio_delivery_app --org com.rio.delivery
cd rio_delivery_app
flutter pub add riverpod flutter_riverpod go_router hive dio mobile_scanner image_picker web_socket_channel firebase_messaging shared_preferences
flutter pub get
```
