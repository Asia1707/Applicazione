import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// Colore 
const Color appColor = Color(0xFF0F8A8F);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // variabile che tiene lo stato dello switch (acceso/spento)
  bool _shareDataWithPsychologist = true;

  // Metodo che apre il popup per modificare il nome utente
  void _editUserName(UserProvider userProvider) {
    // controller: legge/scrive il testo che l'utente digita nel campo
    final controller = TextEditingController(text: userProvider.userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica nome utente'),
          content: TextField(
            controller: controller,
            autofocus: true, // il cursore si posiziona subito qui
            cursorColor: appColor,
          ),
          actions: [
            // Bottone "Annulla": chiude il popup senza salvare
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annulla'),
            ),
            // Bottone "Salva": aggiorna il Provider e chiude il popup
            TextButton(
              // style: cambio il colore del testo del bottone
              style: TextButton.styleFrom(
                foregroundColor: appColor,
              ),
              onPressed: () {
                userProvider.updateUserName(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  // Widget riutilizzabile per una riga "etichetta + valore + matita cliccabile"
  Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // cosa fare quando si clicca sulla riga
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // spazio tra etichetta e valore
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black45),
              ),
              const SizedBox(width: 8), // piccolo spazio tra testo e icona
              const Icon(Icons.edit_outlined, size: 18, color: Colors.black45),
            ],
          ),
        ],
      ),
    );
  }

  // Card "Profilo": nome utente (modificabile) + codice psicologo (sola lettura)
  Widget _buildProfileCard(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // angoli arrotondati
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // testo allineato a sinistra
        children: [
          const Text(
            'Profilo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Nome utente: cliccabile, apre il dialogo di modifica
          _buildInfoRow('Nome utente', userProvider.userName, () {
            _editUserName(userProvider);
          }),

          const Divider(), // linea sottile di separazione

          // Codice Psicologo: arriva dal Login
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Codice Psicologo',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              Text(
                userProvider.psychologistCode,
                style: const TextStyle(fontSize: 15, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card "I tuoi progressi": prende i dati veri dal Provider,
  // aggiornati dalla Home Screen
  Widget _buildProgressCard(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'I tuoi progressi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Riga "Check-in completati"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Check-in completati',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
              // leggo il numero dal Provider e lo trasformo in testo con .toString()
              Text(
                userProvider.checkInCount.toString(),
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),

          const Divider(),

          // Riga "Streak" (streak attuale, aggiornata dalla Home)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_outlined, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Streak',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
              // uso l'interpolazione di stringa ($) per unire numero e testo "giorni"
              Text(
                '${userProvider.currentStreak} giorni',
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card "Obiettivo": target personale, testo fisso per ora
  Widget _buildTargetCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Obiettivo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.track_changes, size: 20, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Target personale',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const Spacer(), // spinge il testo successivo tutto a destra
              const Text(
                '30 giorni senza alcol',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card con lo switch "Invia i miei dati allo psicologo"
  Widget _buildShareDataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Invia i miei dati allo psicologo',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Switch(
            value: _shareDataWithPsychologist, // stato attuale (acceso/spento)
            activeThumbColor: appColor, // colore quando è acceso
            onChanged: (newValue) {
              setState(() {
                _shareDataWithPsychologist = newValue; // aggiorno lo stato
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // leggo il Provider condiviso: "watch" fa sì che questa schermata
    // si ridisegni automaticamente ogni volta che qualcosa cambia
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF9),
        elevation: 0, // niente ombra sotto la barra
        title: const Text(
          'Impostazioni',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        // ListView invece di Column: permette di scorrere se il contenuto
        // non entra tutto nello schermo
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(userProvider),
          const SizedBox(height: 16), // spazio tra le card
          _buildProgressCard(userProvider), // passo userProvider come parametro
          const SizedBox(height: 16),
          _buildShareDataCard(),
        ],
      ),
    );
  }
}