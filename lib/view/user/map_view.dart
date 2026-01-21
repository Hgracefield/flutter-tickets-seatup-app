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

    //  1) route state 변화 감지 -> 화면 맞추기
    _routeSub = ref.listenManual<RouteState>(routeNotifierProvider, (
      prev,
      next,
    ) async {
      if (_controller == null) return;
      if (next.origin == null || next.destination == null) return;

      // routePoints가 생겼을 때만 화면 맞추기
      if (next.routePoints.isEmpty) return;

      // fitBounds의 padding 파라미터가 없는 버전이면 padding 쓰면 에러남
      await _controller!.fitBounds([next.origin!, next.destination!]);
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

      // 여기 키 무조건 user_id 로 통일
      final userId = box.read('user_id');

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

      final userId = GetStorage().read('user_id');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routeNotifierProvider);
    final placeSeq = ref.watch(selectedPlaceSeqProvider);

    final markers = <Marker>[];

    // 출발 마커 (images 폴더로 경로 변경)
    if (state.origin != null) {
      markers.add(
        Marker(
          markerId: 'start',
          latLng: state.origin!,
          width: 42,
          height: 42,
          markerImageSrc: 'images/start.png',
        ),
      );
    }

    // 도착 마커 (images 폴더로 경로 변경)
    if (state.destination != null) {
      markers.add(
        Marker(
          markerId: 'end',
          latLng: state.destination!,
          width: 42,
          height: 42,
          markerImageSrc: 'images/end.png',
        ),
      );
    }

    final polylines = <Polyline>[];
    if (state.routePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: 'route',
          points: state.routePoints,
          strokeWidth: 6,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('앱 안에서 길찾기')),
      body: Stack(
        children: [
          Column(
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
                  onMapCreated: (controller) async {
                    _controller = controller;

                    if (state.origin != null &&
                        state.destination != null) {
                      await _controller!.fitBounds([
                        state.origin!,
                        state.destination!,
                      ]);
                    }
                  },
                  center:
                      state.origin ??  LatLng(37.5665, 126.9780),
                  markers: markers,
                  polylines: polylines,
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    color: Color(0x22000000),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '출발: ${state.userAddress ?? "-"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '도착: ${state.placeAddress ?? "-"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '경로점 개수: ${state.routePoints.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
