import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbf/_pages/profile.page.dart';
import 'package:mbf/widgets/navbar.dart';

import 'package:mbf/constants/Theme.dart';
import 'package:mbf/widgets/drawer.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();


}

final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

class _HomePageState extends State<HomePage> {
  GoogleMapController? controller;
  CameraPosition _centerPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 0
  );
  Set<Marker> _markers = <Marker>{};
  Map<String,BitmapDescriptor> _icons = {};
  User? _user;

  void printText (String text) {
    print("hello");
  }
  TextEditingController _emailTextController = TextEditingController();

  @override
  initState(){

    List labels = ["A", "A-", "B","B-", "AB","AB-", "O", "O-"];
    Future<void> op() async {
      Map<String, BitmapDescriptor> icons = {};
      for(String icon in labels) {
        BitmapDescriptor i = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(devicePixelRatio: 3.2),
            "assets/images/markers/$icon.png");
        icons[icon] = i;
      }

      setState((){
        _icons = icons;
      });
    }
    setState((){
      _user = FirebaseAuth.instance.currentUser;
      op();
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark// transparent status bar
    ));
    return Scaffold(
      appBar: Navbar(
        title: "Home",
        searchBar: true,
        categoryOne: "Blood",
        categoryTwo: "Hospital",
        transparent: true,
        tags: [],
        getCurrentPage: printText,
        searchOnChanged: printText,
        searchController: _emailTextController,
      ),
      backgroundColor: NowUIColors.neutralDark,
      // key: _scaffoldKey,
      drawer: NowDrawer(currentPage: "Home"),
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
                mapToolbarEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(13.00, 18.00),
                initialCameraPosition: CameraPosition(
                  target: _centerPosition.target,
                  zoom: _centerPosition.zoom,
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
                      // MaterialButton(
                      //   onPressed: () => _key.currentState!.openDrawer(),
                      //   padding: const EdgeInsets.all(10),
                      //   color: Colors.white,
                      //   shape: const CircleBorder(),
                      //   child: const Icon(Icons.menu, color: Colors.black,),
                      // ),
                      Expanded(child: Container()),
                      MaterialButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  ProfilePage()),
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
                                    Image.network(_user?.photoURL??"https://i.pravatar.cc/300", height: 60, width: 60,),
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
      // drawer:Drawer(
      //     child: ListView(
      //       // Important: Remove any padding from the ListView.
      //       padding: EdgeInsets.zero,
      //       children: [
      //         const DrawerHeader(
      //           decoration: BoxDecoration(
      //             color: Colors.blue,
      //           ),
      //           child: Text('Drawer Header'),
      //         ),
      //         ListTile(
      //           title: const Text('Item 1'),
      //           onTap: () {
      //             // Update the state of the app.
      //             // ...
      //           },
      //         ),
      //         ListTile(
      //           title: const Text('Item 2'),
      //           onTap: () {
      //             // Update the state of the app.
      //             // ...
      //           },
      //         ),
      //       ],
      //     )
      // ),
    );
  }

  String _getRandomMarkerIcon(){
    List icons = ["A", "A-", "B","B-", "AB","AB-", "O", "O-"];
    final random = Random();
    return icons[random.nextInt(icons.length)];
  }

  Future<void> _fetchDonors() async {
    Set<Marker> markers = <Marker>{};
    //http get request
    http.Response response = await http.get(Uri.parse("https://nafish.me/map/?zoom=${_centerPosition.zoom}&latitude=${_centerPosition.target.latitude}&longitude=${_centerPosition.target.longitude}"));
    String body = response.body;
    List locations = jsonDecode(body);
    for(List coordinates in locations){
      markers.add(
          Marker(
            markerId: MarkerId("marker_${coordinates[0]}_${coordinates[1]}"),
            position: LatLng(coordinates[0],coordinates[1]),
            icon: _icons[_getRandomMarkerIcon()]?? await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 3.2), "assets/images/marker.png"),
          )
      );
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
        _centerPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16);
        controller?.animateCamera(CameraUpdate.newCameraPosition(_centerPosition));
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

}
