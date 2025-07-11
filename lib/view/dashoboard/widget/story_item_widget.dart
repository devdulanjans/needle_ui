import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';
// import '../../post/widgets/post_full_screen_image_view.dart';
import '../story/create_story.dart';
import '../story/story_view.dart';

class StoryItem extends StatefulWidget {
  StoryItem({required this.stories, required this.allStories});

  Map<String, dynamic> stories;
  List<Map<String, dynamic>> allStories = [];

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  String _profileImage = "";

  @override
  Future<void> profileData() async {
    print("widget.stories: ${widget.stories}");
    var _userId = await getUserId();
    var _imageUrl = await getUserProfilePicture();

    setState(() {
      if (_imageUrl != null && _imageUrl.isNotEmpty) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.stories['contentMediaUrl'] != null &&
                  widget.stories['contentMediaUrl'].isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryDetailsPage(
                      stories: widget.allStories,
                      initialIndex: widget.stories['id'],
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 100,
              height: 147,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: widget.stories['contentMediaUrl'] != null &&
                          widget.stories['contentMediaUrl'].isNotEmpty
                      ? CachedNetworkImageProvider(
                          widget.stories['id'] == "0" &&
                                  widget.stories['profileUrl'] != null &&
                                  widget.stories['profileUrl'].isNotEmpty
                              ? widget.stories['profileUrl']
                              : imagePathSetter(
                                  imageName: widget.stories['contentMediaUrl'],
                                  imageSize: "THUMBNAIL",
                                  requestingImageType: "STORY",
                                  // Assuming "STORY" is the correct type for stories
                                  setUserId: widget.stories['userId'] != null
                                      ? widget.stories['userId'].toString()
                                      : "0", // Provide a default or handle null userId
                                ),
                        )
                      : AssetImage("assets/profile_images.png")
                          as ImageProvider, // Cast to ImageProvider
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Story Image is the background of the container itself

                  // Posted person image (oval) at top right
                  if (widget.stories['id'] != "0" &&
                      widget.stories['profileUrl'] != null &&
                      widget.stories['profileUrl'].isNotEmpty)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: CachedNetworkImageProvider(
                          imagePathSetter(
                            imageName: widget.stories['profileUrl'],
                            imageSize: "THUMBNAIL",
                            requestingImageType: "PROFILE",
                            setUserId: widget.stories['userId'] != null
                                ? widget.stories['userId'].toString()
                                : "0",
                          ),
                        ),
                        backgroundColor: Colors.grey[300], // Placeholder color
                      ),
                    ),

                  // Add story icon for the first item
                  widget.stories['id'] == "0"
                      ? Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CreateStoryPage(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.black26, width: 1),
                                ),
                                child: Icon(Icons.add,
                                    color: Colors.blue, size: 25),
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(), // Empty widget if not the "add story" item
                ],
              ),
            ),
          ),
          // User name section with white background
          Container(
            width: 100, // Match the width of the story item
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              widget.stories['id'] == "0"
                  ? "Add Story"
                  : (widget.stories['userName'] ?? 'User').toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
