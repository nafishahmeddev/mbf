import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mbf/_services/socket_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void checkSock(){
    debugPrint(SocketIO.getInstance().connected.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal,
            elevation: 0,
            toolbarHeight:  0.0
        ),
        body:SingleChildScrollView(
            child: Stack(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(50),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        color: Colors.teal,
                      ),
                      width: double.infinity,
                      child: Center(
                        child: Column(
                          children: [
                            Material(
                                color: Colors.transparent,
                                child: GestureDetector(
                                    onTap: () {},
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(120),
                                        child: Image.network("https://i.pravatar.cc/300", height: 120, width: 120,)
                                    )
                                )
                            ),
                            Text("Nafish Ahmed"),
                            Text("Nafish Ahmed"),
                            ElevatedButton(onPressed: _logout,  child: const Text("Logout",style: TextStyle(color: Colors.white),),),
                            ElevatedButton(onPressed: checkSock,  child: const Text("Logout",style: TextStyle(color: Colors.white),),)
                          ],
                        ),
                      )
                  )
                ]
            )
        )
    );
  }
}
