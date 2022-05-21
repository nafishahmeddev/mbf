import 'dart:async';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mbf/_pages/splace.page.dart';
import 'package:mbf/router.dart';
import 'firebase_options.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import  '_services/socket_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const App());
}
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationTitle: "Running in background",
      foregroundServiceNotificationContent: "Mobile Blood Finder is running background."
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}
// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 100,
  );
  StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
    http.get(Uri.parse('https://nafish.me/location.php?location.php?latLong=${position?.latitude}:${position?.longitude}'));
  });
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  service.on('stopService').listen((event) {
    service.stopSelf();
    positionStream.cancel();
  });
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  _checkForPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("permission not granted");
      }
    }else{
      debugPrint("Permission granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkForPermission();
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
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (fbContext, snapshot){
          Widget entryWidget = const SplashPage();
          if (snapshot.hasError) {

          }
          if (snapshot.connectionState == ConnectionState.done) {
            entryWidget = const RootRouter();
          }
          return MaterialApp(
            title: 'MBF',
            theme: ThemeData(
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
          );
        }
    );
  }
}


