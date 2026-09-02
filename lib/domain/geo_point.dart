import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A latitude/longitude pair.
@immutable
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  static const _earthRadiusMetres = 6371000.0;

  /// Great-circle distance in metres (haversine).
  double distanceTo(GeoPoint other) {
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return _earthRadiusMetres * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// The user's assumed position: Sydney Town Hall.
///
/// Device location is deliberately stubbed. This assessment covers the front
/// end only, and adding a location plugin would introduce runtime permission
/// dialogs that interrupt the emulator demo without exercising any UI that
/// isn't already exercised by a fixed origin.
const kSydneyCbd = GeoPoint(-33.8737, 151.2069);
