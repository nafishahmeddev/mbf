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
  final PageController _controller = PageController();

  @override
  initState(){
    super.initState();
  }
  void _onPageChanged(int index) {
    setState((){
      _selectedIndex  = index;
    });
    _controller.jumpToPage(index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: const [
          HomePage(title: "Profile"),
          Text('Index 1: Business',),
          Text('Index 2: School',),
          ProfilePage(title: 'Index 3: Settings',),
        ],
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
        type: BottomNavigationBarType.fixed,
        onTap: _onPageChanged,
      ),
    );
  }
}
