// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/custom_elevated_button.dart';

class FilterPlansSheet extends StatefulWidget {
  const FilterPlansSheet({
    super.key,
    required this.validityOptions,
    required this.dataOptions,
    required this.initialValiditySelected,
    required this.initialDataSelected,
    required this.onApply,
  });

  final List<String> validityOptions;
  final List<String> dataOptions;
  final Set<String> initialValiditySelected;
  final Set<String> initialDataSelected;
  final void Function(Set<String> validity, Set<String> data) onApply;

  @override
  State<FilterPlansSheet> createState() => _FilterPlansSheetState();
}

class _FilterPlansSheetState extends State<FilterPlansSheet> {
  late final Set<String> _selectedValidity =
      Set<String>.from(widget.initialValiditySelected);
  late final Set<String> _selectedData =
      Set<String>.from(widget.initialDataSelected);

  void _clearAll() {
    setState(() {
      _selectedValidity.clear();
      _selectedData.clear();
    });
  }

  Widget _chipGroup({
    required List<String> options,
    required Set<String> selected,
  }) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (value) {
              setState(() {
                if (value) {
                  selected.add(option);
                } else {
                  selected.remove(option);
                }
              });
            },
            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected.contains(option)
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
            selectedColor: AppColors.primary,
            backgroundColor: const Color(0xFFF6F4F3),
            side: BorderSide(color: AppColors.textPrimary.withOpacity(0.12)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter Plans',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                ),
              ],
            ),
            Divider(color: AppColors.textPrimary.withOpacity(0.08)),
            SizedBox(height: 10.h),
            Text(
              'Validity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 10.h),
            _chipGroup(
              options: widget.validityOptions,
              selected: _selectedValidity,
            ),
            SizedBox(height: 18.h),
            Text(
              'Data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 10.h),
            _chipGroup(
              options: widget.dataOptions,
              selected: _selectedData,
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: _clearAll,
                    label: 'Clear All',
                    uppercaseLabel: false,
                    isBorder: true,
                    height: 40.h,
                    backgroundColor: Colors.white,
                    borderColor: AppColors.textPrimary.withOpacity(0.18),
                    labelColor: Colors.black,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        Set<String>.from(_selectedValidity),
                        Set<String>.from(_selectedData),
                      );
                      Navigator.of(context).pop();
                    },
                    label: 'Apply',
                    uppercaseLabel: false,
                    height: 40.h,
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
