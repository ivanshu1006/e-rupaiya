// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/k_dialog.dart';
import '../../profile/controllers/profile_controller.dart';
import '../components/spin_result_dialog.dart';
import '../components/spin_wheel.dart';
import '../controllers/spin_options_controller.dart';
import '../models/spin_reward.dart';
import '../repositories/spin_repository.dart';

/// Static rewards always present on the wheel regardless of API data.
const _staticRewards = [
  SpinReward(label: 'Better Luck\nNext Time', type: SpinRewardType.betterLuck),
  SpinReward(label: 'Extra Spin', type: SpinRewardType.extraSpin),
  SpinReward(label: 'Jackpot Spin', type: SpinRewardType.jackpot),
];

class SpinAndWinView extends HookConsumerWidget {
  const SpinAndWinView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final profileController = ref.read(profileControllerProvider.notifier);
    final profile = profileState.profile;

    final totalSpins = profile?.normalSpinRemaining ?? 0;

    final spinCount = useState(totalSpins);
    final isSpinning = useState(false);

    final spinOptionsState = ref.watch(spinOptionsControllerProvider);

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
    final spinRepository = useMemoized(() => SpinRepository());

    // Sync spin count when profile updates
    useValueChanged<int, void>(totalSpins, (_, __) {
      spinCount.value = totalSpins;
    });

    // Fetch profile on mount (spin options are fetched on home screen)
    useEffect(() {
      Future.microtask(() async {
        if (profile == null) {
          profileController.fetchProfile();
        }
      });
      return null;
    }, const []);

    Future<void> handleSpin() async {
      final rewards = _buildRewards(spinOptionsState.options);
      if (isSpinning.value || spinCount.value == 0 || rewards.isEmpty) {
        return;
      }
      isSpinning.value = true;
      spinCount.value -= 1;

      final currentRewards = rewards;
      final targetIndex = rng.nextInt(currentRewards.length);
      final anglePerSlice = (2 * math.pi) / currentRewards.length;
      final targetAngle =
          (currentRewards.length - targetIndex) * anglePerSlice -
              anglePerSlice / 2;
      final extraTurns = 5 + rng.nextInt(3);
      targetRotation.value = (extraTurns * 2 * math.pi) + targetAngle;
      await controller.forward(from: 0);

      final reward = currentRewards[targetIndex];

      // Skip record-spin API call for "Better Luck Next Time"
      if (reward.type != SpinRewardType.betterLuck) {
        final spinType = reward.type == SpinRewardType.jackpot
            ? 'jackpot'
            : reward.type == SpinRewardType.extraSpin
                ? 'extra'
                : 'normal';

        // For jackpot, pick a random value from the jackpot options
        int rewardValue = reward.coins ?? 0;
        final jackpotValues =
            spinOptionsState.options['Jackpot Spin'] ?? const <int>[];
        if (reward.type == SpinRewardType.jackpot && jackpotValues.isNotEmpty) {
          rewardValue = jackpotValues[rng.nextInt(jackpotValues.length)];
        }

        spinRepository
            .recordSpin(spinType: spinType, rewardValue: rewardValue)
            .then((_) => profileController.fetchProfile())
            .catchError((_) {});
      }

      KDialog.instance.openDialog(
        dialog: SpinResultDialog(
          reward: reward,
          onPrimaryTap: () {
            Navigator.of(context).pop();
            if (reward.type == SpinRewardType.betterLuck ||
                reward.type == SpinRewardType.extraSpin) {
              spinCount.value += 1;
            } else {
              context.go(RouteConstants.home);
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
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: spinOptionsState.isLoading
                        ? const _SpinWheelShimmer(size: 260)
                        : spinOptionsState.errorMessage != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load.\nPlease try again.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () => ref
                                        .read(spinOptionsControllerProvider
                                            .notifier)
                                        .fetchSpinOptions(),
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : SpinWheel(
                                rewards:
                                    _buildRewards(spinOptionsState.options),
                                rotation: targetRotation.value * animValue,
                                size: 260,
                              ),
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
                    onPressed: (isSpinning.value) ? null : handleSpin,
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
                  'You have ${spinCount.value} free spin${spinCount.value == 1 ? '' : 's'} left today.',
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

List<SpinReward> _buildRewards(Map<String, List<int>> options) {
  final normalValues = options['Normal'] ?? const <int>[];
  final coinRewards = normalValues
      .map(
        (v) => SpinReward(
          label: '${v}E-Coins',
          type: SpinRewardType.coins,
          coins: v,
        ),
      )
      .toList();
  return [...coinRewards, ..._staticRewards];
}

class _SpinWheelShimmer extends StatefulWidget {
  const _SpinWheelShimmer({required this.size});

  final double size;

  @override
  State<_SpinWheelShimmer> createState() => _SpinWheelShimmerState();
}

class _SpinWheelShimmerState extends State<_SpinWheelShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = _controller.value * 3 - 1;
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.18),
              ],
              stops: const [0.25, 0.5, 0.75],
              begin: const Alignment(-1, -0.3),
              end: const Alignment(1, 0.3),
              transform: _SpinShimmerTransform(value),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        );
      },
    );
  }
}

class _SpinShimmerTransform extends GradientTransform {
  const _SpinShimmerTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
