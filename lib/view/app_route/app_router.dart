import 'package:flutter/material.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/view/user/curtain_list_screen.dart';
import 'package:seatup_app/view/user/purchase_history_detail.dart';
import 'package:seatup_app/view/user/user_faq.dart';
import 'app_route.dart';

// ===== User =====
import '/view/user/splash_screen.dart';
import '/view/user/user_login.dart';
import '/view/user/user_find_info.dart';
import '/view/user/sign_up.dart';
import '/view/user/user_info_update.dart';
import '/view/user/user_mypage.dart';
import '../user/tab_bar_page.dart';
import '/view/user/main_page.dart';
import '/view/user/ticket_detail.dart';
import '/view/user/purchase_history.dart';
import '/view/user/purchase_history_detail.dart';
import '/view/user/map_view.dart';
import '/view/user/payment.dart';
import '/view/user/category.dart';
import '../user/curtain_search.dart';
import '/view/user/review_write.dart';
import '/view/user/review_list.dart';
import '/view/user/seller_to_admin_chat.dart';
import '/view/user/transaction_review_write.dart';
import '/view/user/transaction_review_list.dart';
import '/view/user/shopping_cart.dart';
import '/view/user/sell_register.dart';
import '/view/user/sell_history.dart';
// import '/view/user/seller_/to_seller_chat.dart';

// ===== ADMIN =====
import '/view/admin/admin_login.dart';
import '/view/admin/admin_dashboard.dart';
import '/view/admin/admin_curtain_edit.dart';
import '../admin/faq_list.dart';
import '../admin/faq_insert.dart';
import '../admin/faq_update.dart';
import '../admin/faq_detail.dart';
import '/view/admin/board_write.dart';
import '/view/admin/board_edit.dart';
import '/view/admin/admin_transaction_manage.dart';
import '/view/admin/admin_review_manage.dart';
import '/view/admin/admin_transaction_review_manage.dart';
import '/view/admin/admin_chat_list.dart';
import '/view/admin/admin_chat_detail.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      // ===== USER =====
      case AppRoute.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoute.userLogin:
        return MaterialPageRoute(builder: (_) => const UserLogin());
      case AppRoute.userFindInfo:
        return MaterialPageRoute(builder: (_) => const UserFindInfo());
      case AppRoute.signUp:
        return MaterialPageRoute(builder: (_) => const SignUp(email: '',name: '',phone: '',));
      case AppRoute.userInfoUpdate:
        return MaterialPageRoute(builder: (_) => const UserInfoUpdate());
      case AppRoute.userMypage:
        return MaterialPageRoute(builder: (_) => const UserMypage());
      case AppRoute.tabBar:
        return MaterialPageRoute(builder: (_) => const TabBarPage());
      case AppRoute.main:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case AppRoute.curtainListscreen:
        return MaterialPageRoute(builder: (_) => const CurtainListScreen());
      case AppRoute.ticketDetail:
        return MaterialPageRoute(builder: (_) => const TicketDetail(postSeq: 1));
      case AppRoute.PurchaseHistory:
        return MaterialPageRoute(builder: (_) => const PurchaseHistory());
      case AppRoute.purchaseHistoryDetail:
        final post = settings.arguments as Post;
        return MaterialPageRoute(builder: (_) =>  PurchaseHistoryDetail(post: post)); // const 제거
      case AppRoute.mapView:
        return MaterialPageRoute(builder: (_) => const MapView());
      // case AppRoute.payment:
      //   return MaterialPageRoute(builder: (_) => const Payment());
      case AppRoute.category:
        return MaterialPageRoute(builder: (_) => const Category());
      case AppRoute.curtainSearch:
        return MaterialPageRoute(builder: (_) => const CurtainSearch());
      case AppRoute.reviewWrite:
        return MaterialPageRoute(builder: (_) => const ReviewWrite());
      case AppRoute.reviewList:
        return MaterialPageRoute(builder: (_) => const ReviewList());
      // case AppRoute.userToUserChat:
      // return MaterialPageRoute(builder: (_) => const UserToUserChat());
      case AppRoute.sellerToAdminChat:
        return MaterialPageRoute(builder: (_) => const SellerToAdminChat());
      // case AppRoute.transactionReviewWrite:
      //   return MaterialPageRoute(builder: (_) => const TransactionReviewWrite());
      // case AppRoute.transactionReviewList:
      //   return MaterialPageRoute(builder: (_) => const TransactionReviewList());

      case AppRoute.shoppingCart:
        return MaterialPageRoute(builder: (_) => const ShoppingCart());
      case AppRoute.sellRegister:
        return MaterialPageRoute(builder: (_) => const SellRegister());
      case AppRoute.sellHistory:
        return MaterialPageRoute(builder: (_) => const SellHistory());
      case AppRoute.userFaq:
        return MaterialPageRoute(builder: (_) => const UserFaq());

      // ===== ADMIN =====
      case AppRoute.adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLogin());
      case AppRoute.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case AppRoute.adminCurtainEdit:
        final data = settings.arguments as Curtain;
        return MaterialPageRoute(
          builder: (_) => AdminCurtainEdit(initialData: data), // const 제거
        );
      case AppRoute.faqList:
        return MaterialPageRoute(builder: (_) => const FaqList());
      case AppRoute.faqInsert:
        return MaterialPageRoute(builder: (_) => FaqInsert());
      case AppRoute.faqUpdate:
        return MaterialPageRoute(builder: (_) => FaqUpdate(), settings: settings);
      case AppRoute.faqDetail:
        return MaterialPageRoute(builder: (_) => const FaqDetail());
      case AppRoute.boardWrite:
        return MaterialPageRoute(builder: (_) => const BoardWrite());
      case AppRoute.boardEdit:
        return MaterialPageRoute(builder: (_) => const BoardEdit());
      case AppRoute.adminTransactionManage:
        return MaterialPageRoute(builder: (_) => const AdminTransactionManage());
      case AppRoute.adminReviewManage:
        return MaterialPageRoute(builder: (_) => const AdminReviewManage());
      case AppRoute.adminTransactionReviewManage:
        return MaterialPageRoute(builder: (_) => const AdminTransactionReviewManage());
      case AppRoute.adminChatList:
        return MaterialPageRoute(builder: (_) => const AdminChatList());
      case AppRoute.adminChatDetail:
        return MaterialPageRoute(builder: (_) => const AdminChatDetail());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
