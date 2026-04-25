import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';
import '../../../shared/models/document.dart';

part 'document_repository.g.dart';

@riverpod
DocumentRepository documentRepository(DocumentRepositoryRef ref) {
  return DocumentRepository(ref.watch(dioProvider));
}

Map<String, dynamic> _normalizeDoc(Map<String, dynamic> j) => {
      'id': j['id'],
      'memberId': j['member_id'] ?? j['memberId'],
      'fileName': j['file_name'] ?? j['fileName'],
      'fileSize': j['file_size'] ?? j['fileSize'],
      'mimeType': j['mime_type'] ?? j['mimeType'],
      'category': j['category'],
      'title': j['title'],
      'documentDate': j['document_date'] ?? j['documentDate'],
      'hospitalName': j['hospital_name'] ?? j['hospitalName'],
      'fileUrl': j['file_url'] ?? j['fileUrl'],
      'storageBucket': j['storage_bucket'] ?? j['storageBucket'],
      'storageKey': j['storage_key'] ?? j['storageKey'],
      'ocrText': j['ocr_text'] ?? j['ocrText'],
      'aiSummary': j['ai_summary'] ?? j['aiSummary'],
      'createdAt': j['created_at'] ?? j['createdAt'],
      'updatedAt': j['updated_at'] ?? j['updatedAt'],
      'downloadUrl': j['download_url'] ?? j['downloadUrl'],
    };

Map<String, dynamic> _normalizeSig(Map<String, dynamic> j) => {
      'uploadUrl': j['upload_url'] ?? j['uploadUrl'],
      'objectKey': j['object_key'] ?? j['objectKey'],
      'fileUrl': j['file_url'] ?? j['fileUrl'],
      'expiresIn': j['expires_in'] ?? j['expiresIn'] ?? 3600,
    };

class DocumentRepository {
  final Dio _dio;
  DocumentRepository(this._dio);

  Future<UploadSignature> getUploadSignature(UploadSignatureRequest req) async {
    final resp = await _dio.post(
      '/documents/upload-signature',
      data: {
        'member_id': req.memberId,
        'file_name': req.fileName,
        'file_size': req.fileSize,
        'mime_type': req.mimeType,
      },
    );
    return UploadSignature.fromJson(
      _normalizeSig(resp.data['data'] as Map<String, dynamic>),
    );
  }

  /// 直传 R2（PUT 预签名）。
  Future<void> putFileToSignedUrl(
    String uploadUrl,
    File file,
    String mimeType,
  ) async {
    final bytes = await file.readAsBytes();
    final dio = Dio();
    await dio.put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentTypeHeader: mimeType,
          Headers.contentLengthHeader: bytes.length,
        },
      ),
    );
  }

  Future<HealthDocument> createDocument(DocumentCreate data) async {
    final resp = await _dio.post(
      '/documents',
      data: {
        'member_id': data.memberId,
        'file_name': data.fileName,
        'file_size': data.fileSize,
        'mime_type': data.mimeType,
        'category': data.category,
        if (data.title != null) 'title': data.title,
        if (data.documentDate != null)
          'document_date': data.documentDate!.toIso8601String(),
        if (data.hospitalName != null) 'hospital_name': data.hospitalName,
        'file_url': data.fileUrl,
        'storage_bucket': data.storageBucket,
        'storage_key': data.storageKey,
      },
    );
    return HealthDocument.fromJson(
      _normalizeDoc(resp.data['data'] as Map<String, dynamic>),
    );
  }

  Future<List<HealthDocument>> listDocuments({
    String? memberId,
    String? category,
  }) async {
    final resp = await _dio.get(
      '/documents',
      queryParameters: {
        if (memberId != null) 'member_id': memberId,
        if (category != null) 'category': category,
      },
    );
    final data = resp.data['data'] as List;
    return data
        .map(
          (e) =>
              HealthDocument.fromJson(_normalizeDoc(e as Map<String, dynamic>)),
        )
        .toList();
  }

  Future<HealthDocument> getDocument(String id) async {
    final resp = await _dio.get('/documents/$id');
    return HealthDocument.fromJson(
      _normalizeDoc(resp.data['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteDocument(String id) async {
    await _dio.delete('/documents/$id');
  }

  Future<Map<String, dynamic>> processOcr(String documentId) async {
    final resp = await _dio.post(
      '/documents/ocr',
      data: {
        'document_id': documentId,
      },
    );
    return resp.data['data'] as Map<String, dynamic>;
  }
}
