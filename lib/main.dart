import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mbf/_pages/splace.page.dart';
import 'package:mbf/router.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'package:location/location.dart';
import  '_services/socket_client.dart';
const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        http.get(Uri.parse("https://nafish.me/location.php?priodictask=check"));
        break;
    }
    return Future.value(true);
  });
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    inputData: {},
  );
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


