import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _eventsByDay = {};

  /// Método para buscar todos os eventos do Firestore e organizá-los por dia
  Future<void> _fetchAllEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .get();

    Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime date = (data['date'] as Timestamp).toDate();

      DateTime day = DateTime(date.year, date.month, date.day);
      if (!events.containsKey(day)) {
        events[day] = [];
      }
      events[day]!.add({'id': doc.id, ...data});
    }

    setState(() {
      _eventsByDay = events;
    });
  }

  /// Função para carregar eventos para um dia específico
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _eventsByDay[DateTime(day.year, day.month, day.day)] ?? [];
  }

  /// Método para buscar eventos do Firestore para o dia selecionado
  Stream<List<Map<String, dynamic>>> _fetchEventsForDay(DateTime day) {
    DateTime startOfDay = DateTime(day.year, day.month, day.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Adicionar evento (implementado anteriormente)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => _getEventsForDay(day),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchEventsForDay(_selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhum evento para este dia.'));
                } else {
                  final events = snapshot.data!;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(event['name']),
                        subtitle:
                            Text('${event['location']} às ${event['time']}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
