import 'dart:convert';
import 'package:ecoguide/services/recommendation_service.dart';
import 'package:http/http.dart' as http;
import 'package:ecoguide/models/site_model.dart';
import 'package:location/location.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData?> fetchWeather(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
          '$_baseUrl?latitude=$latitude&longitude=$longitude&current_weather=true');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        
        return WeatherData(
          temperature: current['temperature'].toDouble(),
          isRainy: _isRainy(current['weathercode']),
          isWindy: current['windspeed'] > 20,
          condition: _mapWeatherCode(current['weathercode']),
        );
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  bool _isRainy(int code) {
    // WMO codes for rain/drizzle/thunderstorm
    return [51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99].contains(code);
  }

  String _mapWeatherCode(int code) {
    // Simplified WMO code mapping
    if (code == 0) return 'sun';
    if (code >= 1 && code <= 3) return 'cloud';
    if ([45, 48].contains(code)) return 'cloud'; // Fog
    if ([51, 53, 55].contains(code)) return 'rain'; // Drizzle
    if ([61, 63, 65].contains(code)) return 'rain'; // Rain
    if ([71, 73, 75].contains(code)) return 'snow'; // Snow
    if (code >= 80 && code <= 82) return 'rain'; // Showers
    if (code >= 95) return 'storm'; // Thunderstorm
    
    return 'sun'; // Default
  }
}
