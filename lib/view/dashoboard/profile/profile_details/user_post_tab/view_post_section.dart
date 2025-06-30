import 'package:flutter/material.dart';

import '../../../widget/common_seperator.dart';
import 'user_defined_post.dart';

class ViewPostDetails extends StatefulWidget {
  final userName;
  final userId;
  const ViewPostDetails({this.userName, this.userId, super.key});

  @override
  State<ViewPostDetails> createState() => _ViewPostDetailsState();
}

class _ViewPostDetailsState extends State<ViewPostDetails> {

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
              UserDefinedPost(userDisplayName: widget.userName,userId: widget.userId,)
            ],
          ),
          SizedBox(height: 10),
          // Add more widgets to display post details here
        ],
      ),
    );
  }
}
