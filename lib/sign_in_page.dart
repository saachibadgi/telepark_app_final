import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart'; // Import your sign-in logic here
import 'auth_service.dart';


class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await signInWithGoogle();
            if (user != null) {
              print("Signed in as: ${user.displayName}");
              // Here, you can navigate to another screen after sign-in
            }
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
