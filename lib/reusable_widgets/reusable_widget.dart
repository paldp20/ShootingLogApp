import 'package:flutter/material.dart';

// Define the colors here
Color backgroundColor = Color(0xFFE5EAF5);
Color textBoxColor = Color(0xFFD0BDF4);
Color iconColor = Color(0xFF8458B3);
Color fontColor = Color(0xFF25042D);
Color buttonColor = Color(0xFFA0D2EB);

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 200,
    height: 200,
    color: Colors.white,
  );
}

TextField reusableTextField(
    String text, IconData icon, bool isPasswordType, TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: fontColor),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: iconColor),
      labelText: text,
      labelStyle: TextStyle(color: fontColor),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: textBoxColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    keyboardType: isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
  );
}

Container signInSignUpButton(
    BuildContext context,
    bool isLogin,
    Function onTap) {
  return Container(
    width: MediaQuery
        .of(context)
        .size
        .width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'LOG IN' : 'SIGN UP',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    ),
  );
}