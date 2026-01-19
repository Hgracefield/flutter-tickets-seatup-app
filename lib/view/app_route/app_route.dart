import 'package:seatup_app/view/admin/faq_detail.dart';
import 'package:seatup_app/view/user/curtain_search.dart';

class AppRoute {
  // ===== USER =====
  static const splash = '/';
  static const userLogin = '/user_login'; // 고객 로그인
  static const userFindInfo =
      '/user_find_info'; // 회원 정보 찾기
  static const signUp = '/sign_up'; // 회원가입
  static const userInfoUpdate =
      '/user_info_update'; // 회원 정보 수정
  static const userMypage = '/user_mypage'; // 마이 페이지
  static const tabBar = '/tab_bar';
  static const main = '/main_page';
  static const curtainDetail =
      '/curtain_detail'; // 공연 정보 페이지
  static const ticketDetail =
      '/ticket_detail'; // 티켓 상세 페이지
  static const purchaseHistory =
      '/purchase_history'; // 구매 이력
  static const purchaseDetail =
      '/purchase_detail'; // 구매 상세
  static const mapView = '/map_view'; // 지도 보기
  static const payment = '/payment'; // 결제 화면
  static const category = '/category'; // 가테고리
  static const curtainSearch = '/curtain_search'; // 검색 결과
  static const reviewWrite = '/review_write'; // 관람 후기 작성
  static const reviewList = '/review_list'; // 관람 후기 내역
  // static const sellerToSellerChat = '/seller_to_seller_chat';
  static const sellerToAdminChat =
      '/seller_to_admin_chat'; // 관리자 문의 채팅
  static const transactionReviewWrite =
      '/transaction_review_write'; // 거래 후기 작성
  static const transactionReviewList =
      '/transaction_review_list'; // 거래 후기 내역
  // static const transactionCancel = '/transaction_cancel';
  // static const transactionTicketsCheck = '/transaction_tickets_check';
  static const shoppingCart = '/shopping_cart'; // 찜하기
  static const sellRegister = '/sell_register'; // 판매 등록
  static const sellHistory = '/sell_history'; // 판매 내역

  // ===== ADMIN =====
  static const adminLogin = '/admin_login'; // 관리자 로그인
  static const adminDashboard =
      '/admin_dashboard'; // 관리자 대시보드
  // static const adminPerformanceCreate = '/admin_performance_create';
  static const adminCurtainEdit =
      '/admin_curtain_edit'; // 뮤지컬 정보 수정
  static const faqList = '/faq_list'; // faq 리스트
  static const faqInsert = '/faq_insert'; // faq 입력
  static const faqUpdate = '/faq_update'; // faq 수정
  static const FaqDetail = '/faq_detail'; // faq 상세 내용
  static const boardWrite = '/board_write'; // 게시판 글 쓰기
  static const boardEdit = '/board_edit'; // 게시판 글 수정
  static const adminTransactionManage =
      '/admin_transaction_manage'; // 거래글 관리
  static const adminReviewManage =
      '/admin_review_manage'; // 관람 후기 관리
  static const adminTransactionReviewManage =
      '/admin_transaction_review_manage'; // 거래 후기 관리
  static const adminChatList =
      '/admin_chat_list'; // 고객 채팅 리스트
  static const adminChatDetail =
      '/admin_chat_detail'; // 고객 채팅 화면
}
