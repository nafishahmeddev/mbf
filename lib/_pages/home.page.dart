import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbf/_pages/profile.page.dart';
import 'package:mbf/_classes/coordinate.dart';

import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();


}

final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

class _HomePageState extends State<HomePage> {
  GoogleMapController? controller;
  CameraPosition _myLocation = const CameraPosition(target: LatLng(0, 0), zoom: 0);
  Set<Marker> _markers = <Marker>{};
  Map<String,BitmapDescriptor> _icons = {};

  void printText (String text) {
    print("hello");
  }
  TextEditingController _emailTextController = TextEditingController();

  @override
  initState(){
    super.initState();
    /*
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark// transparent status bar
    ));

     */
    _loadIcons();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: NowDrawer(currentPage: "/profile"),
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
                minMaxZoomPreference: const MinMaxZoomPreference(15.00, 18.00),
                initialCameraPosition: CameraPosition(
                  target: _myLocation.target,
                  zoom: _myLocation.zoom,
                ),
                markers: _markers,
                onMapCreated: _onMapCreated,
                onCameraIdle: _fetchDonors,
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
              bottom: 25,
              width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).cardColor,
                          ),
                          width: 280,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: (){
                                              print("Container clicked");
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.bloodtype),
                                                  SizedBox(width: 10,),
                                                  Text("Blood")
                                                ],
                                              ),
                                            )
                                        ),
                                      )
                                  ),
                                  Container(height: 46, width: 25, color: Colors.white,),
                                  Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: (){
                                              print("Container clicked");
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.local_hospital),
                                                  SizedBox(width: 10,),
                                                  Text("Hospital")
                                                ],
                                              ),
                                            )
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ],
                          )
                      ),
                    ]
                )

            ),
            Positioned(
                bottom: 18,
                left: 0,
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _getMyLocation,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          primary: Colors.white, // <-- Button color
                          onPrimary: Colors.black12, // <-- Splash color
                        ),
                        child: const Icon(Icons.my_location, color: Colors.black,),
                      )
                    ]
                )
            )
          ]
      ),
    );
  }
  @override
  dispose(){
    controller?.dispose();
    super.dispose();
  }
  void _loadIcons(){
    List<String> iconNames = ["A", "A-", "B-", "AB", "AB-", "O", "O-"];
    for(String iconName in iconNames){
      BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(devicePixelRatio: 3.2), 'assets/images/markers/$iconName.png')
          .then((onValue) {
            setState((){
              _icons[iconName] = onValue;
            });
      });
    }
  }
  String _getRandomIconName(){
    List<String> iconNames = ["A", "A-", "B-", "AB", "AB-", "O", "O-"];
    final random = Random();
    return iconNames[random.nextInt(iconNames.length)];
  }
  void _fetchDonors() async {
    Set<Marker> markers = <Marker>{};
    LatLngBounds visibleRegion = await controller!.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );

    //http get request
    String url = "https://nafish.me/map/?zoom=${await controller!.getZoomLevel()}&latitude=${centerLatLng.latitude}&longitude=${centerLatLng.longitude}";
    http.Response response = await http.get(Uri.parse(url));
    List<dynamic> locations = json.decode(response.body);


    for(dynamic point in locations){
      Coordinate coordinate = Coordinate.fromJson(point);
      markers.add(
          Marker(
            markerId: MarkerId("marker_${coordinate.latitude}_${coordinate.longitude}"),
            position: LatLng(coordinate.latitude,coordinate.longitude),
            icon: _icons[_getRandomIconName()]?? await BitmapDescriptor.fromAssetImage(ImageConfiguration(), "assets/images/marker.png")
          )
      );
    }
    setState((){
      _markers=markers;
    });
  }

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
    _getMyLocation();
  }
  void _getMyLocation() async{
    debugPrint("fetching location");
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _myLocation = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16);
        controller?.animateCamera(CameraUpdate.newCameraPosition(_myLocation));
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }


}
