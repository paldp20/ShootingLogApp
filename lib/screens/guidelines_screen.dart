import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'home_screen.dart';

class GuidelinesScreen extends StatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  State<GuidelinesScreen> createState() => _GuidelinesScreenState();
}

class _GuidelinesScreenState extends State<GuidelinesScreen> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guidelines', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFF8458B3), // Background color of the app bar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              color: Color(0xFFA0D2EB), // Background color of the card
              child: Column(
                children: <Widget>[
                  _buildGuideline("Always keep the gun pointed in a safe direction towards the target, down the range."),
                  _buildGuideline("ALWAYS keep your finger off the trigger until ready to shoot."),
                  _buildGuideline("Only fire when the Range Officer says, 'Commence Fire' and stop immediately when ordered 'Cease Fire'."),
                  _buildGuideline("When not shooting, always insert a safety flag in the chamber of your gun."),
                  _buildGuideline("Do not touch or operate any other shooter's firearm without their explicit permission."),
                  _buildGuideline("USE ONLY THE CORRECT AMMUNITION FOR YOUR GUN."),
                  _buildGuideline("Do not disturb shooters when shooting or create any nuisance on the shooting range."),
                  _buildGuideline("NEVER USE ALCOHOL OR DRUGS BEFORE OR WHILE SHOOTING."),
                ],
              ),
            ),
            CheckboxListTile(
              title: Text("I agree to follow the guidelines", style: TextStyle(color: Colors.black)),
              value: _isAccepted ?? false, // Use the null-aware operator to provide a default value
              onChanged: (value) {
                setState(() {
                  _isAccepted = value ?? false; // Use the null-aware operator to provide a default value
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              checkColor: Colors.white,
              activeColor: Color(0xFF8458B3), // Checkbox color when selected
            ),
            ElevatedButton(
              onPressed: () {
                if (_isAccepted) {
                  // Navigate to the home screen when the checkbox is checked
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                } else {
                  // Show a toast when the checkbox is not checked
                  Fluttertoast.showToast(
                    msg: "Please accept the guidelines policies",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              child: Text("Continue"),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFE5EAF5), // Button color
                textStyle: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return ListTile(
      title: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}

