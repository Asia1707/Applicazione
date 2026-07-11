import 'package:flutter/material.dart'; // contiene i widget 
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astemix_drugbalix/services/impact.dart';
import 'package:astemix_drugbalix/screens/homepage.dart'; 

import 'package:provider/provider.dart';
import 'package:astemix_drugbalix/providers/user_provider.dart';


class Login extends StatefulWidget { //stateful perchè fa il refresh in base all'azione dell'utente (toggle specialista, occhiolino)
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState(); 
}

class _LoginState extends State<Login> { 
  
  // I controller servono a leggere il testo digitato dall'utente. Uno per ogni campo
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController specialistController = TextEditingController();
  
  final Impact impact = Impact(); //collego impact per i token

  // Inizializzo le variabili di stato 
  bool _isPasswordVisible = false; // di default non visibile
  bool _showSpecialistField = false; // di default non visibile

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white, //QUI PER CAMBIARE LO SFONDO
      body: SafeArea(  //garantisco che non si sovrapponga a notch, fotocamere o bordi curvi del telefono
        child: Padding( //spazi vuoti ai lati degli elementi
          padding: const EdgeInsets.symmetric(horizontal: 24.0), 
          child: SingleChildScrollView( //permette di scorrere in verticale. Utile quando compare la tastiera
            child: Column( //dispongo i widget in colonna
              crossAxisAlignment: CrossAxisAlignment.stretch, //allineo su tutta la larghezza
              children: [ 
                const SizedBox(height: 60), //QUI PER CAMBIARE SPAZIO VUOTO SOPRA AL LOGO
                
                // LOGO
                Align(
                  alignment: Alignment.center, 
                  child: Image.asset( 
                    'assets/logo_nuovo.png', //CARICA IN PUBSPEC 
                    height: 190, //QUI PER CAMBIARE DIMENSIONE LOGO
                  ), 
                ),
                
                const SizedBox(height: 40), //QUI PER CAMBIARE SPAZIO VUOTO TRA LOGO E USERNAME

                // USERNAME
                TextField(
                  controller: userController, // collego al controllore
                  decoration: InputDecoration( //visiva del campo di testo
                    filled: true, // Abilita il riempimento con un colore (secchiello)
                    fillColor: Colors.grey.shade50, // grigio chiaro
                    hintText: 'Username', // sparisce quando si inizia a scrivere
                    hintStyle: TextStyle(color: Colors.grey.shade500), // Stile del testo, grigio più chiaro
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20), //spazio tra testo e bordo
                    border: OutlineInputBorder( //bordo quando non selezionato
                      borderRadius: BorderRadius.circular(12), // Angoli arrotondati
                      borderSide: BorderSide.none, // Nessuna linea di bordo visibile
                    ),

                    enabledBorder: OutlineInputBorder( //bordo quando selezionato ma non cliccato (già riempito)
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1), // Bordo grigio sottile
                    ),

                    focusedBorder: OutlineInputBorder(  //bordo cliccato
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF384242), width: 2), // pià spesso e scuro
                    ),
                  ),
                ),

                const SizedBox(height: 20), // QUI PER AGGIUNGERE SPAZIO TRA USERNAME E PASSWORD

                // CAMPO PASSWORD
                TextField(
                  controller: passwordController, //Controllore
                  obscureText: !_isPasswordVisible, //nascondo o mostro in base al valore True/False
                  decoration: InputDecoration( //estetica come sopra
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF384242), width: 2),
                    ),

                    suffixIcon: IconButton( //aggiungo un icona a destra
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off, //cambio l'icona in base al booleano
                        color: Colors.grey.shade600, 
                      ),
                      onPressed: () { //se premuta
                        setState(() { //refresh dell'interfaccia
                          _isPasswordVisible = !_isPasswordVisible; //inverto il booleano
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30), // QUI PER AGGIUNGERE SPAZIO TRA PASSWORD E PSICO

                Row( //Creo una riga per testo e switch
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, //spazio tra testo e switch
                  children: [
                    Expanded( //il testo occupa tutto lo spazio, spingendo lo switch a destra
                      child: Text(
                        "Sei un paziente seguito?\nInserisci il codice dello specialista",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500, //Spessore del testo medio-grassetto
                          color: Colors.grey.shade700,
                          height: 1.4, //QUI PER MODIFICARE L'INTERLINEA
                        ),
                      ),
                    ),

                    Switch(
                      value: _showSpecialistField, //Il valore attuale dello switch
                      activeThumbColor: const Color(0xFF0F8A8F), // Colore quando lo switch è acceso (RAL 5018)
                      // Funzione richiamata ogni volta che l'utente interagisce con lo Switch
                      onChanged: (bool value) { //se cambiato
                        setState(() { //refresh della pagina
                          _showSpecialistField = value; //aggiorno con il nuovo valore
                        });
                      },
                    ),
                  ],
                ),

                // CAMPO CODICE PSICOLOGO
                if (_showSpecialistField) ...[ //Se il toggle è acceso, mostra questo campo (operatore spread "..." per inserire widget condizionalmente)
                  const SizedBox(height: 15), // QUI PER AGGIUNGERE SPAZIO TRA IL TOGGLE E IL CAMPO SPECIALISTA
                  TextField(
                    controller: specialistController, //collego il controller
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      hintText: 'Codice specialista (opzionale)',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1), 
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF384242), width: 2), 
                      ),

                      // Icona fissa sulla destra
                      suffixIcon: Icon(
                        Icons.medical_services,
                        color: Colors.grey.shade600, 
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40), // QUI PER AGGIUNGERE SPAZIO TRA IL CAMPO SPECIALISTA E IL BOTTONE ACCEDI

                // BOTTONE: ACCEDI
                ElevatedButton( 
                  onPressed: () async { //async perché contiene operazioni che richiedono tempo. Deve richiedere i token
                    final result = await impact.getAndStoreTokens(
                        userController.text, passwordController.text);

                    // Il widget potrebbe essere stato smontato (es. l'utente ha chiuso la schermata) mentre aspettavamo la risposta del server: se è successo, non usiamo più "context" per evitare errori
                    if (!context.mounted) return;

                    if (result == 200) { //se la chiamata ha successo esce HTTP 200
                      final sp = await SharedPreferences.getInstance(); //salva username e password in locale
                      
                      await sp.setString('username', userController.text); //salvo username
                      await sp.setString('password', passwordController.text); //salvo password

                      await impact.getPatient();

                      // Altro controllo dopo i nuovi await, per lo stesso motivo di sopra
                      if (!context.mounted) return;

                      // Se il toggle "paziente seguito" è acceso e il codice non è vuoto, salvo il codice sia in locale che nel provider
                      if (_showSpecialistField && specialistController.text.isNotEmpty) {
                        await sp.setString('specialist_code', specialistController.text); //salvo il codice dello specialista
                        context.read<UserProvider>().updatePsychologistCode(specialistController.text);
                      }

                      // Naviga verso la Homepage. pushReplacement "distrugge" la pagina di login, in modo che se l'utente preme il tasto "indietro" non torni qui ma esca dall'app
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(), 
                        ),
                      );
                    } else { // se credenziali errate o altri errori
                      
                      // Mostra un popup temporaneo (SnackBar) nella parte inferiore dello schermo
                      ScaffoldMessenger.of(context) //snackbar
                        ..removeCurrentSnackBar() // tolgo eventuale snackbar precedente
                        ..showSnackBar(const SnackBar(
                            backgroundColor: Colors.red, // Colore di sfondo 
                            behavior: SnackBarBehavior.floating, // "fluttuante" sullo schermo
                            margin: EdgeInsets.all(8), // Distanza dai bordi
                            duration: Duration(seconds: 2), // Il messaggio scompare dopo 2 secondi
                            content: Text("Username o password errati") // Il testo dell'errore
                        ));
                    }
                  },
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A8F), // Colore di sfondo (RAL 5018)
                    foregroundColor: Colors.white, // Colore del testo
                    padding: const EdgeInsets.symmetric(vertical: 16), // Altezza interna del bottone
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Angoli arrotondati
                    ),
                    elevation: 0, // Rimuove l'ombra sotto il bottone
                  ),
                  child: const Text(
                    'Accedi', // Testo del bottone
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),

                const SizedBox(height: 50), //spazio in fondo alla pagina
              ], 
            ),
          ),
        ),
      ),
    );
  }
}