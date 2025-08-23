# Flutter Setup Guide for Rio Delivery App

## Quick Setup Commands

Since Flutter isn't installed on your system, here's how to get started:

### 1. Install Flutter

**For macOS:**
```bash
# Download Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip

# Extract to desired location
unzip flutter_macos_3.16.0-stable.zip

# Add to PATH (add this to your ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:`pwd`/flutter/bin"

# Reload shell
source ~/.zshrc
```

### 2. Verify Installation
```bash
flutter doctor
```

### 3. Create Rio Delivery App Project
```bash
# Navigate to your projects directory
cd /Users/ankuragrawal/Code/projects/Delivery-Boys-App

# Create Flutter project
flutter create rio_delivery_app --org com.rio.delivery

# Navigate to project
cd rio_delivery_app

# Add required dependencies
flutter pub add riverpod flutter_riverpod go_router hive hive_flutter dio mobile_scanner image_picker web_socket_channel firebase_messaging shared_preferences

# Get dependencies
flutter pub get
```

### 4. Run the App
```bash
# For Android
flutter run

# For iOS (if on macOS)
flutter run -d ios
```

## Alternative: Use Android Studio

1. Download Android Studio with Flutter plugin
2. Create new Flutter project through IDE
3. Use the project structure I'll create below

## Next Steps After Flutter Installation

Once Flutter is installed, I'll help you:
1. Set up the complete project structure
2. Implement authentication system
3. Create mock data services
4. Build the UI components
5. Add offline functionality

Let me know when Flutter is ready and I'll continue with the implementation!
