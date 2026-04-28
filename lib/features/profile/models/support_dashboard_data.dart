import 'help_topic.dart';
import 'support_latest_transaction.dart';

class SupportDashboardData {
  const SupportDashboardData({
    required this.latestTransactions,
    required this.helpTopics,
  });

  final List<SupportLatestTransaction> latestTransactions;
  final List<HelpTopic> helpTopics;
}

