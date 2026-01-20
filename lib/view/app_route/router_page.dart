import 'package:flutter/material.dart';
import 'package:seatup_app/view/app_route/app_route.dart';

class RouterPage extends StatelessWidget {
  const RouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SeatUp Main (Route Hub)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('USER'),

          _btn(context, 'splash_screen', AppRoute.splash),
          _btn(context, 'user_login', AppRoute.userLogin),
          _btn(context, 'user_find_info', AppRoute.userFindInfo),
          _btn(context, 'sign_up', AppRoute.signUp),
          _btn(context, 'user_info_update', AppRoute.userInfoUpdate),
          _btn(context, 'user_mypage', AppRoute.userMypage),
          _btn(context, 'tab_bar', AppRoute.tabBar),
          _btn(context, 'main_page', AppRoute.main),
          _btn(context, 'curtain_list', AppRoute.curtainList),
          _btn(context, 'ticket_detail', AppRoute.ticketDetail),
          _btn(context, 'purchase_history', AppRoute.purchaseHistoryDetail),
          _btn(context, 'purchase_history_detail', AppRoute.purchaseHistoryDetail),
          _btn(context, 'map_view', AppRoute.mapView),
          _btn(context, 'payment', AppRoute.payment),
          _btn(context, 'category', AppRoute.category),
          _btn(context, 'search_result', AppRoute.curtainSearch),
          _btn(context, 'review_write', AppRoute.reviewWrite),
          _btn(context, 'review_list', AppRoute.reviewList),
          // _btn(context, 'seller_to_seller_chat', AppRoute.sellerToSellerChat),
          _btn(context, 'seller_to_admin_chat', AppRoute.sellerToAdminChat),
          _btn(context, 'transaction_review_write', AppRoute.transactionReviewWrite),
          _btn(context, 'transaction_review_list', AppRoute.transactionReviewList),
          // _btn(context, 'transaction_cancel', AppRoute.transactionCancel),
          // _btn(context, 'transaction_tickets_check', AppRoute.transactionTicketsCheck),
          _btn(context, 'shopping_cart', AppRoute.shoppingCart),
          _btn(context, 'sell_register', AppRoute.sellRegister),
          _btn(context, 'sell_history', AppRoute.sellHistory),
          _btn(context, 'user_faq', AppRoute.userFaq),

          const SizedBox(height: 24),
          _section('ADMIN'),

          _btn(context, 'admin_login', AppRoute.adminLogin),
          _btn(context, 'admin_dashboard', AppRoute.adminDashboard),
          // _btn(context, 'admin_curtain_create', AppRoute.adminCurtainCreate),
          _btn(context, 'admin_curtain_edit', AppRoute.adminCurtainEdit),
          _btn(context, 'faq_list', AppRoute.faqList),
          _btn(context, 'faq_insert', AppRoute.faqInsert),
          _btn(context, 'faq_update', AppRoute.faqUpdate),
          _btn(context, 'faq_detail', AppRoute.faqDetail),
          _btn(context, 'board_write', AppRoute.boardWrite),
          _btn(context, 'board_edit', AppRoute.boardEdit),
          _btn(context, 'admin_transaction_manage', AppRoute.adminTransactionManage),
          _btn(context, 'admin_review_manage', AppRoute.adminReviewManage),
          _btn(
            context,
            'admin_transaction_review_manage',
            AppRoute.adminTransactionReviewManage,
          ),
          _btn(context, 'admin_chat_list', AppRoute.adminChatList),
          _btn(context, 'admin_chat_detail', AppRoute.adminChatDetail),
        ],
      ),
    );
  }

  // ================= helper =================

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _btn(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(alignment: Alignment.centerLeft),
        child: Text(label),
      ),
    );
  }
}
