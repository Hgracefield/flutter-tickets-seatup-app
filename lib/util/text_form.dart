import 'package:flutter/material.dart';
import 'package:seatup_app/util/color.dart';

class TextForm {
  TextForm._(); // 인스턴스 생성 방지

  static Widget suAppText({required String text}) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textColor,
      ),
    );
  }
}
