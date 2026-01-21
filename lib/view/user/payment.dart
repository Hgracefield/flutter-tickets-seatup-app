import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:seatup_app/model/post.dart';

class PaymentPage extends StatefulWidget {
  final Post post;      // 티켓 정보
  final int buyerId;    // 구매자 ID
  const PaymentPage({super.key, required this.post, required this.buyerId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  @override
  void initState() {
    super.initState();

    // 1. 고객 식별키(customerKey)를 실제 유저 ID로 설정
    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm", 
      customerKey: "USER_${widget.buyerId}"
    );

    // 2. 결제 금액을 실제 티켓 가격으로 설정
    _paymentWidget
        .renderPaymentMethods(
        selector: 'methods',
        amount: Amount(value: widget.post.post_price, currency: Currency.KRW, country: "KR"))
        .then((control) {
      _paymentMethodWidgetControl = control;
    });

    _paymentWidget
        .renderAgreement(selector: 'agreement')
        .then((control) {
      _agreementWidgetControl = control;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("주문 결제"), centerTitle: true),
        body: SafeArea(
            child: Column(children: [
              Expanded(
                  child: ListView(children: [
                    PaymentMethodWidget(
                      paymentWidget: _paymentWidget,
                      selector: 'methods',
                    ),
                    AgreementWidget(paymentWidget: _paymentWidget, selector: 'agreement'),
                    
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            // 3. 실제 티켓 정보로 결제 요청
                            final paymentResult = await _paymentWidget.requestPayment(
                                paymentInfo: PaymentInfo(
                                  orderId: 'ORDER_${widget.post.post_seq}_${DateTime.now().millisecondsSinceEpoch}', 
                                  orderName: '${widget.post.curtain_title} 티켓 ${widget.post.post_quantity}매'
                                ));

                            if (paymentResult.success != null) {
                              // 결제 성공 시 로직 (DB 업데이트 등)
                              print("결제 성공: ${paymentResult.success!.paymentKey}");
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("결제가 완료되었습니다.")));
                            } else if (paymentResult.fail != null) {
                              // 결제 실패 처리
                              // print("결제 실패: ${paymentResult.fail!.message}");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8DE7D),
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text('결제하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                    ),
                  ]))
            ])));
  }
}