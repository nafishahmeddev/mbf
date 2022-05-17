import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                        child: Stack(
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
                            )
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
