import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motora_app/models/delivery_location_point_model.dart';
import 'package:motora_app/models/delivery_tracking_result_model.dart';

class DeliveryTrackingController extends ChangeNotifier {
  static const double _minimumDistanceDeltaMeters = 5;

  final List<DeliveryLocationPoint> _path = [];
  StreamSubscription<Position>? _positionSubscription;

  DeliveryLocationPoint? _lastDistancePoint;
  String? _restaurant;
  String? _paymentProfile;
  DateTime? _startedAt;
  double _totalDistanceMeters = 0;
  bool _isStarting = false;
  bool _isTracking = false;
  bool _isPaused = false;
  String? _errorMessage;

  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  bool get isStarting => _isStarting;
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  String? get restaurant => _restaurant;
  String? get paymentProfile => _paymentProfile;
  String? get errorMessage => _errorMessage;
  double get totalDistanceMeters => _totalDistanceMeters;
  double get totalDistanceKm => _totalDistanceMeters / 1000;
  List<DeliveryLocationPoint> get path => List.unmodifiable(_path);

  String get distanceLabelKm => totalDistanceKm.toStringAsFixed(1);

  String get rawPathText {
    return _path.map((point) => point.toRawPathSegment()).join('|');
  }

  /// Inicia uma entrega, valida servico/permissao de localizacao e abre o
  /// stream continuo do Geolocator para receber os pontos do trajeto.
  Future<void> start({
    required String restaurant,
    required String paymentProfile,
  }) async {
    if (_isStarting || _isTracking) return;

    _isStarting = true;
    _errorMessage = null;
    _restaurant = restaurant;
    _paymentProfile = paymentProfile;
    _startedAt = DateTime.now();
    notifyListeners();

    try {
      await _ensureLocationReady();
      await _positionSubscription?.cancel();

      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );

      _resetDistance();
      _addPosition(initialPosition, countDistance: false);

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: _locationSettings,
          ).listen(
            _handlePositionUpdate,
            onError: (Object error) {
              _errorMessage = 'Erro ao ler localização: $error';
              notifyListeners();
            },
          );

      _isTracking = true;
      _isPaused = false;
    } catch (error) {
      _errorMessage = error.toString();
      _isTracking = false;
      _isPaused = false;
      _resetDistance();
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  /// Pausa a contagem sem encerrar a entrega. Enquanto pausado, novos pontos
  /// recebidos pelo GPS sao ignorados e nao entram no path bruto.
  void pause() {
    if (!_isTracking || _isPaused) return;

    _isPaused = true;
    notifyListeners();
  }

  /// Retoma a entrega e evita somar a distancia entre o ultimo ponto antes da
  /// pausa e o primeiro ponto apos a pausa.
  void resume() {
    if (!_isTracking || !_isPaused) return;

    _isPaused = false;
    _lastDistancePoint = null;
    notifyListeners();
  }

  /// Finaliza a entrega, cancela o stream do Geolocator e devolve um resultado
  /// com quilometragem calculada e path bruto em latitude,longitude|...
  Future<DeliveryTrackingResult> finish() async {
    if (!_isTracking || _startedAt == null) {
      throw StateError('Nenhuma entrega em andamento.');
    }

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    final result = DeliveryTrackingResult(
      restaurant: _restaurant ?? '',
      paymentProfile: _paymentProfile ?? '',
      totalDistanceMeters: _totalDistanceMeters,
      startedAt: _startedAt!,
      endedAt: DateTime.now(),
      path: List.unmodifiable(_path),
    );

    _isTracking = false;
    _isPaused = false;
    notifyListeners();

    return result;
  }

  /// Confere se o GPS esta ativo e solicita permissao quando o usuario ainda
  /// nao liberou o acesso a localizacao do aparelho.
  Future<void> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Ative a localização do aparelho para iniciar.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente. Libere nas configurações do app.',
      );
    }
  }

  /// Recebe cada nova posicao do stream e ignora leituras durante pausa.
  void _handlePositionUpdate(Position position) {
    if (_isPaused) return;

    _addPosition(position);
    notifyListeners();
  }

  /// Guarda a coordenada bruta e soma a distancia em metros entre pontos
  /// consecutivos usando o calculo nativo disponibilizado pelo Geolocator.
  void _addPosition(Position position, {bool countDistance = true}) {
    final point = DeliveryLocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      capturedAt: position.timestamp,
    );

    if (countDistance && _lastDistancePoint != null) {
      final distance = Geolocator.distanceBetween(
        _lastDistancePoint!.latitude,
        _lastDistancePoint!.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance >= _minimumDistanceDeltaMeters) {
        _totalDistanceMeters += distance;
      }
    }

    _path.add(point);
    _lastDistancePoint = point;
  }

  void _resetDistance() {
    _path.clear();
    _lastDistancePoint = null;
    _totalDistanceMeters = 0;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
