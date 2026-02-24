// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../models/plan_item.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.onViewDetails,
    this.onPayNow,
  });

  final PlanItem plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onPayNow;

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Price + E-Coins badge
              _PlanPriceRow(plan: plan),
              const SizedBox(height: 14),
              // Row 2: Validity | Data | Benefit images
              _PlanInfoRow(plan: plan),
              const SizedBox(height: 14),
              // Description
              Text(
                plan.description.isEmpty
                    ? 'No description available.'
                    : plan.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      height: 1.4,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 12),
              // View Details
              GestureDetector(
                onTap: onViewDetails ?? onTap,
                child: Text(
                  'View Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                ),
              ),
              const SizedBox(height: 14),
              // Pay Now button
              _PlanPayNowButton(
                onTap: onPayNow ?? onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanPriceRow extends StatelessWidget {
  const _PlanPriceRow({required this.plan});

  final PlanItem plan;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '₹ ${plan.amount}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                fontSize: 28,
              ),
        ),
        const Spacer(),
        if (plan.eCoins > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B3554),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Get Assured ${plan.eCoins} E-Coins',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ),
      ],
    );
  }
}

class _PlanInfoRow extends StatelessWidget {
  const _PlanInfoRow({required this.plan});

  final PlanItem plan;

  @override
  Widget build(BuildContext context) {
    final hasValidity = plan.validity.isNotEmpty;
    final hasData = plan.data.isNotEmpty;
    final hasBenefitImages = plan.benefitImages.isNotEmpty;

    return Row(
      children: [
        if (hasValidity)
          _PlanInfoColumn(
            label: 'Validity',
            value: plan.validity,
          ),
        if (hasValidity && hasData)
          Container(
            width: 1,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey.shade300,
          ),
        if (hasData)
          _PlanInfoColumn(
            label: 'Data',
            value: plan.data,
          ),
        if ((hasValidity || hasData) && hasBenefitImages) const Spacer(),
        if (hasBenefitImages) _PlanBenefitImages(images: plan.benefitImages),
      ],
    );
  }
}

class _PlanInfoColumn extends StatelessWidget {
  const _PlanInfoColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.5),
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
        ),
      ],
    );
  }
}

class _PlanBenefitImages extends StatelessWidget {
  const _PlanBenefitImages({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    const maxVisible = 3;
    final visibleImages = images.take(maxVisible).toList();
    final remaining = images.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: (visibleImages.length * 26.0) + 10,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < visibleImages.length; i++)
                Positioned(
                  left: i * 26.0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        visibleImages[i],
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (remaining > 0)
          Text(
            '+$remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
          ),
      ],
    );
  }
}

class _PlanPayNowButton extends StatelessWidget {
  const _PlanPayNowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      height: 38.h,
      width: double.infinity,
      onPressed: onTap,
      label: 'Pay Now',
      uppercaseLabel: false,
    );
  }
}
