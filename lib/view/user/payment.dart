import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/purchase.dart';
import 'package:seatup_app/view/user/payment_success.dart';
import 'package:seatup_app/vm/purchase_notifier.dart';
import 'package:seatup_app/vm/storage_provider.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/vm/post_notifier.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final Post post;
  final int buyerId;
  const PaymentPage({super.key, required this.post, required this.buyerId});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  @override
  void initState() {
    super.initState();
    _paymentWidget = PaymentWidget(clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm", customerKey: "USER_${widget.buyerId}");
    _paymentWidget.renderPaymentMethods(selector: 'methods', amount: Amount(value: widget.post.post_price, currency: Currency.KRW, country: "KR")).then((control) => _paymentMethodWidgetControl = control);
    _paymentWidget.renderAgreement(selector: 'agreement').then((control) => _agreementWidgetControl = control);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("주문 결제"), centerTitle: true, backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: ListView(children: [
            PaymentMethodWidget(paymentWidget: _paymentWidget, selector: 'methods'),
            AgreementWidget(paymentWidget: _paymentWidget, selector: 'agreement'),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  final userID = ref.watch(storageProvider).read('user_id');
                  final paymentResult = await _paymentWidget.requestPayment(
                    paymentInfo: PaymentInfo(
                      orderId: 'ORDER_${widget.post.post_seq}_${DateTime.now().millisecondsSinceEpoch}', 
                      orderName: '${widget.post.curtain_title} 티켓 ${widget.post.post_quantity}매'
                    )
                  );

                  if (paymentResult.success != null) {
                    // 1. 서버 DB 상태 업데이트 (판매완료)
                    final result = await ref.read(postNotifierProvider.notifier)
                        .updatePostStatus(widget.post.post_seq!, 1);
                     final purchase =  Purchase(
                        purchase_user_id: userID, 
                        purchase_post_id: widget.post.post_seq!, 
                        purchase_create_date: widget.post.post_create_date!);

                      await ref.read(purchaseNotifierProvider.notifier)
                                                    .insertPurchase(purchase);    

                    if (result.contains("OK") && mounted) {
                      // 2. [수정] 성공 화면으로 이동 (데이터 전달)
                      // pushReplacement를 사용하여 결제창으로 뒤로가기 방지
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentSuccessPage(
                            post: widget.post,
                            buyerId: widget.buyerId,
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8DE7D), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: const Text('결제하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ]))
        ]),
      ),
    );
  }
}