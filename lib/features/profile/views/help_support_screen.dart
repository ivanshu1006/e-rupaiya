import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/my_app_bar.dart';
import '../components/language_chip.dart';
import '../components/policy_banner_card.dart';
import '../components/policy_section_title.dart';

class HelpSupportScreen extends HookWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = useState(LanguageOption.english);
    String t(String en, String hi) =>
        language.value == LanguageOption.hindi ? hi : en;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(title: t('Help & Support', 'Help & Support')),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, 4.h, 0, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t('Help & Support', 'Help & Support'),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            LanguageChip(
                              value: language.value,
                              onChanged: (value) => language.value = value,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        PolicyBannerCard(
                          imageAsset: FileConstants.homeBanner12,
                        ),
                        SizedBox(height: 16.h),
                        PolicySectionTitle(
                          text: t('Help Topics', 'सहायता विषय'),
                        ),
                        SizedBox(height: 10.h),
                        _HelpTopicTile(
                          title: t(
                            'How can I keep my payments safe on e-Rupaiya?',
                            'मैं e‑Rupaiya पर अपने भुगतान सुरक्षित कैसे रखूँ?',
                          ),
                        ),
                        _HelpTopicTile(
                          title: t(
                            'How do I add my bank account on e-Rupaiya?',
                            'मैं e‑Rupaiya पर अपना बैंक अकाउंट कैसे जोड़ूँ?',
                          ),
                        ),
                        _HelpTopicTile(
                          title: t(
                            'How can I pay my bills using e-Rupaiya?',
                            'मैं e‑Rupaiya से बिल भुगतान कैसे करूँ?',
                          ),
                        ),
                        _HelpTopicTile(
                          title: t(
                            'How do I earn coins on e-Rupaiya?',
                            'मैं e‑Rupaiya पर कॉइन्स कैसे कमाऊँ?',
                          ),
                        ),
                        _HelpTopicTile(
                          title: t(
                            'How can I redeem my coins?',
                            'मैं अपने कॉइन्स रिडीम कैसे करूँ?',
                          ),
                        ),
                        _HelpTopicTile(
                          title: t(
                            'What should I do if my payment fails?',
                            'यदि भुगतान विफल हो जाए तो मुझे क्या करना चाहिए?',
                          ),
                        ),
                        SizedBox(height: 18.h),
                        PolicySectionTitle(
                          text: t('Recommended Videos', 'सुझाए गए वीडियो'),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            const Expanded(
                              child: _VideoCard(
                                color: Color(0xFFFFE1D6),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            const Expanded(
                              child: _VideoCard(
                                color: Color(0xFFEFEFEF),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                  _ContactHelpCard(
                    title: t('Need Help? We\'ve Got You',
                        'मदद चाहिए? हम आपके साथ हैं'),
                    subtitle: t('We Are Here To Help You!',
                        'हम आपकी सहायता के लिए यहाँ हैं!'),
                    onTap: () => context.push(RouteConstants.helpCenterChat),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTopicTile extends StatelessWidget {
  const _HelpTopicTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textPrimary.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}

class _ContactHelpCard extends StatelessWidget {
  const _ContactHelpCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFF08A55), Color(0xFFC4572D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 32.h,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              child: Text(
                'Contact Us',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
