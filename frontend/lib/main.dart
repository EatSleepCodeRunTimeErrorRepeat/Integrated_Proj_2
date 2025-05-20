import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: RegisterPage()));

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    final res = await http.post(
      Uri.parse('http://192.168.56.12:3000/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': _email.text, 'password': _pass.text}),
    );
    setState(() => _message = res.body);
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(title: Text('Register')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _email, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _pass, decoration: InputDecoration(labelText: 'Password')),
            ElevatedButton(onPressed: _register, child: Text('Register')),
            SizedBox(height: 20),
            Text(_message),
          ]),
        ),
      );
}