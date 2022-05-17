import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mbf/_pages/login.page.dart';
import 'package:mbf/_pages/root.page.dart';

class RootRouter extends StatefulWidget {
  const RootRouter({Key? key}) : super(key: key);
  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  bool _isSignedIn = false;
  @override
  initState(){
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState((){
        if (user == null) {
          _isSignedIn = false;
        } else {
          _isSignedIn = true;
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return _isSignedIn? const RootPage(title: "Root") : const LoginPage(title: "Page");
  }
}
