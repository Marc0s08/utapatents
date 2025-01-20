import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para usar o TextInputFormatter
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _pointsController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updatePoints(String userId, int pointsToAdd) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        int currentPoints = userSnapshot['points'] ?? 0;
        int newPoints = currentPoints + pointsToAdd;

        // Atualiza ou cria o campo de pontos
        await userDoc.update({'points': newPoints});

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Pontos atualizados com sucesso!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Usuário não encontrado.'),
        ));
      }
    } catch (e) {
      print('Erro ao atualizar pontos: $e');
    }
  }

  // Buscar todos os usuários para exibir na lista
  Stream<List<Map<String, dynamic>>> _fetchUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Administração'),
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
                int currentPoints = user['points'] ?? 0;

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(user['name'] ?? 'Nome não disponível'),
                    subtitle: Text('Pontos: $currentPoints'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Exibir uma caixa de diálogo para adicionar/remover pontos
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Alterar Pontos'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _pointsController,
                                    keyboardType: TextInputType.numberWithOptions(signed: true),
                                    decoration: InputDecoration(
                                      labelText: 'Pontos a adicionar/remover',
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^[\+\-]?\d*$')),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    int pointsToAdd =
                                        int.tryParse(_pointsController.text) ?? 0;

                                    if (pointsToAdd != 0) {
                                      _updatePoints(user['id'], pointsToAdd);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Confirmar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
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
