// MODELLO RHR (Resting Heart Rate)
// Una classe è una sorta di stampo o modello che definisce come è fatto un singolo dato 

class RHR {
  
  final DateTime timestamp; // final perché una volta creato il dato non può più essere modificato

  final double? value; // double per numeri con la virgola. ? per gestire i dati mancanti 

  RHR({
    required this.timestamp, // obbligatorio passare questo dato quando si crea un nuovo record RHR
    required this.value,
  });
  factory RHR.fromJson(Map<String, dynamic> json) {
    return RHR(
      timestamp: DateTime.parse(json['timestamp']), 
      value: json['value'] != null ? (json['value'] as num).toDouble() : null, 
    );
  }
}