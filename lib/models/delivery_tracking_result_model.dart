import 'package:motora_app/models/delivery_location_point_model.dart';

class DeliveryTrackingResult {
  final String restaurant;
  final String paymentProfile;
  final double totalDistanceMeters;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<DeliveryLocationPoint> path;

  const DeliveryTrackingResult({
    required this.restaurant,
    required this.paymentProfile,
    required this.totalDistanceMeters,
    required this.startedAt,
    required this.endedAt,
    required this.path,
  });

  double get totalDistanceKm => totalDistanceMeters / 1000;

  /// Une todos os pontos em uma unica linha:
  /// latitude,longitude|latitude,longitude.
  String get rawPathText {
    return path.map((point) => point.toRawPathSegment()).join('|');
  }
}
