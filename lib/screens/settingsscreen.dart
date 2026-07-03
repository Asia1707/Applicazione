import 'package:flutter/material.dart'; // contiene il widget 
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
@override 
State <SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State <SettingsScreen> {
  Widget _buildProfileCard() {
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
          _buildInfoRow('Nome utente', 'Marco Rossi'), 
          const Divider()
          _buildInfoRow('Codice Psicologo', 'PSI12345'),
        ],
      ),
    );
  }
  Widget _buildInfoRow(String label, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        Row(
          children: [
          Text(
            value, 
            style: const TextStyle(fontSize: 18, color: Colors.black45),
          ),
          const SizedBox(width: 8),
          Icon(MdiIcons.pencilOutline, size: 18, color: Color.black45),
          ],
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
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
          _buildProfileCard(),

        ],
      ),
    ) ;
      
    
  }
}