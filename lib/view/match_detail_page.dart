import 'package:flutter/material.dart';

class MatchDetailsPage extends StatelessWidget {


  const MatchDetailsPage({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Match Details"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Match Details",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              "Teams: ",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            // You can add more match-related information here
            Text(
              "Location: ",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              "Time: ",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            // Additional match details can go here
          ],
        ),
      ),
    );
  }
}
