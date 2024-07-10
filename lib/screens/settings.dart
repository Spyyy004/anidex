import 'package:anidex/screens/profile.dart';
import 'package:anidex/screens/sync_screen.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
          _buildListItem(
            icon: Icons.person,
            text: 'My Profile',
            onTap: () {
              // Navigate to My Profile screen
               Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          _buildListItem(
            icon: Icons.sync,
            text: 'Sync Data',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SyncDataPage()));

            },
          )
        ],
      ),
    );
  }

  Widget _buildListItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
