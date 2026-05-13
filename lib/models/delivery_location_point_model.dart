class DeliveryLocationPoint {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime capturedAt;

  const DeliveryLocationPoint({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.capturedAt,
  });

  /// Transforma o ponto no formato bruto esperado para path:
  /// latitude,longitude.
  String toRawPathSegment() {
    return '$latitude,$longitude';
  }
}
