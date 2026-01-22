import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seatup_app/vm/route_vm.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

enum RouteMode { car, walk }

class _MapViewState extends ConsumerState<MapView> {
  KakaoMapController? _controller;

  ProviderSubscription<RouteState>? _routeSub;
  ProviderSubscription<int?>? _placeSub;

  int? _lastPlaceSeq;

  //  커스텀 마커 아이콘 (assets 로딩용)
  MarkerIcon? _startIcon;
  MarkerIcon? _endIcon;

  RouteMode _mode = RouteMode.car;

  @override
  void initState() {
    super.initState();

    //  마커 아이콘 로드
    _loadMarkerIcons();

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

      // 차량 모드일 때만 앱 내부 폴리라인 길찾기 실행
      if (_mode == RouteMode.car) {
        ref
            .read(routeNotifierProvider.notifier)
            .loadRoute(userId: userId as int, placeSeq: next);
      }
    });

    //  화면 진입 시 이미 placeSeq가 들어있다면 바로 실행
    Future.microtask(() {
      final placeSeq = ref.read(selectedPlaceSeqProvider);
      if (placeSeq == null) return;

      final userId = GetStorage().read('user_id');
      if (userId == null) return;

      _lastPlaceSeq = placeSeq;

      // 차량 모드일 때만 앱 내부 폴리라인 길찾기 실행
      if (_mode == RouteMode.car) {
        ref
            .read(routeNotifierProvider.notifier)
            .loadRoute(userId: userId as int, placeSeq: placeSeq);
      }
    });
  }

  // assets 마커 로딩 함수
  Future<void> _loadMarkerIcons() async {
    try {
      final start = await MarkerIcon.fromAsset('images/start.png');
      final end = await MarkerIcon.fromAsset('images/end.png');

      if (!mounted) return;
      setState(() {
        _startIcon = start;
        _endIcon = end;
      });
    } catch (_) {
      // 로딩 실패해도 기본 마커로 표시되게 그냥 무시
    }
  }

  String _formatDistance(int meter) {
    if (meter <= 0) return '-';
    if (meter >= 1000)
      return '${(meter / 1000).toStringAsFixed(1)}km';
    return '${meter}m';
  }

  String _formatDuration(int sec) {
    if (sec <= 0) return '-';
    final totalMin = (sec / 60).round();
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (h > 0) return '${h}시간 ${m}분';
    return '${m}분';
  }

  Future<void> _openKakaoDirections({
    required RouteMode mode,
    required LatLng start,
    required LatLng end,
  }) async {
    final startName = Uri.encodeComponent('출발');
    final endName = Uri.encodeComponent('도착');

    final modeStr = (mode == RouteMode.walk) ? 'walk' : 'car';

    final url = Uri.parse(
      'https://map.kakao.com/link/by/$modeStr/'
      '$startName,${start.latitude},${start.longitude}/'
      '$endName,${end.latitude},${end.longitude}',
    );

    final ok = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오맵을 열 수 없습니다.')),
      );
    }
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
          icon: _startIcon, //!
        ),
      );
    }

    if (state.destination != null) {
      markers.add(
        Marker(
          markerId: 'end',
          latLng: state.destination!,
          width: 42,
          height: 42,
          icon: _endIcon, //!
        ),
      );
    }

    final polylines = <Polyline>[];
    if (_mode == RouteMode.car && state.routePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: 'route',
          points: state.routePoints,
          strokeWidth: 3,
          strokeColor: Colors.red,
          strokeOpacity: 1.0,
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
                  center: state.origin ?? LatLng(37.5665, 126.9780),
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
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('차량'),
                        selected: _mode == RouteMode.car,
                        onSelected: (v) {
                          if (!v) return;
                          setState(() => _mode = RouteMode.car);

                          final placeSeqNow = ref.read(
                            selectedPlaceSeqProvider,
                          );
                          final userId = GetStorage().read('user_id');
                          if (placeSeqNow == null || userId == null)
                            return;

                          ref
                              .read(routeNotifierProvider.notifier)
                              .loadRoute(
                                userId: userId as int,
                                placeSeq: placeSeqNow,
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('도보'),
                        selected: _mode == RouteMode.walk,
                        onSelected: (v) async {
                          if (!v) return;
                          setState(() => _mode = RouteMode.walk);

                          if (state.origin != null &&
                              state.destination != null) {
                            await _openKakaoDirections(
                              mode: RouteMode.walk,
                              start: state.origin!,
                              end: state.destination!,
                            );
                          }
                        },
                      ),
                      const Spacer(),
                      Text(
                        '${_formatDistance(state.distanceMeter)} · ${_formatDuration(state.durationSec)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
