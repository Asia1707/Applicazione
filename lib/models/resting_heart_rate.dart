// Una classe è una sorta di stampo o modello che definisce come è fatto un singolo dato 
class RHR {
  
  final DateTime timestamp; //final perchè una volta creato il dato non può più essere modificato

  final double? value; // double per numeri con la virgola. ? per gestire i dati mancanti

  RHR({
    required this.timestamp, //obbligatori (required)
    required this.value,
  });
}