import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // serve per la funzione min(), usata per calcolare la percentuale

// Provider condiviso: qui dentro ci sono nome utente, codice psicologo,
// check-in completati e streak, letti anche dalla Settings Screen
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// Le altre due schermate mostrate nella barra in basso
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
  // Dati principali della schermata, tutti modificabili con setState
  int streak = 0; // giorni consecutivi senza alcol
  int giorno = 1; // a che giorno del percorso siamo
  bool? haBevuto; // risposta di oggi (null = non ha ancora risposto)
  String umore = ''; // umore scelto oggi (vuoto = non ancora scelto)
  String nomeUtente = ''; // nome mostrato nel saluto
  DateTime? dataInizio; // data di inizio del percorso (fissa: 1 marzo 2026)

  int _indiceSelezionato = 0; // quale schermata è aperta in basso (Home/Stats/Impostazioni)

  static const int obiettivoGiorni = 30; // obiettivo: 30 giorni senza alcol

  @override
  void initState() {
    super.initState();
    // Appena si apre la Home, carico tutti i dati salvati in precedenza
    _caricaDati();
  }

  // Legge streak, giorno e nome utente da SharedPreferences
  // (la memoria del telefono, che resta anche chiudendo l'app)
  Future<void> _caricaDati() async {
    final prefs = await SharedPreferences.getInstance();
    final dataInizioSalvata = prefs.getString('data_inizio');

    DateTime dataInizioEffettiva;
    if (dataInizioSalvata != null) {
      // c'era già una data salvata, la uso
      dataInizioEffettiva = DateTime.parse(dataInizioSalvata);
    } else {
      // prima volta: fisso la data al 1 marzo 2026 e la salvo
      dataInizioEffettiva = DateTime(2026, 3, 1);
      await prefs.setString('data_inizio', dataInizioEffettiva.toIso8601String());
    }

    setState(() {
      nomeUtente = prefs.getString('nome_utente') ?? '';
      streak = prefs.getInt('streak') ?? 0;
      giorno = prefs.getInt('giorno') ?? 1;
      dataInizio = dataInizioEffettiva;
    });

    // Passo questi numeri anche al Provider condiviso,
    // così la Settings Screen può mostrarli
    context.read<UserProvider>().updateProgress(giorno, streak);
  }

  // Salva streak e giorno in memoria permanente
  Future<void> _salvaDati() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
    await prefs.setInt('giorno', giorno);
  }

  // Percentuale di completamento dell'obiettivo (da 0.0 a 1.0)
  // min() evita che superi il 100% se lo streak va oltre l'obiettivo
  double get percentuale => min(streak / obiettivoGiorni, 1.0);

  // Cambia quale tab è aperto (Home / Stats / Impostazioni)
  void _onItemTapped(int index) {
    setState(() {
      _indiceSelezionato = index;
    });
  }

  // Chiamato quando si preme "VAI AL GIORNO SUCCESSIVO"
  Future<void> giornoSuccessivo() async {
    final prefs = await SharedPreferences.getInstance();

    // Salvo le risposte di oggi, utili per lo storico nelle statistiche
    await prefs.setBool('alcol_giorno_$giorno', haBevuto ?? false);
    await prefs.setString('umore_giorno_$giorno', umore);

    setState(() {
      // Lo streak sale solo se oggi NON ha bevuto.
      // Se ha bevuto, non lo tocchiamo: resta com'era, non si azzera
      if (haBevuto == false) {
        streak++;
      }
      giorno++; // si passa comunque al giorno dopo
      haBevuto = null; // resetto per il nuovo giorno
      umore = ''; // resetto per il nuovo giorno
    });

    await _salvaDati(); // salvo i nuovi valori

    // Aggiorno anche il Provider, così la Settings Screen
    // vede subito i numeri nuovi
    context.read<UserProvider>().updateProgress(giorno, streak);
  }

  // Prepara i dati da passare alla schermata Statistiche
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
        // IndexedStack mostra solo una schermata alla volta (Home/Stats/Impostazioni),
        // ma le tiene tutte "pronte" in memoria, così cambiando tab non si perde nulla
        child: IndexedStack(
          index: _indiceSelezionato,
          children: [
            // ---- SCHERMATA HOME ----
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saluto iniziale
                  Text(
                    nomeUtente.isEmpty ? 'Ciao! 👋' : 'Ciao, $nomeUtente! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF13898C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giorno $giorno del tuo percorso',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 20),

                  // Card: domanda sull'alcol, con i due bottoni Sì/No
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

                  // Card: scelta dell'umore, con le 5 emoji
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

                  // ---- CARD STREAK: cerchio percentuale + info streak ----
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        // Centra verticalmente il cerchio e il testo, uno rispetto all'altro
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Cerchio che si riempie in base alla percentuale
                          SizedBox(
                            width: 80,
                            height: 80,
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
                                // Percentuale scritta al centro del cerchio
                                Text(
                                  '${(percentuale * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          // Testo streak + obiettivo, centrato rispetto al cerchio
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text('🔥',
                                        style: TextStyle(fontSize: 24)),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '$streak giorni senza alcol',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
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

                  // Card: messaggio motivazionale, cambia in base alle risposte del giorno
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

                  // Bottone finale: attivo solo se ha risposto sia ad alcol che a umore
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

            // ---- SCHERMATA STATISTICHE ----
            StatisticsScreen(
              currentDate: infoStatistiche.data,
              currentDay: giorno,
              hasConsumedAlcoholToday: infoStatistiche.haBevutoOggi,
              currentMoodToday: infoStatistiche.umoreOggi,
            ),

            // ---- SCHERMATA IMPOSTAZIONI ----
            const SettingsScreen(),
          ],
        ),
      ),

      // Barra di navigazione in basso, con le 3 sezioni dell'app
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

  // Bottone Sì/No per la domanda sull'alcol.
  // Cambia colore quando viene selezionato: arancione per "Sì", verde per "No"
  Widget _bottoneRisposta(String testo, bool valore) {
    final bool selezionato = haBevuto == valore;
    final Color coloreAttivo =
        valore ? const Color(0xFFF97316) : const Color(0xFF0D9488);

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

  // Emoji cliccabile per scegliere l'umore.
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