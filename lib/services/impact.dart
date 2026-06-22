import 'dart:convert';
// import 'dart:io'; //Per scaricare i dati
// import 'package:intl/intl.dart'; //Per le date
// import 'package:jwt_decoder/jwt_decoder.dart'; // Per i dati
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Impact {

  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';

  static String impactUsername = 'Jpefaq6m58'; // Codice paziente fittizio

  // Funzione per refreshare i token
  Future<int> refreshTokens() async {
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    
    if (refresh != null) {
      final body = {'refresh': refresh};
      print('Calling: $url');
      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      }
      return response.statusCode;
    }
    return 401;
  }

  // Funzione per fare il login
  Future<int> getAndStoreTokens(String username, String password) async {
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};

    print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }
    return response.statusCode;
  }
}