import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';
import '../story/create_story.dart';

class StoryItem extends StatefulWidget {
  StoryItem({
    required this.stories
  });
  Map<String, dynamic> stories;

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  String _profileImage = "";
  @override

  Future<void> profileData()async{
    var _userId = await getUserId();
    var _imageUrl = await getUserProfilePicture();

    setState(() {

      if(_imageUrl != null && _imageUrl.isNotEmpty){
        _profileImage = imagePathSetter(
          imageName: _imageUrl,
          imageSize: "THUMBNAIL",
          requestingImageType: "PROFILE",
          setUserId: _userId,
        );

      } else {
        _profileImage = "";
      }

    });

    print("PROFILE IMAGE: $_profileImage");

  }

  initState() {
    super.initState();
    profileData();
    // You can initialize any state here if needed
  }
  // Dart
  Widget build(BuildContext context) {
    print(widget.stories);
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
                image: widget.stories['contentMediaUrl'] != null && widget.stories['contentMediaUrl'].isNotEmpty
                    ? CachedNetworkImageProvider(
                  imagePathSetter(
                    imageName: widget.stories['contentMediaUrl'],
                    imageSize: "THUMBNAIL",
                    requestingImageType: "STORY",
                    setUserId: 8.toString(),
                  ),
                ):AssetImage("assets/profile_images.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    widget.stories['contentText'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
                widget.stories['id'] == "0"
                    ? Positioned(
                        top: 50,
                        right: 30,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CreateStoryPage(
                                  // userProfile: _results[index]
                                ),
                              ),
                            );
                          },
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
                        ),
                      )
                    : Text(""),
              ],
            ),
          ),
          SizedBox(height: 2), // Change to 2 from 4 had some overflow
          Text('Username'),
        ],
      ),
    );
  }
}