import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../widgets/my_app_bar.dart';
import '../components/language_chip.dart';
import '../components/policy_banner_card.dart';

class TermsPrivacyScreen extends HookWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = useState(LanguageOption.english);
    String t(String en, String hi) =>
        language.value == LanguageOption.hindi ? hi : en;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(title: t('Terms & Conditions', 'Terms & Conditions')),
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
                          t('Terms & Conditions', 'Terms & Conditions'),
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
                    imageAsset: FileConstants.homeBanner9,
                  ),
                  SizedBox(height: 14.h),
                  _Paragraph(
                    t(
                      'At e-Rupaiya, your privacy is our priority. These Terms & '
                          'Conditions explain how we collect, use, and protect your '
                          'information when you use our application and services.',
                      'e‑Rupaiya में आपकी निजता हमारी प्राथमिकता है। ये नियम और शर्तें बताती हैं कि हम आपके डेटा को कैसे एकत्र, उपयोग और सुरक्षित रखते हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'We may collect personal information such as your name, mobile '
                          'number, email address, and KYC details where required. We may also '
                          'collect transaction-related information like bill payments, '
                          'recharges, and rewards activity.',
                      'हम आपका नाम, मोबाइल नंबर, ई‑मेल और आवश्यक होने पर KYC विवरण जैसी व्यक्तिगत जानकारी एकत्र कर सकते हैं। साथ ही बिल भुगतान, रिचार्ज और रिवॉर्ड गतिविधि जैसी लेन‑देन जानकारी भी एकत्र हो सकती है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'Basic device information such as device type, IP address, and '
                          'app usage data may be collected to improve performance and security.',
                      'प्रदर्शन और सुरक्षा सुधारने के लिए डिवाइस टाइप, IP पता और ऐप उपयोग डेटा जैसी मूल जानकारी एकत्र की जा सकती है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'Your information is used to provide seamless and secure services, '
                          'including bill payments, mobile recharges, and reward processing. '
                          'It also helps us enhance your experience, detect fraud, and send '
                          'important updates and notifications.',
                      'आपकी जानकारी का उपयोग सुरक्षित सेवाएँ देने, धोखाधड़ी का पता लगाने और महत्वपूर्ण अपडेट/नोटिफिकेशन भेजने के लिए किया जाता है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'We take data security seriously and implement appropriate technical '
                          'and organizational measures to protect your information. Your personal '
                          'and financial data is encrypted and stored securely.',
                      'हम डेटा सुरक्षा को गंभीरता से लेते हैं और आपकी जानकारी की सुरक्षा के लिए उचित तकनीकी और संगठनात्मक उपाय लागू करते हैं। आपका व्यक्तिगत और वित्तीय डेटा सुरक्षित रूप से एन्क्रिप्टेड रहता है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'e-Rupaiya does not sell your personal information to any third parties. '
                          'However, we may share limited data with trusted partners such as payment '
                          'gateways and service providers to complete transactions and deliver services. '
                          'We may also disclose information if required by law or regulatory authorities.',
                      'e‑Rupaiya आपका निजी डेटा किसी तीसरे पक्ष को नहीं बेचता। लेन‑देन पूरा करने के लिए हम भुगतान गेटवे/सेवा प्रदाताओं के साथ सीमित डेटा साझा कर सकते हैं। कानून के अनुसार आवश्यक होने पर जानकारी साझा की जा सकती है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'Our application may use cookies or similar tracking technologies to '
                          'understand user behavior and improve app functionality. This helps us '
                          'deliver a smoother and more personalized experience.',
                      'हम कुकीज़ या समान तकनीक का उपयोग करके उपयोगकर्ता व्यवहार समझते हैं और ऐप कार्यक्षमता सुधारते हैं, जिससे अनुभव अधिक सहज और व्यक्तिगत बनता है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'You have the right to access, update, or request deletion of your data, '
                          'subject to applicable laws. You may also choose to opt out of promotional '
                          'communications at any time.',
                      'लागू कानूनों के तहत आप अपने डेटा तक पहुँच, अपडेट या हटाने का अनुरोध कर सकते हैं। आप प्रमोशनल कम्युनिकेशन से कभी भी ऑप्ट‑आउट कर सकते हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'e-Rupaiya may include third-party services, and their privacy practices may '
                          'be governed by their respective policies. We encourage users to review those '
                          'policies when interacting with such services.',
                      'e‑Rupaiya में तृतीय‑पक्ष सेवाएँ हो सकती हैं जिनकी गोपनीयता नीतियाँ अलग हो सकती हैं। ऐसे मामलों में उनकी नीतियाँ पढ़ने की सलाह दी जाती है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'We may update these Terms & Conditions from time to time to reflect changes '
                          'in our services or legal requirements. Users will be notified of any significant '
                          'updates.',
                      'हम समय‑समय पर सेवाओं या कानूनी आवश्यकताओं के अनुसार नियम एवं शर्तें अपडेट कर सकते हैं। महत्वपूर्ण बदलावों की सूचना दी जाएगी।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'If you have any questions, concerns, or requests regarding these Terms & '
                          'Conditions, you can contact us at support@erupaiya.com.',
                      'यदि आपको कोई प्रश्न या चिंता हो, तो support@erupaiya.com पर संपर्क करें।',
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
