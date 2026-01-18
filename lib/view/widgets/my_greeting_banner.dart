import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/user_notifier.dart';
class MyGreetingBanner extends ConsumerStatefulWidget {
  const MyGreetingBanner({super.key});

  @override
  ConsumerState<MyGreetingBanner> createState() =>
      _MyGreetingBannerState();
}

class _MyGreetingBannerState extends ConsumerState<MyGreetingBanner> {
  @override
  Widget build(BuildContext context) {
    final message = ref.watch(greetingMessageProvider);

    return Container(
      width: double.infinity, //좌우 꽉채우기 
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        // boxShadow: const [
        //   BoxShadow(
        //     blurRadius: 10,
        //     offset: Offset(0, 4),
        //     color: Color.fromARGB(20, 0, 0, 0),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Image.asset(
              "images/ticket.png",
              width: 115,
              height: 85,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
