import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/policy_page.dart';
import '../repositories/policy_pages_repository.dart';

final policyPagesRepositoryProvider = Provider<PolicyPagesRepository>(
  (ref) => PolicyPagesRepository(),
);

final policyPageControllerProvider = StateNotifierProvider.family
    .autoDispose<PolicyPageController, AsyncValue<PolicyPageData>, String>(
  (ref, slug) => PolicyPageController(
    repository: ref.watch(policyPagesRepositoryProvider),
    slug: slug,
  )..load(),
);

class PolicyPageController extends StateNotifier<AsyncValue<PolicyPageData>> {
  PolicyPageController({
    required PolicyPagesRepository repository,
    required String slug,
  })  : _repository = repository,
        _slug = slug,
        super(const AsyncValue.loading());

  final PolicyPagesRepository _repository;
  final String _slug;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final page = await _repository.fetchPage(_slug);
      state = AsyncValue.data(page);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
