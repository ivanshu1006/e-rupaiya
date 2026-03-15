// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF7F3),
      body: Stack(
        children: [
          _PrivacyBackground(),
          SafeArea(
            child: Column(
              children: [
                _PrivacyHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: _PrivacyBody(),
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

class _PrivacyBackground extends StatelessWidget {
  const _PrivacyBackground();

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

class _PrivacyHeader extends StatelessWidget {
  const _PrivacyHeader();

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
            'Privacy Policy',
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

class _PrivacyBody extends StatelessWidget {
  const _PrivacyBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Privacy Policy – E-Rupaiya'),
        SizedBox(height: 8),
        _MetaText('Effective Date: [Insert Date]'),
        SizedBox(height: 10),
        _Paragraph(
          'INNNOPLIX IT (“Company”, “we”, “our”, or “us”) operates the E-Rupaiya '
          'mobile application and related services (collectively referred to as '
          'the “Services”). This Privacy Policy explains how we collect, use, '
          'disclose, and protect your information when you use our Services.',
        ),
        _Paragraph(
          'By using E-Rupaiya, you agree to the terms of this Privacy Policy.',
        ),
        SizedBox(height: 16),
        _SectionTitle('1. Information We Collect'),
        SizedBox(height: 8),
        _SectionTitle('1.1 During Registration'),
        SizedBox(height: 6),
        _Paragraph('When you register for E-Rupaiya, we only collect:'),
        _Bullet('Mobile number'),
        _Bullet('One-Time Password (OTP) for verification'),
        _Paragraph(
          'This information is used solely to verify your identity and create your account.',
        ),
        SizedBox(height: 10),
        _SectionTitle('1.2 Profile Information'),
        SizedBox(height: 6),
        _Paragraph('After registration, you may optionally provide:'),
        _Bullet('First Name'),
        _Bullet('Last Name'),
        _Bullet('Email Address'),
        _Paragraph(
          'This information helps us personalize your account and send transaction notifications.',
        ),
        SizedBox(height: 10),
        _SectionTitle('1.3 Transaction Information'),
        SizedBox(height: 6),
        _Bullet('Payment amount'),
        _Bullet('Bill or recharge details'),
        _Bullet('Transaction ID and status'),
        _Bullet('Payment method (UPI, bank, or card)'),
        SizedBox(height: 10),
        _SectionTitle('1.4 Device & Location Information'),
        SizedBox(height: 6),
        _Bullet('Device model and operating system version'),
        _Bullet('IP address'),
        _Bullet('App usage and analytics data'),
        _Bullet('Approximate location (for fraud prevention and service optimization)'),
        SizedBox(height: 14),
        _SectionTitle('2. How We Use Your Information'),
        SizedBox(height: 6),
        _Paragraph('We use the collected information to:'),
        _Bullet('Verify mobile number during registration'),
        _Bullet('Create and manage your account'),
        _Bullet('Process bill payments and recharges securely'),
        _Bullet('Send transaction confirmations and notifications'),
        _Bullet('Prevent fraud and unauthorized activity'),
        _Bullet('Improve app performance and user experience'),
        _Bullet('Comply with legal obligations'),
        SizedBox(height: 14),
        _SectionTitle('3. Sharing of Information'),
        SizedBox(height: 6),
        _Paragraph('We may share your information with:'),
        _Bullet(
          'Service Providers: Trusted third-party service providers who help operate, '
          'maintain, and improve our services (including processing transactions, '
          'fraud detection, and notifications)',
        ),
        _Bullet('Legal Authorities: If required by law or regulation'),
        _Bullet(
          'Business Partners: Partners assisting in providing and improving the services',
        ),
        _Paragraph('We do not sell or rent your personal data to third parties.'),
        SizedBox(height: 14),
        _SectionTitle('4. Device Permissions'),
        SizedBox(height: 6),
        _Paragraph('E-Rupaiya may request the following permissions:'),
        _Bullet('SMS Permission: Automatically detect OTP for registration and payment verification'),
        _Bullet('Contacts Permission: Optional, for selecting numbers from contacts when making payments'),
        _Bullet('Location Permission: Approximate location for fraud detection and security'),
        _Bullet('Notification Permission: Send transaction updates, reminders, and service alerts'),
        _Paragraph(
          'Users can manage these permissions in their device settings. Disabling certain '
          'permissions may limit app functionality.',
        ),
        SizedBox(height: 14),
        _SectionTitle('5. Data Security'),
        SizedBox(height: 6),
        _Paragraph('We implement appropriate measures to protect your information:'),
        _Bullet('Encrypted communication for transactions'),
        _Bullet('Secure server infrastructure'),
        _Bullet('Restricted access to sensitive information'),
        _Bullet('Continuous monitoring for security threats'),
        _Paragraph('No system is completely secure; we cannot guarantee absolute security.'),
        SizedBox(height: 14),
        _SectionTitle('6. Data Retention'),
        SizedBox(height: 6),
        _Paragraph(
          'We retain your personal and transaction data only as long as necessary to:',
        ),
        _Bullet('Provide our services'),
        _Bullet('Comply with legal obligations'),
        _Bullet('Prevent fraud and abuse'),
        _Bullet('Resolve disputes'),
        SizedBox(height: 14),
        _SectionTitle('7. User Rights'),
        SizedBox(height: 6),
        _Paragraph('You have the right to:'),
        _Bullet('Access your personal information'),
        _Bullet('Correct inaccurate information'),
        _Bullet('Request deletion of your account'),
        _Bullet('Contact us with privacy concerns'),
        _Paragraph('Requests can be sent to our support email listed below.'),
        SizedBox(height: 14),
        _SectionTitle('8. Children’s Privacy'),
        SizedBox(height: 6),
        _Paragraph(
          'Our services are intended for users 18 years or older. We do not knowingly '
          'collect information from children under 18.',
        ),
        SizedBox(height: 14),
        _SectionTitle('9. Updates to This Privacy Policy'),
        SizedBox(height: 6),
        _Paragraph(
          'We may update this Privacy Policy from time to time. Updated versions will be '
          'posted within the application or on the website with the revised effective date.',
        ),
        SizedBox(height: 14),
        _SectionTitle('10. Contact Us'),
        SizedBox(height: 6),
        _Paragraph('If you have any questions, complaints, or requests regarding this Privacy Policy, please contact:'),
        _MetaText('Company Name: INNNOPLIX IT'),
        _MetaText('Brand: E-Rupaiya'),
        _MetaText('Address:'),
        _Paragraph(
          'Office No 2, 2nd Floor, Mahesh Plaza,\n'
          'Bengaluru – Mumbai Highway, Above KTM Showroom,\n'
          'Near Lodha Hospital, Popular Nagar, Giridhar Nagar, Warje,\n'
          'Pune, Maharashtra 411058, India',
        ),
        _MetaText('Email: support@erupaiya.com'),
        _MetaText('Phone: +91-XXXXXXXXXX'),
        _MetaText('Customer Support Hours: Monday – Saturday, 10:00 AM – 6:00 PM IST'),
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
