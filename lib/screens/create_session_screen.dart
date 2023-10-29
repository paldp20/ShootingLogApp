import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({Key? key}) : super(key: key);

  @override
  _CreateSessionScreenState createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final TextEditingController _sessionDateController = TextEditingController();
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _numShotsController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _showToast(String message, {bool success = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: success ? Colors.green : Colors.red,
      textColor: Colors.white,
    );
  }

  void _submitSessionData() {
    if (_formKey.currentState!.validate()) {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');
        final String userId = user.uid;

        final Map<String, dynamic> sessionData = {
          'sessionDate': Timestamp.fromDate(DateTime.parse(_sessionDateController.text)),
          'sessionName': _sessionNameController.text,
          'numShots': int.tryParse(_numShotsController.text) ?? 0,
          'score': int.tryParse(_scoreController.text) ?? 0,
          'notes': _notesController.text,
        };

        userCollection.doc(userId).collection('sessions').add(sessionData).then((value) {
          _showToast('Session data added successfully', success: true);

          // After successfully adding a session, navigate back to the previous screen (HomeScreen).
          Navigator.of(context).pop();
        }).catchError((error) {
          _showToast('Failed to add session data');
        });
      } else {
        _showToast('User not logged in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Enter your performance now!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _reusableDateField("Session Date", Icons.date_range, _sessionDateController, context: context),
              SizedBox(height: 20),
              _reusableTextField("Session Name", Icons.title, _sessionNameController),
              SizedBox(height: 20),
              _reusableTextField("Number of Shots", Icons.sports_handball, _numShotsController, keyboardType: TextInputType.number),
              SizedBox(height: 20),
              _reusableTextField("Score", Icons.score, _scoreController, keyboardType: TextInputType.number),
              SizedBox(height: 20),
              _reusableTextField("Notes", Icons.notes, _notesController),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                child: ElevatedButton(
                  onPressed: _submitSessionData,
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Widgets
  TextFormField _reusableTextField(
      String text,
      IconData icon,
      TextEditingController controller, {
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Color(0xFF25042D)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF8458B3)),
        labelText: text,
        labelStyle: TextStyle(color: Colors.blue),
        filled: true,
        fillColor: Colors.blue.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $text';
        }
        return null;
      },
    );
  }

  TextFormField _reusableDateField(
      String text,
      IconData icon,
      TextEditingController controller, {
        BuildContext? context,
      }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Color(0xFF25042D)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF8458B3)),
        labelText: text,
        labelStyle: TextStyle(color: Colors.blue),
        filled: true,
        fillColor: Colors.blue.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      readOnly: true,
      onTap: () {
        showDatePicker(
          context: context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ).then((pickedDate) {
          if (pickedDate != null) {
            controller.text = pickedDate.toLocal().toString().split(' ')[0];
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $text';
        }
        return null;
      },
    );
  }
}
