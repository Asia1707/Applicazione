import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../charts/sleep_chart.dart';
import '../charts/rhr_chart.dart';
import '../charts/score_chart.dart'; 
import '../services/impact.dart';
import '../models/sleep.dart';
import '../models/resting_heart_rate.dart';
import '../utils/alteredstatistics.dart';

// Helper per creare la singola voce della legenda
Widget _buildLegendItem(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min, 
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87), 
      ),
    ],
  );
}

class StatisticsScreen extends StatefulWidget {
  final DateTime currentDate;
  final int currentDay; 
  final bool hasConsumedAlcoholToday;
  final String currentMoodToday;

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
  final PageController _pageController = PageController();
  int _currentCard = 0;
  static const Color ral5018 = Color(0xFF13898C);

  bool _isLoading = true;
  List<DailySleepData> _serverSleepData = [];
  List<DailyRHRData> _serverRHRData = []; 

  @override
  void initState() {
    super.initState();
    _fetchServerData();
  }

  @override
  void didUpdateWidget(covariant StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay ||
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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchServerData() async {
    Impact impactService = Impact();
    final prefs = await SharedPreferences.getInstance();
    
    List<DailySleepData> fetchedSleepData = [];
    List<DailyRHRData> fetchedRHRData = []; 

    final int primoGiorno = widget.currentDay - 6;

    for (int d = primoGiorno; d <= widget.currentDay; d++) {
      if (d < 1) {
        fetchedSleepData.add(DailySleepData(
          day: d, minutesAsleep: 0, minutesAwake: 0, minutesAfterWokeup: 0,
          hasConsumedAlcohol: false, hasData: false, exists: false,
        ));
        fetchedRHRData.add(DailyRHRData(
          day: d, value: 0, hasConsumedAlcohol: false, hasData: false, exists: false,
        ));
        continue;
      }

      DateTime targetDate = widget.currentDate.subtract(Duration(days: widget.currentDay - d));

      List<SleepData> daySleepData = await impactService.getSleepDataFromDay(targetDate);
      List<RHR> dayRHRData = await impactService.getRestingHeartRateFromDay(targetDate);

      bool isOggi = (d == widget.currentDay);
      bool haBevuto = isOggi
          ? widget.hasConsumedAlcoholToday
          : (prefs.getBool('alcol_giorno_$d') ?? false);

      // Salvataggio Sonno
      if (daySleepData.isNotEmpty) {
        SleepData sleep = daySleepData.first;
        int finalAsleep = AlteredStatistics.calculateModifiedMinutesAsleep(sleep.minutesAsleep ?? 0, haBevuto);
        int finalAwake = AlteredStatistics.calculateModifiedMinutesAwake(sleep.minutesAwake ?? 0, haBevuto);

        fetchedSleepData.add(DailySleepData(
          day: d, minutesAsleep: finalAsleep, minutesAwake: finalAwake, minutesAfterWokeup: sleep.minutesAfterWakeup ?? 0,
          hasConsumedAlcohol: haBevuto, hasData: true, exists: true,
        ));
      } else {
        fetchedSleepData.add(DailySleepData(
          day: d, minutesAsleep: 0, minutesAwake: 0, minutesAfterWokeup: 0,
          hasConsumedAlcohol: false, hasData: false, exists: true,
        ));
      }

      // Salvataggio RHR
      if (dayRHRData.isNotEmpty && dayRHRData.first.value != null) {
        fetchedRHRData.add(DailyRHRData(
          day: d, 
          value: dayRHRData.first.value!, 
          hasConsumedAlcohol: haBevuto, 
          hasData: true, 
          exists: true,
        ));
      } else {
        fetchedRHRData.add(DailyRHRData(
          day: d, value: 0, hasConsumedAlcohol: false, hasData: false, exists: true,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _serverSleepData = fetchedSleepData;
        _serverRHRData = fetchedRHRData; 
        _isLoading = false;
      });
    }
  }

  String _formatTime(int hours, int minutes) {
    if (hours > 0 && minutes > 0) return "$hours ore e $minutes minuti";
    if (hours > 0) return "$hours ore";
    return "$minutes minuti";
  }

  @override
  Widget build(BuildContext context) {
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

    // --- LOGICA SONNO ---
    String sleepStatsText = "Nessun dato del sonno rilevato per oggi.";
    String sleepFeedbackText = "Assicurati che lo smartwatch sia sincronizzato per iniziare a monitorare i tuoi progressi.";
    double efficiency = 0.0;

    if (todaySleepData != null && todaySleepData.hasData) {
      int asleepMin = todaySleepData.minutesAsleep;
      int awakeMin = todaySleepData.minutesAwake;
      bool hasAlcohol = todaySleepData.hasConsumedAlcohol;

      int totalMin = asleepMin + awakeMin;
      efficiency = totalMin > 0 ? (asleepMin / totalMin) * 100 : 0.0;

      int oreSonno = asleepMin ~/ 60;
      int minSonno = asleepMin % 60;
      int oreSveglio = awakeMin ~/ 60;
      int minSveglio = awakeMin % 60;

      sleepStatsText = "Hai dormito ${_formatTime(oreSonno, minSonno)} e sei stato sveglio ${_formatTime(oreSveglio, minSveglio)}. L'efficienza è del ${efficiency.toStringAsFixed(1)}%.";

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

    // --- LOGICA RESTING HEART RATE ---
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

    // --- LOGICA INDICE DI RECUPERO ---
    int recoveryScore = 100;
    String scoreStatsText = "Dati insufficienti per calcolare l'indice.";
    String scoreFeedbackText = "Sincronizza lo smartwatch e inserisci l'umore nella Home per generare il punteggio di recupero.";

    if (todaySleepData != null && todayRHRData != null && todaySleepData.hasData && todayRHRData.hasData) {
      
      if (widget.hasConsumedAlcoholToday) {
        recoveryScore -= 20;
      }

      int oreSonno = todaySleepData.minutesAsleep ~/ 60;

      if (efficiency >= 90 && oreSonno >= 7) {
        recoveryScore -= 0;
      } else if (efficiency >= 80 || (efficiency >= 90 && oreSonno < 7)) {
        recoveryScore -= 5;
      } else if (efficiency >= 70 || (efficiency >= 80 && oreSonno < 6)) {
        recoveryScore -= 10;
      } else {
        recoveryScore -= 20;
      }

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

      switch (widget.currentMoodToday) {
        case 'Calmo': recoveryScore += 10; break;
        case 'Ok': recoveryScore += 5; break;
        case 'Triste': recoveryScore -= 10; break;
        case 'Stressato': recoveryScore -= 15; break;
        default: recoveryScore += 0;
      }

      recoveryScore = recoveryScore.clamp(0, 100);

      scoreStatsText = "Il tuo Indice di Recupero oggi è $recoveryScore/100.";
      
      if (widget.hasConsumedAlcoholToday) {
        scoreFeedbackText = "L'alcol ha alterato il tuo recupero: il tuo corpo sta usando energia extra per smaltire le tossine. È normale sentirsi un po' meno energici oggi; dai priorità al riposo e sii paziente con te stesso. Un solo giorno no non cancella i tuoi risultati, fa parte del gioco: l'importante è tornare in equilibrio da domani.";
      } else {
        if (recoveryScore >= 80) {
          scoreFeedbackText = "Hai raggiunto un equilibrio perfetto. Il tuo organismo è in piena forma e pronto ad affrontare qualsiasi sfida oggi. Continua così e sfrutta questa energia positiva!";
        } else if (recoveryScore >= 50) {
          scoreFeedbackText = "Tutto sommato una buona giornata. Il tuo indice mostra che sei sulla buona strada, anche se qualche piccola tensione ha frenato la tua ricarica. Stasera prova a staccare la spina un po' prima del solito e dedicati a un momento di puro relax prima di dormire: il tuo corpo ti ringrazierà domani.";
        } else {
          scoreFeedbackText = "Sembri un po' sottotono oggi. Capita a tutti di avere giornate in cui il recupero è faticoso: prendila con calma, non stressarti e dai priorità assoluta al tuo relax.";
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Le tue statistiche',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ral5018),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scorri per esplorare i tuoi dati',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: ral5018))
                    : PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentCard = index;
                          });
                        },
                        children: [
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
                          StatCard(
                            title: 'Indice di Recupero',
                            legendWidget: const SizedBox.shrink(),
                            chartWidget: AstemixScoreChart(score: (todaySleepData != null && todayRHRData != null) ? recoveryScore : 0),
                            statsText: scoreStatsText,
                            feedbackText: scoreFeedbackText,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedContainer( 
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentCard == index ? 24 : 8,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          if (legendWidget is! SizedBox) ...[
            const SizedBox(height: 15),
            legendWidget,
          ],
          const SizedBox(height: 15),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, right: 20, left: 15, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
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
            style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            feedbackText,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w500, height: 1.3),
          ),
        ],
      ),
    );
  }
}