import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticação Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController(); // Data de nascimento
  String? _selectedClass; // Classe selecionada

  // Lista de opções de classes
  final List<String> classes = ['ASSAULT', 'D.M.R.', 'SNIPER', 'SUPPORT'];

  Future<void> _register(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      // Se as senhas não forem iguais
      print('As senhas não coincidem!');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Após o registro, salva os dados no Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': _nameController.text,
        'dob': _dobController.text,
        'class': _selectedClass,
        'email': _emailController.text,
      });

      // Após o registro e salvamento, navega para a tela de perfil
      Navigator.pushReplacementNamed(context, '/profile');
    } on FirebaseAuthException catch (e) {
      // Trate erros, como email já em uso
      print("Erro de cadastro: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome do Operador'),
              ),
              TextField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Data de Nascimento'),
                keyboardType: TextInputType.datetime, // Para data
              ),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                hint: Text('Selecione a Classe'),
                items: classes.map((String classOption) {
                  return DropdownMenuItem<String>(
                    value: classOption,
                    child: Text(classOption),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedClass = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Classe',
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress, // Para email
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirmar Senha'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _register(context),
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
