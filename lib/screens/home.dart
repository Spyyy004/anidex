import 'package:anidex/screens/favourites.dart';
import 'package:anidex/screens/library.dart';
import 'package:anidex/screens/profile.dart';
import 'package:anidex/screens/scan.dart';
import 'package:anidex/screens/scan_camera.dart';
import 'package:anidex/utils.dart';
import 'package:flutter/material.dart';

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

  static List<Widget> _widgetOptions = <Widget>[
    ScansListPage(),
    LibraryPage(),
    CameraExampleHome(),
    FavoritesPage(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Anidex'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: CircularNotchedRectangle(),
        child: SizedBox(
          height: 200, // Adjusted height to prevent overflow
          child: BottomNavigationBar(

            iconSize: 16,

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
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.black,
            onTap: (index) {
              // Skip the floating button's placeholder
              if (index == 2) return;
              _onItemTapped(index);
            },
            type: BottomNavigationBarType.shifting,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          _onItemTapped(2); // Navigate to the Scan page
        },
        child: Icon(Icons.camera, size: 40), // Larger icon
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class MyScansPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('My Scans Page'),
    );
  }
}



class ScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Scan Page'),
    );
  }
}




