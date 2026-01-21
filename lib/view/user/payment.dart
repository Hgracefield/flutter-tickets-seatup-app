import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: const Text("주문 결제"), centerTitle: true),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: ListView(children: [
            PaymentMethodWidget(paymentWidget: _paymentWidget, selector: 'methods'),
            AgreementWidget(paymentWidget: _paymentWidget, selector: 'agreement'),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  final paymentResult = await _paymentWidget.requestPayment(
                    paymentInfo: PaymentInfo(
                      orderId: 'ORDER_${widget.post.post_seq}_${DateTime.now().millisecondsSinceEpoch}', 
                      orderName: '${widget.post.curtain_title} 티켓 ${widget.post.post_quantity}매'
                    )
                  );

                  if (paymentResult.success != null) {
                    // [핵심] 결제 성공 시 DB 상태를 1(판매완료)로 변경
                    final result = await ref.read(postNotifierProvider.notifier)
                        .updatePostStatus(widget.post.post_seq!, 1);

                    if (result == "OK" && mounted) {
                      Navigator.pop(context); // 결제창 닫기
                      Navigator.pop(context); // 상세페이지 닫기
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("결제가 완료되어 판매가 종료되었습니다.")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8DE7D), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('결제하기', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]))
        ]),
      ),
    );
  }
}