import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Fulllog extends StatefulWidget {
  @override
  _FulllogState createState() => _FulllogState();
}

class _FulllogState extends State<Fulllog> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

 Future<void> _fetchLogs() async {
  final response = await http.get(Uri.parse('https://nitc-attendify-v2.onrender.com/api/attendance'));
  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    setState(() {
      _logs = List<Map<String, dynamic>>.from(responseData.map((log) {
        return {
          'name': log['name'], // Correctly access 'name' from the response
          'tag_id': log['id'],
          'event_type': log['action'],
          'timestamp': log['time'],
        };
      }));
    });
  } else {
    print('Failed to load logs');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Logs'),
      ),
      body: _logs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${log['name']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tag ID: ${log['tag_id']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Event Type: ${log['event_type']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Timestamp: ${DateTime.parse(log['timestamp']).toString()}',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Fulllog(),
  ));
}
