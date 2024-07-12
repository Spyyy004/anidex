import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile.dart';
import 'sync_screen.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        children: [
          _buildListItem(
            icon: Icons.person,
            text: 'My Profile',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          Divider(),
          _buildListItem(
            icon: Icons.sync,
            text: 'Sync Data',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SyncDataPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blueAccent,
        size: 28,
      ),
      title: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),

      hoverColor: Colors.grey[200],
    );
  }
}
