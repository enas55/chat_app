import 'dart:developer';
import 'dart:typed_data';

import 'package:chat_app/widgets/user_image_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  final _formKey = GlobalKey<FormState>();
  Uint8List? _selectedImage;

  final _firebase = FirebaseAuth.instance;

  void _onSumbit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) {
      if (_selectedImage == null && !_isLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image!')),
        );
      }
      return;
    }
    _formKey.currentState!.save();

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final user = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        var storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.user!.uid}.jpg');

        log('Uploading selected image...');
        await storageRef.putData(_selectedImage!);
        Future.delayed(const Duration(seconds: 3));
        final imageUrl = await storageRef.getDownloadURL();
        log('Uploaded image URL: $imageUrl');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? 'Authintication failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (isValid) {
      _formKey.currentState!.save();
      log(_enteredEmail);
      log(_enteredPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat-png.webp'),
              ),
              Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 30,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            UserImageWidget(
                              onSelectImage: (image) {
                                _selectedImage = image;
                              },
                            ),
                            if (!_isLogin) TextFormField(
                            autocorrect: false,
                            decoration: const InputDecoration(
                              label: Text('Username'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (newValue) {
                              _enteredUsername = newValue!;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length<6
                                  ) {
                                return 'Invalid Username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            autocorrect: false,
                            decoration: const InputDecoration(
                              label: Text('Email'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Invalid Email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Password'),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            onPressed: _onSumbit,
                            child: Text(
                              _isLogin ? 'Login' : 'Sign Up',
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          TextButton(
                            onPressed: () {
                              _isLogin = !_isLogin;
                              setState(() {});
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an account'
                                  : 'I already have an account',
                            ),
                          ),
                        ],
                      ),
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
}
