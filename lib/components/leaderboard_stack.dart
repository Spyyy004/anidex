import 'package:anidex/utils.dart';
import 'package:flutter/material.dart';

class LeaderboardStack extends StatelessWidget {
  final String userName;
  final String points;
  final double height;
  final String img;

  LeaderboardStack({
    required this.userName,
    required this.points,
    required this.height,
    required this.img,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height + 100,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(img),
                radius: 30,
              ),
              SizedBox(height: 8),
              Text(
                userName,
                style: labelStyles.merge(TextStyle(color: Colors.white)),
                textAlign: TextAlign.center,
              ),
              Text(
                "Scans",
                style: boldSubtitleStyles.merge(TextStyle(color: Colors.white)),
              ),
              Text(
                points,
                style: boldSubtitleStyles.merge(TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
