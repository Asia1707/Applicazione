import 'package:flutter/material.dart'; 
 
 
class Login extends StatefulWidget { //Stateful: cambia il stato della password visibility
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // i CONTROLLERS tengono traccia di quello che l'utente scrive nei campi di testo. Uno per username, uno per password.
  
  final TextEditingController userController = TextEditingController();     // legge il campo username
  final TextEditingController passwordController = TextEditingController(); // legge il campo password
  
  // Stato per tracciare se la password è visibile o nascosta
  bool _isPasswordVisible = false;
 
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea( //SafeArea evita che il contenuto finisca sotto la barra di stato del telefono
        child: Padding(
 
          // SPAZIATURA ESTERNA della pagina
          // QUI PER CAMBIARE I MARGINI DELLA PAGINA
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 50,
            bottom: 20,
          ),
          child: SingleChildScrollView( // Permette di scrollare se il contenuto è troppo grande
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // centra tutto al centro
              children: [
 

              // 1. Creare una cartella "assets"
              // 2. Aggiungere in pubspec.yaml:
              //      flutter:
              //        assets:
              //          - assets/logo.png
              // QUI PER CAMBIARE IL LOGO 

              Image.asset(
                'assets/logo.png',
                scale: 2, // più è alto più è piccola l'immagine
              ),
 
              const SizedBox(height: 50), // spazio verticale vuoto
 
              
              
              // QUI PER CAMBIARE IL TESTO DI BENVENUTO
  
              const Text(
                'Benvenuto',
                style: TextStyle(
                  fontWeight: FontWeight.w500, // grassetto medio
                  fontSize: 30,               // QUI PER CAMBIARE DIMENSIONE TITOLO
                ),
              ),
 
              const SizedBox(height: 20), 
 

              // QUI PER CAMBIARE IL SOTTOTITOLO
              const Text('Accedi al tuo account'),
 
              const SizedBox(height: 40), 
 
   
              // CAMPO USERNAME
              // TextField = casella di testo interattiva

              TextField(
                controller: userController, // collega il controller per leggere il testo
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // QUI PER CAMBIARE L'ARROTONDAMENTO DEL BORDO
                  ),
                  labelText: 'Username',                    // QUI PER CAMBIARE L'ETICHETTA
                  hintText: 'Inserisci il tuo username',   // QUI PER CAMBIARE IL SUGGERIMENTO
                  suffixIcon: const Icon(Icons.person),    // Icona omino sul lato destro
                ),
              ),
 
              const SizedBox(height: 30), 
 
  
              // CAMPO PASSWORD
              // obscureText: true → nasconde i caratteri (puntini)

     
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible, // inverte lo stato: true nasconde, false mostra
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // QUI PER CAMBIARE L'ARROTONDAMENTO
                  ),
                  labelText: 'Password',                    // QUI PER CAMBIARE L'ETICHETTA
                  hintText: 'Inserisci la tua password',   // QUI PER CAMBIARE IL SUGGERIMENTO
                  // Icona occhio che toggia la visibilità della password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility  // Occhio aperto se visibile
                          : Icons.visibility_off, // Occhio chiuso se nascosto
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Toggle visibilità
                      });
                    },
                  ),
                ),
              ),
 
              const SizedBox(height: 30), 
 
   
              // BOTTONE LOGIN
              // Align + Center per centrarlo orizzontalmente
    
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
 
     
                    // LOGICA AL CLICK DEL BOTTONE
                    // Controlla username e password inseriti

                    onPressed: () {
                      // Legge il testo scritto nei due campi
                      // e lo confronta con username/password corretti
 
                      // QUI PER CAMBIARE USERNAME E PASSWORD DI ACCESSO ↓
                      if (userController.text == 'admin' &&
                          passwordController.text == '123456') {
 
                        // Credenziali corrette → per ora stampa solo un messaggio
                        // In futuro qui metterai la navigazione alla schermata successiva:
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AltraSchermata()));
                        print('Login effettuato con successo');
 
                      } else {
 
                        // Credenziali errate → mostra un messaggio di errore rosso
                        // QUI PER CAMBIARE IL MESSAGGIO DI ERRORE
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red, // QUI PER CAMBIARE COLORE ERRORE
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(8),
                              duration: Duration(seconds: 2),
                              content: Text('Username o password errati'),
                            ),
                          );
                      }
                    },
 
                    // ----------------------------------------
                    // STILE DEL BOTTONE
                    // QUI PER CAMBIARE COLORE, DIMENSIONI E TESTO DEL BOTTONE
                    // ----------------------------------------
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          horizontal: 80, // QUI PER CAMBIARE LARGHEZZA BOTTONE
                          vertical: 12,   // QUI PER CAMBIARE ALTEZZA BOTTONE
                        ),
                      ),
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.white, // QUI PER CAMBIARE COLORE TESTO BOTTONE
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        const Color(0xFF384242), // QUI PER CAMBIARE COLORE SFONDO BOTTONE

                      ),
                    ),
 
                    child: const Text('Accedi'), // QUI PER CAMBIARE IL TESTO DEL BOTTONE
                  ),
                ),
              ),
 
              const SizedBox(height: 20),
 
            ],
            ),
          ),
        ),
      ),
    );
  }
}