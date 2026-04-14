import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../widgets/my_app_bar.dart';
import '../components/language_chip.dart';
import '../components/policy_banner_card.dart';
import '../components/policy_section_title.dart';

class PrivacyPolicyScreen extends HookWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = useState(LanguageOption.english);
    String t(String en, String hi) =>
        language.value == LanguageOption.hindi ? hi : en;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(title: t('Privacy Policy', 'Privacy Policy')),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t('Privacy Policy', 'Privacy Policy'),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    imageAsset: FileConstants.homeBanner10,
                  ),
                  SizedBox(height: 14.h),
                  PolicySectionTitle(
                    text: t(
                      'At e-Rupaiya, your privacy is our priority.',
                      'e‑Rupaiya में आपकी निजता हमारी प्राथमिकता है।',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _Paragraph(
                    t(
                      'This Privacy Policy explains how we collect, use, and '
                          'protect your information when you use our application and '
                          'services.',
                      'यह गोपनीयता नीति बताती है कि हम आपके डेटा को कैसे एकत्र, '
                          'उपयोग और सुरक्षित रखते हैं जब आप हमारे ऐप और सेवाओं का उपयोग करते हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'We may collect certain personal information such as your '
                          'name, mobile number, email address, and KYC details where '
                          'required. In addition, we may collect transaction-related '
                          'information like bill payments, recharges, and rewards activity.',
                      'हम कुछ व्यक्तिगत जानकारी जैसे आपका नाम, मोबाइल नंबर, ई‑मेल और आवश्यक होने पर KYC विवरण एकत्र कर सकते हैं। इसके अतिरिक्त, हम बिल भुगतान, रिचार्ज और रिवॉर्ड गतिविधि जैसी लेन‑देन संबंधी जानकारी भी एकत्र कर सकते हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'Basic device information such as device type, IP address, '
                          'and app usage data may also be collected to improve performance '
                          'and security.',
                      'प्रदर्शन और सुरक्षा बेहतर करने के लिए डिवाइस टाइप, IP पता और ऐप उपयोग डेटा जैसी मूल डिवाइस जानकारी भी एकत्र की जा सकती है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'Your information is used to provide seamless and secure '
                          'services, including bill payments, mobile recharges, and reward '
                          'processing. It also helps us enhance your experience, detect '
                          'fraud, and send important updates.',
                      'आपकी जानकारी का उपयोग सुरक्षित सेवाएँ देने, जैसे बिल भुगतान, मोबाइल रिचार्ज और रिवॉर्ड प्रोसेसिंग के लिए किया जाता है। यह आपके अनुभव को बेहतर बनाने, धोखाधड़ी का पता लगाने और महत्वपूर्ण अपडेट भेजने में भी मदद करती है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'We take data security seriously and implement appropriate '
                          'technical and organizational measures to protect your information. '
                          'Your personal and financial data is encrypted and stored securely.',
                      'हम डेटा सुरक्षा को गंभीरता से लेते हैं और आपकी जानकारी की सुरक्षा के लिए उपयुक्त तकनीकी और संगठनात्मक उपाय लागू करते हैं। आपका व्यक्तिगत और वित्तीय डेटा एन्क्रिप्टेड और सुरक्षित रूप से संग्रहीत होता है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'e-Rupaiya does not sell your personal information to any third '
                          'parties. We may share limited data with trusted partners (such as '
                          'payment gateways) to complete transactions or where required by law.',
                      'e‑Rupaiya आपका निजी डेटा किसी तीसरे पक्ष को नहीं बेचता। लेन‑देन पूरा करने या कानून के अनुसार आवश्यक होने पर, हम विश्वसनीय भागीदारों (जैसे भुगतान गेटवे) के साथ सीमित डेटा साझा कर सकते हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'We may use cookies or similar technologies to understand user '
                          'behavior and improve functionality. This helps deliver a smoother '
                          'and more personalized experience.',
                      'हम उपयोगकर्ता व्यवहार समझने और कार्यक्षमता सुधारने के लिए कुकीज़ या समान तकनीक का उपयोग कर सकते हैं। इससे अधिक सहज और व्यक्तिगत अनुभव मिलता है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'You have the right to access, update, or request deletion of your '
                          'data, subject to applicable laws. You may also opt out of promotional '
                          'communications at any time.',
                      'लागू कानूनों के तहत आपको अपने डेटा तक पहुँचने, उसे अपडेट करने या हटाने का अनुरोध करने का अधिकार है। आप किसी भी समय प्रमोशनल कम्युनिकेशन से ऑप्ट‑आउट भी कर सकते हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'If you have any questions or concerns, contact us at '
                          'support@erupaiya.com.',
                      'यदि आपके कोई प्रश्न या चिंताएँ हैं, तो support@erupaiya.com पर संपर्क करें।',
                    ),
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

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary.withOpacity(0.75),
              height: 1.5,
            ),
      ),
    );
  }
}
