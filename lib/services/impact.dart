import 'dart:convert'; 
import 'package:intl/intl.dart'; 
import 'package:jwt_decoder/jwt_decoder.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/resting_heart_rate.dart';
import '../models/sleep.dart';

class Impact { //indirizzi per il login

  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';

  Future<void> getPatient() async { // Codice paziente
    var header = await getBearer();
    final r = await http.get(
        Uri.parse('${Impact.baseUrl}study/v1/patients/active'),
        headers: header);

    final decodedResponse = jsonDecode(r.body);
    final sp = await SharedPreferences.getInstance();

    await sp.setString('impactPatient', decodedResponse['data'][0]['username']);
  }

  Future<bool> isImpactUp() async { //il server è online? 
    final url = Impact.baseUrl + Impact.pingEndpoint;
    print('Calling: $url');
    final response = await http.get(Uri.parse(url));
    return response.statusCode == 200; //True se 200 (OK)
  }

  Future<int> refreshTokens() async { //uso il refresh token per ottenere un nuovo access token
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
    return 401; //non autorizzato se non c'è il refresh token. Login da rifare
  }

  Future<int> getAndStoreTokens(String username, String password) async { //salvo in memoria i token
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};

    print('Calling: $url'); 
    final response = await http.post(Uri.parse(url), body: body);

    if (response.statusCode == 200) { //se OK, salvo i token in memoria
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }
    return response.statusCode;
  }

  Future<bool> checkSavedToken({bool refresh = false}) async { // Controlla se abbiamo un token salvato in memoria e se è ancora valido
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(refresh ? 'refresh' : 'access');

    if (token == null) return false;
    try {
      return Impact.checkToken(token);
    } catch (_) {
      return false;
    }
  }

  static bool checkToken(String token) { // Controlla materialmente se il token è scaduto leggendo la sua data di scadenza interna
    if (JwtDecoder.isExpired(token)) return false;
    return true;
  }

  Future<Map<String, String>> getBearer() async { //se è scaduto, chiamo la funzione per refresh
    if (!await checkSavedToken()) {
      await refreshTokens();
    }
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('access');

    return {'Authorization': 'Bearer $token'};
  }

  
  // RESTING HEART RATE

  Future<List<RHR>> getRestingHeartRateFromDay(DateTime startTime) async {
    final sp = await SharedPreferences.getInstance();
    String? user = sp.getString('impactPatient'); 

    var header = await getBearer();
    var end = DateFormat('yyyy-MM-dd').format(startTime);  
    var start = DateFormat('yyyy-MM-dd').format(startTime.subtract(const Duration(days: 1)));
    
    var r = await http.get(
      Uri.parse('${Impact.baseUrl}data/v1/resting_heart_rate/patients/$user/daterange/start_date/$start/end_date/$end/'),
      headers: header,
    );
    
    if (r.statusCode != 200) return [];

    List<dynamic> data = jsonDecode(r.body)['data'];
    List<RHR> rhrList = [];
    
    for (var daydata in data) {
      // Controlliamo che 'data' esista e sia una mappa (dizionario), non una lista
      if (daydata['data'] != null && daydata['data'] is Map) {
        
        String day = daydata['date']; 
        var dataday = daydata['data']; // Estraiamo l'oggetto direttamente, SENZA il ciclo for

        // A volte il server potrebbe restituire dati incompleti, facciamo un controllo di sicurezza
        if (dataday.containsKey('time') && dataday.containsKey('value')) {
          String hour = dataday['time'];
          String datetime = '${day}T$hour'; 
          DateTime timestamp = _truncateSeconds(DateTime.parse(datetime)); 
          double? rhrValue; 
          
          if (dataday['value'] != null) {
            rhrValue = (dataday['value'] is int) 
                ? (dataday['value'] as int).toDouble() 
                : (dataday['value'] as double); // Forza il cast a double per sicurezza
          }

          RHR rhrNew = RHR(timestamp: timestamp, value: rhrValue);
          
          if (!rhrList.any((e) => e.timestamp.isAtSameMomentAs(rhrNew.timestamp))) { 
            rhrList.add(rhrNew);
          }
        }
      }
    }
    
    var sortedList = rhrList.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sortedList;
  }

   // DATI SONNO

  Future<List<SleepData>> getSleepDataFromDay(DateTime startTime) async {
    final sp = await SharedPreferences.getInstance();
    String? user = sp.getString('impactPatient');

    var header = await getBearer();
    var end = DateFormat('yyyy-MM-dd').format(startTime);
    var start = DateFormat('yyyy-MM-dd').format(startTime.subtract(const Duration(days: 1)));
    
    final url = '${Impact.baseUrl}data/v1/sleep/patients/$user/daterange/start_date/$start/end_date/$end/';
    print('URL SONNO: $url'); 

    var r = await http.get(
      Uri.parse(url),
      headers: header,
    );

    if (r.statusCode != 200) {
      print('Errore API Sonno: ${r.statusCode}'); 
      print('Corpo risposta errore: ${r.body}'); 
      return [];
    }

    List<dynamic> responseData = jsonDecode(r.body)['data'];
    List<SleepData> sleepRecords = [];

    for (var dayRecord in responseData) {
      final dailyData = dayRecord['data'];
      
      if (dailyData != null && dailyData is Map<String, dynamic>) {
        sleepRecords.add(SleepData.fromJson(dailyData));
      }
    }

    return sleepRecords;
  }

  DateTime _truncateSeconds(DateTime input) {
    return DateTime(input.year, input.month, input.day, input.hour, input.minute);
  }
}