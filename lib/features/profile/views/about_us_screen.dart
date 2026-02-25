// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF7F3),
      body: Stack(
        children: [
          _AboutBackground(),
          SafeArea(
            child: Column(
              children: [
                _AboutHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: _AboutBody(),
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

class _AboutBackground extends StatelessWidget {
  const _AboutBackground();

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

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

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
            'About E-Rupaiya',
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

class _AboutBody extends StatelessWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AboutParagraph(
          "E-Rupaiya Is India’s Own Smart And Secure Digital "
          "Payments App, Designed To Make Your Everyday Bill "
          "Payments Simple, Fast, And Reliable. Whether It’s "
          "Electricity, Water, Gas, Mobile Recharge, Or DTH — "
          "E-Rupaiya Helps You Pay All Your Bills In One Place, "
          "Within Seconds.",
        ),
        SizedBox(height: 16),
        _AboutParagraph(
          "Our Goal Is To Bring Convenience And Trust "
          "Together — Giving Every User A Smooth Payment "
          "Experience With Complete Control And Transparency.",
        ),
        SizedBox(height: 22),
        _AboutSectionTitle('Fast Payments'),
        SizedBox(height: 10),
        _AboutParagraph(
          "No More Waiting Or Switching Between Apps. With "
          "E-Rupaiya, Your Bills Are Paid Instantly Through A "
          "Few Quick Taps — Saving Your Time And Effort Every "
          "Month.",
        ),
        SizedBox(height: 22),
        _AboutSectionTitle('Safe & Secure'),
        SizedBox(height: 10),
        _AboutParagraph(
          "Your Data And Transactions Are Fully Protected With "
          "Advanced Encryption And Multi-Layer Security. "
          "E-Rupaiya Follows Strict Privacy Standards To Ensure "
          "Your Money And Information Remain Completely Safe.",
        ),
        SizedBox(height: 22),
        _AboutSectionTitle('User-Focused Experience'),
        SizedBox(height: 10),
        _AboutParagraph(
          "Built For Every Indian User, E-Rupaiya Offers A Clean, "
          "Easy-To-Use Interface That Works Seamlessly On All "
          "Devices. From Earning Coins To Tracking Your Payments "
          "— Everything Is Designed To Give You More Value And "
          "A Better Experience.",
        ),
        SizedBox(height: 22),
        _AboutSectionTitle('Why We Created E-Rupaiya'),
        SizedBox(height: 10),
        _AboutParagraph(
          "We Believe Paying Bills Shouldn’t Be Complicated. "
          "E-Rupaiya Was Created To Simplify Digital Payments "
          "For Everyone — Secure, Accessible, And Rewarding.",
        ),
        SizedBox(height: 20),
        _AboutTagline(
          "One App For All Your Payments\n"
          "Fast, Safe, And Truly Indian.",
        ),
      ],
    );
  }
}

class _AboutSectionTitle extends StatelessWidget {
  const _AboutSectionTitle(this.text);

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

class _AboutParagraph extends StatelessWidget {
  const _AboutParagraph(this.text);

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

class _AboutTagline extends StatelessWidget {
  const _AboutTagline(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black.withOpacity(0.45),
            height: 1.4,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
