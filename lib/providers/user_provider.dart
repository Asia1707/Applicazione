import 'package:flutter/material.dart';
// ChangeNotifier è la classe che permette di "avvisare" le altre schermate
// quando qualcosa cambia in questo file.

class UserProvider extends ChangeNotifier {
  // Variabili private (accessibili solo da dentro questa classe)
  String _userName = 'Marco Rossi'; // nome utente di partenza
  String _psychologistCode = 'PSI12345'; // codice psicologo di partenza
  int _checkInCount = 0; // quanti giorni/check-in ha completato l'utente
  int _currentStreak = 0; // giorni consecutivi senza alcol, aggiornati dalla Home

  // Getter: permettono alle altre schermate di leggere i valori,
  // ma non di modificarli direttamente
  String get userName => _userName;
  String get psychologistCode => _psychologistCode;
  int get checkInCount => _checkInCount;
  int get currentStreak => _currentStreak;

  // Metodo per aggiornare il nome utente
  void updateUserName(String newName) {
    _userName = newName; // aggiorno il valore
    notifyListeners(); // avviso tutte le schermate collegate di ridisegnarsi
  }

  // Metodo per aggiornare il codice psicologo (usato dal Login)
  void updatePsychologistCode(String newCode) {
    _psychologistCode = newCode;
    notifyListeners();
  }

  // Metodo per aggiornare check-in e streak insieme
  void updateProgress(int newCheckInCount, int newStreak) {
    _checkInCount = newCheckInCount;
    _currentStreak = newStreak;
    notifyListeners(); // avviso la Settings Screen di aggiornarsi
  }
}