import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para buscar os dados dos usuários e ordená-los pelos pontos
  Stream<List<Map<String, dynamic>>> _fetchUsers() {
    return _firestore.collection('users').orderBy('points', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    });
  }

  // Função para calcular a patente do usuário com base nos pontos
  String getRank(int points) {
    if (points >= 1000) return 'Marechal';
    if (points >= 801) return 'General';
    if (points >= 701) return 'Coronel';
    if (points >= 601) return 'Comandante';
    if (points >= 501) return 'Capitão';
    if (points >= 401) return 'Tenente';
    if (points >= 201) return 'Sargento';
    if (points >= 51) return 'Soldado';
    if (points >= 1) return 'Aspirante';
    return 'Recruta';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum usuário encontrado.'));
          } else {
            final users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                int points = user['points'] ?? 0;
                String rank = getRank(points);

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nome e patente
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'] ?? 'Nome não disponível', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Patente: $rank'),
                          ],
                        ),
                        // Pontos
                        Text('$points pontos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    onTap: () {
                      // Ao clicar, exibe a carteirinha do usuário
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/multicam_black.jpg'), // Caminho do fundo
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nome do usuário
                                  Text(
                                    user['name'] ?? 'Nome não disponível',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Contraste com o fundo
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // Informações adicionais
                                  Text(
                                    'Classe: ${user['class'] ?? 'Classe não definida'}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    'Data de Nascimento: ${user['dob'] ?? 'Data de nascimento não disponível'}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    'Patente: $rank',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  // Foto de perfil
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: user['photoURL'] != null
                                          ? Image.network(
                                              user['photoURL'],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
