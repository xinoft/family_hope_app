enum GalleryMediaType { image, video, other }

/// Mirrors `Gallery/GetStudentGallery` and `Gallery/GetSharedGallery`'s
/// items - see `InkersCore.Models.DataModels.GalleryListData`. `studentId`
/// is null for shared items (they aren't tied to one student).
class GalleryItem {
  final String id;
  final String fileId;
  final String? studentId;
  final String fileName;
  final String contentType;
  final String fileUrl;
  final DateTime createdTime;
  final GalleryMediaType mediaType;

  const GalleryItem({
    required this.id,
    required this.fileId,
    required this.studentId,
    required this.fileName,
    required this.contentType,
    required this.fileUrl,
    required this.createdTime,
    required this.mediaType,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json, {required String apiBaseUrl}) {
    final contentType = json['ContentType'] as String? ?? '';
    final createdTime = DateTime.tryParse(json['CreatedTime'] as String? ?? '') ?? DateTime.now();

    return GalleryItem(
      id: (json['Id'] ?? 0).toString(),
      fileId: (json['FileId'] ?? 0).toString(),
      studentId: json['StudentId']?.toString(),
      fileName: json['FileName'] as String? ?? '',
      contentType: contentType,
      fileUrl: _resolveUrl(json['FileUrl'] as String? ?? '', apiBaseUrl),
      createdTime: createdTime,
      mediaType: _mediaTypeOf(contentType),
    );
  }

  static GalleryMediaType _mediaTypeOf(String contentType) {
    if (contentType.startsWith('image/')) return GalleryMediaType.image;
    if (contentType.startsWith('video/')) return GalleryMediaType.video;
    return GalleryMediaType.other;
  }

  /// The backend returns an already-absolute URL for cloud-stored files,
  /// but a relative path (e.g. `Gallery/GetGalleryFile?fileId=1`) for
  /// locally-stored ones - see `GalleryManager.GetPublicFileUrl`.
  static String _resolveUrl(String rawUrl, String apiBaseUrl) {
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    final base = apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
    final path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '$base$path';
  }
}
