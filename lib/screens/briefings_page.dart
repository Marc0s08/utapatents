import 'package:flutter/material.dart';

class BriefingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Briefings'),
      ),
      body: Center(
        child: Text(
          'Aqui você verá os briefings!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
