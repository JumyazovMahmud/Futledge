import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class ApiService {
  static final Map<String, String> _headers = {
    'x-rapidapi-host': Constants.apiHost,
    'x-rapidapi-key': Constants.apiKey,
  };

  static Future<dynamic> get(String endpoint, [Map<String, dynamic>? params]) async {
    final uri = Uri.parse('${Constants.baseUrl}$endpoint').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}