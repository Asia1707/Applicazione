import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

// importo le schermate per la bottom navigation bar
import 'statisticsscreen.dart';
import 'settingsscreen.dart';

class Home extends StatefulWidget {
  static const route = '/home/';
  static const routeDisplayName = 'HomePage';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int streak = 0;
  int giorno = 1;
  bool? haBevuto;
  String umore = '';
  String nomeUtente = '';
  DateTime? dataInizio; // Data di inizio percorso, fissa al 1° marzo 2026

  int _indiceSelezionato = 0; // indice della BottomNavigationBar

  static const int obiettivoGiorni = 30;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    final prefs = await SharedPreferences.getInstance();
    final dataInizioSalvata = prefs.getString('data_inizio');

    DateTime dataInizioEffettiva;
    if (dataInizioSalvata != null) {
      dataInizioEffettiva = DateTime.parse(dataInizioSalvata);
    } else {
      dataInizioEffettiva = DateTime(2026, 3, 1);
      await prefs.setString('data_inizio', dataInizioEffettiva.toIso8601String());
    }

    setState(() {
      nomeUtente = prefs.getString('nome_utente') ?? '';
      streak = prefs.getInt('streak') ?? 0;
      giorno = prefs.getInt('giorno') ?? 1;
      dataInizio = dataInizioEffettiva;
    });
  }

  Future<void> _salvaDati() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
    await prefs.setInt('giorno', giorno);
  }

  double get percentuale => min(streak / obiettivoGiorni, 1.0);

  void _onItemTapped(int index) {
    setState(() {
      _indiceSelezionato = index;
    });
  }

  Future<void> giornoSuccessivo() async {
    final prefs = await SharedPreferences.getInstance();

    // Salvo le risposte per la giornata appena conclusa
    await prefs.setBool('alcol_giorno_$giorno', haBevuto ?? false);
    await prefs.setString('umore_giorno_$giorno', umore); // <-- AGGIUNTO IL SALVATAGGIO DELL'UMORE

    setState(() {
      if (haBevuto == false) {
        streak ++;
      
      }
      giorno++;
      haBevuto = null;
      umore = '';
    });
    await _salvaDati();
  }

  // Aggiunto umoreOggi ai dati esportati
  ({DateTime data, bool haBevutoOggi, String umoreOggi}) datiPerStatistiche() {
    final base = dataInizio ?? DateTime(2026, 3, 1);
    final dataSimulata = base.add(Duration(days: giorno - 1));
    return (data: dataSimulata, haBevutoOggi: haBevuto ?? false, umoreOggi: umore);
  }

  @override
  Widget build(BuildContext context) {
    final infoStatistiche = datiPerStatistiche();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      body: SafeArea( 
        child: IndexedStack(
          index: _indiceSelezionato,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomeUtente.isEmpty ? 'Ciao! 👋' : 'Ciao, $nomeUtente! 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giorno $giorno del tuo percorso',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text(
                            'Hai bevuto alcol oggi?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _bottoneRisposta('No', false),
                              const SizedBox(width: 20),
                              _bottoneRisposta('Sì', true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text(
                            'Come ti senti oggi?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              bottoneUmore('☀️', 'Calmo'),
                              bottoneUmore('🌤️', 'Ok'),
                              bottoneUmore('☁️', 'Neutro'),
                              bottoneUmore('🌧️', 'Triste'),
                              bottoneUmore('⛈️', 'Stressato'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: percentuale,
                                  strokeWidth: 7,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0D9488)),
                                ),
                                Text(
                                  '${(percentuale * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('🔥',
                                        style: TextStyle(fontSize: 26)),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$streak giorni\nsenza alcol',
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Obiettivo: $obiettivoGiorni giorni',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    color: const Color(0xFFCCFBF1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              messaggioInsight(),
                              style: const TextStyle(
                                  fontSize: 15, color: Color(0xFF134E4A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: haBevuto == null || umore == ''
                          ? null
                          : giornoSuccessivo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      child: const Text(
                        'VAI AL GIORNO SUCCESSIVO',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            StatisticsScreen(
              currentDate: infoStatistiche.data,
              currentDay: giorno,
              hasConsumedAlcoholToday: infoStatistiche.haBevutoOggi,
              currentMoodToday: infoStatistiche.umoreOggi, // <-- PASSIAMO IL NUOVO DATO
            ),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSelezionato,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0D9488),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Impostazioni'),
        ],
      ),
    );
  }

  Widget _bottoneRisposta(String testo, bool valore) {
    final bool selezionato = haBevuto == valore;
    final Color coloreAttivo =
        valore ? const Color(0xFFEF4444) : const Color(0xFF0D9488);

    return ElevatedButton(
      onPressed: () => setState(() => haBevuto = valore),
      style: ElevatedButton.styleFrom(
        backgroundColor: selezionato ? coloreAttivo : Colors.grey.shade200,
        foregroundColor: selezionato ? Colors.white : Colors.black87,
        minimumSize: const Size(90, 44),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: selezionato ? 4 : 0,
      ),
      child: Text(testo, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget bottoneUmore(String emoji, String nome) {
    return GestureDetector(
      onTap: () {
        setState(() {
          umore = nome;
        });
      },
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: umore == nome ? 36 : 28),
          ),
          Text(
            nome,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  umore == nome ? FontWeight.bold : FontWeight.normal,
              color: umore == nome
                  ? const Color(0xFF0D9488)
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String messaggioInsight() {
    if (haBevuto == null || umore == '') {
      return 'Completa il check-in per ricevere un feedback personalizzato.';
    }
    if (haBevuto == false && umore == 'Stressato') {
      return 'Hai scelto di non bere anche in una giornata stressante. Ottimo segnale di consapevolezza.';
    }
    if (haBevuto == false && umore == 'Triste') {
      return 'Hai resistito anche oggi. Ricorda: le emozioni difficili passano, la tua forza rimane.';
    }
    if (haBevuto == false) {
      return 'Ottimo lavoro: hai mantenuto una giornata senza alcol. Continua così!';
    }
    return 'Una giornata difficile non cancella i progressi. Domani puoi ripartire.';
  }
}