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
        'profilePic':userDoc['profilePic']
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LeaderboardStack(userName: leaderboard[2]['username'],img: leaderboard[2]['profilePic'] ?? "https://picsum.photos/200/300",height: 60,points: leaderboard[2]['scanCount'].toString(),),
                    LeaderboardStack(userName: leaderboard[0]['username'],img: leaderboard[0]['profilePic'] ?? "https://picsum.photos/200/300",height: 100,points: leaderboard[0]['scanCount'].toString(),),
                    LeaderboardStack(userName: leaderboard[1]['username'],img: leaderboard[1]['profilePic'] ?? "https://picsum.photos/200/300",height: 80,points: leaderboard[1]['scanCount'].toString(),),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    var user = leaderboard[index];
                    if(index > 2){
                      return ListTile(
                        leading: CircleAvatar(
                            child: index <= 2 ? Image(image: AssetImage("assets/${index+1}th.png")) : Text("${index+1}")
                        ),
                        title: Text(user['username']),
                        trailing: Text('Scans: ${user['scanCount']}'),
                      );
                    }
                    else{
                      return Container();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
