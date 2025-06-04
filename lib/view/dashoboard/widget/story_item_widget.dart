import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StoryItem extends StatelessWidget {
  StoryItem({
    required this.stories
  });
  Map<String, dynamic> stories;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 100, // Square shape
            height: 150, // Square shape
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                    stories['contentMediaUrl'] != null && stories['contentMediaUrl'].isNotEmpty
                        ? stories['contentMediaUrl']
                        : "https://images.pexels.com/photos/14653174/pexels-photo-14653174.jpeg"
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    stories['contentText'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
                stories['id'] == "0"?
                Positioned(
                  top: 50,
                  right: 30,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                )
                    :Text("")
              ],
            ),
            // child: CircleAvatar(
            //   radius: 28,
            //   backgroundImage: CachedNetworkImageProvider(
            //       'https://randomuser.me/api/portraits/women/${45 + 1}.jpg'),
            // ),
          ),
          SizedBox(height: 4),
          Text('Username'),
        ],
      ),
    );
  }
}