// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../refer_and_earn/components/refer_and_earn_app_bar.dart';
import '../../refer_and_earn/views/add_bank_account_view.dart';
import '../repositories/bank_accounts_repository.dart';

class BankAccountsView extends HookWidget {
  const BankAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    final refreshKey = useState(0);
    final repository = useMemoized(() => BankAccountsRepository());
    final future = useMemoized(
      () => repository.fetchAccounts(),
      [refreshKey.value],
    );
    final snapshot = useFuture(future);

    Future<void> openAddBank() async {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddBankAccountView()),
      );
      refreshKey.value += 1;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
          child: CustomElevatedButton(
            label: 'Add New Bank Account',
            onPressed: openAddBank,
            height: 52.h,
            uppercaseLabel: false,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              ReferAndEarnAppBar(
                title: 'Bank Accounts',
                onHelp: () {},
                height: 260,
              ),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),
          Positioned.fill(
            top: 200.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 12.h),
                child: _buildBody(context, snapshot, openAddBank),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBody(
  BuildContext context,
  AsyncSnapshot<List<BankAccountEntry>> snapshot,
  VoidCallback onAddBank,
) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }
  if (snapshot.hasError) {
    return Text(
      'Failed to load bank accounts. Please try again.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary.withOpacity(0.6),
          ),
    );
  }

  final accounts = snapshot.data ?? const <BankAccountEntry>[];
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (accounts.isEmpty)
          Text(
            'No bank accounts added yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
          )
        else
          ...accounts.map((account) => _BankAccountCard(account: account)),
        SizedBox(height: 14.h),
        InkWell(
          onTap: onAddBank,
          borderRadius: BorderRadius.circular(12.r),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textPrimary.withOpacity(0.4),
                  ),
                ),
                child: const Icon(Icons.account_balance_outlined),
              ),
              SizedBox(width: 12.w),
              Text(
                'Add New Bank Account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BankAccountCard extends HookWidget {
  const _BankAccountCard({required this.account});

  final BankAccountEntry account;

  @override
  Widget build(BuildContext context) {
    final bankName =
        account.bankName.isNotEmpty ? account.bankName : 'Bank Account';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBorder.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: Color(0xFF1A56A1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bankName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    if (account.verified)
                      Text(
                        'Verified',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF1B8E36),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  account.accountNumber,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, size: 18),
        ],
      ),
    );
  }
}
