import 'package:flutter/material.dart';

class MyPageMenuSection extends StatelessWidget {
  final String title;
  final List<MyPageMenuItemData> items;

  const MyPageMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color.fromARGB(160, 0, 0, 0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        ...items.map((item) => _MenuLineItem(item: item)),
      ],
    );
  }
}

class MyPageMenuItemData {
  final String text;
  final VoidCallback onTap;

  const MyPageMenuItemData({
    required this.text,
    required this.onTap,
  });
}

class _MenuLineItem extends StatelessWidget {
  final MyPageMenuItemData item;
  const _MenuLineItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
     padding: const EdgeInsets.symmetric(vertical: 7),
     child: Row(
       children: [
         Text(
           item.text,
           style: const TextStyle(
             fontSize: 16,
             fontWeight: FontWeight.w600,
           ),
         ),
      
       ],
     ),
            ),
          );
  }
}
