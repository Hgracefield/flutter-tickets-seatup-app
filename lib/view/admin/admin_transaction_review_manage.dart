import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';

class AdminTransactionReviewManage extends ConsumerWidget {
  const AdminTransactionReviewManage({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref ) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            AdminSideBar(selectedMenu: SideMenu.transactionReviewManager, onMenuSelected: (menu) {}),
          ],
        ),
      ),
    );
  }
}
