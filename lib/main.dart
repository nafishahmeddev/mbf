import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mbf/_pages/login.page.dart';
import 'firebase_options.dart';
import '_pages/root.page.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App>{
  bool _isSignedIn = false;
  @override
  void initState(){
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      setState((){
        if (user == null) {
          print('User is currently signed out!');
          _isSignedIn = false;
        } else {
          _isSignedIn = true;
        }


      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'IBMPlexSans'
      ),
      home: _isSignedIn?const RootPage(title: 'Home'): const LoginPage(title: "Login"),
    );
  }
}

