import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  DateTime? _selectedDate;
  TabController? _tabController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _updatePoints(String userId, int pointsToAdd) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        int currentPoints = userSnapshot['points'] ?? 0;
        int newPoints = currentPoints + pointsToAdd;

        await userDoc.update({'points': newPoints});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pontos atualizados com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não encontrado.')),
        );
      }
    } catch (e) {
      print('Erro ao atualizar pontos: $e');
    }
  }

  Future<void> _addEvent(String name, String location, String time, DateTime date) async {
    try {
      final newEvent = {
        'name': name,
        'location': location,
        'time': time,
        'date': date,
      };

      await _firestore.collection('events').add(newEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento adicionado com sucesso!')),
      );

      _eventNameController.clear();
      _eventLocationController.clear();
      _eventTimeController.clear();
      setState(() {
        _selectedDate = null;
      });
    } catch (e) {
      print('Erro ao adicionar evento: $e');
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento excluído com sucesso!')),
      );
    } catch (e) {
      print('Erro ao excluir evento: $e');
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> _fetchEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tela de Administração'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Gerenciar Pontos'),
              Tab(text: 'Agendar Eventos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Gerenciar Pontos
            StreamBuilder<List<Map<String, dynamic>>>(
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Alterar Pontos'),
                                    content: TextField(
                                      controller: _pointsController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Pontos a adicionar/remover',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          int pointsToAdd = int.tryParse(_pointsController.text) ?? 0;
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
            // Agendar Eventos
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agendar Novo Evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    TextField(
                      controller: _eventNameController,
                      decoration: InputDecoration(labelText: 'Nome do Evento'),
                    ),
                    TextField(
                      controller: _eventLocationController,
                      decoration: InputDecoration(labelText: 'Localização'),
                    ),
                    TextField(
                      controller: _eventTimeController,
                      decoration: InputDecoration(labelText: 'Hora (HH:mm)'),
                      keyboardType: TextInputType.datetime,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(_selectedDate != null
                            ? 'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                            : 'Selecione uma data'),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _pickDate,
                          child: Text('Escolher Data'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_eventNameController.text.isNotEmpty &&
                            _eventLocationController.text.isNotEmpty &&
                            _eventTimeController.text.isNotEmpty &&
                            _selectedDate != null) {
                          _addEvent(
                            _eventNameController.text,
                            _eventLocationController.text,
                            _eventTimeController.text,
                            _selectedDate!,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Preencha todos os campos!')),
                          );
                        }
                      },
                      child: Text('Salvar Evento'),
                    ),
                    SizedBox(height: 20),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _fetchEvents(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('Nenhum evento encontrado.'));
                        } else {
                          final events = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              var event = events[index];
                              return Card(
                                margin: EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text(event['name']),
                                  subtitle: Text(
                                    '${event['location']} - ${event['time']}\n${DateFormat('dd/MM/yyyy').format(event['date'].toDate())}',
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteEvent(event['id']);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
