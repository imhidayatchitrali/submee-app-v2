import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/helper_modal.dart';

import '../network/dio_client.dart';
import '../providers/environment_service.dart';

final helperModalService = Provider<HelperModalService>((ref) {
  final envService = ref.watch(environmentService);
  final client = ref.watch(dioClient);
  final service = HelperModalService(
    baseUrl: envService.environment.baseApiUrl,
    client: client,
  );
  return service;
});

class HelperModalService {
  HelperModalService({
    required this.baseUrl,
    required this.client,
  });

  final String baseUrl;
  final DioClient client;

  Future<List<HelperModal>> getUnseenHelpers() async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '$baseUrl/helpers/unseen',
      );
      return response.data!['results']
          .map<HelperModal>((e) => HelperModal.fromJson(e))
          .toList()
          .cast<HelperModal>();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markHelperAsSeen(int helperId) async {
    try {
      await client.post(
        '$baseUrl/helpers/$helperId/mark-seen',
      );
    } catch (e) {
      rethrow;
    }
  }
}
