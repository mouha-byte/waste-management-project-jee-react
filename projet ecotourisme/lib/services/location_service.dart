import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final Location _location = Location();

  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await _location.getLocation();
  }

  double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  int estimateWalkingTime(double distanceKm) {
    // Average walking speed: 5 km/h
    return (distanceKm / 5 * 60).round();
  }

  int estimateCyclingTime(double distanceKm) {
    // Average cycling speed: 15 km/h
    return (distanceKm / 15 * 60).round();
  }

  Stream<LocationData> getPositionStream() {
    return _location.onLocationChanged;
  }
}
