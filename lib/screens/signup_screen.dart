import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shooting_log_flutter/screens/guidelines_screen.dart';
import 'package:shooting_log_flutter/screens/home_screen.dart';
import '../reusable_widgets/reusable_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFFA0D2EB),
            Color(0xFF8458B3),
            Color(0xFF25042D)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter UserName", Icons.person_outline, false, _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Email Id", Icons.person_3_outlined, false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true, _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    final userName = _userNameTextController.text.trim();
                    final email = _emailTextController.text.trim();
                    final password = _passwordTextController.text;

                    if (userName.isEmpty || email.isEmpty || password.isEmpty) {
                      _showErrorToast("Please fill in all fields.");
                    } else if (userName.length < 5 || userName.length > 30 || userName.contains(' ')) {
                      _showErrorToast("Invalid username (max length 50 and min length 5).");
                    } else if (password.length < 8 || password.length > 30 || password.contains(' ')) {
                      _showErrorToast("Invalid password (max length 50 and min length 8).");
                    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email)) {
                      _showErrorToast("Invalid email format.");
                    } else {
                      _signUp(email, password, userName);
                    }
                  },
                  child: Text("Sign Up"),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFE5EAF5),
                    textStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _signUp(String email, String password, String username) {
    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) {
      // Save the username to Firestore when the user signs up.
      _saveUsernameToFirestore(value.user?.uid, username);

      _showSuccessToast("Account created successfully!");
      Navigator.push(context, MaterialPageRoute(builder: (context) => GuidelinesScreen()));
    }).onError((error, stackTrace) {
      _showErrorToast("Error: ${error.toString()}");
    });
  }

  void _saveUsernameToFirestore(String? userId, String username) {
    if (userId != null) {
      FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
      });
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}
