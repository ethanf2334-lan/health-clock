import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';

part 'ai_input_provider.g.dart';

@riverpod
class AIParseResult extends _$AIParseResult {
  @override
  FutureOr<Map<String, dynamic>?> build() {
    return null;
  }

  Future<void> parseText(String text, {String? memberName}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/ai/parse-text',
        data: {
          'text': text,
          if (memberName != null) 'member_name': memberName,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    });
  }
}
