import 'package:flutter/material.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';

class AdminReviewManage extends StatelessWidget {
  const AdminReviewManage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            AdminSideBar(selectedMenu: SideMenu.reviewManage, onMenuSelected: (menu) {}),
           
          ],
        )),
    );
  }
}
