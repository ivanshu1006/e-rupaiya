import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../models/spin_reward.dart';

class SpinResultDialog extends StatelessWidget {
  const SpinResultDialog({
    super.key,
    required this.reward,
    required this.onPrimaryTap,
  });

  final SpinReward reward;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final isExtraSpin = reward.type == SpinRewardType.extraSpin;
    final title = isExtraSpin
        ? 'Woww,\nYou Got An Extra Spin!'
        : reward.type == SpinRewardType.jackpot
            ? 'Woww,\nJackpot Spin!'
            : 'Woww,\nYou Have Won ${reward.coins ?? 0}e-Coins';
    final subtitle = isExtraSpin
        ? 'Rock this chance and earn e-Coins for real\nuse. Spin now and boost your wallet!'
        : 'Use your earned e-Coins for real-world\nbenefits like mobile recharges, electricity\nbills, or credit card payments. Spin now\nand boost your wallet!';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onPrimaryTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isExtraSpin ? 'Spin Again' : 'Claim Now',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
