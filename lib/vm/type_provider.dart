import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [핵심] UI에서 이 provider를 watch하여 데이터의 로딩/성공/에러 상태를 자동으로 관리함
final productNotifierProvider = AsyncNotifierProvider<ProductNotifier, List<Product>>(() {
  return ProductNotifier();
});

class ProductNotifier extends AsyncNotifier<List<Product>> {
  
  // [설명] 초기 데이터를 가져오는 로직. build()가 실행되면 상태가 'loading'이 됨
  @override
  Future<List<Product>> build() async {
    return fetchProducts();
  }

  // [Read] Python 서버에서 데이터 가져오기
  Future<List<Product>> fetchProducts() async {
    var url = Uri.parse("http://localhost:8000/products"); // 본인 서버 주소
    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("데이터를 불러오는데 실패했습니다.");
    }
  }

  // [Insert] 데이터 추가
  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading(); // 화면에 로딩 표시를 위해 상태 변경
    state = await AsyncValue.guard(() async {
      var url = Uri.parse("http://localhost:8000/insert");
      await http.post(url, body: product.toJson());
      return fetchProducts(); // 추가 후 목록을 새로고침하여 UI 업데이트
    });
  }

  // [Update] 데이터 수정 (이미지의 '수정' 버튼 클릭 시 활용)
  Future<void> updateProduct(Product product) async {
    state = await AsyncValue.guard(() async {
      var url = Uri.parse("http://localhost:8000/update");
      await http.post(url, body: product.toJson());
      return fetchProducts(); // 수정 후 목록 새로고침
    });
  }

  // [Delete] 데이터 삭제
  Future<void> deleteProduct(int id) async {
    state = await AsyncValue.guard(() async {
      var url = Uri.parse("http://localhost:8000/delete?id=$id");
      await http.get(url);
      return fetchProducts();
    });
  }
}