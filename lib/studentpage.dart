import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  StudentPage({required this.studentId, required this.studentName});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  List<dynamic> allEvents = [];
  List<dynamic> studentEvents = [];

  @override
  void initState() {
    super.initState();
    fetchTagEvents();
  }

  Future<void> fetchTagEvents() async {
    final response = await http.get(
        Uri.parse('https://nitcattendify.onrender.com/api/last-10-tag-events'));
    if (response.statusCode == 200) {
      setState(() {
        allEvents = jsonDecode(response.body);
        if (widget.studentId == 'B220623EC') {
          studentEvents = allEvents
              .where((event) => event['tag_id'] == '13ED1D11')
              .toList();
        } else if (widget.studentId == 'B220618EC') {
          studentEvents =
              allEvents.where((event) => event['tag_id'] == '8354E8D').toList();
        }
      });
    } else {
      throw Exception('Failed to load tag events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Page'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome, ${widget.studentName}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: studentEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(studentEvents[index]['tag_id']),
                    subtitle: Text(studentEvents[index]['event_type']),
                    trailing: Text(studentEvents[index]['timestamp']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
