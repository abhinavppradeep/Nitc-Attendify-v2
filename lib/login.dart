import 'package:flutter/material.dart';
import 'package:nitcattendify/admin.dart';
import 'package:nitcattendify/studentpage.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _selectedRole;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> roles = ['Admin', 'Student'];

  final Map<String, String> studentCredentials = {
    'B220623EC': 'abhinav',
    'B220618EC': 'abhay',
  };

  final String adminUsername = 'admin';
  final String adminPassword = 'admin@nitc';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  value: _selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  items: roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _handleLogin();
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (_selectedRole == null || username.isEmpty || password.isEmpty) {
      _showErrorMessage('Please fill in all fields.');
      return;
    }

    if (_selectedRole == 'Admin') {
      if (username == adminUsername && password == adminPassword) {
        // Navigate to admin page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        _showErrorMessage('Invalid credentials for admin.');
      }
    } else if (_selectedRole == 'Student') {
      if (studentCredentials.containsKey(username) &&
          studentCredentials[username] == password) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentPage(
              studentId: username,
              studentName: username == 'B220623EC' ? 'Abhinav' : 'Abhay',
            ),
          ),
        );
      } else {
        _showErrorMessage('Invalid credentials for student.');
      }
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
