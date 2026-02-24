// ignore_for_file: deprecated_member_use

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
    final isBetterLuck = reward.type == SpinRewardType.betterLuck;
    final isExtraSpin = reward.type == SpinRewardType.extraSpin;

    final title = isBetterLuck
        ? 'Better Luck\nNext Time!'
        : isExtraSpin
            ? 'Woww,\nYou Got An Extra Spin!'
            : reward.type == SpinRewardType.jackpot
                ? 'Woww,\nJackpot Spin!'
                : 'Woww,\nYou Have Won ${reward.coins ?? 0}e-Coins';

    final subtitle = isBetterLuck
        ? "Don't give up! Spin again for another\nchance to win amazing rewards."
        : isExtraSpin
            ? 'Rock this chance and earn e-Coins for real\nuse. Spin now and boost your wallet!'
            : 'Use your earned e-Coins for real-world\nbenefits like mobile recharges, electricity\nbills, or credit card payments. Spin now\nand boost your wallet!';

    final buttonLabel =
        isBetterLuck || isExtraSpin ? 'Try Again' : 'Claim Now';

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
                    color: isBetterLuck
                        ? Colors.grey.shade700
                        : AppColors.textPrimary,
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
                  backgroundColor:
                      isBetterLuck ? Colors.grey.shade500 : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonLabel,
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
