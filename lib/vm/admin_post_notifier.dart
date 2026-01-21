// lib/vm/admin_post_notifier.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final adminPostListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      debugPrint('🔥 adminPostListProvider EXECUTED');

      final res = await http.get(
        Uri.parse('http://192.168.45.25:8000/post/allSelectAdmin'),
      );

      debugPrint('STATUS CODE => ${res.statusCode}');
      debugPrint('RAW BODY => ${utf8.decode(res.bodyBytes)}');

      if (res.statusCode != 200) {
        throw Exception('서버 오류: ${res.statusCode}');
      }

      final body = jsonDecode(utf8.decode(res.bodyBytes));
      debugPrint('DECODED BODY => $body');

      if (body == null || body['results'] == null) {
        throw Exception('API 응답에 results 없음');
      }

      if (body['results'] is! List) {
        throw Exception('results가 List가 아님: ${body['results']}');
      }

      return List<Map<String, dynamic>>.from(body['results']);
    });
