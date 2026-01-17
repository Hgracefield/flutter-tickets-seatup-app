import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class GpsNotifier extends Notifier<GpsState>{

  @override
  GpsState build() => GpsState();
  Future checkLocationPermission() async{
    LocationPermission permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if(permission == LocationPermission.deniedForever) return;

    if(permission == LocationPermission.whileInUse || permission == LocationPermission.always){
      final position = await Geolocator.getCurrentPosition();
      
      state = state.copywith(
        latitude: position.latitude,
        longitude: position.longitude,
      );  
    }
  }
} // GpsNotifier

final gpsNotifierProvider = NotifierProvider<GpsNotifier, GpsState>(
  GpsNotifier.new);

class GpsState
{
  final double latitude;
  final double longitude;

  GpsState({
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  GpsState copywith({double? latitude, double? longitude})
  {
    return GpsState(
      latitude: latitude ?? this.latitude, 
      longitude: longitude ?? this.longitude,
      );
  }
} // GpsState