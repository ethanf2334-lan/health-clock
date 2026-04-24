import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
class HealthDocument with _$HealthDocument {
  const factory HealthDocument({
    required String id,
    required String memberId,
    required String fileName,
    required int fileSize,
    required String mimeType,
    required String category,
    String? title,
    DateTime? documentDate,
    String? hospitalName,
    required String fileUrl,
    required String storageBucket,
    required String storageKey,
    String? ocrText,
    Map<String, dynamic>? aiSummary,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? downloadUrl,
  }) = _HealthDocument;

  factory HealthDocument.fromJson(Map<String, dynamic> json) =>
      _$HealthDocumentFromJson(json);
}

@freezed
class UploadSignatureRequest with _$UploadSignatureRequest {
  const factory UploadSignatureRequest({
    required String memberId,
    required String fileName,
    required int fileSize,
    required String mimeType,
  }) = _UploadSignatureRequest;

  factory UploadSignatureRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadSignatureRequestFromJson(json);
}

@freezed
class UploadSignature with _$UploadSignature {
  const factory UploadSignature({
    required String uploadUrl,
    required String objectKey,
    required String fileUrl,
    @Default(3600) int expiresIn,
  }) = _UploadSignature;

  factory UploadSignature.fromJson(Map<String, dynamic> json) =>
      _$UploadSignatureFromJson(json);
}

@freezed
class DocumentCreate with _$DocumentCreate {
  const factory DocumentCreate({
    required String memberId,
    required String fileName,
    required int fileSize,
    required String mimeType,
    required String category,
    String? title,
    DateTime? documentDate,
    String? hospitalName,
    required String fileUrl,
    required String storageBucket,
    required String storageKey,
  }) = _DocumentCreate;

  factory DocumentCreate.fromJson(Map<String, dynamic> json) =>
      _$DocumentCreateFromJson(json);
}
