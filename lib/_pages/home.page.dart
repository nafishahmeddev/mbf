import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbf/_pages/profile.page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();


}

final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

class _HomePageState extends State<HomePage> {
  GoogleMapController? controller;
  BitmapDescriptor? _markerIcon;
  CameraPosition _centerPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 15
  );
  Set<Marker> _markers = <Marker>{};
  User? _user;
  @override
  initState(){
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 3.2),
        'assets/images/marker.png')
        .then((d) {
          print("Bitmap $d");
          setState((){
            _markerIcon = d;
            _user = FirebaseAuth.instance.currentUser;
          });

    });

  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark// transparent status bar
    ));
    return Scaffold(
      key: _key,
      body: Stack(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child:GoogleMap(
                mapType: MapType.terrain,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _centerPosition.target,
                  zoom: 15,
                ),
                markers: _markers,
                onMapCreated: _onMapCreated,

                onCameraMove: (CameraPosition position){
                  setState((){
                    _centerPosition = position;
                  });
                },
                onCameraIdle: (){
                  _fetchDonors();
                },
              ),
            ),
            Positioned(
                left: 0,
                top: 45.0,
                height: 60,
                width: MediaQuery.of(context).size.width,
                child:SizedBox(
                  height: 60,
                  width: double.infinity,
                  child:    Row(
                    children: [
                      MaterialButton(
                        onPressed: () => _key.currentState!.openDrawer(),
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.menu, color: Colors.black,),
                      ),
                      Expanded(child: Container()),
                      MaterialButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfilePage()),
                          );
                        },
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.person, color: Colors.black,),
                      )
                    ],
                  ),
                )
            ),
            Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              child:
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(120),
                                    child:
                                    Image.network("https://i.pravatar.cc/300", height: 60, width: 60,),
                                  ),
                                  const SizedBox(width: 15,),
                                  Expanded(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Hi! ${_user?.displayName??""}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                          Text("${_user?.email??""}"),
                                        ]
                                    ),
                                  ),
                                  IconButton(onPressed: _fetchMyLocation, icon: Icon(Icons.my_location))
                                ],
                              ),
                            )
                          ],
                        )
                    ),
                )
            )
          ]
      ),
      drawer:Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          )
      ),
    );
  }
  void _fetchDonors() {
    double zoom = _centerPosition.zoom;
    double range = ((40000/pow(2, zoom)) * 2)/((150*2));
    Set<Marker> markers = <Marker>{};
    double random(double mn, double mx) {
      int fraction = 1000000;
      int min = (fraction*mn).toInt();
      int max = (fraction*mx).toInt();
      double randomValue = (min + Random().nextInt(max - min))/fraction;
      return randomValue;
    }
    for(int x=0; x<random(10.00, 50.00).toInt(); x++){
      double lat = _centerPosition.target.latitude;
      double long = _centerPosition.target.longitude;
      LatLng ltLng= LatLng(
        random((lat-range), (lat+range)),
        random((long-range), (long+range)),
      );
      if (_markerIcon != null) {
        markers.add(Marker(
          markerId: MarkerId('marker_$x'),
          position: ltLng,
          icon: _markerIcon!,
        ));
      } else {
        markers.add(Marker(
          markerId: MarkerId('marker_$x'),
          position: ltLng,
        ));
      }
    }
    setState((){
      _markers = markers;
    });
  }
  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
      _fetchMyLocation();
    });
  }
  void _fetchMyLocation() async{
    debugPrint("fetching location");
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _centerPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 15);
        controller?.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

}
