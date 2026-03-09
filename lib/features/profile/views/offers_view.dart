import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../widgets/my_app_bar.dart';
import '../../home/controllers/home_tab_controller.dart';
import '../components/offer_card.dart';
import '../models/offer_model.dart';
import '../repositories/offers_repository.dart';
import 'offer_detail_view.dart';

final offersRepositoryProvider =
    Provider<OffersRepository>((ref) => OffersRepository());

final offersProvider =
    FutureProvider.autoDispose<List<OfferModel>>((ref) async {
  final userId = await Utils.getUserId() ?? '';
  if (userId.isEmpty) {
    return [];
  }
  final repository = ref.read(offersRepositoryProvider);
  return repository.fetchOffers(userId);
});

class OffersView extends HookConsumerWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'Offers',
            onBack: () {
              if (context.canPop()) {
                context.pop();
                return;
              }
              ref.read(homeTabControllerProvider).index = 0;
            },
            trailing: IconButton(
              icon:
                  const Icon(Icons.help_outline, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ),
          Expanded(
            child: offersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, _) => RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref.refresh(offersProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  children: [
                    Text(
                      'Failed to load offers. Pull to refresh.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              data: (offers) => RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref.refresh(offersProvider.future),
                child: offers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                        children: [
                          Text(
                            'No offers available right now.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        itemCount: offers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return OfferCard(
                            offer: offers[index],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OfferDetailView(
                                    offer: offers[index],
                                  ),
                                ),
                              );
                            },
                            onViewOffer: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OfferDetailView(
                                    offer: offers[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
