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

  // Define as faixas de pontos para as patentes
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
    for (var rank in rankRanges.keys) {
      if (points >= rankRanges[rank]!['min']! && points <= rankRanges[rank]!['max']!) {
        return rank;
      }
    }
    return 'Recruta'; // Se nenhum rank corresponder, retorna "Recruta"
  }

  String getNextRank(int points) {
    List<String> ranks = rankRanges.keys.toList();

    // Se o usuário estiver no maior rank, a próxima patente será o primeiro rank
    if (points >= rankRanges[ranks.first]!['min']!) {
      return 'Marechal'; // O maior rank
    }

    // Itera pelas patentes para encontrar a próxima
    for (int i = 0; i < ranks.length; i++) {
      if (points >= rankRanges[ranks[i]]!['min']! && points < rankRanges[ranks[i]]!['max']!) {
        // A próxima patente será a seguinte na lista
        return i + 1 < ranks.length ? ranks[i + 1] : ranks[i];
      }
    }
    return 'Recruta'; // Caso não caia em nenhum rank, retorna "Recruta"
  }

  @override
  Widget build(BuildContext context) {
    int points = userData?['points'] ?? 0; // Obtém os pontos do usuário (caso não tenha, define como 0)
    String currentRank = getCurrentRank(points);
    String nextRank = getNextRank(points);

    // Calcula a barra de progresso com base na patente atual
    double progress = 0.0;
    int rankMin = rankRanges[currentRank]!['min']!;
    int rankMax = rankRanges[currentRank]!['max']!;
    if (rankMax > rankMin) {
      progress = (points - rankMin) / (rankMax - rankMin); // Calcula a porcentagem dentro da faixa da patente
    }

    // Limita o progresso para não ultrapassar 1
    progress = progress > 1 ? 1 : progress;

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
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                    // Foto de perfil
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: userData!['photoURL'] != null
                          ? Image.network(
                              userData!['photoURL'],
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
                    // Nome do operador
                    Text(
                      userData!['name'] ?? 'Nome não disponível',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Classe do operador
                    Text(
                      'Classe: ${userData!['class'] ?? 'Classe não definida'}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Data de nascimento
                    Text(
                      'Data de Nascimento: ${userData!['dob'] ?? 'Data de nascimento não disponível'}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Email
                    Text(
                      'Email: ${user?.email ?? 'Email não disponível'}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Barra de progresso e patente
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.orangeAccent,
                      minHeight: 10,
                    ),
                    SizedBox(height: 10),
                    // Exibindo patente atual e próxima com destaque
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
                    // Botão de Sair com animação
                    ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.redAccent, // Corrigido de 'primary' para 'backgroundColor'
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 5,
  ),
  onPressed: () {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  },
  child: Text(
    'Sair',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),

                  ],
                ),
              ),
            ),
    );
  }
}
