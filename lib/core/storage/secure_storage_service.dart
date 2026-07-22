import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around secure, on-device storage for session data (auth
/// token, user type, entity id) that must survive app restarts.
class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _userTypeKey = 'user_type';
  static const _entityIdKey = 'entity_id';
  static const _themeModeKey = 'theme_mode';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveUserType(String userType) =>
      _storage.write(key: _userTypeKey, value: userType);

  Future<String?> readUserType() => _storage.read(key: _userTypeKey);

  /// The real backend id the session was established for - a staff
  /// `UserAccount` id, or (for now) a hardcoded student id for a parent.
  /// Persisted alongside the token so a real login can start writing a
  /// real id here without any other change to how sessions are restored.
  Future<void> saveEntityId(String entityId) =>
      _storage.write(key: _entityIdKey, value: entityId);

  Future<String?> readEntityId() => _storage.read(key: _entityIdKey);

  /// A device/UI preference, not session state - deliberately untouched
  /// by [clear()] so logging out doesn't reset it.
  Future<void> saveThemeMode(String mode) => _storage.write(key: _themeModeKey, value: mode);

  Future<String?> readThemeMode() => _storage.read(key: _themeModeKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userTypeKey);
    await _storage.delete(key: _entityIdKey);
  }
}
