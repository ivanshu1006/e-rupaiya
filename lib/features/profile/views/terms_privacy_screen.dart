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
            'Terms & Privacy Policy',
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
        _MetaText('Effective Date: 05-10-2025'),
        SizedBox(height: 10),
        _Paragraph(
          "Welcome To E-Rupaiya, A Buy & Bill Our Application "
          "And Services. You Agree To Comply With And Be Bound By "
          "The Following Terms And Conditions. Please Read Them Carefully.",
        ),
        SizedBox(height: 16),
        _SectionTitle('1. Acceptance Of Terms'),
        SizedBox(height: 8),
        _Paragraph(
          "By Accessing Or Using The E-Rupaiya App, You Agree To "
          "Be Bound By These Terms & Conditions And Any Additional "
          "Terms Referenced Herein. If You Do Not Agree, Please Do "
          "Not Use Our Services.",
        ),
        SizedBox(height: 14),
        _SectionTitle('2. Eligibility'),
        SizedBox(height: 8),
        _Paragraph(
          "You Must Be At Least 18 Years Old To Use This App. "
          "By Registering, You Confirm That You Meet This Age "
          "Requirement And Have The Legal Capacity To Enter "
          "Into A Binding Agreement.",
        ),
        SizedBox(height: 14),
        _SectionTitle('3. Account Registration'),
        SizedBox(height: 8),
        _Paragraph(
            "Users Must Provide Accurate And Complete Information While Creating An Account."),
        SizedBox(height: 8),
        _Bullet(
            'You Are Responsible For Maintaining The Confidentiality Of Your Account Credentials.'),
        _Bullet(
            'You Agree To Notify Us Immediately Of Any Unauthorized Use Of Your Account.'),
        SizedBox(height: 14),
        _SectionTitle('4. Services Provided'),
        SizedBox(height: 8),
        _Paragraph("E-Rupaiya Allows Users To:"),
        SizedBox(height: 8),
        _Bullet(
            'Pay Utility Bills, Recharge Mobile Numbers, And Other Bill Payment Services.'),
        _Bullet('Link Bank Accounts Or UPI IDs For Transactions.'),
        _Bullet('Track Payment History And Receive Notifications.'),
        SizedBox(height: 8),
        _Paragraph(
          "All Services Are Provided In Accordance With Applicable "
          "Laws And Regulations.",
        ),
        SizedBox(height: 14),
        _SectionTitle('5. Transactions & Payments'),
        SizedBox(height: 8),
        _Bullet(
          "Transactions Are Subject To Verification And May Require "
          "KYC/Know Your Customer Compliance.",
        ),
        _Bullet(
          "E-Rupaiya Is Not Responsible For Errors Caused By Incorrect "
          "Payment Information Provided By Users.",
        ),
        _Bullet("All Payments Are Final Unless Otherwise Stated."),
        SizedBox(height: 14),
        _SectionTitle('6. Privacy & Data Security'),
        SizedBox(height: 8),
        _Paragraph(
          "We Respect Your Privacy And Handle Your Data In "
          "Accordance With Our Privacy Policy.",
        ),
        _Paragraph(
          "Users Consent To The Collection, Use, And Storage Of "
          "Personal Data For The Purpose Of Providing Services.",
        ),
        SizedBox(height: 14),
        _SectionTitle('7. User Responsibilities'),
        SizedBox(height: 8),
        _Bullet(
            "You Agree Not To Misuse The App Or Engage In Fraudulent Or Illegal Activities."),
        _Bullet(
          "Users Must Ensure Their Devices And Internet Connections "
          "Are Secure While Using The App.",
        ),
        SizedBox(height: 14),
        _SectionTitle('8. Limitation Of Liability'),
        SizedBox(height: 8),
        _Paragraph(
          "E-Rupaiya Will Not Be Liable For Any Indirect, "
          "Incidental, Or Consequential Damages Arising From "
          "The Use Of The App.",
        ),
        _Paragraph(
          "We Strive To Ensure Uninterrupted And Secure Services "
          "But Cannot Guarantee 100% Availability.",
        ),
        SizedBox(height: 14),
        _SectionTitle('9. Intellectual Property'),
        SizedBox(height: 8),
        _Paragraph(
          "All Content, Logos, Graphics, And Software Used In "
          "E-Rupaiya Are Owned By Or Licensed To The App And "
          "Are Protected By Intellectual Property Laws.",
        ),
        _Paragraph(
          "Users May Not Reproduce, Distribute, Or Modify Any "
          "Content Without Prior Written Consent.",
        ),
        SizedBox(height: 14),
        _SectionTitle('10. Modifications To Terms'),
        SizedBox(height: 8),
        _Paragraph(
          "We Reserve The Right To Modify These Terms & "
          "Conditions At Any Time. Updates Will Be Posted "
          "On The App, And Continued Use Constitutes "
          "Acceptance Of The Changes.",
        ),
        SizedBox(height: 14),
        _SectionTitle('11. Governing Law'),
        SizedBox(height: 8),
        _Paragraph(
          "These Terms And Conditions Are Governed By The "
          "Laws Of India. Any Disputes Will Be Subject To "
          "The Exclusive Jurisdiction Of The Courts In "
          "[City/State].",
        ),
        SizedBox(height: 14),
        _SectionTitle('12. Contact Us'),
        SizedBox(height: 8),
        _Paragraph(
            "For Any Questions Or Concerns Regarding These Terms, Please Contact Us At:"),
        SizedBox(height: 8),
        _MetaText('Email: (support@e-rupaiya.com)'),
        _MetaText('Phone: (+91-123-456-7890)'),
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
