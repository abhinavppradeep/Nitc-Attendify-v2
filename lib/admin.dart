import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nitcattendify/action.dart';
import 'package:nitcattendify/login.dart';
import 'package:nitcattendify/fulllog.dart';
import 'package:nitcattendify/profile.dart'; // Assuming Fulllog.dart contains the full log page

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    final response =
        await http.get(Uri.parse('https://nitc-attendify-v2.onrender.com/api/last-10-attendance'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _logs = data.cast<Map<String, dynamic>>();
        _filteredLogs = List.from(_logs); // Initialize filtered logs with all logs
        _filteredLogs.sort((a, b) => a['name'].compareTo(b['name'])); // Sort logs by name
      });
    } else {
      print('Failed to load logs');
    }
  }

  int _binarySearch(List<Map<String, dynamic>> list, String searchTerm) {
    int low = 0;
    int high = list.length - 1;

    while (low <= high) {
      int mid = low + ((high - low) ~/ 2);
      String name = list[mid]['name'].toString().toLowerCase();

      if (name.contains(searchTerm.toLowerCase())) {
        return mid; // Found the name
      } else if (name.compareTo(searchTerm.toLowerCase()) < 0) {
        low = mid + 1; // Search the right half
      } else {
        high = mid - 1; // Search the left half
      }
    }

    return -1; // Name not found
  }

  void _searchByName(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredLogs = List.from(_logs); // Reset filtered logs if search term is empty
      } else {
        int index = _binarySearch(_logs, searchTerm); // Use _logs instead of _filteredLogs for search
        if (index != -1) {
          _filteredLogs = [_logs[index]]; // Set _filteredLogs with the found item
        } else {
          _filteredLogs = []; // No matching name found
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Last 10 Tag Events'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchByName(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(tagId: log['id']),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                'Name: ${log['name']}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text(
                                    'Tag ID: ${log['id']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Event Type: ${log['action']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Timestamp: ${log['time']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActionPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _fetchLogs(); // Refresh logs when refresh button is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Fulllog(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminPage(),
  ));
}
