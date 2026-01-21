import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/admin/admin_grade_insert.dart';
import 'package:seatup_app/view/admin/admin_grade_update.dart';
import 'package:seatup_app/vm/grade_notifier.dart';

class AdminGradeQuery extends ConsumerWidget {
  const AdminGradeQuery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradeAsync = ref.watch(gradeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('좌석 등급'),
        actions: [ IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminGradeInsert()),
            ),
          ),],
      ),
      body: gradeAsync.when(
        data: (grades) {
          return grades.isEmpty
          ? const Center(child: Text('좌석 등급 정보가 없습니다'))
          : ListView.builder(
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return ListTile(
                  title: Text('${grade.grade_name} (${grade.grade_seq})'),
                  subtitle: Text('${grade.grade_value}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminGradeUpdate(
                          seq: grade.grade_seq!,
                          name: grade.grade_name,
                          value: grade.grade_value,
                          date: grade.grade_create_date!,
                          price: grade.grade_price,
                        ),
                      ),
                    );
                  },
                );
              },
            );
        }, 
        error: (error, stackTrace) => Center(child: Text('오류 발생 : $error'),), 
        loading: () => Center(child: CircularProgressIndicator(),),)
    );
  }
}
