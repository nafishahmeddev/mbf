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
    Color color = Theme.of(context).primaryColor;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: color,
            elevation: 0,
            toolbarHeight:  0.0
        ),
        body:SingleChildScrollView(
            child: Stack(
                children: <Widget>[

                  Container(
                      padding: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                        color: color,
                      ),
                    width: double.infinity,
                    child:
                    Center(
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
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: const [
                                  Text("Nafish Ahmed", style: TextStyle( fontSize:20, color: Colors.white, fontWeight: FontWeight.w600),),
                                  Text("Berhampore, Murshidabad", style: TextStyle(fontSize:12,color: Colors.white),),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top:0.0,
                    right: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          icon: const Icon(Icons.logout,color: Colors.white,),
                          onPressed: _logout
                      ),
                    ),
                  ),
                ]
            )
        )
    );
  }
}
