import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/document.dart';
import '../data/document_repository.dart';

part 'document_provider.g.dart';

@riverpod
class DocumentList extends _$DocumentList {
  String? _memberId;

  @override
  Future<List<HealthDocument>> build() {
    return ref
        .read(documentRepositoryProvider)
        .listDocuments(memberId: _memberId);
  }

  Future<void> setMemberFilter(String? memberId) async {
    _memberId = memberId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(documentRepositoryProvider)
          .listDocuments(memberId: memberId),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(documentRepositoryProvider)
          .listDocuments(memberId: _memberId),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(documentRepositoryProvider).deleteDocument(id);
    await refresh();
  }
}
