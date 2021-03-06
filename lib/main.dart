import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:mbf/_pages/bloodRequestDetails.page.dart';
import 'package:mbf/_pages/bloodRequests.page.dart';
import 'package:mbf/_pages/donorDetails.page.dart';
import 'package:mbf/_pages/donors.page.dart';
import 'package:mbf/_pages/editProfile.page.dart';
import 'package:mbf/_pages/login.page.dart';
import 'package:mbf/_pages/newBloodRequest.page.dart';
import 'package:mbf/_pages/profile.page.dart';
import 'package:mbf/_pages/signup.page.dart';

import 'package:mbf/_pages/splace.page.dart';
import 'package:mbf/router.dart';
import 'firebase_options.dart';

import  '_services/socket_client.dart';
const fetchBackground = "fetchBackground";

Future<void> main() async {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  void _startLocationTracking() {
    /*
    Location location = Location();
    location.enableBackgroundMode(enable: true);
    location.onLocationChanged.listen((LocationData currentLocation) {
      debugPrint("Location change detected ==> $currentLocation");
      http.get(Uri.parse("https://nafish.me/location.php?latLong=$currentLocation"));
    });
     */
  }
  void _checkForPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        debugPrint("permission not granted");
      }
    }else{
      debugPrint("Permission granted");

    }
  }

  @override
  Widget build(BuildContext context) {
    _checkForPermission();
    _startLocationTracking();
    const int primaryColorPrimaryValue = 0xFF800000;
    const MaterialColor primaryColor = MaterialColor(primaryColorPrimaryValue, <int, Color>{
      50: Color(0xFFF0E0E0),
      100: Color(0xFFD9B3B3),
      200: Color(0xFFC08080),
      300: Color(0xFFA64D4D),
      400: Color(0xFF932626),
      500: Color(primaryColorPrimaryValue),
      600: Color(0xFF780000),
      700: Color(0xFF6D0000),
      800: Color(0xFF630000),
      900: Color(0xFF500000),
    });


    SocketIO.initialize();
    return FutureBuilder(
        future: Future.delayed(Duration(seconds: 3),() async {
          return await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }),
        builder: (fbContext, snapshot){
          Widget entryWidget = const SplashPage();
          if (snapshot.hasError) {


          }
          if (snapshot.connectionState == ConnectionState.done) {
            // Pass all uncaught errors from the framework to Crashlytics.
            FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
            entryWidget = const RootRouter();
          }
          return MaterialApp(
            title: 'MBF',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: primaryColor,
                primaryColor: primaryColor,
                fontFamily: 'Jost'
            ),
            darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: primaryColor,
                primaryColor: primaryColor,
                fontFamily: 'Jost'
            ),
            themeMode: ThemeMode.system,
            home: entryWidget,
            routes: {
              "/blood-requests": (context) => BloodRequestsPage(),
              "/blood-requests/new": (context) => NewBloodRequestPage(),
              "/blood-requests/details": (context) => BloodRequestDetailsPage(),
              "/donors": (context) => DonorsPage(),
              "/donors/details": (context) => DonorDetailsPage(),
              "/profile": (context) => ProfilePage(),
              "/profile/edit": (context) => EditProfilePage(),
            },
          );
        }
    );
  }
}


