import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';


class AddressState{
  String? address = "";
  AddressState({this.address});
  AddressState copyWith({String? address})=>AddressState(address: address);
} // AddressState


class AddressNotifier extends Notifier<AddressState>{
  
  @override
  AddressState build() => AddressState();

  Future getAddressFromCoordinates(double lat, double lng) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  if (placemarks.isNotEmpty) {
    Placemark place = placemarks[0];
    String address = "${place.country}, ${place.administrativeArea}, ${place.locality}, ${place.street}";
    state = state.copyWith(address: address);
  }
}
} // AddressNotifier
final addressNotifier = NotifierProvider<AddressNotifier, AddressState>(
  AddressNotifier.new
);


