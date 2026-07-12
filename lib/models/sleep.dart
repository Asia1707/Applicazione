// MODELLO SLEEP DATA

class SleepData {

  final String? dateOfSleep;        // ? indica che accetta anche il valore null
  final int? minutesAsleep;         // Minuti totali di sonno effettivo
  final int? minutesAwake;          // Minuti passati svegli durante la notte
  final int? minutesAfterWakeup;    // Minuti passati a letto svegli prima di alzarsi
  final int? efficiency;            // Percentuale di efficienza del sonno calcolata dallo smartwatch
  
  SleepData({ // Costruttore della classe
    required this.dateOfSleep, 
    required this.minutesAsleep,
    required this.minutesAwake,
    required this.minutesAfterWakeup,
    required this.efficiency,
  });

 
  factory SleepData.fromJson(Map<String, dynamic> json) {  // factory serve a tradurre i dati grezzi scaricati da internet (in formato JSON) in un oggetto Flutter leggibile
    return SleepData(
      dateOfSleep: json['dateOfSleep'], 
      minutesAsleep: json['minutesAsleep'],
      minutesAwake: json['minutesAwake'],
      minutesAfterWakeup: json['minutesAfterWakeup'],
      efficiency: json['efficiency'],
    );
  }
}