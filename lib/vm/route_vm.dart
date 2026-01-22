import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:seatup_app/util/global_data.dart';
import '../model/address.dart';
import '../repository/address_repository.dart';
import '../repository/kakao_directions_repository.dart';

//  1) Repository Provider들
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(GlobalData.url);
});
final selectedPlaceSeqProvider = StateProvider<int?>((ref) => null);

final kakaoDirectionsRepositoryProvider =
    Provider<KakaoDirectionsRepository>((ref) {
      return KakaoDirectionsRepository();
    });

//  2) RouteState (길찾기 상태)
class RouteState {
  final bool isLoading;
  final String? error;

  final String? userAddress;
  final String? placeAddress;

  final LatLng? origin;
  final LatLng? destination;

  final List<LatLng> routePoints;

  // 추가 기능: 총 거리/시간
  final int distanceMeter;
  final int durationSec;

 
  const RouteState({
    this.isLoading = false,
    this.error,
    this.userAddress,
    this.placeAddress,
    this.origin,
    this.destination,
    this.routePoints = const [],
    this.distanceMeter = 0,
    this.durationSec = 0,
  });

  RouteState copyWith({
    bool? isLoading,
    String? error,
    String? userAddress,
    String? placeAddress,
    LatLng? origin,
    LatLng? destination,
    List<LatLng>? routePoints,
    int? distanceMeter,
    int? durationSec,
  }) {
    return RouteState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userAddress: userAddress ?? this.userAddress,
      placeAddress: placeAddress ?? this.placeAddress,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      routePoints: routePoints ?? this.routePoints,
      distanceMeter: distanceMeter ?? this.distanceMeter,
      durationSec: durationSec ?? this.durationSec,
    );
  }
}

//  3. RouteNotifier Provider
final routeNotifierProvider =
    NotifierProvider<RouteNotifier, RouteState>(RouteNotifier.new);

// 4. RouteNotifier (주소 2개 → 좌표 2개 → Polyline 점 리스트)
class RouteNotifier extends Notifier<RouteState> {
  @override
  RouteState build() => const RouteState();

  Future<void> loadRoute({
    required int userId,
    required int placeSeq,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      routePoints: [],
      distanceMeter: 0,
      durationSec: 0,
    );

    try {
      // 1. FastAPI에서 주소 가져오기
      final addressRepo = ref.read(addressRepositoryProvider);

      final UserAddress user = await addressRepo.fetchUserAddress(
        userId,
      );
      final PlaceAddress place = await addressRepo.fetchPlace(
        placeSeq,
      );

      final userAddress = user.userAddress;
      final placeAddress = place.placeAddress;

      // 2. 주소 → 좌표 변환
      final originLoc = await _geocode(userAddress);
      final destLoc = await _geocode(placeAddress);

      if (originLoc == null || destLoc == null) {
        throw Exception('주소 → 좌표 변환 실패 (주소가 너무 짧거나 형식이 이상할 수 있음)');
      }

      final origin = LatLng(originLoc.latitude, originLoc.longitude);
      final destination = LatLng(destLoc.latitude, destLoc.longitude);

      //  3. 카카오 길찾기 API로 경로 점 가져오기
      final kakaoRepo = ref.read(kakaoDirectionsRepositoryProvider);

      final result = await kakaoRepo.fetchRouteResult(
        originLat: origin.latitude,
        originLng: origin.longitude,
        destLat: destination.latitude,
        destLng: destination.longitude,
      );

      state = state.copyWith(
        isLoading: false,
        userAddress: userAddress,
        placeAddress: placeAddress,
        origin: origin,
        destination: destination,
        routePoints: result.points,
        distanceMeter: result.distanceMeter,
        durationSec: result.durationSec,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Location?> _geocode(String address) async {
    final list = await locationFromAddress(address);
    if (list.isEmpty) return null;
    return list.first;
  }
}
