import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newprjct/home.dart';
import 'package:newprjct/password_controller.dart';

import 'forgotPassword.dart';
import 'login_screen.dart';
// Adjust the path as needed

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final userName = TextEditingController();
  final userEmail = TextEditingController();
  final userPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Initialize PasswordController
    final PasswordController passwordController = Get.put(PasswordController());

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  Text('SignUp Page'),
                  SizedBox(height: 100.0),
                  TextField(
                    controller: userName,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.pink, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green, width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: userEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.pink, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green, width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Obx(() {
                    return TextField(
                      controller: userPassword,
                      obscureText: passwordController.obscureText.value,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordController.obscureText.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            passwordController.togglePasswordVisibility();
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.pink, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green, width: 1),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      signUpHere(context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  
                    
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


Future<void> signUpHere(BuildContext context) async {
  final email = userEmail.text.trim();
  final password = userPassword.text.trim();

  // Basic email validation
  if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(email)) {
    Get.snackbar('SignUp', 'Invalid email format');
    return;
  }

  if (email.isEmpty || password.isEmpty) {
    Get.snackbar('SignUp', 'Please enter all fields');
    return;
  }

  try {
    // Check if the email is already in use
    final signInMethods = await firebaseAuth.fetchSignInMethodsForEmail(email);
    
    if (signInMethods.isNotEmpty) {
      // Email is already in use; attempt to sign in
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Get.snackbar('Sign In', 'Signed in successfully');
        Get.to(HomeScreen());
      } on FirebaseAuthException catch (e) {
        Get.snackbar('SignIn Error', 'Failed to sign in: ${e.message}');
        print('SignIn Error: ${e.toString()}');
      } catch (e) {
        Get.snackbar('SignIn Error', 'An unexpected error occurred');
        print('Unexpected SignIn Error: ${e.toString()}');
      }
    } else {
      // Email is not in use; proceed with sign up
      try {
        await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        Get.snackbar('Sign Up', 'Signed up successfully');
        Get.offAll(HomeScreen());
      } on FirebaseAuthException catch (e) {
        Get.snackbar('SignUp Error', 'Failed to sign up: ${e.message}');
        print('SignUp Error: ${e.toString()}');
      } catch (e) {
        Get.snackbar('SignUp Error', 'An unexpected error occurred');
        print('Unexpected SignUp Error: ${e.toString()}');
      }
    }
  } catch (e) {
    Get.snackbar('SignUp Error', 'An unexpected error occurred');
    print('Unexpected Error: ${e.toString()}');
  }
}
}