import 'package:flutter/material.dart';

import '../../../widget/common_seperator.dart';

class UserAboutDetails extends StatefulWidget {
  final userName;
  final userId;
  const UserAboutDetails({this.userName, this.userId, super.key});

  @override
  State<UserAboutDetails> createState() => _UserAboutDetailsState();
}

class _UserAboutDetailsState extends State<UserAboutDetails> {
  final List<Map<String, String>> _myFriends = [
    {
      "image": "https://randomuser.me/api/portraits/men/1.jpg",
      "displayName": "John Doe"
    },
    {
      "image": "https://randomuser.me/api/portraits/women/2.jpg",
      "displayName": "Jane Smith"
    },
    {
      "image": "https://randomuser.me/api/portraits/men/3.jpg",
      "displayName": "Peter Jones"
    },
    {
      "image": "https://randomuser.me/api/portraits/women/4.jpg",
      "displayName": "Alice Williams"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Details",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
          SizedBox(height: 10),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, size: 25, color: Colors.purple),
                  SizedBox(width: 10,),
                  Text(
                    "Profile. ",
                    style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Entrepreneur",
                    style: TextStyle(fontSize: 16,color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.link, size: 25, color: Colors.purple),
                  SizedBox(width: 10,),
                  Text(
                    "Website. ",
                    style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "sample.com",
                    style: TextStyle(fontSize: 16,color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.more_horiz, size: 25, color: Colors.purple),
                  SizedBox(width: 10,),
                  Text(
                    "See more ${widget.userName} About info",
                    style: TextStyle(fontSize: 16,color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Separator(),

            ],
          ),
          SizedBox(height: 10),
          Text(
            "Friends",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _myFriends.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 16.0, // Increased spacing for display name
              childAspectRatio: 1, // Adjust as needed, made it square for image and text below
            ),
            itemBuilder: (context, index) {
              final friend = _myFriends[index];
              return Column( // Changed to Column to place text below image
                children: [
                  Expanded( // Use Expanded to make the image take available space
                    child: ClipRRect( // Added ClipRRect for curvy corners
                      borderRadius: BorderRadius.circular(8.0), // Adjust corner radius as needed
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(friend['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4), // Spacing between image and text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      friend['displayName']!,
                      style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w700), // Adjusted font size
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
