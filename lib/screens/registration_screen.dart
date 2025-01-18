import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_starting_project/components/rounded_button.dart';
import 'package:flash_chat_starting_project/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import '/constants.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwoedController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  var auth = FirebaseAuth.instance;
  String erroeMessage = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //******************************************************  13.1
            Hero(
              tag: 'logo',
              child: SizedBox(
                height: 200,
                child: Image.asset('images/logo.png'),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your email', labelText: 'Email'),
                    controller: _emailController,
                    //*****
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) {
                      return email != null && EmailValidator.validate(email)
                          ? null
                          : 'please enter a valid email';
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your password', labelText: 'password'),
                    obscureText: true,
                    controller: _passwoedController,
                    //******************
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (password) {
                      return password != null && password.length > 5
                          ? null
                          : 'the password should be of 6 characters at least';
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24.0,
            ),
            Text(
              erroeMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            RoundedButton(
                color: kRegisterButtonColor,
                title: 'Register',
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    try {
                      auth
                          .createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwoedController.text,
                      )
                          .then((onValue) {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, ChatScreen.id);
                      });
                    } catch (e) {
                      print('error ${e.toString()}');
                      setState(() {
                        erroeMessage = e.toString().split(']')[1];
                      });
                    }
                  }
                }),
            const SizedBox(height: 12),

            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
