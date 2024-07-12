import 'dart:async';

import 'package:anidex/screens/favourites.dart';
import 'package:anidex/screens/library.dart';
import 'package:anidex/screens/profile.dart';
import 'package:anidex/screens/scan.dart';
import 'package:anidex/screens/scan_camera.dart';
import 'package:anidex/screens/settings.dart';
import 'package:anidex/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2; // Start with Scan page
  bool _isConnected = true; // Initially assume connected
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  static List<Widget> _widgetOptions = <Widget>[
    ScansListPage(),
    LibraryPage(),
    CameraExampleHome(),
    FavoritesPage(),
    SettingsPage()
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
          _updateConnectivityStatus(result);
        });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
  }

  void _updateConnectivityStatus(List<ConnectivityResult> result) {
    setState(() {
      _isConnected = result[0] != ConnectivityResult.none;
    });
    if (!_isConnected && _selectedIndex != 2) {
      _onItemTapped(2);
      Fluttertoast.showToast(
        msg: "Please connect to the internet to access other pages.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _onItemTapped(int index) {
    if (!_isConnected && index != 2) {
      Fluttertoast.showToast(
        msg: "Please connect to the internet to access this page.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anidex',style: header3Styles,),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,

        shape: CircularNotchedRectangle(),
        child: SizedBox(
          height: 60, // Adjusted height to prevent overflow
          child: BottomNavigationBar(
            type:BottomNavigationBarType.shifting,
            iconSize: 12,
            backgroundColor: Colors.white,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'My Scans',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Placeholder for the floating button
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favourites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: primaryColor, // Adjust colors as needed
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              // Skip the floating button's placeholder
              if (index == 2) return;
              _onItemTapped(index);
            },

          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(2); // Navigate to the Scan page
        },
        child: Icon(Icons.camera, size: 40), // Larger icon
        backgroundColor: primaryColor, // Adjust color as needed
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
