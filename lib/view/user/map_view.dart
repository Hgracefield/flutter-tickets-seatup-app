import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:seatup_app/vm/route_vm.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  KakaoMapController? _controller;

  ProviderSubscription<RouteState>? _routeSub;
  ProviderSubscription<int?>? _placeSub;

  int? _lastPlaceSeq;

  @override
  void initState() {
    super.initState();

    //  1) route state 변화 감지 -> polyline 그리기
    _routeSub = ref.listenManual<RouteState>(routeNotifierProvider, (
      prev,
      next,
    ) {
      if (_controller == null) return;
      if (next.routePoints.isEmpty) return;

      _controller!.clearPolyline(polylineIds: ['route']);

      _controller!.addPolyline(
        polylines: [
          Polyline(
            polylineId: 'route',
            points: next.routePoints,
            strokeWidth: 6,
          ),
        ],
      );

      if (next.origin != null && next.destination != null) {
        _controller!.fitBounds([next.origin!, next.destination!]);
      }
    });

    //  2) placeSeq 변화 감지 -> 길찾기 실행
    _placeSub = ref.listenManual<int?>(selectedPlaceSeqProvider, (
      prev,
      next,
    ) {
      if (next == null) return;
      if (_lastPlaceSeq == next) return; //  중복 호출 방지
      _lastPlaceSeq = next;

      final box = GetStorage();
      final userId = box.read('user_Id');

      if (userId == null) {
        // 로그인 안 된 상태
        return;
      }

      ref
          .read(routeNotifierProvider.notifier)
          .loadRoute(userId: userId as int, placeSeq: next);
    });

    //  화면 진입 시 이미 placeSeq가 들어있다면 바로 실행
    Future.microtask(() {
      final placeSeq = ref.read(selectedPlaceSeqProvider);
      if (placeSeq == null) return;

      final userId = GetStorage().read('user_Id');
      if (userId == null) return;

      _lastPlaceSeq = placeSeq;

      ref
          .read(routeNotifierProvider.notifier)
          .loadRoute(userId: userId as int, placeSeq: placeSeq);
    });
  }

  @override
  void dispose() {
    _routeSub?.close();
    _placeSub?.close();

    // 원하면 맵 나갈 때 선택값 비우기 (선택)
    // ref.read(selectedPlaceSeqProvider.notifier).state = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routeNotifierProvider);
    final placeSeq = ref.watch(selectedPlaceSeqProvider);

    final markers = <Marker>[];
    if (state.origin != null) {
      markers.add(Marker(markerId: 'start', latLng: state.origin!));
    }
    if (state.destination != null) {
      markers.add(
        Marker(markerId: 'end', latLng: state.destination!),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('앱 안에서 길찾기')),
      body: Column(
        children: [
          if (placeSeq == null)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('선택된 공연장(placeSeq)이 없습니다.'),
            ),

          if (state.isLoading)
            const LinearProgressIndicator(minHeight: 3),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          Expanded(
            child: KakaoMap(
              onMapCreated: (controller) => _controller = controller,
              center: state.origin ?? LatLng(37.5665, 126.9780),
              markers: markers,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('출발: ${state.userAddress ?? "-"}'),
                Text('도착: ${state.placeAddress ?? "-"}'),
                Text('경로점 개수: ${state.routePoints.length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
