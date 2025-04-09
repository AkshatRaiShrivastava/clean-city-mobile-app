import 'package:cleancity/config/theme.dart';
import 'package:cleancity/services/incentive_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncentivesScreen extends StatelessWidget {
  const IncentivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Incentives'),
      ),
      body: FutureBuilder<double>(
        future: IncentiveService().getUserIncentiveBalance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final balance = snapshot.data ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹$balance', // Use the balance from FutureBuilder
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '+₹50 this month',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Show redeem options
                          _showRedeemOptions(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Redeem Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Section
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        icon: Icons.file_present,
                        title: 'Reports',
                        value: '12',
                        color: Colors.blue[100]!,
                        iconColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        icon: Icons.check_circle,
                        title: 'Resolved',
                        value: '8',
                        color: Colors.green[100]!,
                        iconColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context: context,
                        icon: Icons.trending_up,
                        title: 'Rank',
                        value: '24',
                        color: Colors.purple[100]!,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        // Show all transactions
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTransactionItem(
                  context: context,
                  title: 'Report Reward',
                  description: 'Garbage pile report verified',
                  amount: '+₹25',
                  date: DateTime.now().subtract(const Duration(days: 2)),
                  isCredit: true,
                ),
                _buildTransactionItem(
                  context: context,
                  title: 'Report Reward',
                  description: 'Littering report verified',
                  amount: '+₹15',
                  date: DateTime.now().subtract(const Duration(days: 5)),
                  isCredit: true,
                ),
                _buildTransactionItem(
                  context: context,
                  title: 'Mobile Recharge',
                  description: 'Redeem to mobile number',
                  amount: '-₹50',
                  date: DateTime.now().subtract(const Duration(days: 10)),
                  isCredit: false,
                ),
                _buildTransactionItem(
                  context: context,
                  title: 'Report Reward',
                  description: 'Garbage pile report verified',
                  amount: '+₹25',
                  date: DateTime.now().subtract(const Duration(days: 15)),
                  isCredit: true,
                ),
                const SizedBox(height: 16),

                // Reward Tiers Section
                Text(
                  'Reward Tiers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildRewardTierCard(
                  context: context,
                  title: 'Bronze',
                  description: '0-10 reports',
                  reward: '₹15 per verified report',
                  currentTier: false,
                ),
                _buildRewardTierCard(
                  context: context,
                  title: 'Silver',
                  description: '11-25 reports',
                  reward: '₹25 per verified report',
                  currentTier: true,
                ),
                _buildRewardTierCard(
                  context: context,
                  title: 'Gold',
                  description: '26-50 reports',
                  reward: '₹40 per verified report',
                  currentTier: false,
                ),
                _buildRewardTierCard(
                  context: context,
                  title: 'Platinum',
                  description: '51+ reports',
                  reward: '₹60 per verified report',
                  currentTier: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required String title,
    required String description,
    required String amount,
    required DateTime date,
    required bool isCredit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              Text(
                DateFormat('MMM dd').format(date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTierCard({
    required BuildContext context,
    required String title,
    required String description,
    required String reward,
    required bool currentTier,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentTier ? Colors.blue.withOpacity(0.1) : AppTheme.darkTheme.cardColor,
        boxShadow: [BoxShadow(
          offset: Offset(2, 2)
        ),],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentTier ? Colors.blue : Colors.grey.withOpacity(0.2),
          width: currentTier ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTierColor(title).withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _getTierIcon(title),
              color: _getTierColor(title),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (currentTier)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            reward,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Bronze':
        return Colors.brown;
      case 'Silver':
        return Colors.blueGrey;
      case 'Gold':
        return Colors.amber;
      case 'Platinum':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier) {
      case 'Bronze':
        return Icons.workspace_premium;
      case 'Silver':
        return Icons.workspace_premium;
      case 'Gold':
        return Icons.workspace_premium;
      case 'Platinum':
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }

  void _showRedeemOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Redeem Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildRedeemOptionCard(
                        context: context,
                        title: 'Mobile Recharge',
                        description: 'Recharge your mobile phone',
                        icon: Icons.phone_android,
                        color: Colors.orange,
                      ),
                      _buildRedeemOptionCard(
                        context: context,
                        title: 'Bank Transfer',
                        description: 'Transfer to your bank account',
                        icon: Icons.account_balance,
                        color: Colors.blue,
                      ),
                      _buildRedeemOptionCard(
                        context: context,
                        title: 'Gift Cards',
                        description: 'Redeem for popular gift cards',
                        icon: Icons.card_giftcard,
                        color: Colors.purple,
                      ),
                      _buildRedeemOptionCard(
                        context: context,
                        title: 'Utility Bills',
                        description: 'Pay your electricity or water bills',
                        icon: Icons.receipt_long,
                        color: Colors.green,
                      ),
                      _buildRedeemOptionCard(
                        context: context,
                        title: 'Donate',
                        description: 'Donate to environmental causes',
                        icon: Icons.volunteer_activism,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRedeemOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

