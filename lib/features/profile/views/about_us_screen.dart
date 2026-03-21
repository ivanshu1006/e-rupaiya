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
            'About E-Rupiya',
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
          "E-Rupiya is your all-in-one mobile solution for fast, easy, and "
          "secure bill payments. Designed for today’s on-the-go lifestyle, "
          "our app lets you manage and pay all your bills anytime, anywhere "
          "— right from your smartphone.",
        ),
        SizedBox(height: 16),
        _AboutParagraph(
          "From mobile recharges and utility bills to everyday payments, "
          "E-Rupiya brings everything into one simple, user-friendly app. "
          "With a focus on speed, security, and convenience, we ensure every "
          "transaction is smooth and reliable.",
        ),
        SizedBox(height: 22),
        _AboutParagraph(
          "Our mission is to make digital payments effortless and accessible "
          "for everyone by combining smart technology with a seamless mobile "
          "experience.",
        ),
        SizedBox(height: 22),
        _AboutSectionTitle('Why E-Rupiya?'),
        SizedBox(height: 10),
        _AboutParagraph(
          "• Quick and hassle-free payments",
        ),
        SizedBox(height: 10),
        _AboutParagraph(
          "• Secure and reliable transactions",
        ),
        SizedBox(height: 10),
        _AboutParagraph(
          "• Simple and intuitive mobile interface",
        ),
        SizedBox(height: 10),
        _AboutParagraph(
          "• All your bills in one place",
        ),
        SizedBox(height: 20),
        _AboutTagline(
          "Experience smarter payments with E-Rupiya—anytime, anywhere.",
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
