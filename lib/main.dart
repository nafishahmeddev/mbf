import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mbf/_pages/splace.page.dart';
import 'package:mbf/router.dart';
import 'firebase_options.dart';
import  '_services/socket_client.dart';
import '_pages/root.page.dart';
import '_pages/login.page.dart';

void main(){
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SocketIO.initialize();
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (fbContext, snapshot){
          Widget entryWidget = const SplashPage();
          if (snapshot.hasError) {

          }
          if (snapshot.connectionState == ConnectionState.done) {
            entryWidget = const RootRouter();
          }
          return MaterialApp(
            title: 'MBF',
            theme: ThemeData(
                primarySwatch: Colors.teal,
                fontFamily: 'Jost'
            ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                  primarySwatch: Colors.teal,
                  fontFamily: 'Jost'
                /* dark theme settings */
              ),
              themeMode: ThemeMode.system,
              home: entryWidget
          );
        }
    );
  }
}


