import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home'); // Redireciona para o menu principal
    } catch (e) {
      print('Erro de login: $e');
      // Aqui você pode adicionar tratamento de erros (ex. exibir mensagem para o usuário)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a cor com base no tema
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // Cor do texto no tema escuro
        : Colors.black; // Cor do texto no tema claro

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/register'); // Redireciona para a página de registro
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza os elementos na tela
          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
          children: [
            // Imagem centralizada
            Center(
              child: Image.asset(
                'assets/images/log.png', // Caminho da imagem
                width: MediaQuery.of(context).size.width * 0.5, // 50% da largura da tela
                height: MediaQuery.of(context).size.height * 0.2, // 20% da altura da tela
                fit: BoxFit.contain, // Mantém a proporção da imagem
              ),
            ),
            SizedBox(height: 40), // Espaço entre a imagem e o texto
            // Texto entre a imagem e os campos de login
            Text(
              'UNIDADE TÁTICA AIRSOFT', // O texto que você deseja exibir
              style: TextStyle(
                fontFamily: 'Rye', // Aplica a fonte Rye
                fontSize: 28, // Tamanho da fonte
                fontWeight: FontWeight.bold,
                color: textColor, // Altera a cor com base no tema
              ),
              textAlign: TextAlign.center, // Alinha o texto no centro
            ),
            SizedBox(height: 40), // Espaço entre o texto e os campos de login
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
