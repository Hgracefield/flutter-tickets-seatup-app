import 'package:flutter/material.dart';
import 'package:seatup_app/util/color.dart';

class BtnStyle {
  BtnStyle._();
  // adminBtn
  static Widget primary({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.suyellow,
        backgroundColor: AppColors.textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }

  // adminBtn -small
  static Widget primarySmall({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.suyellow,
        backgroundColor: AppColors.textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
