import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../charts/sleep_chart.dart';
import '../charts/rhr_chart.dart';
import '../charts/score_chart.dart';
import '../services/impact.dart';
import '../models/sleep.dart';
import '../models/resting_heart_rate.dart';
import '../utils/alteredstatistics.dart';

// LEGENDA
Widget _buildLegendItem(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12, // dimensione pallino legenda
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87), // testo/colore legenda
      ),
    ],
  );
}

// Schermata principale con 3 card con grafico + testo + feedback
class StatisticsScreen extends StatefulWidget {
  final DateTime currentDate; // data reale corrispondente al giorno simulato
  final int currentDay; // numero del giorno corrente nella simulazione
  final bool hasConsumedAlcoholToday; // passato dalla Home
  final String currentMoodToday; // passato dalla Home

  const StatisticsScreen({
    super.key,
    required this.currentDate,
    required this.currentDay,
    required this.hasConsumedAlcoholToday,
    required this.currentMoodToday,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PageController _pageController = PageController(); // scorrimento tra le 3 card
  int _currentCard = 0; // indice della card attualmente visibile

  static const Color ral5018 = Color(0xFF13898C); // salvo il colore in una costante

  bool _isLoading = true; // cerchietto di caricamento mentre aspetto i dati
  List<DailySleepData> _serverSleepData = []; // Dati sonno degli ultimi giorni, pronti per il grafico
  List<DailyRHRData> _serverRHRData = []; // Dati RHR degli ultimi giorni, pronti per il grafico

  @override
  void initState() {
    super.initState();
    _fetchServerData(); // Scarica subito i dati appena la schermata viene creata
  }

  @override
  void didUpdateWidget(covariant StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentDay != widget.currentDay || // se cambia il giorno dalla home, scarico i dati da capo
        oldWidget.currentDate != widget.currentDate ||
        oldWidget.hasConsumedAlcoholToday != widget.hasConsumedAlcoholToday ||
        oldWidget.currentMoodToday != widget.currentMoodToday) {
      setState(() {
        _isLoading = true;
      });
      _fetchServerData();
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // cancello le risorse sul controller quando la schermata viene chiusa
    super.dispose();
  }

  // Scarica dal server gli ultimi 7 giorni di dati sonno e RHR, applica le eventuali alterazioni dovute all'alcol e li salva
  Future<void> _fetchServerData() async {
    Impact impactService = Impact();
    final prefs = await SharedPreferences.getInstance();

    List<DailySleepData> fetchedSleepData = [];
    List<DailyRHRData> fetchedRHRData = [];

    // Se siamo nella prima settimana, riempio da sx a destra, altrimenti scorro
    final int primoGiorno = (widget.currentDay - 6) < 1 ? 1 : widget.currentDay - 6;

    for (int d = primoGiorno; d <= widget.currentDay; d++) { // data reale corrispondente al giorno simulato
      DateTime targetDate = widget.currentDate.subtract(Duration(days: widget.currentDay - d));

      List<SleepData> daySleepData = await impactService.getSleepDataFromDay(targetDate);
      List<RHR> dayRHRData = await impactService.getRestingHeartRateFromDay(targetDate);

      bool isOggi = (d == widget.currentDay); // giorno di oggi dalla home, altri giorni da sharedpreferences
      bool haBevuto = isOggi
          ? widget.hasConsumedAlcoholToday
          : (prefs.getBool('alcol_giorno_$d') ?? false);

      // Salvataggio Sonno
      if (daySleepData.isNotEmpty) {
        SleepData sleep = daySleepData.first;

        // Applica penalità per l'alcol
        int finalAsleep = AlteredStatistics.calculateModifiedMinutesAsleep(sleep.minutesAsleep ?? 0, haBevuto);
        int finalAwake = AlteredStatistics.calculateModifiedMinutesAwake(sleep.minutesAwake ?? 0, haBevuto);
        int finalEfficiency = AlteredStatistics.calculateModifiedEfficiency(sleep.efficiency ?? 0, haBevuto);

        fetchedSleepData.add(DailySleepData(
          day: d,
          minutesAsleep: finalAsleep,
          minutesAwake: finalAwake,
          minutesAfterWokeup: sleep.minutesAfterWakeup ?? 0,
          efficiency: finalEfficiency,
          hasConsumedAlcohol: haBevuto,
          hasData: true,
        ));
      } else {

        // Nessun dato sonno per questo giorno: lo aggiungo comunque con hasData:false, così il grafico mostra l'etichetta del giorno ma senza barra
        fetchedSleepData.add(DailySleepData(
          day: d,
          minutesAsleep: 0,
          minutesAwake: 0,
          minutesAfterWokeup: 0,
          efficiency: 0,
          hasConsumedAlcohol: false,
          hasData: false,
        ));
      }

      // Salvataggio RHR 
      if (dayRHRData.isNotEmpty && dayRHRData.first.value != null) {

        // Applica la penalità per l'alcol
        double finalRHR = AlteredStatistics.calculateModifiedRHR(dayRHRData.first.value!, haBevuto);

        fetchedRHRData.add(DailyRHRData(
          day: d,
          value: finalRHR,
          hasConsumedAlcohol: haBevuto,
          hasData: true,
        ));
      } else {

        // Nessun dato RHR per questo giorno: lo aggiungo comunque con hasData:false, così il grafico mostra l'etichetta del giorno ma senza pallino
        fetchedRHRData.add(DailyRHRData(
          day: d,
          value: 0,
          hasConsumedAlcohol: false,
          hasData: false,
        ));
      }
    }

    // Aggiorna lo stato solo se il widget è ancora "vivo" sullo schermo (evita errori se l'utente cambia schermata mentre il download è in corso)
    if (mounted) {
      setState(() {
        _serverSleepData = fetchedSleepData;
        _serverRHRData = fetchedRHRData;
        _isLoading = false;
      });
    }
  }

  // Trasforma ore e minuti in una frase leggibile
  String _formatTime(int hours, int minutes) {
    if (hours > 0 && minutes > 0) return "$hours ore e $minutes minuti";
    if (hours > 0) return "$hours ore";
    return "$minutes minuti";
  }

  @override
  Widget build(BuildContext context) {

    // Recupera il dato di oggi dalla lista scaricata (per sicurezza, se non lo trova usa l'ultimo elemento disponibile invece di andare in errore)
    DailySleepData? todaySleepData = _serverSleepData.isNotEmpty
        ? _serverSleepData.lastWhere(
            (d) => d.day == widget.currentDay,
            orElse: () => _serverSleepData.last)
        : null;

    DailyRHRData? todayRHRData = _serverRHRData.isNotEmpty
        ? _serverRHRData.lastWhere(
            (d) => d.day == widget.currentDay,
            orElse: () => _serverRHRData.last)
        : null;


    // LOGICA SONNO

    String sleepStatsText = "Nessun dato del sonno rilevato per oggi.";
    String sleepFeedbackText = "Assicurati che lo smartwatch sia sincronizzato per iniziare a monitorare i tuoi progressi.";
    double efficiency = 0.0; // Se non ho nessun dato, di default zero

    if (todaySleepData != null && todaySleepData.hasData) {
      int asleepMin = todaySleepData.minutesAsleep;
      int awakeMin = todaySleepData.minutesAwake;
      bool hasAlcohol = todaySleepData.hasConsumedAlcohol;

      efficiency = todaySleepData.efficiency.toDouble(); // efficienza alterata se ha consumato alcol

      int oreSonno = asleepMin ~/ 60;
      int minSonno = asleepMin % 60;
      int oreSveglio = awakeMin ~/ 60;
      int minSveglio = awakeMin % 60;

      sleepStatsText = "Hai dormito ${_formatTime(oreSonno, minSonno)} e sei stato sveglio ${_formatTime(oreSveglio, minSveglio)}. L'efficienza è del ${efficiency.toStringAsFixed(1)}%.";

      // Testo di feedback 
      if (hasAlcohol) {
        if (efficiency < 85) {
          sleepFeedbackText = "Oggi l'efficienza del sonno è un po' bassa. Anche quantità minime di alcol possono alterare i normali cicli del sonno, rendendo il riposo meno continuo del solito.";
        } else {
          sleepFeedbackText = "Come ti senti oggi? Spesso l'alcol fa addormentare in fretta, ma riduce drasticamente la fase REM, la fase dei sogni essenziale per la nostra lucidità mentale. Questo può farti svegliare con una sensazione di stanchezza, anche se i numeri sembrano buoni.";
        }
      } else {
        if (efficiency >= 85 && oreSonno >= 7) {
          sleepFeedbackText = "Ottimo lavoro! Giornate come questa permettono al tuo corpo e alla tua mente di ricaricarsi completamente. Continua così!";
        } else if (efficiency >= 85) {
          sleepFeedbackText = "Hai riposato benissimo e senza interruzioni. L'unica cosa che manca è un po' di durata: cerca di concederti un po' di sonno extra appena riesci! Un riposo leggermente più lungo ti aiuterà a sfruttare al massimo l'ottima qualità del tuo sonno.";
        } else {
          sleepFeedbackText = "Oggi l'efficienza è un po' sotto la media, ma le notti storte capitano a chiunque. La cosa importante è che hai fatto l'ottima scelta di non bere. Sii paziente e stasera prova a dedicarti a qualcosa di rilassante prima di chiudere gli occhi.";
        }
      }
    }


    // LOGICA RESTING HEART RATE
    String rhrStatsText = "Nessun dato RHR rilevato per oggi.";
    String rhrFeedbackText = "Indossa lo smartwatch durante la notte per registrare la tua frequenza cardiaca a riposo.";

    if (todayRHRData != null && todayRHRData.hasData) {
      int bpm = todayRHRData.value.toInt();
      bool hasAlcohol = todayRHRData.hasConsumedAlcohol;

      rhrStatsText = "Il tuo battito a riposo oggi è di $bpm bpm.";

      if (hasAlcohol) {
        rhrFeedbackText = "La frequenza cardiaca a riposo (RHR) indica quanti battiti compie il tuo cuore al minuto in uno stato di completo relax. L'alcol costringe il corpo a un sforzo per smaltire le tossine, mantenendo il battito più alto del dovuto e impedendoti un recupero completo.";
      } else {
        if (bpm > 75) { 
          rhrFeedbackText = "La tua frequenza cardiaca a riposo è leggermente sopra la media. Anche senza alcol, fattori come stress, allenamenti intensi o stanchezza possono tenerla alta. Hai fatto bene a evitare l'alcol: prova stasera una respirazione lenta prima di dormire per aiutare il cuore a ritrovare il suo ritmo.";
        } else {
          rhrFeedbackText = "Stai mantenendo la tua frequenza cardiaca a riposo su livelli ottimali. Una RHR bassa è segno di un cuore efficiente e allenato; significa che il tuo sistema cardiovascolare è in salute e che le tue scelte quotidiane, come l'astensione dall'alcol, stanno dando i loro frutti.";
        }
      }
    }


    // LOGICA INDICE DI RECUPERO

    int recoveryScore = 100; // Si parte dal massimo e si sottraggono penalità
    String scoreStatsText = "Dati insufficienti per calcolare l'indice.";
    String scoreFeedbackText = "Sincronizza lo smartwatch e inserisci l'umore nella Home per generare il punteggio di recupero.";

    // Il punteggio si calcola solo se abbiamo sia dati di sonno che di RHR per oggi
    if (todaySleepData != null && todayRHRData != null && todaySleepData.hasData && todayRHRData.hasData) {

      if (widget.hasConsumedAlcoholToday) {
        recoveryScore -= 20; // PENALITÀ PER L'ALCOL
      }

      int oreSonno = todaySleepData.minutesAsleep ~/ 60;

      // Penalità in base a efficienza del sonno e ore dormite
      if (efficiency >= 90 && oreSonno >= 7) {
        recoveryScore -= 0;
      } else if (efficiency >= 80 || (efficiency >= 90 && oreSonno < 7)) {
        recoveryScore -= 5;
      } else if (efficiency >= 70 || (efficiency >= 80 && oreSonno < 6)) {
        recoveryScore -= 10;
      } else {
        recoveryScore -= 20;
      }

      // Confronta l'RHR di oggi con la media dei giorni precedenti: se è più alto, penalità
      List<DailyRHRData> pastWeekRHR = _serverRHRData.where((d) => d.day < widget.currentDay && d.hasData).toList();
      if (pastWeekRHR.isNotEmpty) {
        double rhrAverage = pastWeekRHR.map((d) => d.value).reduce((a, b) => a + b) / pastWeekRHR.length;
        double diff = todayRHRData.value - rhrAverage;

        if (diff > 10) {
          recoveryScore -= 20;
        } else if (diff > 4) {
          recoveryScore -= 10;
        } else if (diff > 0) {
          recoveryScore -= 5;
        }
      }

      // Bonus/penalità in base all'umore selezionato oggi
      switch (widget.currentMoodToday) {
        case 'Calmo':
          recoveryScore += 10;
          break;
        case 'Ok':
          recoveryScore += 5;
          break;
        case 'Triste':
          recoveryScore -= 10;
          break;
        case 'Stressato':
          recoveryScore -= 15;
          break;
        default:
          recoveryScore += 0;
      }

      recoveryScore = recoveryScore.clamp(0, 100); // Tiene il punteggio sempre tra 0 e 100

      scoreStatsText = "Il tuo Indice di Recupero oggi è $recoveryScore/100.";

      if (widget.hasConsumedAlcoholToday) {
        scoreFeedbackText = "L'alcol ha alterato il tuo recupero: il tuo corpo sta usando energia extra per smaltire le tossine. È normale sentirsi un po' meno energici oggi; dai priorità al riposo e sii paziente con te stesso. Un solo giorno no non cancella i tuoi risultati, fa parte del gioco: l'importante è tornare in equilibrio da domani.";
      } else {
        if (recoveryScore >= 80) { // --- QUI PER CAMBIARE LA SOGLIA DI PUNTEGGIO "OTTIMO" ---
          scoreFeedbackText = "Hai raggiunto un equilibrio perfetto. Il tuo organismo è in piena forma e pronto ad affrontare qualsiasi sfida oggi. Continua così e sfrutta questa energia positiva!";
        } else if (recoveryScore >= 50) { // --- QUI PER CAMBIARE LA SOGLIA DI PUNTEGGIO "BUONO" ---
          scoreFeedbackText = "Tutto sommato una buona giornata. Il tuo indice mostra che sei sulla buona strada, anche se qualche piccola tensione ha frenato la tua ricarica. Stasera prova a staccare la spina un po' prima del solito e dedicati a un momento di puro relax prima di dormire: il tuo corpo ti ringrazierà domani.";
        } else {
          scoreFeedbackText = "Sembri un po' sottotono oggi. Capita a tutti di avere giornate in cui il recupero è faticoso: prendila con calma, non stressarti e dai priorità assoluta al tuo relax.";
        }
      }
    }

    // COSTRUZIONE DELL'INTERFACCIA

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9), // colore di sfondo schermata
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // margine schermata
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Le tue statistiche',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ral5018), // titolo principale
              ),
              const SizedBox(height: 4),
              const Text(
                'Scorri per esplorare i tuoi dati',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 20),

              // Finché i dati non sono arrivati mostra una rotella, altrimenti le 3 card scorrevoli
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: ral5018))
                    : PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentCard = index; // Aggiorna quale puntino evidenziare in basso
                          });
                        },
                        children: [

                          // CARD 1: SONNO
                          StatCard(
                            title: 'Sonno',
                            legendWidget: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  _buildLegendItem(const Color(0xFF13898C), "Sonno"),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(const Color(0xFF80CBC4), "Sveglio"),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(Colors.deepOrange.shade400, "Sonno (alcol)"),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(Colors.orange.shade200, "Sveglio (alcol)"),
                                ],
                              ),
                            ),
                            chartWidget: SleepChart(sleepData: _serverSleepData),
                            statsText: sleepStatsText,
                            feedbackText: sleepFeedbackText,
                          ),

                          // CARD 2: RESTING HEART RATE
                          StatCard(
                            title: 'Resting Heart Rate (RHR)',
                            legendWidget: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  _buildLegendItem(const Color(0xFF13898C), "Senza alcol"),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(Colors.deepOrange.shade400, "Con alcol"),
                                ],
                              ),
                            ),
                            chartWidget: RHRChart(rhrData: _serverRHRData),
                            statsText: rhrStatsText,
                            feedbackText: rhrFeedbackText,
                          ),

                          // CARD 3: INDICE DI RECUPERO
                          StatCard(
                            title: 'Indice di Recupero',
                            legendWidget: const SizedBox.shrink(), // Nessuna legenda per questa card
                            chartWidget: ScoreChart(
                              score: (todaySleepData != null && todayRHRData != null) ? recoveryScore : 0,
                            ),
                            statsText: scoreStatsText,
                            feedbackText: scoreFeedbackText,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Puntini indicatori in basso: mostrano quale card è attiva
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3, // Numero di card totali
                  (index) => AnimatedContainer( //animazione dei puntini
                    duration: const Duration(milliseconds: 300), // velocità
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8, // altezza
                    width: _currentCard == index ? 24 : 8, // se attiva largo 24, altrimenti 8
                    decoration: BoxDecoration(
                      color: _currentCard == index ? ral5018 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder della card con titolo, legenda opzionale, grafico e testi
class StatCard extends StatelessWidget {
  final String title;
  final Widget legendWidget;
  final Widget chartWidget;
  final String statsText;
  final String feedbackText;

  const StatCard({
    super.key,
    required this.title,
    required this.legendWidget,
    required this.chartWidget,
    required this.statsText,
    required this.feedbackText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      padding: const EdgeInsets.all(20), // spazio interno
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), //arrotondamento degli angoli 
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15), //sfumatura 
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), // titolo
          ),

          if (legendWidget is! SizedBox) ...[ //se la legenda non è vuota la mostro
            const SizedBox(height: 15),
            legendWidget,
          ],
          const SizedBox(height: 15),

          // Riquadro del grafico
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, right: 20, left: 15, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade50, // colore di sfondo
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: chartWidget,
            ),
          ),
          const SizedBox(height: 25),

          Text(
            statsText,
            style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold), // testo principale
          ),
          const SizedBox(height: 12),
          Text(
            feedbackText,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w500, height: 1.3), // testo di feedback
          ),
        ],
      ),
    );
  }
}