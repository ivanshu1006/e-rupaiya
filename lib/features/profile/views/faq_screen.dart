// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../models/faq_item.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  static const List<Map<String, dynamic>> _mockFaqs = [
    {
      'id': 'services',
      'question': 'What services can I pay using e-Rupaiya?',
      'answer': 'You Can Pay Your Utility Bills, Mobile Recharge, DTH, Broadband, '
          'Electricity, Water, Gas, And More Directly Through The E-Rupaiya App. '
          'The App Provides A Fast, Secure, And Convenient Way To Manage All '
          'Your Payments In One Place.',
    },
    {
      'id': 'safe',
      'question': 'Is e-Rupaiya safe to use for payments?',
      'answer':
          'Yes. Transactions Are Encrypted And Protected By Multiple Layers '
              'Of Security. We Follow Industry Standards To Keep Your Data Safe.',
    },
    {
      'id': 'bank',
      'question': 'Do I need a bank account to use e-Rupaiya?',
      'answer':
          'You Can Use UPI Or Linked Bank Accounts For Payments. A Bank Account '
              'Is Recommended For Full Access To Services.',
    },
    {
      'id': 'rewards',
      'question': 'How do I get rewards or cashback?',
      'answer':
          'Rewards Are Applied Based On Eligible Transactions And Offers. '
              'Check The Offers Section For Current Promotions.',
    },
    {
      'id': 'fails',
      'question': 'What should I do if my payment fails?',
      'answer':
          'If A Payment Fails, Please Wait A Few Minutes And Check Your Status. '
              'If The Issue Persists, Contact Support With The Transaction ID.',
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int? _expandedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = FaqItem.fromJsonList(_mockFaqs);
    final filtered = _query.trim().isEmpty
        ? faqs
        : faqs
            .where(
              (item) => item.question.toLowerCase().contains(
                    _query.trim().toLowerCase(),
                  ),
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F3),
      body: Stack(
        children: [
          const ColoredBox(color: Color(0xFFFFF7F3)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              FileConstants.ellipse14,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _FaqHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FaqSearchField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _query = value;
                              _expandedIndex = null;
                            });
                          },
                        ),
                        SizedBox(height: 12.h),
                        ...List.generate(filtered.length, (index) {
                          final item = filtered[index];
                          final isExpanded = _expandedIndex == index;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _FaqCard(
                              question: item.question,
                              answer: item.answer,
                              isExpanded: isExpanded,
                              onTap: () {
                                setState(() {
                                  _expandedIndex = isExpanded ? null : index;
                                });
                              },
                            ),
                          );
                        }),
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

class _FaqHeader extends StatelessWidget {
  const _FaqHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 16.w, 6.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 22.sp),
          ),
          SizedBox(width: 4.w),
          Text(
            'Faq',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _FaqSearchField extends StatelessWidget {
  const _FaqSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search Service',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.55),
                    ),
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.7),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.search,
              size: 14.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary.withOpacity(0.7),
                  size: 20.sp,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: 10.h),
            const Divider(color: AppColors.lightBorder),
            SizedBox(height: 8.h),
            Text(
              answer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
