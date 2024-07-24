import 'package:anidex/screens/favourites.dart';
import 'package:anidex/screens/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'profile.dart';
import 'sync_screen.dart';

class SettingsPage extends StatelessWidget {
  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'Version ${packageInfo.version}';
  }

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
          kIsWeb ? Container(): Divider(),
          kIsWeb ? Container(): _buildListItem(
            icon: Icons.sync,
            text: 'Sync Data',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SyncDataPage()));
            },
          ),
          Divider(),
          _buildListItem(
            icon: Icons.favorite,
            text: 'Favourites',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritesPage()));
            },
          ),
          Divider(),
          _buildListItem(
            icon: Icons.rate_review,
            text: 'Help Us',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
            },
          ),
          Divider(),
          FutureBuilder<String>(
            future: _getAppVersion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ListTile(
                  leading: Icon(
                    Icons.error,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                  title: Text(
                    'Version info not available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              } else {
                return ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  title: Text(
                    snapshot.data!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
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
