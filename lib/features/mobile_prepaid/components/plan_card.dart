// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../models/plan_item.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final PlanItem plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content area
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left content: price, badges, dashed line, description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price + orange badge row
                        Row(
                          children: [
                            Text(
                              '₹ ${plan.amount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: _buildBadgeRow(context)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Dashed line
                        _buildDashedLine(),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          plan.description.isEmpty
                              ? 'No description available.'
                              : plan.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary.withOpacity(0.7),
                                    height: 1.35,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Orange circle arrow
                  _buildArrowCircle(),
                ],
              ),
            ),
            // Blue bottom bar
            if (plan.planName.isNotEmpty || plan.eCoins > 0)
              _buildBlueBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow(BuildContext context) {
    final hasValidity = plan.validity.isNotEmpty;
    final hasData = plan.data.isNotEmpty;

    if (!hasValidity && !hasData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasValidity) ...[
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Validity - ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                  ),
                  TextSpan(
                    text: plan.validity,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
          if (hasValidity && hasData) ...[
            Container(
              width: 1,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white.withOpacity(0.5),
            ),
          ],
          if (hasData) ...[
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Data - ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                    ),
                    TextSpan(
                      text: plan.data,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade300),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildArrowCircle() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 2.5,
        ),
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_right,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildBlueBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1B3554),
      ),
      child: Row(
        children: [
          if (plan.planName.isNotEmpty) ...[
            Expanded(
              child: Text(
                plan.planName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (plan.planName.isNotEmpty && plan.eCoins > 0)
            const SizedBox(width: 8),
          if (plan.eCoins > 0) ...[
            Icon(
              Icons.local_offer,
              color: Colors.white.withOpacity(0.85),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Get Assured ${plan.eCoins} E-Coins',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
