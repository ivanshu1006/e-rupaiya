// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/k_dialog.dart';
import '../../refer_and_earn/components/refer_and_earn_app_bar.dart';
import '../../refer_and_earn/repositories/bank_account_repository.dart';
import '../../refer_and_earn/views/add_bank_account_view.dart';
import '../../refer_and_earn/views/select_bank_view.dart';
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

    Future<void> openAddBank([BankAccountEntry? account]) async {
      if (account == null) {
        final selected = await Navigator.of(context).push<BankListItem>(
          MaterialPageRoute(
            builder: (_) => const SelectBankView(),
          ),
        );
        if (selected == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                AddBankAccountView(selectedBankName: selected.bankName),
          ),
        );
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddBankAccountView(existingAccount: account),
          ),
        );
      }
      refreshKey.value += 1;
    }

    Future<void> openEditBank(BankAccountEntry account) async {
      final selected = await Navigator.of(context).push<BankListItem>(
        MaterialPageRoute(
          builder: (_) => const SelectBankView(),
        ),
      );
      if (selected == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddBankAccountView(
            existingAccount: account,
            selectedBankName: selected.bankName,
          ),
        ),
      );
      refreshKey.value += 1;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      // bottomNavigationBar: SafeArea(
      //   top: false,
      //   child: Padding(
      //     padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
      //     child: CustomElevatedButton(
      //       label: 'Add New Bank Account',
      //       onPressed: openAddBank,
      //       height: 52.h,
      //       uppercaseLabel: false,
      //     ),
      //   ),
      // ),
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
                child: _buildBody(
                  context,
                  snapshot,
                  openAddBank,
                  openEditBank,
                  () => refreshKey.value += 1,
                ),
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
  void Function([BankAccountEntry?]) onAddBank,
  Future<void> Function(BankAccountEntry) onEditBank,
  VoidCallback refresh,
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
  final existingAccount = accounts.isNotEmpty ? accounts.first : null;
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (existingAccount == null)
          Text(
            'No bank accounts added yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
          )
        else
          _BankAccountCard(
            account: existingAccount,
            onEdit: () => onEditBank(existingAccount),
            onDelete: () async {
              if (existingAccount.id == null) {
                AppSnackbar.show('Unable to delete bank account.');
                return;
              }

              final dialog = _ConfirmDeleteBankDialog(
                bankName: existingAccount.bankName,
                onCancel: () => Navigator.of(context).pop(),
                onConfirm: () async {
                  Navigator.of(context).pop();
                  try {
                    final response = await BankAccountsRepository()
                        .deleteBank(bankId: existingAccount.id!);
                    if (response.status) {
                      AppSnackbar.show(response.message.isEmpty
                          ? 'Bank account deleted successfully.'
                          : response.message);
                      refresh();
                    } else {
                      AppSnackbar.show(response.message.isEmpty
                          ? 'Failed to delete bank account.'
                          : response.message);
                    }
                  } catch (e) {
                    AppSnackbar.show('Failed to delete bank account.');
                  }
                },
              );
              await KDialog.instance.openDialog(dialog: dialog);
            },
          ),
        if (existingAccount == null) ...[
          SizedBox(height: 14.h),
          InkWell(
            onTap: () => onAddBank(),
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
      ],
    ),
  );
}

class _BankAccountCard extends HookWidget {
  const _BankAccountCard({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final BankAccountEntry account;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

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
          PopupMenuButton<_BankAccountMenuAction>(
            icon: const Icon(Icons.more_vert, size: 18),
            splashRadius: 20,
            onSelected: (value) async {
              switch (value) {
                case _BankAccountMenuAction.edit:
                  onEdit();
                  break;
                case _BankAccountMenuAction.delete:
                  await onDelete();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _BankAccountMenuAction.edit,
                child: Text('Edit Bank'),
              ),
              PopupMenuItem(
                value: _BankAccountMenuAction.delete,
                child: Text('Delete Bank'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _BankAccountMenuAction { edit, delete }

class _ConfirmDeleteBankDialog extends StatelessWidget {
  const _ConfirmDeleteBankDialog({
    required this.bankName,
    required this.onCancel,
    required this.onConfirm,
  });

  final String bankName;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECE8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance,
                size: 40,
                color: Color(0xFFE85A2C),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Bank Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to delete $bankName?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.75),
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text(
                      'No',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85A2C),
                    ),
                    child: const Text('Yes',
                        style: TextStyle(color: AppColors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
