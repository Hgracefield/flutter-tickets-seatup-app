import 'package:flutter/material.dart';
import 'app_route.dart';

// ===== USER =====
import '/view/user/splash_screen.dart';
import '/view/user/customer_login.dart';
import '/view/user/customer_find_info.dart';
import '/view/user/sign_up.dart';
import '/view/user/customer_info_update.dart';
import '/view/user/customer_mypage.dart';
import '../user/tab_bar_page.dart';
import '/view/user/main_page.dart';
import '/view/user/performance_detail.dart';
import '/view/user/ticket_detail.dart';
import '/view/user/purchase_history.dart';
import '/view/user/purchase_detail.dart';
import '/view/user/map_view.dart';
import '/view/user/payment.dart';
import '/view/user/category.dart';
import '/view/user/search_result.dart';
import '/view/user/review_write.dart';
import '/view/user/review_list.dart';
import '/view/user/seller_to_seller_chat.dart';
import '/view/user/seller_to_admin_chat.dart';
import '/view/user/transaction_review_write.dart';
import '/view/user/transaction_review_list.dart';
import '/view/user/transaction_cancel.dart';
import '/view/user/transaction_tickets_check.dart';
import '/view/user/shopping_cart.dart';
import '/view/user/sell_register.dart';
import '/view/user/sell_history.dart';
import '/view/user/tab_bar_page.dart';

// ===== ADMIN =====
import '/view/admin/admin_login.dart';
import '/view/admin/admin_dashboard.dart';
import '/view/admin/admin_performance_create.dart';
import '/view/admin/admin_performance_edit.dart';
import '/view/admin/faq.dart';
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
      case AppRoute.customerLogin:
        return MaterialPageRoute(builder: (_) => const CustomerLogin());
      case AppRoute.customerFindInfo:
        return MaterialPageRoute(builder: (_) => const CustomerFindInfo());
      case AppRoute.signUp:
        return MaterialPageRoute(builder: (_) => const SignUp());
      case AppRoute.customerInfoUpdate:
        return MaterialPageRoute(builder: (_) => const CustomerInfoUpdate());
      case AppRoute.customerMypage:
        return MaterialPageRoute(builder: (_) => const CustomerMypage());
      case AppRoute.tabBar:
        return MaterialPageRoute(builder: (_) => const TabBarPage());
      case AppRoute.main:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case AppRoute.performanceDetail:
        return MaterialPageRoute(builder: (_) => const PerformanceDetail());
      case AppRoute.ticketDetail:
        return MaterialPageRoute(builder: (_) => const TicketDetail());
      case AppRoute.purchaseHistory:
        return MaterialPageRoute(builder: (_) => const PurchaseHistory());
      case AppRoute.purchaseDetail:
        return MaterialPageRoute(builder: (_) => const PurchaseDetail());
      case AppRoute.mapView:
        return MaterialPageRoute(builder: (_) => const MapView());
      case AppRoute.payment:
        return MaterialPageRoute(builder: (_) => const Payment());
      case AppRoute.category:
        return MaterialPageRoute(builder: (_) => const Category());
      case AppRoute.searchResult:
        return MaterialPageRoute(builder: (_) => const SearchResult());
      case AppRoute.reviewWrite:
        return MaterialPageRoute(builder: (_) => const ReviewWrite());
      case AppRoute.reviewList:
        return MaterialPageRoute(builder: (_) => const ReviewList());
      case AppRoute.sellerToSellerChat:
        return MaterialPageRoute(builder: (_) => const SellerToSellerChat());
      case AppRoute.sellerToAdminChat:
        return MaterialPageRoute(builder: (_) => const SellerToAdminChat());
      case AppRoute.transactionReviewWrite:
        return MaterialPageRoute(builder: (_) => const TransactionReviewWrite());
      case AppRoute.transactionReviewList:
        return MaterialPageRoute(builder: (_) => const TransactionReviewList());
      case AppRoute.transactionCancel:
        return MaterialPageRoute(builder: (_) => const TransactionCancel());
      case AppRoute.transactionTicketsCheck:
        return MaterialPageRoute(builder: (_) => const TransactionTicketsCheck());
      case AppRoute.shoppingCart:
        return MaterialPageRoute(builder: (_) => const ShoppingCart());
      case AppRoute.sellRegister:
        return MaterialPageRoute(builder: (_) => const SellRegister());
      case AppRoute.sellHistory:
        return MaterialPageRoute(builder: (_) => const SellHistory());

      // ===== ADMIN =====
      case AppRoute.adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLogin());
      case AppRoute.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case AppRoute.adminPerformanceCreate:
        return MaterialPageRoute(builder: (_) => const AdminPerformanceCreate());
      case AppRoute.adminPerformanceEdit:
        return MaterialPageRoute(builder: (_) => const AdminPerformanceEdit());
      case AppRoute.faq:
        return MaterialPageRoute(builder: (_) => const Faq());
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
