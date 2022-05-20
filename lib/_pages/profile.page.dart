import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mbf/_services/socket_client.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Position? _currentPosition;
  String _currentAddress = "";

  void _logout(){
    print("logging out");
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  @override
  initState(){
    _getCurrentLocation();
    super.initState();
  }



  _getCurrentLocation() async{
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
        print("_current Address $_currentAddress");
      });
    } catch (e) {
      print(e);
    }
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
                      padding: const EdgeInsets.fromLTRB(25, 50, 25, 25),
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
                                children: [
                                  Text("Nafish Ahmed", style: TextStyle( fontSize:20, color: Colors.white, fontWeight: FontWeight.w600),),
                                  Text(_currentAddress!=""?_currentAddress:"Fetching location...", style: TextStyle(fontSize:12,color: Colors.white),),
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
