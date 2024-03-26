import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  /// Gets the current device location.
  ///
  /// Returns [LocationData] on success, [null] on failure.
  Future<LocationData?> getCurrentLocation() async {
    try {
      return await location.getLocation();
    } catch (e) {
      // Handle specific exceptions if needed
      print('Error getting location: $e');
      return null;
    }
  }
}