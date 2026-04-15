import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/k_dialog.dart';
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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(0, 4.h, 0, 0.h),
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
                                    onChanged: (value) =>
                                        language.value = value,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              _TicketsCard(
                                onTap: () => context.push(RouteConstants.faq),
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                'Bill Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: 12.h),
                              SizedBox(
                                height: 128.h,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: const [
                                    _BillDetailCard(),
                                    _BillDetailCard(),
                                    _BillDetailCard(),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
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
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HelpTopicDetailView(
                                        title: t(
                                          'How can I keep my payments safe on e-Rupaiya?',
                                          'मैं e‑Rupaiya पर अपने भुगतान सुरक्षित कैसे रखूँ?',
                                        ),
                                        description: t(
                                          'To keep your payments safe on e‑Rupaiya, always use a strong password and never share your OTP or PIN. Enable app security features like fingerprint or face lock, avoid using public Wi‑Fi for transactions, and regularly check your transaction history. Update the app frequently to stay protected from security threats.',
                                          'अपने भुगतान सुरक्षित रखने के लिए मजबूत पासवर्ड रखें और OTP या PIN साझा न करें। फिंगरप्रिंट या फेस लॉक सक्षम करें, सार्वजनिक Wi‑Fi पर लेनदेन से बचें और अपने ट्रांजैक्शन नियमित रूप से जांचें। सुरक्षा के लिए ऐप अपडेट करते रहें।',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _HelpTopicTile(
                                title: t(
                                  'How do I add my bank account on e-Rupaiya?',
                                  'मैं e‑Rupaiya पर अपना बैंक अकाउंट कैसे जोड़ूँ?',
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HelpTopicDetailView(
                                        title: t(
                                          'How do I add my bank account on e-Rupaiya?',
                                          'मैं e‑Rupaiya पर अपना बैंक अकाउंट कैसे जोड़ूँ?',
                                        ),
                                        description: t(
                                          'Go to Profile > Bank Accounts, tap Add Account, and verify with your mobile number. Once verified, your account will be linked for payments.',
                                          'प्रोफाइल > बैंक अकाउंट्स में जाएं, Add Account पर टैप करें और अपने मोबाइल नंबर से सत्यापन करें। सत्यापित होने के बाद आपका अकाउंट लिंक हो जाएगा।',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _HelpTopicTile(
                                title: t(
                                  'How can I pay my bills using e-Rupaiya?',
                                  'मैं e‑Rupaiya से बिल भुगतान कैसे करूँ?',
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HelpTopicDetailView(
                                        title: t(
                                          'How can I pay my bills using e-Rupaiya?',
                                          'मैं e‑Rupaiya से बिल भुगतान कैसे करूँ?',
                                        ),
                                        description: t(
                                          'Select the bill category, choose your provider, enter the required details, and confirm payment. You will receive a confirmation once payment succeeds.',
                                          'बिल श्रेणी चुनें, प्रदाता चुनें, आवश्यक जानकारी भरें और भुगतान की पुष्टि करें। सफल भुगतान के बाद पुष्टि मिल जाएगी।',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _HelpTopicTile(
                                title: t(
                                  'How do I earn coins on e-Rupaiya?',
                                  'मैं e‑Rupaiya पर कॉइन्स कैसे कमाऊँ?',
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HelpTopicDetailView(
                                        title: t(
                                          'How do I earn coins on e-Rupaiya?',
                                          'मैं e‑Rupaiya पर कॉइन्स कैसे कमाऊँ?',
                                        ),
                                        description: t(
                                          'Earn coins by completing eligible payments, referrals, and participating in app offers. Coin availability may vary by campaign.',
                                          'योग्य भुगतान, रेफरल और ऑफ़र में भाग लेने पर कॉइन्स मिलते हैं। कॉइन्स की उपलब्धता अभियान के अनुसार बदल सकती है।',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _HelpTopicTile(
                                title: t(
                                  'How can I redeem my coins?',
                                  'मैं अपने कॉइन्स रिडीम कैसे करूँ?',
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HelpTopicDetailView(
                                        title: t(
                                          'How can I redeem my coins?',
                                          'मैं अपने कॉइन्स रिडीम कैसे करूँ?',
                                        ),
                                        description: t(
                                          'Go to Rewards, choose a redemption option, and confirm. Coins will be applied instantly if available.',
                                          'Rewards सेक्शन में जाएं, रिडेम्प्शन विकल्प चुनें और पुष्टि करें। उपलब्ध होने पर कॉइन्स तुरंत लागू हो जाएंगे।',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _HelpTopicTile(
                                title: t(
                                  'What should I do if my payment fails?',
                                  'यदि भुगतान विफल हो जाए तो मुझे क्या करना चाहिए?',
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HelpTopicDetailView(
                                        title: t(
                                          'What should I do if my payment fails?',
                                          'यदि भुगतान विफल हो जाए तो मुझे क्या करना चाहिए?',
                                        ),
                                        description: t(
                                          'If a payment fails, wait a few minutes and check your transaction history. If the amount was deducted, it will be reversed within the standard refund timeline. You can also contact support from the Help Center.',
                                          'भुगतान विफल हो तो कुछ मिनट प्रतीक्षा करें और ट्रांजैक्शन हिस्ट्री जांचें। यदि राशि कटी है तो मानक रिफंड समय में वापस हो जाएगी। आप हेल्प सेंटर से सपोर्ट भी ले सकते हैं।',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 18.h),
                              PolicySectionTitle(
                                text:
                                    t('Recommended Videos', 'सुझाए गए वीडियो'),
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
                          onTap: () =>
                              context.push(RouteConstants.helpCenterChat),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTopicTile extends StatelessWidget {
  const _HelpTopicTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
              Icons.chevron_right,
              color: AppColors.textPrimary.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketsCard extends StatelessWidget {
  const _TicketsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0B7D3B),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Tickets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Icon(Icons.arrow_outward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _BillDetailCard extends StatelessWidget {
  const _BillDetailCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Utility Payment',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E8B3E),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'Successful',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  height: 32.h,
                  width: 32.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EB),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Color(0xFFEA5A30),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maharashtra State E...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Ivanshu Patil... 8 Mar\'26',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textPrimary.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹160.00',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
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
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        gradient: const LinearGradient(
          colors: [Color(0xFFF28C5C), Color(0xFF8C3B1D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Quick Contact',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 18.h),
          const _ContactRow(
            icon: Icons.email_outlined,
            text: 'support@erupaiya.com',
          ),
          SizedBox(height: 10.h),
          const _ContactRow(
            icon: Icons.call_outlined,
            text: 'support@erupaiya.com',
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              const _DividerDot(),
              Expanded(
                child: Divider(
                  color: Colors.white.withOpacity(0.2),
                  thickness: 1,
                ),
              ),
              const _DividerDot(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Need Help? We\u2019ve Got You',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'We Are Here To Help You!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 36.h,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                side: BorderSide(color: Colors.white.withOpacity(0.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'Chat With Us',
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        SizedBox(width: 10.w),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _DividerDot extends StatelessWidget {
  const _DividerDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

class HelpTopicDetailView extends HookWidget {
  const HelpTopicDetailView({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MyAppBar(
        title: 'Help & Support',
        showHelp: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 14.h),
            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1D6),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE7B6A8)),
              ),
              child: Center(
                child: Container(
                  height: 36.h,
                  width: 36.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA5A30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.75),
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 18.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  Text(
                    'Was this information helpful ?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ReactionButton(
                        icon: Icons.thumb_up_alt_outlined,
                        onTap: () {},
                      ),
                      SizedBox(width: 16.w),
                      _ReactionButton(
                        icon: Icons.thumb_down_alt_outlined,
                        onTap: () {
                          KDialog.instance.openSheet(
                            dialog: const _FeedbackSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 38.h,
        width: 38.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textPrimary.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _FeedbackSheet extends HookWidget {
  const _FeedbackSheet();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final text = useState('');

    useEffect(() {
      void listener() => text.value = controller.text;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'What Didn\'t Work For You?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Feedback',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            maxLength: 400,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Feedback',
              counterText: '${text.value.length}/400',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2A98E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 0,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
