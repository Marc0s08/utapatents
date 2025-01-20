import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/profile_page.dart';
import 'screens/briefings_page.dart';
import 'screens/ranking_page.dart';
import 'screens/admin_page.dart';
import 'screens/agenda_page.dart';
import 'screens/home_page.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  // Lista de páginas do menu
  final List<Widget> _pages = [
    HomePage(), // Página inicial (Carteirinha)
    BriefingsPage(), // Briefings
    RankingPage(), // Ranking
    AdminPage(), // Administração (controle via Firebase)
    AgendaPage(), // Agenda
  ];

  // Função para desconectar (logout)
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();  // Desconectar do Firebase
    Navigator.pushReplacementNamed(context, '/login');  // Redireciona para a tela de login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UTA Patents'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Chama a função de logout
          ),
        ],
      ),
      body: _pages[_currentIndex], // Exibe a página atual
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
