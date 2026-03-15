// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF7F3),
      body: Stack(
        children: [
          _TermsBackground(),
          SafeArea(
            child: Column(
              children: [
                _TermsHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: _TermsBody(),
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

class _TermsBackground extends StatelessWidget {
  const _TermsBackground();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE2D7), Color(0xFFFFF7F3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const Expanded(
          child: ColoredBox(color: Color(0xFFFFF7F3)),
        ),
      ],
    );
  }
}

class _TermsHeader extends StatelessWidget {
  const _TermsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 4),
          Text(
            'Legal & Policy Document',
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

class _TermsBody extends StatelessWidget {
  const _TermsBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('E-Rupaiya – Complete Legal & Policy Document'),
        SizedBox(height: 8),
        _MetaText('Effective Date: [Insert Date]'),
        SizedBox(height: 8),
        _MetaText('Company: INNNOPLIX IT PVT LTD'),
        _MetaText('Brand: E-Rupaiya'),
        SizedBox(height: 8),
        _MetaText('Address:'),
        _Paragraph(
          'Office No 2, 2nd Floor, Mahesh Plaza,\n'
          'Bengaluru – Mumbai Highway, Above KTM Showroom,\n'
          'Near Lodha Hospital, Popular Nagar, Giridhar Nagar, Warje,\n'
          'Pune, Maharashtra 411058, India',
        ),
        SizedBox(height: 8),
        _MetaText('Email: support@erupaiya.com'),
        _MetaText('Phone: +91-XXXXXXXXXX'),
        SizedBox(height: 16),
        _SectionTitle('1. Terms & Conditions'),
        SizedBox(height: 8),
        _Paragraph(
          'Acceptance of Terms: By using E-Rupaiya, you agree to comply with '
          'these Terms & Conditions.',
        ),
        _Paragraph(
          'User Eligibility: Only users 18 years or older can use the Services.',
        ),
        _Paragraph(
          'Account Registration: You must provide a valid mobile number and OTP '
          'to create an account.',
        ),
        _Paragraph('User Responsibilities:'),
        _Bullet('Keep account credentials secure'),
        _Bullet('Ensure all payment information is accurate'),
        _Bullet('Do not misuse the Services'),
        _Paragraph(
          'Payment & Transactions: All transactions are final unless otherwise stated. '
          'Refunds will follow our Refund Policy.',
        ),
        _Paragraph(
          'Service Availability: We may suspend services for maintenance or upgrades.',
        ),
        _Paragraph(
          'Limitation of Liability: INNNOPLIX IT is not liable for indirect losses '
          'arising from the use of the app.',
        ),
        _Paragraph('Governing Law: These Terms are governed by Indian law.'),
        SizedBox(height: 14),
        _SectionTitle('2. Privacy Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'Please refer to the full Privacy Policy as drafted earlier (covers '
          'registration, profile, transaction, device permissions, third-party '
          'sharing, data security, retention, user rights, and children’s privacy).',
        ),
        SizedBox(height: 14),
        _SectionTitle('3. Refund Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'Transaction Failure: If a payment fails but the amount is deducted, we '
          'will process a refund automatically within 5–7 business days.',
        ),
        _Paragraph(
          'Refund Eligibility: Refunds are applicable only for failed or duplicate '
          'transactions initiated via the app.',
        ),
        _Paragraph('Non-Refundable Transactions:'),
        _Bullet('Successful payments'),
        _Bullet('Payments outside the app'),
        _Paragraph(
          'Refund Method: Refunds are credited to the original payment method used.',
        ),
        SizedBox(height: 14),
        _SectionTitle('4. Cookie Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'We may use cookies or similar technology to improve user experience '
          'and app performance.',
        ),
        _Paragraph(
          'Cookies may be used for analytics, security, and personalized notifications.',
        ),
        _Paragraph(
          'Users can manage or disable cookies in device settings.',
        ),
        SizedBox(height: 14),
        _SectionTitle('5. KYC / AML Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'E-Rupaiya may require users to complete KYC verification for certain '
          'transaction limits.',
        ),
        _Paragraph(
          'We comply with Indian KYC and Anti-Money Laundering (AML) regulations.',
        ),
        _Paragraph(
          'Required information may include identity documents and bank account '
          'verification.',
        ),
        SizedBox(height: 14),
        _SectionTitle('6. Security Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'All transactions are processed securely using encrypted communication.',
        ),
        _Paragraph(
          'User data is stored securely on protected servers.',
        ),
        _Paragraph(
          'Access to sensitive information is restricted to authorized personnel.',
        ),
        _Paragraph(
          'Users should keep login credentials confidential.',
        ),
        SizedBox(height: 14),
        _SectionTitle('7. Charges / Fees Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'The app may levy nominal service fees for certain transactions.',
        ),
        _Paragraph(
          'Fees, if any, will be displayed before the user confirms a transaction.',
        ),
        _Paragraph(
          'Charges are non-refundable unless a transaction fails.',
        ),
        SizedBox(height: 14),
        _SectionTitle('8. Grievance Redressal Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'Users can submit complaints via support@erupaiya.com.',
        ),
        _Paragraph(
          'Complaints will be acknowledged within 24 hours and resolved within 48–72 hours.',
        ),
        _Paragraph(
          'Grievance Officer Contact: [Name], Email: grievance@erupaiya.com',
        ),
        SizedBox(height: 14),
        _SectionTitle('9. Disclaimer Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'E-Rupaiya acts as a payment facilitator for bill payments and recharges.',
        ),
        _Paragraph(
          'We are not responsible for delays, errors, or service failures caused '
          'by banks, telecom operators, or utility providers.',
        ),
        _Paragraph(
          'All transactions are subject to the terms of the service provider.',
        ),
        SizedBox(height: 14),
        _SectionTitle('10. Referral & Rewards Policy'),
        SizedBox(height: 8),
        _Paragraph(
          'Users may participate in referral programs at the discretion of INNNOPLIX IT.',
        ),
        _Paragraph(
          'Referral rewards are credited only if the referred user successfully '
          'completes a valid registration and transaction.',
        ),
        _Paragraph(
          'Rewards are non-transferable and subject to expiry as notified in-app.',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black.withOpacity(0.75),
            height: 1.55,
          ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black.withOpacity(0.7),
            fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withOpacity(0.75),
                  height: 1.55,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(0.75),
                    height: 1.55,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
