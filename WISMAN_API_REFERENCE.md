# WisMan API Reference

## Base Configuration

**File**: `lib/core/network/wisman.dart`

```dart
static const String baseUrl = 'https://your-wisman-server.com'; // TODO: Update
static const String path = '/api'; // TODO: Update
```

**Headers** (Auto-configured):
- `Content-Type: text/json; charset=utf-8`
- `Content-Version: 1.0`

---

## Envelope Format

### Request Structure
```json
{
  "msgId": <integer>,
  "method": "<method_name>",
  "tokenId": "<optional_token>",
  "data": {
    // Method-specific data
  }
}
```

### Response Structure
```json
{
  "msgId": <integer>,
  "method": "<method_name>",
  "resultCode": <integer>,  // 0 = success, non-zero = error
  "reason": "<string>",
  "data": {
    // Method-specific response data
  }
}
```

---

## Authentication

### Method: `apartmentLogin`

**Request**:
```json
{
  "msgId": 1701234567890,
  "method": "apartmentLogin",
  "data": {
    "accountName": "huixianggongyu-test",
    "password": "E10ADC3949BA59ABBE56E057F20F883E"
  }
}
```

**Success Response**:
```json
{
  "msgId": 1701234567890,
  "method": "apartmentLogin",
  "resultCode": 0,
  "reason": "Success",
  "data": {
    "tokenId": "Y0IFV96ntTMVlfElMC6TGUAE0HQ5ftc2S1rJ+ODDKbWp0eCB5ub/SjCT4S/0h/UoGdPGd1HpR8YH\nQSStG7g2Xg==",
    "expireTime": 604800
  }
}
```

**Error Codes**:
- `500001` - Account name cannot be empty
- `500002` - Password cannot be empty
- `500003` - Account does not exist
- `500004` - Password incorrect

**Usage in Dart**:
```dart
final wisMan = WisMan(Dio());

// Call without msgId (auto-generated)
final response = await wisMan.call(
  method: 'apartmentLogin',
  data: {
    'accountName': 'huixianggongyu-test',
    'password': 'E10ADC3949BA59ABBE56E057F20F883E', // MD5 hashed
  },
);

// Or with custom msgId
final response = await wisMan.call(
  method: 'apartmentLogin',
  msgId: 123456, // Optional: specify your own msgId
  data: {
    'accountName': 'huixianggongyu-test',
    'password': 'E10ADC3949BA59ABBE56E057F20F883E',
  },
);

final tokenId = response['tokenId'] as String;
final expireTime = response['expireTime'] as int;
```

**Note**: 
- `msgId` is **optional** - if not provided, it will be auto-generated
- `tokenId` is **optional** - only include it for authenticated requests (it will be omitted from the request body if not provided)

---

## Future WisMan Methods (To Be Added)

When adding new WisMan methods, follow this pattern:

### 1. Create Request Model
```dart
// lib/features/<feature>/data/models/<method>_request_model.dart
class YourMethodRequestModel {
  final String param1;
  final int param2;
  
  Map<String, dynamic> toJson() => {
    'param1': param1,
    'param2': param2,
  };
}
```

### 2. Create Response Model
```dart
// lib/features/<feature>/data/models/<method>_response_model.dart
class YourMethodResponseModel {
  final String result;
  
  factory YourMethodResponseModel.fromJson(Map<String, dynamic> json) {
    return YourMethodResponseModel(
      result: json['result'] as String,
    );
  }
}
```

### 3. Add to RemoteDataSource
```dart
// lib/features/<feature>/data/datasources/<feature>_remote_datasource.dart
abstract class IYourFeatureRemoteDataSource {
  Future<YourMethodResponseModel> yourMethod(YourMethodRequestModel request);
}

class YourFeatureRemoteDataSource implements IYourFeatureRemoteDataSource {
  final WisMan wisMan;
  final String? tokenId; // If authentication required
  
  @override
  Future<YourMethodResponseModel> yourMethod(YourMethodRequestModel request) async {
    final data = await wisMan.call(
      method: 'yourMethodName',
      data: request.toJson(),
      tokenId: tokenId, // Include if authenticated
    );
    
    return YourMethodResponseModel.fromJson(data);
  }
}
```

### 4. Add to Repository
```dart
// lib/features/<feature>/data/repositories/<feature>_repository_impl.dart
@override
Future<Either<Failure, YourMethodResponseModel>> yourMethod(
  YourMethodRequestModel request,
) async {
  try {
    final response = await remoteDataSource.yourMethod(request);
    return Right(response);
  } on ServerException catch (e) {
    return Left(ServerFailure(
      message: e.message,
      resultCode: e.resultCode,
      reason: e.reason,
    ));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure('Unexpected error: $e'));
  }
}
```

### 5. Create UseCase
```dart
// lib/features/<feature>/domain/usecases/<method>_usecase.dart
class YourMethodUseCase {
  final IYourFeatureRepository repository;
  
  Future<Either<Failure, YourMethodResponseModel>> call({
    required String param1,
    required int param2,
  }) {
    final request = YourMethodRequestModel(
      param1: param1,
      param2: param2,
    );
    return repository.yourMethod(request);
  }
}
```

---

## Example: Adding a Hypothetical "getLockList" Method

Assuming WisMan has a method to fetch locks for an account:

**1. Request Model**:
```dart
// lib/features/locks/data/models/get_lock_list_request_model.dart
class GetLockListRequestModel {
  final int page;
  final int pageSize;
  
  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
  };
}
```

**2. Response Model**:
```dart
// lib/features/locks/data/models/get_lock_list_response_model.dart
class GetLockListResponseModel {
  final List<LockModel> locks;
  final int total;
  
  factory GetLockListResponseModel.fromJson(Map<String, dynamic> json) {
    return GetLockListResponseModel(
      locks: (json['locks'] as List)
          .map((lock) => LockModel.fromJson(lock))
          .toList(),
      total: json['total'] as int,
    );
  }
}
```

**3. Remote DataSource**:
```dart
// lib/features/locks/data/datasources/locks_remote_datasource.dart
abstract class ILocksRemoteDataSource {
  Future<GetLockListResponseModel> getLockList(
    GetLockListRequestModel request,
    String tokenId,
  );
}

class LocksRemoteDataSource implements ILocksRemoteDataSource {
  final WisMan wisMan;
  
  @override
  Future<GetLockListResponseModel> getLockList(
    GetLockListRequestModel request,
    String tokenId,
  ) async {
    final data = await wisMan.call(
      method: 'getLockList',
      data: request.toJson(),
      tokenId: tokenId,
    );
    
    return GetLockListResponseModel.fromJson(data);
  }
}
```

**4. Usage**:
```dart
final response = await locksRemoteDataSource.getLockList(
  GetLockListRequestModel(page: 1, pageSize: 20),
  'YOUR_TOKEN_ID',
);

print('Found ${response.locks.length} locks');
```

---

## Debugging Tips

### Enable Logging
Logs are automatically enabled via `WisManLoggingInterceptor`.

Check console for:
```
[WisMan Request] ╔════════════════════════════════════════
[WisMan Request] ║ POST https://your-server.com/api
[WisMan Request] ║ Headers:
[WisMan Request] ║   Content-Type: text/json; charset=utf-8
[WisMan Request] ║   Content-Version: 1.0
[WisMan Request] ║ Body: {"msgId":123456,"method":"apartmentLogin",...}
[WisMan Request] ╚════════════════════════════════════════

[WisMan Response] ╔════════════════════════════════════════
[WisMan Response] ║ Status: 200
[WisMan Response] ║ Data: {"msgId":123456,"resultCode":0,...}
[WisMan Response] ╚════════════════════════════════════════
```

### Common Issues

**Issue**: `resultCode != 0` (Server error)
- Check the `reason` field for details
- Verify request data matches expected format
- Ensure tokenId is valid (if required)

**Issue**: Network timeout
- Check `baseUrl` is correct
- Verify server is reachable
- Check firewall/network settings

**Issue**: JSON parsing error
- Verify response structure matches model
- Check for null fields
- Use optional chaining (`as String?`)

---

## Password Hashing (MD5)

**Important**: Password must be MD5 hashed before sending.

**Example** (not included in project, add if needed):
```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String md5Hash(String input) {
  return md5.convert(utf8.encode(input)).toString().toUpperCase();
}

// Usage:
final password = '123456';
final hashedPassword = md5Hash(password); // E10ADC3949BA59ABBE56E057F20F883E
```

**Add to pubspec.yaml if needed**:
```yaml
dependencies:
  crypto: ^3.0.3
```

---

## Token Management

Currently, the token is passed around manually. For production:

**Option 1: Store in Memory (Current)**
```dart
class TokenManager {
  static String? _tokenId;
  
  static void setToken(String token) => _tokenId = token;
  static String? getToken() => _tokenId;
  static void clearToken() => _tokenId = null;
}
```

**Option 2: Store Securely**
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'tokenId', value: tokenId);
final token = await storage.read(key: 'tokenId');
```

**Option 3: Auto-inject in WisMan**
```dart
class WisMan {
  String? _tokenId;
  
  void setToken(String token) => _tokenId = token;
  
  Future<Map<String, dynamic>> call({...}) async {
    // Auto-use stored token if not provided
    final token = tokenId ?? _tokenId;
    // ...
  }
}
```

---

## Testing WisMan Calls

Use the test credentials provided:
- **Account**: `huixianggongyu-test`
- **Password**: `E10ADC3949BA59ABBE56E057F20F883E` (MD5 of `123456`)

**Quick Test**:
```dart
void testWisManLogin() async {
  final wisMan = WisMan(Dio());
  
  try {
    final response = await wisMan.call(
      method: 'apartmentLogin',
      data: {
        'accountName': 'huixianggongyu-test',
        'password': 'E10ADC3949BA59ABBE56E057F20F883E',
      },
    );
    
    print('Login successful!');
    print('Token: ${response['tokenId']}');
    print('Expires in: ${response['expireTime']} seconds');
  } catch (e) {
    print('Login failed: $e');
  }
}
```

---

**Remember**: Update `baseUrl` and `path` in `lib/core/network/wisman.dart` before testing!
