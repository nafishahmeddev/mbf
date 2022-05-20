import 'dart:math';

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
  LatLng _myLatLong = const LatLng(52.4478, -3.5402);
  Set<Marker> _markers = <Marker>{};

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.001),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.75,
                builder: (_, controller) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.remove,
                          color: Colors.grey[600],
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: controller,
                            itemCount: 100,
                            itemBuilder: (_, index) {
                              return Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Element at index($index)"),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark// transparent status bar
    ));
    return Scaffold(
      key: _key,
      body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child:GoogleMap(
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: _myLatLong,
                          zoom: 15,
                        ),
                        markers: _markers,
                        onMapCreated: _onMapCreated,
                      ),
                    ),
                    Positioned(
                        left: 0,
                        top: 45.0,
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child:Container(
                          height: 60,
                          width: double.infinity,
                          child:    Row(
                            children: [
                              MaterialButton(
                                onPressed: () => _key.currentState!.openDrawer(),
                                child: Icon(Icons.menu, color: Colors.black,),
                                padding: EdgeInsets.all(10),
                                color: Colors.white,
                                shape: const CircleBorder(),
                              ),
                              Expanded(child: Container()),
                              MaterialButton(
                                onPressed: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                                  );
                                },
                                child: Icon(Icons.account_circle, color: Colors.black,),
                                padding: EdgeInsets.all(10),
                                color: Colors.white,
                                shape: const CircleBorder(),
                              )
                            ],
                          ),
                        )
                    ),
                    Positioned(
                        left: 0,
                        bottom: 0,
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        child:Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                          ),
                        )
                    ),
                  ]
              ),
            ),
            Container(
              height: 150,
              color: Theme.of(context).backgroundColor,
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
  void _createMarker() {
    Set<Marker> markers = <Marker>{};
    double random(double mn, double mx) {
      int fraction = 1000000;
      int min = (fraction*mn).toInt();
      int max = (fraction*mx).toInt();
      double randomValue = (min + Random().nextInt(max - min))/fraction;
      print("Random double is => $randomValue");
      return randomValue;
    }
    for(int x=0; x<random(10.00, 60.00).toInt(); x++){
      double lat = _myLatLong.latitude;
      double long = _myLatLong.longitude;
      LatLng ltLng= LatLng(
        random((lat-0.01), (lat+0.01)),
        random((long-0.01), (long+0.01)),
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
      _getCurrentLocation();
    });
  }

  void _getCurrentLocation() async{
    print("fetching location");
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _myLatLong = LatLng(position.latitude, position.longitude);
        controller?.animateCamera(CameraUpdate.newLatLng(_myLatLong));
        _createMarker();
      });
    }).catchError((e) {
      print(e);
    });
  }

}
