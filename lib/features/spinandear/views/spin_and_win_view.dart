// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../widgets/k_dialog.dart';
import '../components/spin_result_dialog.dart';
import '../components/spin_wheel.dart';
import '../models/spin_reward.dart';

class SpinAndWinView extends HookWidget {
  const SpinAndWinView({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = useMemoized(
      () => const [
        SpinReward(label: '10E-Coins', type: SpinRewardType.coins, coins: 10),
        SpinReward(label: '25E-Coins', type: SpinRewardType.coins, coins: 25),
        SpinReward(label: '50E-Coins', type: SpinRewardType.coins, coins: 50),
        SpinReward(label: '100E-Coins', type: SpinRewardType.coins, coins: 100),
        SpinReward(label: 'Special Bonus', type: SpinRewardType.extraSpin),
        SpinReward(label: 'Jackpot Spin', type: SpinRewardType.jackpot),
        SpinReward(label: 'Free Recharge', type: SpinRewardType.extraSpin),
        SpinReward(label: 'Extra Spin', type: SpinRewardType.extraSpin),
      ],
    );

    final spinCount = useState(1);
    final isSpinning = useState(false);
    final rng = useMemoized(() => math.Random());
    final targetRotation = useState(0.0);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 2800),
    );
    final animation = useMemoized(
      () => CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      [controller],
    );
    final animValue = useAnimation(animation);

    Future<void> handleSpin() async {
      if (isSpinning.value || spinCount.value == 0) return;
      isSpinning.value = true;
      spinCount.value -= 1;

      final targetIndex = rng.nextInt(rewards.length);
      final anglePerSlice = (2 * math.pi) / rewards.length;
      final targetAngle =
          (rewards.length - targetIndex) * anglePerSlice - anglePerSlice / 2;
      final extraTurns = 5 + rng.nextInt(3);
      targetRotation.value = (extraTurns * 2 * math.pi) + targetAngle;
      await controller.forward(from: 0);

      final reward = rewards[targetIndex];
      KDialog.instance.openDialog(
        dialog: SpinResultDialog(
          reward: reward,
          onPrimaryTap: () {
            Navigator.of(context).pop();
            if (reward.type == SpinRewardType.extraSpin) {
              spinCount.value += 1;
            }
          },
        ),
      );

      isSpinning.value = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = constraints.maxHeight * 0.52;
          final curveHeight = headerHeight * 0.7;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Image.asset(
                  FileConstants.curve,
                  height: curveHeight,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: 86,
                child: Column(
                  children: [
                    Text(
                      'Spin And Win',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Spin the wheel once a day and stand a\nchance to win cashback, coupons, or free\nrecharge.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: curveHeight - 80,
                child: Center(
                  child: SpinWheel(
                    rewards: rewards,
                    rotation: targetRotation.value * animValue,
                    size: 260,
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 72,
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isSpinning.value ? null : handleSpin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isSpinning.value ? 'Spinning...' : 'Spin Now',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 36,
                child: Text(
                  'You have ${spinCount.value} free spin left today.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
