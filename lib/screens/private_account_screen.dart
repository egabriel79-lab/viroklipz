import 'package:flutter/material.dart';

class PrivateAccountScreen extends StatefulWidget {
  const PrivateAccountScreen({super.key});

  @override
  State<PrivateAccountScreen> createState() => _PrivateAccountScreenState();
}

class _PrivateAccountScreenState extends State<PrivateAccountScreen> {
  bool _isPrivate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cuenta privada',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            value: _isPrivate,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF25F4EE),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[700],
            onChanged: (value) {
              setState(() => _isPrivate = value);
            },
            title: const Text(
              'Cuenta privada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Con una cuenta privada, solo los usuarios que apruebes podrán seguirte y ver tus videos. Esto no afectará a tus seguidores actuales.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}