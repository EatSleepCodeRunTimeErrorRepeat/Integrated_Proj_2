import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    final res = await http.post(
      Uri.parse(
          'http://192.168.1.33:3000/register'), // or 10.0.2.2 for emulator
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _email.text.trim(),
        'password': _pass.text.trim(),
      }),
    );

    print('STATUS: ${res.statusCode}');
    print('BODY: ${res.body}');

    if (res.statusCode == 200) {
      final responseData = json.decode(res.body);
      if (responseData['success'] == true) {
        Navigator.pushNamed(context, '/selection');
      } else {
        setState(() {
          _message = responseData['message'] ?? 'Registration failed';
        });
      }
    } else {
      setState(() {
        _message = 'Registration failed (status ${res.statusCode})';
      });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
            const SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
