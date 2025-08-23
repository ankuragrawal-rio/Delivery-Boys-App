# 🚀 Quick Development Setup Guide

## Recommended: VS Code + Flutter Web (Fastest Iteration)

### 1. Install Required Tools (5 minutes)

```bash
# Install Flutter via Homebrew (easiest)
brew install --cask flutter

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:/opt/homebrew/bin/flutter"

# Verify installation
flutter doctor
```

### 2. VS Code Setup (2 minutes)

1. **Install VS Code Extensions:**
   - Flutter (by Dart Code)
   - Dart (by Dart Code)

2. **Open Project:**
   ```bash
   code /Users/ankuragrawal/Code/projects/Delivery-Boys-App
   ```

### 3. Run App (30 seconds)

**Method 1: Command Palette**
- Press `Cmd+Shift+P`
- Type "Flutter: Launch Emulator"
- Select "Chrome (web-javascript)"
- Press `F5` to run

**Method 2: Terminal**
```bash
cd /Users/ankuragrawal/Code/projects/Delivery-Boys-App
flutter run -d chrome
```

### 4. Development Workflow

**Hot Reload (Instant Changes):**
- Save any file (`Cmd+S`) → Changes appear instantly
- Or press `r` in terminal
- Or press `Ctrl+F5` in VS Code

**Hot Restart (Full Restart):**
- Press `R` in terminal
- Or press `Shift+Cmd+F5` in VS Code

---

## Alternative: Android Studio (Best for Mobile Testing)

### Setup Steps:
1. Download Android Studio
2. Install Flutter plugin
3. Create AVD (Android Virtual Device)
4. Open project → Run

### Pros:
- Better mobile simulation
- Built-in device manager
- Excellent debugging tools

### Cons:
- Slower startup (2-3 minutes)
- Requires more resources

---

## Development Tips

### 🔥 Hot Reload Best Practices:
- **Works for:** UI changes, widget updates, styling
- **Doesn't work for:** New dependencies, main() changes, state initialization
- **When to restart:** Adding new packages, changing app structure

### 📱 Testing Strategy:
1. **Primary:** Chrome web (fastest iteration)
2. **Secondary:** Android emulator (mobile-specific testing)
3. **Final:** Real device (performance testing)

### 🛠️ Debugging Tools:
- **Flutter Inspector:** Widget tree visualization
- **DevTools:** Performance profiling
- **Debug Console:** Print statements and errors
- **Breakpoints:** Step-through debugging

---

## Quick Commands Reference

```bash
# Run on web
flutter run -d chrome

# Run on Android emulator
flutter run

# Hot reload
r

# Hot restart
R

# Quit
q

# Check for issues
flutter analyze

# Get dependencies
flutter pub get

# Clean build
flutter clean
```

---

## Recommended Workflow for This Project:

1. **Start development session:**
   ```bash
   cd /Users/ankuragrawal/Code/projects/Delivery-Boys-App
   flutter run -d chrome
   ```

2. **Make changes in VS Code**
3. **Save file** → See changes instantly
4. **Test features** in browser
5. **Periodically test on Android** for mobile-specific behavior

This setup gives you **sub-second feedback** for UI changes and allows rapid iteration on the Rio Delivery App features!
