import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/my_app_bar.dart';
import '../components/offer_card.dart';
import '../models/offer_model.dart';
import '../../home/controllers/home_tab_controller.dart';

class OffersView extends HookConsumerWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = useMemoized(
      () => kMockOffers.map(OfferModel.fromJson).toList(),
    );

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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return OfferCard(
                  offer: offers[index],
                  onViewOffer: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
