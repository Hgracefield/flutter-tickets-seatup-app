import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_item.dart';
import 'package:seatup_app/view/app_route/app_route.dart';
import 'package:seatup_app/vm/staff_notifier.dart';


class AdminSideBar extends ConsumerWidget {
  final SideMenu selectedMenu;
  final ValueChanged<SideMenu> onMenuSelected;

  const AdminSideBar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 220,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          const SizedBox(height: 24),

          AdminSideItem(
            icon: Icons.dashboard_outlined,
            text: '대시보드',
            selected: selectedMenu == SideMenu.dashboard,
            onTap: () {
                Navigator.pushNamed(context, AppRoute.adminDashboard);
              // Get.to(AdminDashboard());
            },
          ),
          AdminSideItem(
            icon: Icons.view_in_ar_rounded,
            text: '게시판',
            selected: selectedMenu == SideMenu.board,
            onTap: () {
                Navigator.pushNamed(context, AppRoute.faqList);
              // Get.to(AdminInsertProduct());
            },
          ),
          AdminSideItem(
            icon: Icons.shop,
            text: '거래 글 리스트',
            selected: selectedMenu == SideMenu.transaction,
            onTap: () {
                Navigator.pushNamed(context, AppRoute.adminTransactionManage);
              // Get.to(AdminDeliveryProduct());
            },
          ),
          AdminSideItem(
            icon: Icons.reviews,
            text: '거래 후기 관리',
            selected: selectedMenu == SideMenu.transactionReviewManager,
            onTap: () {
                Navigator.pushNamed(context, AppRoute.adminTransactionReviewManage);
              // Get.to(AdminPurchaseManage());
            },
          ),
          AdminSideItem(
            icon: Icons.rate_review,
            text: '관람 후기 관리',
            selected: selectedMenu == SideMenu.reviewManage,
            onTap: () {
                Navigator.pushNamed(context, AppRoute.adminReviewManage);
              // Get.to(AdminReturnProduct());
            },
          ),
          AdminSideItem(
            icon: Icons.chat,
            text: '고객 채팅 관리',
            selected: selectedMenu == SideMenu.chatlist,
            onTap: () {
                Navigator.pushNamed(context, AppRoute.adminChatList);
              // Get.to(AdminStockList());
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                ref.read(staffNotifierProvider.notifier).logout();
                Navigator.pop(context);
              },
              child: _sideLogout(),
            ),
          ),
          // AdminSideItem(
          //   icon: Icons.bar_chart_sharp,
          //   text: '매출 확인',
          //   selected: selectedMenu == SideMenu.sales,
          //   onTap: () {
          //     // Get.to(AdminSalesChart());
          //   },
          // ),
          // AdminSideItem(
          //   icon: Icons.approval_outlined,
          //   text: '품의',
          //   selected: selectedMenu == SideMenu.approval,
          //   onTap: () {
          //     // Get.to(AdminApprovalList());
          //   },
          // ),
          // AdminSideItem(
          //   icon: Icons.call_made,
          //   text: '발주 페이지',
          //   selected: selectedMenu == SideMenu.procure,
          //   onTap: () {
          //     // Get.to(AdminPurchaseOrder());
          //   },
          // ),
          // AdminSideItem(
          //   icon: Icons.chat,
          //   text: '문의 받기',
          //   selected: selectedMenu == SideMenu.chatting,
          //   onTap: () {
          //     // Get.to(AdminChatList());
          //   },
          // ),
          // AdminSideItem(
          //   icon: Icons.border_all_rounded,
          //   text: '게시판',
          //   selected: selectedMenu == SideMenu.board,
          //   onTap: () {
          //     // Get.to(AdminBoard());
          //   },
          // ),
          
          // AdminSideItem(
          //   icon: Icons.settings_outlined,
          //   text: '설정',
          //   selected: selectedMenu == SideMenu.settings,
          //   onTap: () {
          //     // Get.to(());
          //   },
          // ),
        ],
      ),
    );
  } // build

   Widget _sideLogout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2F57C9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '로그아웃',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
} // class
