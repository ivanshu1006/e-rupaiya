import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/referral_share_service.dart';

class ReferralShareActions extends HookWidget {
  const ReferralShareActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => ReferralShareService.shareWhatsApp(context),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE85A2C),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      size: 14,
                      color: Color(0xFF25D366),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Refer On Whatsapp',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => ReferralShareService.shareAny(context),
          child: Container(
            height: 44.h,
            width: 54.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF7DCD2),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: const Icon(Icons.share_outlined, color: Color(0xFFB44B2F)),
          ),
        ),
      ],
    );
  }
}
