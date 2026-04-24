// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthDocumentImpl _$$HealthDocumentImplFromJson(Map<String, dynamic> json) =>
    _$HealthDocumentImpl(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      mimeType: json['mimeType'] as String,
      category: json['category'] as String,
      title: json['title'] as String?,
      documentDate: json['documentDate'] == null
          ? null
          : DateTime.parse(json['documentDate'] as String),
      hospitalName: json['hospitalName'] as String?,
      fileUrl: json['fileUrl'] as String,
      storageBucket: json['storageBucket'] as String,
      storageKey: json['storageKey'] as String,
      ocrText: json['ocrText'] as String?,
      aiSummary: json['aiSummary'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      downloadUrl: json['downloadUrl'] as String?,
    );

Map<String, dynamic> _$$HealthDocumentImplToJson(
        _$HealthDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
      'category': instance.category,
      'title': instance.title,
      'documentDate': instance.documentDate?.toIso8601String(),
      'hospitalName': instance.hospitalName,
      'fileUrl': instance.fileUrl,
      'storageBucket': instance.storageBucket,
      'storageKey': instance.storageKey,
      'ocrText': instance.ocrText,
      'aiSummary': instance.aiSummary,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'downloadUrl': instance.downloadUrl,
    };

_$UploadSignatureRequestImpl _$$UploadSignatureRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UploadSignatureRequestImpl(
      memberId: json['memberId'] as String,
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      mimeType: json['mimeType'] as String,
    );

Map<String, dynamic> _$$UploadSignatureRequestImplToJson(
        _$UploadSignatureRequestImpl instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
    };

_$UploadSignatureImpl _$$UploadSignatureImplFromJson(
        Map<String, dynamic> json) =>
    _$UploadSignatureImpl(
      uploadUrl: json['uploadUrl'] as String,
      objectKey: json['objectKey'] as String,
      fileUrl: json['fileUrl'] as String,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
    );

Map<String, dynamic> _$$UploadSignatureImplToJson(
        _$UploadSignatureImpl instance) =>
    <String, dynamic>{
      'uploadUrl': instance.uploadUrl,
      'objectKey': instance.objectKey,
      'fileUrl': instance.fileUrl,
      'expiresIn': instance.expiresIn,
    };

_$DocumentCreateImpl _$$DocumentCreateImplFromJson(Map<String, dynamic> json) =>
    _$DocumentCreateImpl(
      memberId: json['memberId'] as String,
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      mimeType: json['mimeType'] as String,
      category: json['category'] as String,
      title: json['title'] as String?,
      documentDate: json['documentDate'] == null
          ? null
          : DateTime.parse(json['documentDate'] as String),
      hospitalName: json['hospitalName'] as String?,
      fileUrl: json['fileUrl'] as String,
      storageBucket: json['storageBucket'] as String,
      storageKey: json['storageKey'] as String,
    );

Map<String, dynamic> _$$DocumentCreateImplToJson(
        _$DocumentCreateImpl instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
      'category': instance.category,
      'title': instance.title,
      'documentDate': instance.documentDate?.toIso8601String(),
      'hospitalName': instance.hospitalName,
      'fileUrl': instance.fileUrl,
      'storageBucket': instance.storageBucket,
      'storageKey': instance.storageKey,
    };
