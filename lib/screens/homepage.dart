import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // serve per la funzione min(), usata nel calcolo della percentuale

// import per collegare questa schermata al Provider condiviso con Nome utente,
// Codice psicologo, Check-in e Streak
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// importo le altre schermate per poterle mostrare nella bottom navigation bar
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
  // Variabili che tengono lo stato della Home, tutte modificabili con setState
  int streak = 0; // giorni consecutivi senza alcol
  int giorno = 1; // numero del giorno attuale del percorso
  bool? haBevuto; // risposta al check-in di oggi (null finché non risponde)
  String umore = ''; // umore scelto oggi (vuoto finché non lo sceglie)
  String nomeUtente = ''; // nome utente, letto da SharedPreferences
  DateTime? dataInizio; // data di inizio del percorso, fissa al 1° marzo 2026

  int _indiceSelezionato = 0; // quale tab è selezionato in basso (Home/Stats/Impostazioni)

  static const int obiettivoGiorni = 30; // obiettivo fisso: 30 giorni senza alcol

  @override
  void initState() {
    super.initState();
    // Appena la Home viene creata, carico i dati salvati in precedenza
    _caricaDati();
  }

  // Carica streak, giorno, nome utente e data di inizio da SharedPreferences
  // (la "memoria permanente" del telefono, che resta anche chiudendo l'app)
  Future<void> _caricaDati() async {
    final prefs = await SharedPreferences.getInstance();
    final dataInizioSalvata = prefs.getString('data_inizio');

    DateTime dataInizioEffettiva;
    if (dataInizioSalvata != null) {
      // se una data di inizio era già stata salvata, la uso
      dataInizioEffettiva = DateTime.parse(dataInizioSalvata);
    } else {
      // altrimenti, prima volta: fisso la data di inizio al 1° marzo 2026 e la salvo
      dataInizioEffettiva = DateTime(2026, 3, 1);
      await prefs.setString('data_inizio', dataInizioEffettiva.toIso8601String());
    }

    // setState: aggiorna le variabili E dice a Flutter di ridisegnare la schermata
    setState(() {
      nomeUtente = prefs.getString('nome_utente') ?? ''; // se non c'è, stringa vuota
      streak = prefs.getInt('streak') ?? 0; // se non c'è, parto da 0
      giorno = prefs.getInt('giorno') ?? 1; // se non c'è, parto dal giorno 1
      dataInizio = dataInizioEffettiva;
    });

    // Comunico i valori appena caricati al Provider condiviso.
    // Questo permette alla Settings Screen di leggere questi stessi numeri
    // (check-in completati = giorno, streak = streak) senza doverli ricalcolare.
    context.read<UserProvider>().updateProgress(giorno, streak);
  }

  // Salva streak e giorno in memoria permanente, così restano anche
  // se l'utente chiude e riapre l'app
  Future<void> _salvaDati() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
    await prefs.setInt('giorno', giorno);
  }

  // Calcola la percentuale di completamento dell'obiettivo (0.0 - 1.0),
  // usata per riempire il cerchio di progresso.
  // min(...) evita che superi il 100% se streak > obiettivoGiorni
  double get percentuale => min(streak / obiettivoGiorni, 1.0);

  // Cambia quale schermata mostrare quando l'utente tocca la bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _indiceSelezionato = index;
    });
  }

  // Chiamato quando l'utente preme il bottone "VAI AL GIORNO SUCCESSIVO"
  Future<void> giornoSuccessivo() async {
    final prefs = await SharedPreferences.getInstance();

    // Salvo le risposte di oggi (alcol e umore) associate al numero del giorno,
    // utile per le statistiche storiche
    await prefs.setBool('alcol_giorno_$giorno', haBevuto ?? false);
    await prefs.setString('umore_giorno_$giorno', umore);

    setState(() {
      // Lo streak aumenta SOLO se oggi non ha bevuto.
      // Se ha bevuto (haBevuto == true), non tocchiamo streak:
      // resta esattamente com'era, non si azzera più.
      if (haBevuto == false) {
        streak++;
      }
      giorno++; // si passa comunque al giorno successivo
      haBevuto = null; // resetto la risposta per il nuovo giorno
      umore = ''; // resetto l'umore per il nuovo giorno
    });

    await _salvaDati(); // salvo i nuovi valori in memoria permanente

    // Comunico anche al Provider condiviso i valori appena aggiornati,
    // così la Settings Screen si aggiorna automaticamente (grazie a notifyListeners
    // dentro updateProgress) senza bisogno di ricaricare la pagina manualmente
    context.read<UserProvider>().updateProgress(giorno, streak);
  }

  // Prepara un pacchetto di dati (record) da passare alla schermata Statistiche:
  // la data "simulata" del giorno attuale, se ha bevuto oggi, e l'umore di oggi
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
        // IndexedStack: tiene "pronte" tutte le schermate (Home, Stats, Impostazioni)
        // ma ne mostra solo una alla volta, in base a _indiceSelezionato.
        // Utile perché così, cambiando tab, non si perde lo stato delle altre schermate.
        child: IndexedStack(
          index: _indiceSelezionato,
          children: [
            // ---- SCHERMATA 0: HOME (check-in) ----
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saluto con nome utente (o generico se non impostato)
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

                  // Card: "Hai bevuto alcol oggi?" con bottoni Sì/No
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

                  // Card: "Come ti senti oggi?" con le 5 emoji dell'umore
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

                  // Card: cerchio di progresso + streak attuale
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
                                // Cerchio che si riempie in base alla percentuale
                                CircularProgressIndicator(
                                  value: percentuale,
                                  strokeWidth: 7,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0D9488)),
                                ),
                                // Percentuale scritta al centro del cerchio
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

                  // Card: messaggio motivazionale/insight, generato da messaggioInsight()
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

                  // Bottone "VAI AL GIORNO SUCCESSIVO":
                  // disabilitato (onPressed: null) finché l'utente non ha
                  // risposto sia ad alcol che a umore
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

            // ---- SCHERMATA 1: STATISTICHE ----
            // Le passo i dati calcolati sopra (data simulata, alcol/umore di oggi)
            StatisticsScreen(
              currentDate: infoStatistiche.data,
              currentDay: giorno,
              hasConsumedAlcoholToday: infoStatistiche.haBevutoOggi,
              currentMoodToday: infoStatistiche.umoreOggi,
            ),

            // ---- SCHERMATA 2: IMPOSTAZIONI ----
            const SettingsScreen(),
          ],
        ),
      ),

      // Barra di navigazione in basso, con 3 tab
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

  // Bottone "Sì"/"No" per la domanda "Hai bevuto alcol oggi?"
  // Cambia colore quando è selezionato
  Widget _bottoneRisposta(String testo, bool valore) {
    final bool selezionato = haBevuto == valore;
    // Rosso se il bottone è "Sì" ed è selezionato, verde se "No" ed è selezionato
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

  // Icona emoji cliccabile per scegliere l'umore del giorno
  // Si ingrandisce e cambia colore quando è selezionata
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

  // Genera il messaggio motivazionale in base alle risposte del giorno
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