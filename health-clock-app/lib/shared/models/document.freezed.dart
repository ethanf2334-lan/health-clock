// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthDocument _$HealthDocumentFromJson(Map<String, dynamic> json) {
  return _HealthDocument.fromJson(json);
}

/// @nodoc
mixin _$HealthDocument {
  String get id => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  DateTime? get documentDate => throw _privateConstructorUsedError;
  String? get hospitalName => throw _privateConstructorUsedError;
  String get fileUrl => throw _privateConstructorUsedError;
  String get storageBucket => throw _privateConstructorUsedError;
  String get storageKey => throw _privateConstructorUsedError;
  String? get ocrText => throw _privateConstructorUsedError;
  Map<String, dynamic>? get aiSummary => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get downloadUrl => throw _privateConstructorUsedError;

  /// Serializes this HealthDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthDocumentCopyWith<HealthDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthDocumentCopyWith<$Res> {
  factory $HealthDocumentCopyWith(
          HealthDocument value, $Res Function(HealthDocument) then) =
      _$HealthDocumentCopyWithImpl<$Res, HealthDocument>;
  @useResult
  $Res call(
      {String id,
      String memberId,
      String fileName,
      int fileSize,
      String mimeType,
      String category,
      String? title,
      DateTime? documentDate,
      String? hospitalName,
      String fileUrl,
      String storageBucket,
      String storageKey,
      String? ocrText,
      Map<String, dynamic>? aiSummary,
      DateTime createdAt,
      DateTime updatedAt,
      String? downloadUrl});
}

/// @nodoc
class _$HealthDocumentCopyWithImpl<$Res, $Val extends HealthDocument>
    implements $HealthDocumentCopyWith<$Res> {
  _$HealthDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? category = null,
    Object? title = freezed,
    Object? documentDate = freezed,
    Object? hospitalName = freezed,
    Object? fileUrl = null,
    Object? storageBucket = null,
    Object? storageKey = null,
    Object? ocrText = freezed,
    Object? aiSummary = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? downloadUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      documentDate: freezed == documentDate
          ? _value.documentDate
          : documentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hospitalName: freezed == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      storageBucket: null == storageBucket
          ? _value.storageBucket
          : storageBucket // ignore: cast_nullable_to_non_nullable
              as String,
      storageKey: null == storageKey
          ? _value.storageKey
          : storageKey // ignore: cast_nullable_to_non_nullable
              as String,
      ocrText: freezed == ocrText
          ? _value.ocrText
          : ocrText // ignore: cast_nullable_to_non_nullable
              as String?,
      aiSummary: freezed == aiSummary
          ? _value.aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthDocumentImplCopyWith<$Res>
    implements $HealthDocumentCopyWith<$Res> {
  factory _$$HealthDocumentImplCopyWith(_$HealthDocumentImpl value,
          $Res Function(_$HealthDocumentImpl) then) =
      __$$HealthDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String memberId,
      String fileName,
      int fileSize,
      String mimeType,
      String category,
      String? title,
      DateTime? documentDate,
      String? hospitalName,
      String fileUrl,
      String storageBucket,
      String storageKey,
      String? ocrText,
      Map<String, dynamic>? aiSummary,
      DateTime createdAt,
      DateTime updatedAt,
      String? downloadUrl});
}

/// @nodoc
class __$$HealthDocumentImplCopyWithImpl<$Res>
    extends _$HealthDocumentCopyWithImpl<$Res, _$HealthDocumentImpl>
    implements _$$HealthDocumentImplCopyWith<$Res> {
  __$$HealthDocumentImplCopyWithImpl(
      _$HealthDocumentImpl _value, $Res Function(_$HealthDocumentImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? category = null,
    Object? title = freezed,
    Object? documentDate = freezed,
    Object? hospitalName = freezed,
    Object? fileUrl = null,
    Object? storageBucket = null,
    Object? storageKey = null,
    Object? ocrText = freezed,
    Object? aiSummary = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? downloadUrl = freezed,
  }) {
    return _then(_$HealthDocumentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      documentDate: freezed == documentDate
          ? _value.documentDate
          : documentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hospitalName: freezed == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      storageBucket: null == storageBucket
          ? _value.storageBucket
          : storageBucket // ignore: cast_nullable_to_non_nullable
              as String,
      storageKey: null == storageKey
          ? _value.storageKey
          : storageKey // ignore: cast_nullable_to_non_nullable
              as String,
      ocrText: freezed == ocrText
          ? _value.ocrText
          : ocrText // ignore: cast_nullable_to_non_nullable
              as String?,
      aiSummary: freezed == aiSummary
          ? _value._aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthDocumentImpl implements _HealthDocument {
  const _$HealthDocumentImpl(
      {required this.id,
      required this.memberId,
      required this.fileName,
      required this.fileSize,
      required this.mimeType,
      required this.category,
      this.title,
      this.documentDate,
      this.hospitalName,
      required this.fileUrl,
      required this.storageBucket,
      required this.storageKey,
      this.ocrText,
      final Map<String, dynamic>? aiSummary,
      required this.createdAt,
      required this.updatedAt,
      this.downloadUrl})
      : _aiSummary = aiSummary;

  factory _$HealthDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String memberId;
  @override
  final String fileName;
  @override
  final int fileSize;
  @override
  final String mimeType;
  @override
  final String category;
  @override
  final String? title;
  @override
  final DateTime? documentDate;
  @override
  final String? hospitalName;
  @override
  final String fileUrl;
  @override
  final String storageBucket;
  @override
  final String storageKey;
  @override
  final String? ocrText;
  final Map<String, dynamic>? _aiSummary;
  @override
  Map<String, dynamic>? get aiSummary {
    final value = _aiSummary;
    if (value == null) return null;
    if (_aiSummary is EqualUnmodifiableMapView) return _aiSummary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? downloadUrl;

  @override
  String toString() {
    return 'HealthDocument(id: $id, memberId: $memberId, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, category: $category, title: $title, documentDate: $documentDate, hospitalName: $hospitalName, fileUrl: $fileUrl, storageBucket: $storageBucket, storageKey: $storageKey, ocrText: $ocrText, aiSummary: $aiSummary, createdAt: $createdAt, updatedAt: $updatedAt, downloadUrl: $downloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.documentDate, documentDate) ||
                other.documentDate == documentDate) &&
            (identical(other.hospitalName, hospitalName) ||
                other.hospitalName == hospitalName) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.storageBucket, storageBucket) ||
                other.storageBucket == storageBucket) &&
            (identical(other.storageKey, storageKey) ||
                other.storageKey == storageKey) &&
            (identical(other.ocrText, ocrText) || other.ocrText == ocrText) &&
            const DeepCollectionEquality()
                .equals(other._aiSummary, _aiSummary) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      memberId,
      fileName,
      fileSize,
      mimeType,
      category,
      title,
      documentDate,
      hospitalName,
      fileUrl,
      storageBucket,
      storageKey,
      ocrText,
      const DeepCollectionEquality().hash(_aiSummary),
      createdAt,
      updatedAt,
      downloadUrl);

  /// Create a copy of HealthDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthDocumentImplCopyWith<_$HealthDocumentImpl> get copyWith =>
      __$$HealthDocumentImplCopyWithImpl<_$HealthDocumentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthDocumentImplToJson(
      this,
    );
  }
}

abstract class _HealthDocument implements HealthDocument {
  const factory _HealthDocument(
      {required final String id,
      required final String memberId,
      required final String fileName,
      required final int fileSize,
      required final String mimeType,
      required final String category,
      final String? title,
      final DateTime? documentDate,
      final String? hospitalName,
      required final String fileUrl,
      required final String storageBucket,
      required final String storageKey,
      final String? ocrText,
      final Map<String, dynamic>? aiSummary,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? downloadUrl}) = _$HealthDocumentImpl;

  factory _HealthDocument.fromJson(Map<String, dynamic> json) =
      _$HealthDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get memberId;
  @override
  String get fileName;
  @override
  int get fileSize;
  @override
  String get mimeType;
  @override
  String get category;
  @override
  String? get title;
  @override
  DateTime? get documentDate;
  @override
  String? get hospitalName;
  @override
  String get fileUrl;
  @override
  String get storageBucket;
  @override
  String get storageKey;
  @override
  String? get ocrText;
  @override
  Map<String, dynamic>? get aiSummary;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get downloadUrl;

  /// Create a copy of HealthDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthDocumentImplCopyWith<_$HealthDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UploadSignatureRequest _$UploadSignatureRequestFromJson(
    Map<String, dynamic> json) {
  return _UploadSignatureRequest.fromJson(json);
}

/// @nodoc
mixin _$UploadSignatureRequest {
  String get memberId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;

  /// Serializes this UploadSignatureRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UploadSignatureRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UploadSignatureRequestCopyWith<UploadSignatureRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadSignatureRequestCopyWith<$Res> {
  factory $UploadSignatureRequestCopyWith(UploadSignatureRequest value,
          $Res Function(UploadSignatureRequest) then) =
      _$UploadSignatureRequestCopyWithImpl<$Res, UploadSignatureRequest>;
  @useResult
  $Res call({String memberId, String fileName, int fileSize, String mimeType});
}

/// @nodoc
class _$UploadSignatureRequestCopyWithImpl<$Res,
        $Val extends UploadSignatureRequest>
    implements $UploadSignatureRequestCopyWith<$Res> {
  _$UploadSignatureRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UploadSignatureRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
  }) {
    return _then(_value.copyWith(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UploadSignatureRequestImplCopyWith<$Res>
    implements $UploadSignatureRequestCopyWith<$Res> {
  factory _$$UploadSignatureRequestImplCopyWith(
          _$UploadSignatureRequestImpl value,
          $Res Function(_$UploadSignatureRequestImpl) then) =
      __$$UploadSignatureRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String memberId, String fileName, int fileSize, String mimeType});
}

/// @nodoc
class __$$UploadSignatureRequestImplCopyWithImpl<$Res>
    extends _$UploadSignatureRequestCopyWithImpl<$Res,
        _$UploadSignatureRequestImpl>
    implements _$$UploadSignatureRequestImplCopyWith<$Res> {
  __$$UploadSignatureRequestImplCopyWithImpl(
      _$UploadSignatureRequestImpl _value,
      $Res Function(_$UploadSignatureRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadSignatureRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
  }) {
    return _then(_$UploadSignatureRequestImpl(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UploadSignatureRequestImpl implements _UploadSignatureRequest {
  const _$UploadSignatureRequestImpl(
      {required this.memberId,
      required this.fileName,
      required this.fileSize,
      required this.mimeType});

  factory _$UploadSignatureRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UploadSignatureRequestImplFromJson(json);

  @override
  final String memberId;
  @override
  final String fileName;
  @override
  final int fileSize;
  @override
  final String mimeType;

  @override
  String toString() {
    return 'UploadSignatureRequest(memberId: $memberId, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadSignatureRequestImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, memberId, fileName, fileSize, mimeType);

  /// Create a copy of UploadSignatureRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadSignatureRequestImplCopyWith<_$UploadSignatureRequestImpl>
      get copyWith => __$$UploadSignatureRequestImplCopyWithImpl<
          _$UploadSignatureRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UploadSignatureRequestImplToJson(
      this,
    );
  }
}

abstract class _UploadSignatureRequest implements UploadSignatureRequest {
  const factory _UploadSignatureRequest(
      {required final String memberId,
      required final String fileName,
      required final int fileSize,
      required final String mimeType}) = _$UploadSignatureRequestImpl;

  factory _UploadSignatureRequest.fromJson(Map<String, dynamic> json) =
      _$UploadSignatureRequestImpl.fromJson;

  @override
  String get memberId;
  @override
  String get fileName;
  @override
  int get fileSize;
  @override
  String get mimeType;

  /// Create a copy of UploadSignatureRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadSignatureRequestImplCopyWith<_$UploadSignatureRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UploadSignature _$UploadSignatureFromJson(Map<String, dynamic> json) {
  return _UploadSignature.fromJson(json);
}

/// @nodoc
mixin _$UploadSignature {
  String get uploadUrl => throw _privateConstructorUsedError;
  String get objectKey => throw _privateConstructorUsedError;
  String get fileUrl => throw _privateConstructorUsedError;
  int get expiresIn => throw _privateConstructorUsedError;

  /// Serializes this UploadSignature to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UploadSignature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UploadSignatureCopyWith<UploadSignature> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadSignatureCopyWith<$Res> {
  factory $UploadSignatureCopyWith(
          UploadSignature value, $Res Function(UploadSignature) then) =
      _$UploadSignatureCopyWithImpl<$Res, UploadSignature>;
  @useResult
  $Res call(
      {String uploadUrl, String objectKey, String fileUrl, int expiresIn});
}

/// @nodoc
class _$UploadSignatureCopyWithImpl<$Res, $Val extends UploadSignature>
    implements $UploadSignatureCopyWith<$Res> {
  _$UploadSignatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UploadSignature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uploadUrl = null,
    Object? objectKey = null,
    Object? fileUrl = null,
    Object? expiresIn = null,
  }) {
    return _then(_value.copyWith(
      uploadUrl: null == uploadUrl
          ? _value.uploadUrl
          : uploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      objectKey: null == objectKey
          ? _value.objectKey
          : objectKey // ignore: cast_nullable_to_non_nullable
              as String,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UploadSignatureImplCopyWith<$Res>
    implements $UploadSignatureCopyWith<$Res> {
  factory _$$UploadSignatureImplCopyWith(_$UploadSignatureImpl value,
          $Res Function(_$UploadSignatureImpl) then) =
      __$$UploadSignatureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uploadUrl, String objectKey, String fileUrl, int expiresIn});
}

/// @nodoc
class __$$UploadSignatureImplCopyWithImpl<$Res>
    extends _$UploadSignatureCopyWithImpl<$Res, _$UploadSignatureImpl>
    implements _$$UploadSignatureImplCopyWith<$Res> {
  __$$UploadSignatureImplCopyWithImpl(
      _$UploadSignatureImpl _value, $Res Function(_$UploadSignatureImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadSignature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uploadUrl = null,
    Object? objectKey = null,
    Object? fileUrl = null,
    Object? expiresIn = null,
  }) {
    return _then(_$UploadSignatureImpl(
      uploadUrl: null == uploadUrl
          ? _value.uploadUrl
          : uploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      objectKey: null == objectKey
          ? _value.objectKey
          : objectKey // ignore: cast_nullable_to_non_nullable
              as String,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UploadSignatureImpl implements _UploadSignature {
  const _$UploadSignatureImpl(
      {required this.uploadUrl,
      required this.objectKey,
      required this.fileUrl,
      this.expiresIn = 3600});

  factory _$UploadSignatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$UploadSignatureImplFromJson(json);

  @override
  final String uploadUrl;
  @override
  final String objectKey;
  @override
  final String fileUrl;
  @override
  @JsonKey()
  final int expiresIn;

  @override
  String toString() {
    return 'UploadSignature(uploadUrl: $uploadUrl, objectKey: $objectKey, fileUrl: $fileUrl, expiresIn: $expiresIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadSignatureImpl &&
            (identical(other.uploadUrl, uploadUrl) ||
                other.uploadUrl == uploadUrl) &&
            (identical(other.objectKey, objectKey) ||
                other.objectKey == objectKey) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, uploadUrl, objectKey, fileUrl, expiresIn);

  /// Create a copy of UploadSignature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadSignatureImplCopyWith<_$UploadSignatureImpl> get copyWith =>
      __$$UploadSignatureImplCopyWithImpl<_$UploadSignatureImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UploadSignatureImplToJson(
      this,
    );
  }
}

abstract class _UploadSignature implements UploadSignature {
  const factory _UploadSignature(
      {required final String uploadUrl,
      required final String objectKey,
      required final String fileUrl,
      final int expiresIn}) = _$UploadSignatureImpl;

  factory _UploadSignature.fromJson(Map<String, dynamic> json) =
      _$UploadSignatureImpl.fromJson;

  @override
  String get uploadUrl;
  @override
  String get objectKey;
  @override
  String get fileUrl;
  @override
  int get expiresIn;

  /// Create a copy of UploadSignature
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadSignatureImplCopyWith<_$UploadSignatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentCreate _$DocumentCreateFromJson(Map<String, dynamic> json) {
  return _DocumentCreate.fromJson(json);
}

/// @nodoc
mixin _$DocumentCreate {
  String get memberId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  DateTime? get documentDate => throw _privateConstructorUsedError;
  String? get hospitalName => throw _privateConstructorUsedError;
  String get fileUrl => throw _privateConstructorUsedError;
  String get storageBucket => throw _privateConstructorUsedError;
  String get storageKey => throw _privateConstructorUsedError;

  /// Serializes this DocumentCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DocumentCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentCreateCopyWith<DocumentCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentCreateCopyWith<$Res> {
  factory $DocumentCreateCopyWith(
          DocumentCreate value, $Res Function(DocumentCreate) then) =
      _$DocumentCreateCopyWithImpl<$Res, DocumentCreate>;
  @useResult
  $Res call(
      {String memberId,
      String fileName,
      int fileSize,
      String mimeType,
      String category,
      String? title,
      DateTime? documentDate,
      String? hospitalName,
      String fileUrl,
      String storageBucket,
      String storageKey});
}

/// @nodoc
class _$DocumentCreateCopyWithImpl<$Res, $Val extends DocumentCreate>
    implements $DocumentCreateCopyWith<$Res> {
  _$DocumentCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? category = null,
    Object? title = freezed,
    Object? documentDate = freezed,
    Object? hospitalName = freezed,
    Object? fileUrl = null,
    Object? storageBucket = null,
    Object? storageKey = null,
  }) {
    return _then(_value.copyWith(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      documentDate: freezed == documentDate
          ? _value.documentDate
          : documentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hospitalName: freezed == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      storageBucket: null == storageBucket
          ? _value.storageBucket
          : storageBucket // ignore: cast_nullable_to_non_nullable
              as String,
      storageKey: null == storageKey
          ? _value.storageKey
          : storageKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentCreateImplCopyWith<$Res>
    implements $DocumentCreateCopyWith<$Res> {
  factory _$$DocumentCreateImplCopyWith(_$DocumentCreateImpl value,
          $Res Function(_$DocumentCreateImpl) then) =
      __$$DocumentCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String memberId,
      String fileName,
      int fileSize,
      String mimeType,
      String category,
      String? title,
      DateTime? documentDate,
      String? hospitalName,
      String fileUrl,
      String storageBucket,
      String storageKey});
}

/// @nodoc
class __$$DocumentCreateImplCopyWithImpl<$Res>
    extends _$DocumentCreateCopyWithImpl<$Res, _$DocumentCreateImpl>
    implements _$$DocumentCreateImplCopyWith<$Res> {
  __$$DocumentCreateImplCopyWithImpl(
      _$DocumentCreateImpl _value, $Res Function(_$DocumentCreateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DocumentCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? category = null,
    Object? title = freezed,
    Object? documentDate = freezed,
    Object? hospitalName = freezed,
    Object? fileUrl = null,
    Object? storageBucket = null,
    Object? storageKey = null,
  }) {
    return _then(_$DocumentCreateImpl(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      documentDate: freezed == documentDate
          ? _value.documentDate
          : documentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hospitalName: freezed == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      storageBucket: null == storageBucket
          ? _value.storageBucket
          : storageBucket // ignore: cast_nullable_to_non_nullable
              as String,
      storageKey: null == storageKey
          ? _value.storageKey
          : storageKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentCreateImpl implements _DocumentCreate {
  const _$DocumentCreateImpl(
      {required this.memberId,
      required this.fileName,
      required this.fileSize,
      required this.mimeType,
      required this.category,
      this.title,
      this.documentDate,
      this.hospitalName,
      required this.fileUrl,
      required this.storageBucket,
      required this.storageKey});

  factory _$DocumentCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentCreateImplFromJson(json);

  @override
  final String memberId;
  @override
  final String fileName;
  @override
  final int fileSize;
  @override
  final String mimeType;
  @override
  final String category;
  @override
  final String? title;
  @override
  final DateTime? documentDate;
  @override
  final String? hospitalName;
  @override
  final String fileUrl;
  @override
  final String storageBucket;
  @override
  final String storageKey;

  @override
  String toString() {
    return 'DocumentCreate(memberId: $memberId, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, category: $category, title: $title, documentDate: $documentDate, hospitalName: $hospitalName, fileUrl: $fileUrl, storageBucket: $storageBucket, storageKey: $storageKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentCreateImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.documentDate, documentDate) ||
                other.documentDate == documentDate) &&
            (identical(other.hospitalName, hospitalName) ||
                other.hospitalName == hospitalName) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.storageBucket, storageBucket) ||
                other.storageBucket == storageBucket) &&
            (identical(other.storageKey, storageKey) ||
                other.storageKey == storageKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      memberId,
      fileName,
      fileSize,
      mimeType,
      category,
      title,
      documentDate,
      hospitalName,
      fileUrl,
      storageBucket,
      storageKey);

  /// Create a copy of DocumentCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentCreateImplCopyWith<_$DocumentCreateImpl> get copyWith =>
      __$$DocumentCreateImplCopyWithImpl<_$DocumentCreateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentCreateImplToJson(
      this,
    );
  }
}

abstract class _DocumentCreate implements DocumentCreate {
  const factory _DocumentCreate(
      {required final String memberId,
      required final String fileName,
      required final int fileSize,
      required final String mimeType,
      required final String category,
      final String? title,
      final DateTime? documentDate,
      final String? hospitalName,
      required final String fileUrl,
      required final String storageBucket,
      required final String storageKey}) = _$DocumentCreateImpl;

  factory _DocumentCreate.fromJson(Map<String, dynamic> json) =
      _$DocumentCreateImpl.fromJson;

  @override
  String get memberId;
  @override
  String get fileName;
  @override
  int get fileSize;
  @override
  String get mimeType;
  @override
  String get category;
  @override
  String? get title;
  @override
  DateTime? get documentDate;
  @override
  String? get hospitalName;
  @override
  String get fileUrl;
  @override
  String get storageBucket;
  @override
  String get storageKey;

  /// Create a copy of DocumentCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentCreateImplCopyWith<_$DocumentCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
