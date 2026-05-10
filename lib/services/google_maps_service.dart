import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:motora_app/models/delivery_location_point_model.dart';

class GoogleMapsService {
  static const String _apiKey = 'AIzaSyChT0xMwkxeCgqTGyMv5WzMOm_w_v0IVFY'; 
  static const String _baseUrl = 'https://roads.googleapis.com/v1/snapToRoads';

  /// Pega a rota bruta, alinha às estradas e retorna a distância total em KM
  Future<double> calcularDistanciaReal(List<DeliveryLocationPoint> path) async {
    if (path.length < 2) return 0.0;

    // Divide a lista em blocos de 100 pontos (limite do Google)
    List<List<DeliveryLocationPoint>> chunks = [];
    for (var i = 0; i < path.length; i += 100) {
      chunks.add(path.sublist(i, i + 100 > path.length ? path.length : i + 100));
    }

    double distanciaTotalKm = 0.0;

    for (var chunk in chunks) {
      final pathString = chunk.map((p) => '${p.latitude},${p.longitude}').join('|');
      
      final url = Uri.parse('$_baseUrl?path=$pathString&interpolate=false&key=$_apiKey');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final snappedPoints = data['snappedPoints'] as List? ?? [];
        
        // Calcula a distância entre os pontos corrigidos que o Google devolveu
        for (int i = 0; i < snappedPoints.length - 1; i++) {
          final p1 = snappedPoints[i]['location'];
          final p2 = snappedPoints[i + 1]['location'];

          distanciaTotalKm += Geolocator.distanceBetween(
            p1['latitude'], p1['longitude'],
            p2['latitude'], p2['longitude']
          ) / 1000;
        }
      } else {
        throw Exception('Erro na API Roads: ${response.body}');
      }
    }

    return distanciaTotalKm;
  }
}