import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'studentpage.dart'; // Assuming this is your student page

class ActionPage extends StatefulWidget {
  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  String? _selectedStudent;
  final Map<String, String> studentEmails = {
    'B220623EC': 'abhinav_b220623ec@nitc.ac.in',
    'B220618EC': 'abhay_b220618ec@nitc.ac.in',
  };
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: _getInitialMessage());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _getInitialMessage() {
    return 'Dear student, your attendance is very low. If you miss more classes, you may not be eligible to appear in the Endsem exams.';
  }

  void _viewLogs() {
    if (_selectedStudent != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentPage(
            studentId: _selectedStudent!,
            studentName: _selectedStudent!,
          ),
        ),
      );
    } else {
      // Show snackbar if no student selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a student.'),
        ),
      );
    }
  }

  void _sendWarningMessage(String recipient, String body) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        'subject': 'Attendance Warning',
        'body': body,
      },
    );
    try {
      await launch(emailLaunchUri.toString());
    } catch (e) {
      print('Error launching email: $e');
      // Handle error here, such as showing an error message to the user
    }
  }

  void _showEmailDialog(String recipient, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Warning Message'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('To: $recipient'),
              SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String body = _messageController.text;
                _sendWarningMessage(recipient, body);
                Navigator.of(context).pop();
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStudent,
              onChanged: (value) {
                setState(() {
                  _selectedStudent = value;
                });
              },
              items: studentEmails.keys
                  .map<DropdownMenuItem<String>>(
                    (String studentId) => DropdownMenuItem<String>(
                      value: studentId,
                      child: Text(studentId),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Select Student',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _viewLogs,
              child: Text('View Logs'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedStudent != null) {
                  String? recipient = studentEmails[_selectedStudent!];
                  if (recipient != null) {
                    String body = _messageController.text;
                    _showEmailDialog(recipient, body);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a student.'),
                    ),
                  );
                }
              },
              child: Text('Send Warning Message'),
            ),
          ],
        ),
      ),
    );
  }
}
