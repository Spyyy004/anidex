import 'package:anidex/components/leaderboard_stack.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    QuerySnapshot userSnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> leaderboard = [];

    for (var userDoc in userSnapshot.docs) {
      List<String> scans = List<String>.from(userDoc['scans'] ?? []);
      int scanCount = scans.length;

      leaderboard.add({
        'username': userDoc['firstName'], // Ensure the username field exists in your user documents
        'scanCount': scanCount,
        'profilePic': userDoc['profilePic']
      });
    }

    leaderboard.sort((a, b) => b['scanCount'].compareTo(a['scanCount']));
    return leaderboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No leaderboard data found.'));
          }

          List<Map<String, dynamic>> leaderboard = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (leaderboard.length > 2)
                      LeaderboardStack(
                        userName: leaderboard[2]['username'],
                        img: leaderboard[2]['profilePic'] ?? "https://picsum.photos/200/300",
                        height: 80,
                        points: leaderboard[2]['scanCount'].toString(),
                      ),
                    if (leaderboard.isNotEmpty)
                      LeaderboardStack(
                        userName: leaderboard[0]['username'],
                        img: leaderboard[0]['profilePic'] ?? "https://picsum.photos/200/300",
                        height: 100,
                        points: leaderboard[0]['scanCount'].toString(),
                      ),
                    if (leaderboard.length > 1)
                      LeaderboardStack(
                        userName: leaderboard[1]['username'],
                        img: leaderboard[1]['profilePic'] ?? "https://picsum.photos/200/300",
                        height: 90,
                        points: leaderboard[1]['scanCount'].toString(),
                      ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      if (index > 2) {
                        var user = leaderboard[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user['profilePic'] ?? "https://picsum.photos/200/300"),
                              child: index <= 2 ? Image(image: AssetImage("assets/${index + 1}th.png")) : null,
                            ),
                            title: Text(
                              user['username'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              'Scans: ${user['scanCount']}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
