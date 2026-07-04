import 'package:flutter/material.dart';

class UserProvider  extends ChangeNotifier{
  String _userName='Marco Rossi'; 
  String _psychologistCode='PSI12345'; 

  String get userName => _userName; 
  String get psychologistCode => _psychologistCode; 

  void updateUserName (String newName){
    _userName = newName; 
    notifyListeners();
  }
  void updatePsychologistCode (String newCode){
    _psychologistCode = newCode; 
    notifyListeners();
  }
}