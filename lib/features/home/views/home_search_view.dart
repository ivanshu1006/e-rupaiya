import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/search_textfield.dart';
import '../components/home_icon_tile.dart';
import '../components/home_section_header.dart';
import '../components/service_utils.dart';
import '../controllers/home_controller.dart';
import '../models/quick_action_model.dart';

class HomeSearchView extends HookConsumerWidget {
  const HomeSearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState('');
    final isLoading = useState(false);
    final error = useState<String?>(null);
    final results = useState<List<QuickActionCategory>>([]);
    Timer? debounce;

    useEffect(() {
      void fetch() async {
        isLoading.value = true;
        error.value = null;
        try {
          final data = await ref
              .read(homeRepositoryProvider)
              .fetchQuickActions(search: query.value.trim());
          results.value = data;
        } catch (_) {
          error.value = 'Failed to fetch services. Please try again.';
        } finally {
          isLoading.value = false;
        }
      }

      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 300), fetch);

      return () {
        debounce?.cancel();
      };
    }, [query.value]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'Search Services',
            showHelp: false,
            onBack: () => Navigator.of(context).pop(),
            onHelp: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchTextfield(
              hintText: 'Search Service',
              controller: searchController,
              onChange: (value) {
                query.value = value;
              },
            ),
          ),
          if (isLoading.value)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: CircularProgressIndicator(),
            )
          else if (error.value != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                error.value!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
              ),
            )
          else if (results.value.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'No services found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: results.value.length,
                itemBuilder: (context, index) {
                  final category = results.value[index];
                  return _CategorySection(
                    category: category,
                    onServiceTap: (serviceName) {
                      if (serviceName == 'Credit Card') {
                        context.push(RouteConstants.creditCardListing);
                      } else if (serviceName == 'Mobile Prepaid') {
                        context.push(RouteConstants.mobilePrepaid);
                      } else {
                        context.push(
                          RouteConstants.billerListing,
                          extra: serviceName,
                        );
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.onServiceTap,
  });

  final QuickActionCategory category;
  final void Function(String serviceName) onServiceTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: category.category,
            actionLabel: '',
            onAction: () {},
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              const int columns = 4;
              const double spacing = 12;
              final double itemWidth =
                  (maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 16,
                children: List.generate(category.services.length, (index) {
                  final service = category.services[index];
                  final icon = serviceIconMap[service.name];
                  return SizedBox(
                    width: itemWidth,
                    child: HomeIconTile(
                      label: displayServiceName(service.name),
                      asset: icon,
                      onTap: () => onServiceTap(service.name),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
