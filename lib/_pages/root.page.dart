import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mbf/_pages/profile.page.dart';

import 'home.page.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(title: "Profile"),
    Text('Index 1: Business',),
    Text('Index 2: School',),
    ProfilePage(title: 'Index 3: Settings',),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /*
      appBar: AppBar(
        title: Center(child: Text(widget.title, textAlign: TextAlign.center)),
        elevation: 0,
      ),

       */
      body:  _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        //selectedItemColor: Colors.amber[800],
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
