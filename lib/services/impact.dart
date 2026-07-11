// Classe per gestire le comunicazioni con il server Impact

import 'dart:convert'; 
import 'package:intl/intl.dart'; 
import 'package:jwt_decoder/jwt_decoder.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/resting_heart_rate.dart';
import '../models/sleep.dart';


class Impact { 
  
  // INDIRIZZI SERVER
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';

  // METODI DI AUTENTICAZIONE E RETE 

  // Verifica se il server è acceso e raggiungibile
  Future<bool> isImpactUp() async { 
    final url = Impact.baseUrl + Impact.pingEndpoint;
    final response = await http.get(Uri.parse(url)); // Esegue una richiesta GET vuota
    return response.statusCode == 200; // 200 significa "OK"
  }

  // Rinnova i permessi usando il refresh token per ottenere un nuovo access token
  Future<int> refreshTokens() async { 
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance(); // Accede alla memoria del telefono
    final refresh = sp.getString('refresh'); // Recupera il vecchio refresh token
    
    if (refresh != null) {
      final body = {'refresh': refresh}; // Prepara i dati da inviare al server
      final response = await http.post(Uri.parse(url), body: body);

      // Se il server accetta il refresh token, ci manda la nuova coppia di token
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body); // Decodifica il JSON in testo leggibile
        await sp.setString('access', decodedResponse['access']); // Salva il nuovo access token
        await sp.setString('refresh', decodedResponse['refresh']); // Salva il nuovo refresh token
      }
      return response.statusCode; // Ritorna il codice di stato (utile per gestire errori nella UI)
    }
    return 401; // 401 = Non Autorizzato (se manca il refresh token l'utente deve rifare il login)
  }

  // Login iniziale: invia le credenziali e riceve la prima coppia di token
  Future<int> getAndStoreTokens(String username, String password) async { 
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};
    
    // Esegue una richiesta POST passando username e password in modo sicuro
    final response = await http.post(Uri.parse(url), body: body);

    if (response.statusCode == 200) { 
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      
      // Salva i token appena ricevuti
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }
    return response.statusCode; 
  }

  // Controlla se abbiamo un token in memoria e se è ancora valido
  Future<bool> checkSavedToken({bool refresh = false}) async { 
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(refresh ? 'refresh' : 'access'); // Decide quale dei due token controllare in base al parametro passato

    if (token == null) return false; // Se la stringa è vuota, blocca tutto
    try {
      return Impact.checkToken(token); // Altrimenti passa alla verifica della scadenza
    } catch (_) {
      return false; // Se il token è scritto male, ritorna falso
    }
  }

  // Decodifica il token per leggerne la data di scadenza
  static bool checkToken(String token) { 
    if (JwtDecoder.isExpired(token)) return false; // Se la data odierna supera quella nel token, è scaduto
    return true;
  }

  // Crea l'header Authorization da attaccare a tutte le chiamate
  Future<Map<String, String>> getBearer() async { 
    if (!await checkSavedToken()) { // Prima di attaccare la chiave, controlla se è scaduta
      await refreshTokens(); // Se è scaduta, fa partire la richiesta di rinnovo
    }
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('access');
    
    // Restituisce l'intestazione standard richiesta dai sistemi JWT (Bearer + Token)
    return {'Authorization': 'Bearer $token'};
  }

  // Scarica il nome utente del paziente attivo e lo salva in memoria
  Future<void> getPatient() async { 
    var header = await getBearer(); // Recupera i permessi necessari
    
    // Chiama l'endpoint del server che restituisce i dati dell'utente
    final r = await http.get(
        Uri.parse('${Impact.baseUrl}study/v1/patients/active'),
        headers: header);

    final decodedResponse = jsonDecode(r.body); 
    final sp = await SharedPreferences.getInstance(); 
    
    // Estraggo l'username e lo salvo in memoria 
    await sp.setString('impactPatient', decodedResponse['data'][0]['username']);
  }

  // DOWNLOAD DATI RESTING HEART RATE
  
  Future<List<RHR>> getRestingHeartRateFromDay(DateTime startTime) async {
    final sp = await SharedPreferences.getInstance();
    String? user = sp.getString('impactPatient'); // Legge il nome paziente salvato prima

    var header = await getBearer();
    
    var end = DateFormat('yyyy-MM-dd').format(startTime); // Formatta la data per il server

    var start = DateFormat('yyyy-MM-dd').format(startTime.subtract(const Duration(days: 1))); // passo al giorno precedente
    
    var r = await http.get(
      Uri.parse('${Impact.baseUrl}data/v1/resting_heart_rate/patients/$user/daterange/start_date/$start/end_date/$end/'),
      headers: header,
    );
    
    if (r.statusCode != 200) return []; // In caso di errore API, restituisce lista vuota invece di crashare

    List<dynamic> data = jsonDecode(r.body)['data'];
    List<RHR> rhrList = [];
    
    // Ciclo che scorre i giorni uno a uno
    for (var daydata in data) {

      // Controlliamo che 'data' esista e sia effettivamente una mappa (dizionario): per alcuni giorni il server restituisce invece una
      // lista, che qui viene semplicemente ignorata invece di far crashare il codice sotto
      if (daydata['data'] == null || daydata['data'] is! Map) continue;

      var dataday = daydata['data'];
      String day = daydata['date'];

      // A volte il server potrebbe restituire dati incompleti, facciamo un controllo di sicurezza
      if (!dataday.containsKey('time') || !dataday.containsKey('value')) continue;

      String? hour = dataday['time'];

      if (hour != null) { // guardo se ho un'ora
        DateTime timestamp = _truncateSeconds(DateTime.parse('${day}T$hour')); // Unisce stringa giorno e ora e la converte in oggetto DateTime azzerando i secondi

        
        double? rhrValue = (dataday['value'] as num?)?.toDouble();

        RHR rhrNew = RHR(timestamp: timestamp, value: rhrValue);
        
        if (!rhrList.any((e) => e.timestamp.isAtSameMomentAs(rhrNew.timestamp))) { // aggiunge il nuovo dato solo se non esiste già un record con lo stesso timestamp
          rhrList.add(rhrNew);
        }
      }
    }
    
    rhrList.sort((a, b) => a.timestamp.compareTo(b.timestamp)); //metto in ordine crescente di timestamp
    return rhrList;
  }

   // DOWNLOAD DATI SONNO
   
  Future<List<SleepData>> getSleepDataFromDay(DateTime startTime) async {
    final sp = await SharedPreferences.getInstance();
    String? user = sp.getString('impactPatient');

    var header = await getBearer();
    var end = DateFormat('yyyy-MM-dd').format(startTime);
    var start = DateFormat('yyyy-MM-dd').format(startTime.subtract(const Duration(days: 1)));
    
    final url = '${Impact.baseUrl}data/v1/sleep/patients/$user/daterange/start_date/$start/end_date/$end/';

    var r = await http.get(
      Uri.parse(url),
      headers: header,
    );

    if (r.statusCode != 200) return []; // Di sicurezza in caso disconnessione o server down

    List<dynamic> responseData = jsonDecode(r.body)['data'];
    List<SleepData> sleepRecords = [];

    // Cicla tutti i giorni restituiti dal server
    for (var dayRecord in responseData) {
      final dailyData = dayRecord['data'];
      
      // Aggiungiamo il record solo se 'data' esiste ed è effettivamente una mappa: per alcuni giorni il server restituisce invece
      // una lista (es. più sessioni di sonno), che qui viene semplicemente ignorata invece di far crashare SleepData.fromJson
      if (dailyData != null && dailyData is Map<String, dynamic>) {
        sleepRecords.add(SleepData.fromJson(dailyData));
      }
    }

    return sleepRecords;
  }

  DateTime _truncateSeconds(DateTime input) { // tolgo i secondi
    return DateTime(input.year, input.month, input.day, input.hour, input.minute);
  }
}