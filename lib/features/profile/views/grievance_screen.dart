import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../widgets/my_app_bar.dart';
import '../components/language_chip.dart';
import '../components/policy_banner_card.dart';
import '../components/policy_section_title.dart';

class GrievanceScreen extends HookWidget {
  const GrievanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = useState(LanguageOption.english);
    String t(String en, String hi) =>
        language.value == LanguageOption.hindi ? hi : en;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(title: t('Grievance', 'Grievance')),
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
                          t('Grievance', 'Grievance'),
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
                    imageAsset: FileConstants.homeBanner8,
                  ),
                  SizedBox(height: 14.h),
                  _Paragraph(
                    t(
                      'At e-Rupaiya, we aim to make everyday bill payments and financial '
                          'services more rewarding by offering users cashback, rewards, and '
                          'e-coins. This Rewards & Coins Policy outlines how users can earn, '
                          'use, and manage rewards within the platform.',
                      'e‑Rupaiya में हम कैशबैक, रिवॉर्ड्स और e‑coins देकर दैनिक बिल भुगतान और वित्तीय सेवाओं को अधिक लाभकारी बनाते हैं। यह नीति बताती है कि रिवॉर्ड्स कैसे कमाए, उपयोग और प्रबंधित किए जाते हैं।',
                    ),
                  ),
                  SizedBox(height: 14.h),
                  PolicySectionTitle(
                    text: t(
                        'Earning Rewards & Coins', 'रिवॉर्ड्स और कॉइन्स कमाना'),
                  ),
                  SizedBox(height: 8.h),
                  _Paragraph(
                    t(
                      'Users can earn rewards or e-coins by performing eligible '
                          'transactions on the e-Rupaiya app. These transactions may include '
                          'bill payments, mobile recharges, FASTag recharges, credit card '
                          'payments, and other promotional activities.',
                      'e‑Rupaiya ऐप पर पात्र लेन‑देन करने पर यूज़र रिवॉर्ड्स या e‑coins कमा सकते हैं। इनमें बिल भुगतान, मोबाइल रिचार्ज, FASTag रिचार्ज, क्रेडिट कार्ड भुगतान और अन्य प्रोमोशनल गतिविधियाँ शामिल हो सकती हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'Rewards may be offered as instant cashback, scratch cards, or '
                          'coin-based incentives depending on ongoing campaigns.',
                      'रिवॉर्ड्स अभियान के आधार पर इंस्टेंट कैशबैक, स्क्रैच कार्ड या कॉइन‑आधारित प्रोत्साहन के रूप में मिल सकते हैं।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'The eligibility of rewards may vary based on transaction type, '
                          'value, frequency, and promotional offers. Not all transactions are '
                          'guaranteed to earn rewards.',
                      'रिवॉर्ड की पात्रता लेन‑देन के प्रकार, राशि, आवृत्ति और ऑफ़र पर निर्भर करती है। सभी लेन‑देन पर रिवॉर्ड मिलना सुनिश्चित नहीं है।',
                    ),
                  ),
                  SizedBox(height: 14.h),
                  PolicySectionTitle(
                    text: t('Credit of Rewards', 'रिवॉर्ड क्रेडिट'),
                  ),
                  SizedBox(height: 8.h),
                  _Paragraph(
                    t(
                      'Rewards and e-coins may be credited instantly or within a specified '
                          'time frame after successful completion of a transaction. In some '
                          'cases, rewards may be delayed due to verification processes or '
                          'partner confirmations, or system checks.',
                      'रिवॉर्ड्स और e‑coins सफल लेन‑देन के तुरंत बाद या तय समय में क्रेडिट हो सकते हैं। कुछ मामलों में सत्यापन या पार्टनर कन्फर्मेशन के कारण देरी हो सकती है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'Users are advised to wait for the specified period before raising a '
                          'query.',
                      'यूज़र से अनुरोध है कि शिकायत दर्ज करने से पहले निर्धारित अवधि तक प्रतीक्षा करें।',
                    ),
                  ),
                  SizedBox(height: 14.h),
                  PolicySectionTitle(
                    text: t('Usage of e-Coins', 'e‑Coins का उपयोग'),
                  ),
                  SizedBox(height: 8.h),
                  _Paragraph(
                    t(
                      'e-coins earned on e-Rupaiya can be used within the platform for '
                          'discounts, partial payments, or exclusive offers, wherever applicable.',
                      'e‑Rupaiya पर कमाए गए e‑coins का उपयोग प्लेटफ़ॉर्म के भीतर छूट, आंशिक भुगतान या विशेष ऑफ़र के लिए किया जा सकता है।',
                    ),
                  ),
                  _Bullet(t('Can be transferred to another user',
                      'किसी अन्य यूज़र को ट्रांसफर किए जा सकते हैं')),
                  _Bullet(
                      t('Can be withdrawn as cash', 'नकद निकाले जा सकते हैं')),
                  _Bullet(t('Can be exchanged outside the platform',
                      'प्लेटफ़ॉर्म के बाहर एक्सचेंज किए जा सकते हैं')),
                  SizedBox(height: 14.h),
                  PolicySectionTitle(
                    text: t('Expiry of Rewards', 'रिवॉर्ड्स की एक्सपायरी'),
                  ),
                  SizedBox(height: 8.h),
                  _Paragraph(
                    t(
                      'All rewards and e-coins come with a validity period. If not used '
                          'within the specified time, they will automatically expire and be '
                          'removed from the user’s account. Users are encouraged to check '
                          'expiry details regularly within the app.',
                      'सभी रिवॉर्ड्स और e‑coins की एक वैधता अवधि होती है। समय पर उपयोग न करने पर ये स्वतः समाप्त हो जाते हैं और खाते से हट जाते हैं। कृपया ऐप में एक्सपायरी विवरण नियमित रूप से देखें।',
                    ),
                  ),
                  SizedBox(height: 14.h),
                  PolicySectionTitle(
                    text: t('Fair Usage & Abuse', 'उचित उपयोग और दुरुपयोग'),
                  ),
                  SizedBox(height: 8.h),
                  _Paragraph(
                    t(
                      'e-Rupaiya follows a strict policy against misuse of rewards. Users '
                          'must not create multiple accounts, perform fake transactions, or '
                          'manipulate the system to gain unfair advantages.',
                      'e‑Rupaiya रिवॉर्ड्स के दुरुपयोग के खिलाफ सख्त नीति अपनाता है। कई खाते बनाना, फर्जी लेन‑देन करना या सिस्टम से छेड़छाड़ करना निषिद्ध है।',
                    ),
                  ),
                  _Paragraph(
                    t(
                      'In case of suspicious or fraudulent activity, e-Rupaiya reserves the '
                          'right to:',
                      'संदिग्ध या धोखाधड़ी गतिविधि पाए जाने पर e‑Rupaiya निम्न अधिकार सुरक्षित रखता है:',
                    ),
                  ),
                  _Bullet(
                      t('Cancel rewards or coins', 'रिवॉर्ड/कॉइन्स रद्द करना')),
                  _Bullet(t('Suspend or terminate user accounts',
                      'यूज़र अकाउंट निलंबित/समाप्त करना')),
                  _Bullet(
                      t('Recover any undue benefits', 'अनुचित लाभ वापस लेना')),
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

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 4.w,
            height: 4.w,
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.75),
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
