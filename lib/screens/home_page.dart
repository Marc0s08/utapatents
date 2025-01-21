import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  final List<String> ranks = [
    'Recruta',
    'Aspirante',
    'Soldado',
    'Sargento',
    'Tenente',
    'Capitão',
    'Comandante',
    'Coronel',
    'General',
    'Marechal'
  ];

  final Map<String, Map<String, int>> rankRanges = {
    'Marechal': {'min': 1000, 'max': 10000},
    'General': {'min': 801, 'max': 999},
    'Coronel': {'min': 701, 'max': 800},
    'Comandante': {'min': 601, 'max': 700},
    'Capitão': {'min': 501, 'max': 600},
    'Tenente': {'min': 401, 'max': 500},
    'Sargento': {'min': 201, 'max': 400},
    'Soldado': {'min': 51, 'max': 200},
    'Aspirante': {'min': 1, 'max': 50},
    'Recruta': {'min': 0, 'max': 0},
  };

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      } catch (e) {
        print('Erro ao buscar os dados do Firestore: $e');
      }
    }
  }

  String getCurrentRank(int points) {
    for (var rank in ranks) {
      if (points >= rankRanges[rank]!['min']! && points <= rankRanges[rank]!['max']!) {
        return rank;
      }
    }
    return 'Recruta';
  }

  String getNextRank(int points) {
    String currentRank = getCurrentRank(points);
    int currentRankIndex = ranks.indexOf(currentRank);

    // Verifica se já estamos na última patente
    if (currentRankIndex == ranks.length - 1) {
      return ranks[currentRankIndex]; // Última patente, não há próxima
    }

    // Retorna a próxima patente na lista
    return ranks[currentRankIndex + 1];
  }

  @override
  Widget build(BuildContext context) {
    int points = userData?['points'] ?? 0;
    String currentRank = getCurrentRank(points);
    String nextRank = getNextRank(points);

    // Obtém os valores mínimo e máximo de pontos da patente atual
    int rankMin = rankRanges[currentRank]!['min']!;
    int rankMax = rankRanges[currentRank]!['max']!;
    
    double progress = 0.0;

    // Se o ponto máximo da patente for maior que o mínimo
    if (rankMax > rankMin) {
      // Calcula a porcentagem de progresso do usuário dentro do intervalo da patente
      progress = (points - rankMin) / (rankMax - rankMin);
      
      // Garante que o valor da barra não ultrapasse 1.0 (100%)
      if (progress > 1.0) {
        progress = 1.0;
      }
      // Garante que o valor da barra não seja menor que 0
      else if (progress < 0.0) {
        progress = 0.0;
      }
    } else {
      // Se o ponto máximo for igual ao mínimo (Recruta), a barra fica em 0
      progress = 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Carteirinha do Operador'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: userData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/multicam_black.jpg'), // Adicione a imagem no diretório assets/images/
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                width: 350,
                height: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: userData!['profile_picture'] != null
                          ? Image.network(
                              userData!['profile_picture'], // Campo correto para a foto de perfil
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.person,
                              size: 120,
                              color: Colors.white70,
                            ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      userData!['name'] ?? 'Nome não disponível',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Classe: ${userData!['class'] ?? 'Classe não definida'}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Data de Nascimento: ${userData!['dob'] ?? 'Data de nascimento não disponível'}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.orangeAccent,
                      minHeight: 10,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Patente Atual: $currentRank',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Próxima Patente: $nextRank',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
    );
  }
}
