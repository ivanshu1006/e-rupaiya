import 'package:flutter/material.dart';
import '../constants/policy_page_slugs.dart';
import 'policy_page_screen.dart';

class GrievanceScreen extends StatelessWidget {
  const GrievanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyPageScreen(
      slug: PolicyPageSlugs.grievance,
      title: 'Grievance',
    );
  }
}
