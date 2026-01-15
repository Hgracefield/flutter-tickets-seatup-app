import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPerformanceCreate extends ConsumerWidget {
  const AdminPerformanceCreate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [핵심] productNotifierProvider의 상태를 감시함 (data, error, loading으로 나뉨)
    final typeAsync = ref.watch(typeNotifierProvider);
    final vmHandler = ref.read(typeNotifierProvider.notifier);

    return Scaffold(
      body: Row(
        children: [
          // 왼쪽 사이드바 (생략 - 파란색 배경 부분)
          Container(width: 200, color: Colors.blueAccent),
          
          // 메인 컨텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("제품 정보", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                  const SizedBox(height: 20),
                  
                  // 필터 영역 (이미지 상단의 SelectBox들)
                  _buildFilterHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // [설명] Riverpod의 .when을 사용하여 로딩/에러/데이터 상태에 따른 화면 처리
                  productAsync.when(
                    data: (productList) => _buildProductTable(productList, vmHandler),
                    error: (err, stack) => Center(child: Text("에러 발생: $err")),
                    loading: () => const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 테이블 헤더와 데이터 렌더링
  Widget _buildProductTable(productList, vmHandler) {
    return Expanded(
      child: ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: index % 2 == 0 ? Colors.white : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(value: false, onChanged: (val){}),
                Expanded(child: Text(product.type, textAlign: TextAlign.center)),
                Expanded(child: Text(product.title, textAlign: TextAlign.center)),
                Expanded(child: Text(product.location, textAlign: TextAlign.center)),
                Expanded(child: Text(product.place, textAlign: TextAlign.center)),
                Expanded(child: Text(product.grade, textAlign: TextAlign.center)),
                Expanded(child: Text(product.area, textAlign: TextAlign.center)),
                Expanded(child: Text(product.showDate, textAlign: TextAlign.center)),
                Expanded(child: Text(product.showTime, textAlign: TextAlign.center)),
                Expanded(child: Text(product.showCast, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
                ElevatedButton(
                  onPressed: () {
                    // [설명] 수정 버튼 클릭 시 vmHandler.updateProduct() 호출 로직 연결
                  },
                  child: const Text("수정"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader() {
     // 이미지 상단의 드롭다운 박스들 구성 (생략)
     return Container(); 
  }
}