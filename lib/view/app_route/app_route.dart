class AppRoute {
  // ===== USER =====
  static const splash = '/';
  static const userLoginSelectPage = '/user_login_select_page'; // 로그인 방법 선택
  static const userLogin = '/user-login'; // 고객 로그인
  static const userFindInfo = '/user-find-info'; // 회원 정보 찾기
  static const signUp = '/sign-up'; // 회원가입
  static const userInfoUpdate = '/user-info-update'; // 회원 정보 수정
  static const userMypage = '/user-mypage'; // 마이 페이지
  static const tabBar = '/tab-bar';
  static const main = '/main_page';
  static const curtainDetail = '/curtain-detail'; // 공연 정보 페이지
  static const ticketDetail = '/ticket-detail'; // 티켓 상세 페이지
  static const purchaseHistory = '/purchase-history'; // 구매 이력
  static const purchaseDetail = '/purchase-detail'; // 구매 상세
  static const mapView = '/map-view'; // 지도 보기
  static const payment = '/payment'; // 결제 화면
  static const category = '/category'; // 가테고리
  static const searchResult = '/search-result'; // 검색 결과
  static const reviewWrite = '/review-write'; // 관람 후기 작성
  static const reviewList = '/review-list'; // 관람 후기 내역
  // static const sellerToSellerChat = '/seller-to-seller-chat';
  static const sellerToAdminChat = '/seller-to-admin-chat'; // 관리자 문의 채팅
  static const transactionReviewWrite = '/transaction-review-write'; // 거래 후기 작성
  static const transactionReviewList = '/transaction-review-list'; // 거래 후기 내역
  // static const transactionCancel = '/transaction-cancel';
  // static const transactionTicketsCheck = '/transaction-tickets-check';
  static const shoppingCart = '/shopping-cart'; // 찜하기
  static const sellRegister = '/sell-register'; // 판매 등록
  static const sellHistory = '/sell-history'; // 판매 내역

  // ===== ADMIN =====
  static const adminLogin = '/admin-login'; // 관리자 로그인
  static const adminDashboard = '/admin-dashboard'; // 관리자 대시보드
  // static const adminPerformanceCreate = '/admin-performance-create';
  static const adminCurtainEdit = '/admin-curtain-edit'; // 뮤지컬 정보 수정
  static const faq = '/faq';
  static const boardWrite = '/board-write'; // 게시판 글 쓰기
  static const boardEdit = '/board-edit'; // 게시판 글 수정
  static const adminTransactionManage = '/admin-transaction-manage'; // 거래글 관리
  static const adminReviewManage = '/admin-review-manage'; // 관람 후기 관리
  static const adminTransactionReviewManage =
      '/admin-transaction-review-manage'; // 거래 후기 관리
  static const adminChatList = '/admin-chat-list'; // 고객 채팅 리스트
  static const adminChatDetail = '/admin-chat-detail'; // 고객 채팅 화면
}
