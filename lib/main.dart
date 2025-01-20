import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importando o Firestore
import 'screens/profile_page.dart';
import 'screens/briefings_page.dart';
import 'screens/ranking_page.dart';
import 'screens/admin_page.dart';
import 'screens/agenda_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';  // Importando a tela de login
import 'screens/register_page.dart';  // Importando a tela de registro
import 'firebase_options.dart';  // Importando a configuração do Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTA Patents',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',  // A rota inicial será a verificação de login
      routes: {
        '/': (context) => AuthWrapper(), // Tela de verificação de login
        '/login': (context) => LoginPage(), // Página de login
        '/register': (context) => RegisterPage(), // Página de registro
        '/home': (context) => BottomNavBar(), // Página de navegação principal (barra de navegação inferior)
      },
    );
  }
}

// Widget para verificar se o usuário está autenticado
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),  // Observa as mudanças no estado de autenticação
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Exibe um indicador de carregamento
        } else if (snapshot.hasData) {
          return BottomNavBar();  // Se o usuário estiver autenticado, exibe a navegação principal
        } else {
          return LoginPage();  // Se o usuário não estiver autenticado, exibe a tela de login
        }
      },
    );
  }
}

// Página de navegação com o menu inferior
class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  bool _isAdmin = false;  // Variável para armazenar se o usuário é administrador
  bool _isLoading = true; // Variável para controlar se a página está carregando

  // Lista de páginas do menu
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkUserRole();  // Verifica o papel do usuário ao inicializar
  }

  // Função para verificar se o usuário é admin
  Future<void> _checkUserRole() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        // Fazendo o cast para Map<String, dynamic>
        var userData = userDoc.data() as Map<String, dynamic>;

        // Verifica se o campo 'role' existe no mapa
        _isAdmin = userData.containsKey('role') && userData['role'] == 'admin';
        _isLoading = false;  // Define o estado de carregamento como falso
      });

      // Atualiza a lista de páginas com ou sem a opção de Administração
      _pages = [
        HomePage(),  // Página inicial (Carteirinha)
        BriefingsPage(),  // Briefings
        RankingPage(),  // Ranking
        if (_isAdmin) AdminPage(),  // Exibe AdminPage apenas se for admin
        AgendaPage(),  // Agenda
      ];
    }
  }
}


  @override
  Widget build(BuildContext context) {
    // Enquanto estamos verificando o papel do usuário, mostramos o indicador de carregamento
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],  // Exibe a página selecionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Carteirinha',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Briefings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Ranking',
          ),
          if (_isAdmin)  // Exibe a opção de Administração apenas se for admin
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Administração',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
        ],
      ),
    );
  }
}
