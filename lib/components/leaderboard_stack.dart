import 'package:anidex/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeaderboardStack extends StatelessWidget {
  String userName;
  String points;
  double height;
  String img;
  LeaderboardStack({required this.userName , required this.points, required this.height , required this.img ,  super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(

        height: height+100,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                child:
                Image(image: NetworkImage(img),height: 30,width: 30,),
                radius: 30,
              ),
              Text(userName,style: labelStyles.merge(TextStyle(color: Colors.white))),
              Text("Scans",style: boldSubtitleStyles.merge(TextStyle(color: Colors.white)),),

              Text(points,style: boldSubtitleStyles.merge(TextStyle(color: Colors.white)),)
            ],
          ),
        ),
      ),
    );
  }
}
