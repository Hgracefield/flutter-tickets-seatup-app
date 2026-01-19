import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/admin/admin_area_insert.dart';
import 'package:seatup_app/view/admin/admin_area_update.dart';
import 'package:seatup_app/vm/area_notifier.dart';

class AdminAreaQuery extends ConsumerWidget {
  const AdminAreaQuery({super.key});

@override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaAsync = ref.watch(areaNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('구역'),
        actions: [ IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminAreaInsert()),
            ),
          ),],
      ),
      body: areaAsync.when(
        data: (areas) {
          return areas.isEmpty
          ? const Center(child: Text('구역 정보가 없습니다'))
          : ListView.builder(
              itemCount: areas.length,
              itemBuilder: (context, index) {
                final area = areas[index];
                return ListTile(
                  title: Text('${area.area_number} (${area.area_seq})'),
                  subtitle: Text('${area.area_value}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminAreaUpdate(
                          seq: area.area_seq!,
                          name: area.area_number,
                          value: area.area_value,
                          date: area.area_create_date!,
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
