# 🚀 Quick Start Checklist

## Prerequisites ✓
- [ ] Flutter SDK installed (>=3.9.2)
- [ ] Android Studio or VS Code
- [ ] Android device or emulator
- [ ] BLE AAR files available

---

## Setup Steps

### 1. Dependencies Installation
```bash
cd wiseman_iot
flutter pub get
```
**Expected**: "Got dependencies!" message

### 2. Configure WisMan Server
**File**: `lib/core/network/wisman.dart` (Line 29-30)

```dart
static const String baseUrl = 'https://your-actual-server.com';
static const String path = '/api/your-endpoint';
```

### 3. Verify AAR Files
**Location**: `android/app/libs/`

Required files:
- [ ] `hxjblinklibrary-release.aar`
- [ ] `bleoad-release.aar`
- [ ] `dfu.aar`

### 4. Test Basic Build
```bash
flutter run
```

**Expected**: App launches to Login page

---

## Testing Authentication

### Test 1: Login Flow
1. **Launch app** → Login page appears
2. **Enter credentials**:
   - Account Name: `huixianggongyu-test`
   - Password: `E10ADC3949BA59ABBE56E057F20F883E`
3. **Tap Login**
4. **Expected**: Navigate to Home page showing:
   - Token ID
   - Expiration time (604800 seconds)

### Test 2: Check Logs
**In terminal/console, look for**:
```
[WisMan Request] ╔════════════════════════════════════════
[WisMan Request] ║ POST https://your-server.com/api
...
[WisMan Response] ║ Status: 200
[WisMan Response] ║ Data: {"resultCode":0,...}
```

### Test 3: Error Handling
1. Enter wrong password
2. **Expected**: Red snackbar with error message

---

## Next: Implement BLE (Native Android)

### Quick Steps
1. **Open**: `android/app/src/main/kotlin/com/example/wiseman_iot/BleMethodHandler.kt`
2. **Find**: `// TODO: Initialize HxjScanner and MyBleClient here`
3. **Add**:
   ```kotlin
   private val hxjScanner = HxjScanner(context)
   private val myBleClient = MyBleClient.getInstance()
   ```
4. **Implement**: Methods marked with TODO (see IMPLEMENTATION_GUIDE.md)

### BLE Implementation Priority
1. ✅ **startScan()** - Required for device discovery
2. ✅ **connect()** - Required for communication
3. ✅ **syncLockKeys()** - Core functionality
4. ✅ **openLock()** - Core functionality
5. ⏳ **disconnect()** - Cleanup
6. ⏳ **stopScan()** - Cleanup

---

## File Structure Quick Reference

```
wiseman_iot/
├── 📄 README.md                    # Project overview
├── 📄 IMPLEMENTATION_GUIDE.md      # Detailed implementation steps
├── 📄 WISMAN_API_REFERENCE.md      # API documentation
├── 📄 QUICK_START.md               # This file
│
├── lib/
│   ├── core/
│   │   ├── network/
│   │   │   └── wisman.dart         # 🔧 UPDATE SERVER URL HERE
│   │   └── ...
│   ├── features/
│   │   ├── auth/                   # ✅ Authentication (complete)
│   │   └── locks/                  # 🚧 BLE (Dart side complete)
│   └── main.dart                   # ✅ App entry point
│
└── android/
    └── app/
        ├── libs/                   # 🔧 PLACE AAR FILES HERE
        └── src/main/kotlin/com/example/wiseman_iot/
            ├── MainActivity.kt     # ✅ Complete
            ├── BleMethodHandler.kt # 🚧 IMPLEMENT TODOs HERE
            └── BleScanStreamHandler.kt # ✅ Complete
```

**Legend**:
- ✅ Complete and ready
- 🔧 Requires configuration
- 🚧 Requires implementation

---

## Common Issues & Solutions

### Issue: Build fails with "AAR not found"
**Solution**: 
```bash
# 1. Verify AAR files exist in android/app/libs/
# 2. Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Issue: Login fails with network error
**Solution**:
1. Check `baseUrl` in `lib/core/network/wisman.dart`
2. Verify server is accessible
3. Check device internet connection
4. Review logs in console

### Issue: Login succeeds but shows empty token
**Solution**:
1. Check WisMan response format
2. Verify `AuthResponseModel.fromJson()` parsing
3. Add debug prints in `auth_remote_datasource.dart`

### Issue: BLE methods return "Not implemented"
**Solution**:
1. This is expected - native TODOs not yet implemented
2. Follow IMPLEMENTATION_GUIDE.md steps 1-5
3. Implement HXJ SDK integration in `BleMethodHandler.kt`

---

## Development Workflow

### Making Changes
1. **Edit Dart code** → Hot reload (press `r` in terminal)
2. **Edit native Android** → Hot restart (press `R` in terminal)
3. **Add dependencies** → `flutter pub get` → Restart app
4. **Change gradle** → Rebuild: `flutter clean && flutter run`

### Debugging
- **Dart**: Use `print()` or `debugPrint()` or DevTools
- **Native**: Use `Log.d(TAG, "message")` or Android Studio debugger
- **BlocObserver**: Auto-logs all state changes to console
- **WisMan**: Auto-logs all HTTP requests/responses

### Testing Flow
1. Write code
2. Run `flutter run`
3. Test feature manually
4. Check logs for errors
5. Fix and hot reload
6. Repeat

---

## Quick Commands

```bash
# Install dependencies
flutter pub get

# Run app (debug)
flutter run

# Run app (release)
flutter run --release

# Clean build
flutter clean

# Check for outdated packages
flutter pub outdated

# Format code
dart format lib/

# Analyze code
flutter analyze

# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

---

## What to Do After Setup

### Phase 1: Verify Auth Works ✅
- [ ] Update WisMan server URL
- [ ] Run app
- [ ] Test login
- [ ] Verify token display on Home page

### Phase 2: Implement BLE Native 🚧
- [ ] Add HxjScanner initialization
- [ ] Implement startScan()
- [ ] Implement connect()
- [ ] Implement syncLockKeys()
- [ ] Implement openLock()
- [ ] Test each method

### Phase 3: Build Lock UI ⏳
- [ ] Create LockListPage (scan UI)
- [ ] Create LockFunPage (operations UI)
- [ ] Wire up HxjBleManager
- [ ] Add navigation from Home

### Phase 4: Polish & Production ⏳
- [ ] Add error handling
- [ ] Add loading states
- [ ] Add permissions handling
- [ ] Add local database
- [ ] Add tests
- [ ] Add app icon
- [ ] Prepare for release

---

## Resources

- **Main Guide**: `IMPLEMENTATION_GUIDE.md` - Detailed implementation steps
- **API Docs**: `WISMAN_API_REFERENCE.md` - WisMan protocol reference
- **Project README**: `README.md` - Architecture overview
- **This File**: `QUICK_START.md` - Quick reference

---

## Support Contacts

- **Flutter Docs**: https://docs.flutter.dev
- **Bloc Docs**: https://bloclibrary.dev
- **Dio Docs**: https://pub.dev/packages/dio

---

## Status Dashboard

| Component | Status | Location |
|-----------|--------|----------|
| WisMan Client | ✅ Complete | `lib/core/network/wisman.dart` |
| Auth Module | ✅ Complete | `lib/features/auth/` |
| Login UI | ✅ Complete | `lib/features/auth/presentation/pages/login_page.dart` |
| Home UI | ✅ Complete | `lib/features/auth/presentation/pages/home_page.dart` |
| BLE Models | ✅ Complete | `lib/features/locks/data/models/` |
| HxjBleManager | ✅ Dart Complete | `lib/features/locks/data/datasources/hxj_ble_manager.dart` |
| Android Bridge | 🚧 Skeleton | `android/.../BleMethodHandler.kt` |
| Lock List UI | ⏳ Not Started | - |
| Lock Fun UI | ⏳ Not Started | - |
| Tests | ⏳ Not Started | `test/` |

---

**Current Priority**: Configure WisMan server URL and test auth flow!

Good luck! 🎉
