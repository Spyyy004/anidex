import 'package:anidex/screens/encyclopedia.dart';
import 'package:flutter/material.dart';
import 'package:anidex/screens/leaderboard_screen.dart'; // Import your leaderboard screen
import 'package:anidex/screens/badges_screen.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import your badges screen

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(

            tabs: [
              Tab(
                  iconMargin: EdgeInsets.symmetric(vertical: 8.0),
                  icon: Icon(Icons.search), text: 'Explore'),
              Tab(
                  iconMargin: EdgeInsets.symmetric(vertical: 8.0),

                  icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
              Tab(
                  iconMargin: EdgeInsets.symmetric(vertical: 8.0),

                  icon: Icon(Icons.badge), text: 'Badges'),

            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllScansListPage(),
            LeaderboardScreen(), // Your leaderboard screen
            BadgesScreen(), // Your badges screen
             // Your explore screen
            // Center(
            //   child: Text(
            //     'Trivia Time - Coming Soon!',
            //     style: TextStyle(fontSize: 24),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
