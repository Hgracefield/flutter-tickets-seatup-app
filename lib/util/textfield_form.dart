import 'package:flutter/material.dart';

class TextfieldForm {
  TextfieldForm._(); // 인스턴스 생성 방지

  // === Widgets ===
  static Widget suTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    void Function(String value)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),

        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

        filled: true,
        fillColor: const Color(0xFFF8F8F8),

        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}


// =========================== 사용 예시 ============================
// TextfieldForm.searchTextField(
//   controller: searchController,
//   hintText: '검색어를 입력하세요',
//   prefixIcon: Icons.search,
//   onSubmitted: (value) {
//     search();
//   },
// ),