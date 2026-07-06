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
    String? user = sp.getString('impactPatient'); //recupero il nome utente dalla memoria

    var header = await getBearer();
    var end = DateFormat('y-M-d').format(startTime); // Format AAAA-mm-dd 
    var start = DateFormat('y-M-d').format(startTime.subtract(const Duration(days: 1)));
    var r = await http.get(
      Uri.parse('${Impact.baseUrl}data/v1/resting_heart_rate/patients/$user/daterange/start_date/$start/end_date/$end/'),
      headers: header,
    );
    
    if (r.statusCode != 200) return [];

    List<dynamic> data = jsonDecode(r.body)['data'];
    List<RHR> rhrList = [];
    
    for (var daydata in data) { // Ciclo sui vari giorni scaricati
      if (daydata['data'] != null && daydata['data'].isNotEmpty) {
        
        String day = daydata['date']; // data del giorno
        for (var dataday in daydata['data']) { //prendo le variabili
          String hour = dataday['time'];
          String datetime = '${day}T$hour'; // giorno e ora insieme
          DateTime timestamp = _truncateSeconds(DateTime.parse(datetime)); 
          double? rhrValue; 
          
        // Controllo se il valore è un numero intero. Se è un numero intero lo converto in double. Se lo lascio int l'app si aspetta un double e crasha
          if (dataday['value'] != null) {
            rhrValue = (dataday['value'] is int) 
                ? (dataday['value'] as int).toDouble() 
                : dataday['value'];
          }

          RHR rhrNew = RHR(timestamp: timestamp, value: rhrValue);
          
          if (!rhrList.any((e) => e.timestamp.isAtSameMomentAs(rhrNew.timestamp))) { // controllo non ci siano doppioni
            rhrList.add(rhrNew);
          }
        }
      }
    }
    
    // Riordina i battiti dal più vecchio al più recente prima di restituirli
    var sortedList = rhrList.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sortedList;
  }

   // DATI SONNO

  Future<List<SleepData>> getSleepDataFromDay(DateTime startTime) async {
    // Aggiunto il recupero del nome utente dinamico dalla memoria
    final sp = await SharedPreferences.getInstance();
    String? user = sp.getString('impactPatient');

    var header = await getBearer();
    var end = DateFormat('y-M-d').format(startTime);
    var start = DateFormat('y-M-d').format(startTime.subtract(const Duration(days: 1)));
    
    // Aggiornato l'URL per usare $user
    var r = await http.get(
      Uri.parse('${Impact.baseUrl}data/v1/sleep/patients/$user/daterange/start_date/$start/end_date/$end/'),
      headers: header,
    );

    if (r.statusCode != 200) {
      print('Errore API Sonno: ${r.statusCode}'); 
      return [];
    }

    List<dynamic> responseData = jsonDecode(r.body)['data'];
    List<SleepData> sleepRecords = [];

    for (var dayRecord in responseData) {
      if (dayRecord['data'] != null) {
        sleepRecords.add(SleepData.fromJson(dayRecord['data']));
      }
    }

    return sleepRecords;
  }
  
  // Rimuove i secondi dal timestamp per avere orari esatti e puliti
  DateTime _truncateSeconds(DateTime input) {
    return DateTime(input.year, input.month, input.day, input.hour, input.minute);
  }
}