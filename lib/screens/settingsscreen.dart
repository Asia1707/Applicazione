import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
@override 
State <SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State <SettingsScreen> {
  bool _shareDataWithPsychologist = true;
  void _editUserName(UserProvider userProvider){
    final controller = TextEditingController(text: userProvider.userName);

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title : const Text('Modifica nome utente'), 
          content: TextField(
            controller : controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed:(){
                Navigator.pop(context);
              },
              child: const Text ('Annulla'),
            ),
            TextButton(
              onPressed: () {
                userProvider.updateUserName(controller.text);
                Navigator.pop(context);
              },
              child: const Text ('Salva'),
            ),
          ],
        );
      },
    );
  }
  void _editPsychologistCode(UserProvider userProvider){
    final controller = TextEditingController(text: userProvider.psychologistCode);

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title : const Text('Modifica codice psicologo'), 
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed:(){
                Navigator.pop(context);
              },
              child: const Text ('Annulla'),
            ),
            TextButton(
              onPressed: () {
                userProvider.updatePsychologistCode(controller.text);
                Navigator.pop(context);
              },
              child: const Text ('Salva'),
            ),
          ],
        );
      },
    );
  }
  Widget _buildProfileCard(UserProvider userProvider) {
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
            'Profilo',
            style:TextStyle(
              fontSize: 14, 
              color: Colors.black54,
              fontWeight:FontWeight.w600,
            ),
          ),
          const SizedBox (height:12), 
          
        GestureDetector(
          onTap: () {
            _editUserName(userProvider);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text (
                'Nome Utente',
                style: TextStyle(fontSize:15, color: Colors.black87),
              ),
              Row(
                children: [
                  Text(
                    userProvider.userName,
                    style: const TextStyle(fontSize:15, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.mode_edit_outline_outlined, size:18, color: Colors.black45),
                ],
                ),
            ],
          ),
        ),
        
    const Divider(),

    GestureDetector(
          onTap: () {
            _editPsychologistCode(userProvider);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text (
                'Codice Psicologo',
                style: TextStyle(fontSize:15, color: Colors.black87),
              ),
              Row(
                children: [
                  Text(
                    userProvider.psychologistCode,
                    style: const TextStyle(fontSize:15, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.mode_edit_outline_outlined, size:18, color: Colors.black45),
                ],
                ),
            ],
          ),
        ),
        ],
      ),
    );

  }
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
            value: _shareDataWithPsychologist,
            onChanged: (newValue) {
              setState(() {
                _shareDataWithPsychologist = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider> ();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: AppBar(
        backgroundColor: const Color (0xFFF0FDF9),
        elevation:0, 
        title: const Text (
          'Impostazioni',
          style: TextStyle(
            color:Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      body: ListView(
        padding: const EdgeInsets.all(16), 
        children: [
          _buildProfileCard(userProvider),
          const SizedBox(height:16),
          _buildShareDataCard(),

        ],
      ),
    ) ;
      
    
  }
}