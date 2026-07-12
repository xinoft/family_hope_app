import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../models/gallery_item.dart';

// TODO(gallery-upload): staff need an upload flow (file picker -> base64
// encode -> POST /Gallery/UploadGalleryFiles, with progress polled via
// GET /Gallery/GetUploadProgress?uploadTrackingId=... - see
// GalleryUploadRequest/GalleryManager.UploadGalleryFiles on the backend).
// Staff's `add` capability on AppModule.gallery is already granted by
// PersonaPolicy, so this is purely a Flutter-side gap: add an
// `uploadFiles(...)` method here and a FAB/entry point in GalleryPage,
// gated with `PermissionGate(module: AppModule.gallery, action:
// CapabilityAction.add)`, matching the pattern used elsewhere in the app.
class GalleryRepository {
  final ApiClient _apiClient;

  GalleryRepository(this._apiClient);

  Future<List<GalleryItem>> fetchStudentGallery({
    required String studentId,
    int skip = 0,
    int take = 30,
  }) async {
    final result = await _apiClient.getResult(
      '/Gallery/GetStudentGallery',
      queryParameters: {'studentId': studentId, 'skip': skip, 'take': take},
    );
    return _parseItems(result);
  }

  Future<List<GalleryItem>> fetchSharedGallery({int skip = 0, int take = 30}) async {
    final result = await _apiClient.getResult(
      '/Gallery/GetSharedGallery',
      queryParameters: {'skip': skip, 'take': take},
    );
    return _parseItems(result);
  }

  List<GalleryItem> _parseItems(dynamic result) {
    return (result as List)
        .map((item) => GalleryItem.fromJson(
              item as Map<String, dynamic>,
              apiBaseUrl: AppConfig.current.apiBaseUrl,
            ))
        .toList();
  }
}
