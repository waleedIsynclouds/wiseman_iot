# WisMan IoT - Flutter + Native Android BLE Migration

A Flutter application integrating with the WisMan IoT platform and native Android BLE SDK for smart lock management.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with the following structure:

```
lib/
├── core/
│   ├── bloc_observer/      # Global BlocObserver for debugging
│   ├── error/              # Failures and exceptions
│   ├── network/            # WisMan HTTP client & interceptors
│   └── utils/              # Utilities (msgId generator, etc.)
├── features/
│   ├── auth/               # Authentication module
│   │   ├── data/           # Data sources, models, repositories
│   │   ├── domain/         # Use cases, repository interfaces
│   │   └── presentation/   # UI, Bloc/Cubit, states
│   └── locks/              # BLE lock management module
│       ├── data/           # BLE models, HxjBleManager
│       ├── domain/         # Lock-related use cases
│       └── presentation/   # Lock UI (TODO)
└── main.dart              # App entry point with DI setup
```

## 📦 Dependencies

### Flutter Packages
- **flutter_bloc** (^8.1.3) - State management
- **dio** (^5.4.0) - HTTP client for WisMan API
- **dartz** (^0.10.1) - Functional programming (Either, etc.)
- **equatable** (^2.0.5) - Value equality

### Native Android
- **hxjblinklibrary-release.aar** - HXJ BLE SDK (in `android/app/libs/`)
- **bleoad-release.aar** - BLE OAD support
- **dfu.aar** - Device firmware update
- **Nordic Semiconductor libraries**:
  - scanner: 1.6.0
  - log: 2.5.0
  - ble: 2.11.0

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.9.2)
- Android Studio / VS Code
- Android SDK (minSdk 21+)

### Installation

1. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

2. **Place BLE AAR files** (if not already present)
   - Copy `hxjblinklibrary-release.aar`, `bleoad-release.aar`, `dfu.aar` to `android/app/libs/`

3. **Update WisMan server URL**
   - Edit `lib/core/network/wisman.dart`
   - Update `baseUrl` and `path` constants with your WisMan server details

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔐 WisMan Authentication

### Protocol
All WisMan API calls use a custom JSON envelope:

**Request:**
```json
{
  "msgId": 123456,
  "method": "apartmentLogin",
  "tokenId": "optional-token",
  "data": {
    "accountName": "your-account",
    "password": "MD5_HASHED_PASSWORD"
  }
}
```

**Response:**
```json
{
  "msgId": 123456,
  "method": "apartmentLogin",
  "resultCode": 0,
  "reason": "Success",
  "data": {
    "tokenId": "YOUR_TOKEN",
    "expireTime": 604800
  }
}
```

### Login Credentials (Example)
- **Account Name**: `huixianggongyu-test`
- **Password (MD5)**: `E10ADC3949BA59ABBE56E057F20F883E`

## 📱 BLE Integration

### Flutter Side (`HxjBleManager`)
Located at `lib/features/locks/data/datasources/hxj_ble_manager.dart`

**Available methods:**
- `startScan({int timeoutMillis})` - Start BLE scanning
- `stopScan()` - Stop scanning
- `connect(String mac)` - Connect to lock
- `disconnect()` - Disconnect from lock
- `syncLockKeys(LockModel lock)` - Sync lock keys
- `openLock(LockModel lock)` - Open lock

### Android Side (Native Bridge)
Located at `android/app/src/main/kotlin/com/example/wiseman_iot/`

**Key classes:**
- `MainActivity.kt` - Sets up MethodChannel and EventChannel
- `BleMethodHandler.kt` - Handles method calls from Flutter
- `BleScanStreamHandler.kt` - Streams scan results to Flutter

**Channels:**
- **MethodChannel**: `com.example.hxjblesdk/ble`
- **EventChannel**: `com.example.hxjblesdk/ble_scan`

### ⚠️ TODO: Complete BLE Integration
The native Android side provides a **skeleton implementation** with TODOs. To complete:

1. **Initialize HXJ SDK classes** in `BleMethodHandler.kt`:
   ```kotlin
   private val hxjScanner = HxjScanner(context)
   private val myBleClient = MyBleClient.getInstance()
   ```

2. **Implement scan logic** using `HxjScanner`
3. **Implement connect/disconnect** using `MyBleClient`
4. **Port LockFunViewModel logic** for:
   - `syncLockKeys()`
   - `openLock()`
   - Other lock operations

## 🧪 Testing the App

### Test Authentication Flow
1. Run the app
2. Enter account credentials on Login page
3. Tap "Login"
4. On success, you'll see the Home page with token details

## 📝 Implementation Status

### ✅ Completed
- [x] Core architecture setup (Clean Architecture)
- [x] WisMan HTTP client with Dio & interceptors
- [x] Auth module (data, domain, presentation layers)
- [x] Login & Home UI pages
- [x] BlocObserver for state monitoring
- [x] Dependency injection in main.dart
- [x] Android Gradle configuration for BLE AARs
- [x] MethodChannel/EventChannel bridge (skeleton)
- [x] Dart BLE models (Lock, Device, Result)
- [x] HxjBleManager wrapper class

### 🚧 Remaining Work
- [ ] Complete native Android BLE SDK integration
- [ ] Create Lock List UI
- [ ] Create Lock Function UI
- [ ] Add proper error handling for BLE
- [ ] Implement lock data persistence
- [ ] Add tests

## 🔧 Configuration

### Update WisMan Server URL
File: `lib/core/network/wisman.dart`

```dart
static const String baseUrl = 'https://your-server.com';
static const String path = '/api/endpoint';
```

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Bloc Library](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Status**: Core architecture complete, BLE native integration pending.

