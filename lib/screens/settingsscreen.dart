import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _shareDataWithPsychologist = true;

  void _editUserName(UserProvider userProvider) {
    final controller = TextEditingController(text: userProvider.userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica nome utente'),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annulla'),
            ),
            TextButton(
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

  Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
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
                style: const TextStyle(fontSize: 15, color: Colors.black45),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, size: 18, color: Colors.black45),
            ],
          ),
        ],
      ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Nome utente: modificabile con dialogo
          _buildInfoRow('Nome utente', userProvider.userName, () {
            _editUserName(userProvider);
          }),

          const Divider(),

          // Codice Psicologo: SOLA LETTURA, arriva dal Login
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

  Widget _buildProgressCard() {
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
              const Text(
                '15',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_outlined, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Streak migliore',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
              const Text(
                '12 giorni',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              const Spacer(),
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
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF9),
        elevation: 0,
        title: const Text(
          'Impostazioni',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(userProvider),
          const SizedBox(height: 16),
          _buildProgressCard(),
          const SizedBox(height: 16),
          _buildTargetCard(),
          const SizedBox(height: 16),
          _buildShareDataCard(),
        ],
      ),
    );
  }
}