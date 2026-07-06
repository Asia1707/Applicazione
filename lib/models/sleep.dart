class SleepData {

  final String? dateOfSleep;          // ? se puuò essere anche null
  final int? minutesAsleep;
  final int? minutesAwake;
  final int? minutesAfterWakeup;
  final int? efficiency;
  
  SleepData({ //costruttore della classe
    required this.dateOfSleep, //ho usato ?, accetta anche il null
    required this.minutesAsleep,
    required this.minutesAwake,
    required this.minutesAfterWakeup,
    required this.efficiency,
  });


  factory SleepData.fromJson(Map<String, dynamic> json) { //converto i dati grezzi (JSON) in un oggetto
    return SleepData(
      dateOfSleep: json['dateOfSleep'],
      minutesAsleep: json['minutesAsleep'],
      minutesAwake: json['minutesAwake'],
      minutesAfterWakeup: json['minutesAfterWakeup'],
      efficiency: json['efficiency'],
    );
  }
}