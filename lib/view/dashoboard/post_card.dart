import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controller/api/api_controller.dart';
import '../../controller/config/image_path_setter.dart';
import '../../model/logged_user_profile_model.dart';
import '../widget/expandableText.dart';
import 'post/full_screenImage.dart';
import 'profile/profile.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> wallPost;

  PostCard(this.wallPost);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.wallPost['likeCount'] ?? 0;
    isLiked = widget.wallPost['isLiked'] ?? false;
  }

  void _likePost() async {
    // Call the API to like/unlike the post
    print("widget.wallPost['id']: ${widget.wallPost['wallId']}");

    var _bodyData = {
      "type":"COMMENT",
      "itemId":widget.wallPost['wallId'],
      "reaction":"LIKE"
    };

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    // return;
    final response = await API_V1_call(
      url: "/api/interaction/like",
      body: _bodyData,
      // url: "/api/post/like/${widget.wallPost['id']}",
      method: "POST",
    );

    print("response.statusCode: ${response.statusCode}");
    print("response.statusCode: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking the post')),
      );
    }
  }

  void _showReactionsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up, color: Colors.blue),
                onPressed: () {
                  Navigator.pop(context);
                  print("Like reaction selected");
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  print("Love reaction selected");
                },
              ),
              IconButton(
                icon: Icon(Icons.emoji_emotions, color: Colors.yellow),
                onPressed: () {
                  Navigator.pop(context);
                  print("Happy reaction selected");
                },
              ),
              IconButton(
                icon: Icon(Icons.emoji_emotions_sharp, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  print("Angry reaction selected");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void callProfileScreen() {
    Map<String, dynamic> userData = {
      "id": widget.wallPost['userId'],
      "displayName": widget.wallPost['userName'],
      "email": widget.wallPost['userId'].toString() ?? "",
      "bio": widget.wallPost['userId'].toString() ?? "",
      "profilePicture": widget.wallPost['userProfilePicture'] ?? "",
      "coverImage": widget.wallPost['userProfilePicture'] ?? "",
      "mobileNo": widget.wallPost['userId'].toString() ?? "",
    };

    LoggedUserProfile userProfile = LoggedUserProfile.fromJson(userData);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userProfile: userProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime postDate = DateTime.parse(widget.wallPost['createdAt']);
    final String formattedDate = timeago.format(postDate);

    ImageProvider<Object>? _profileImage = widget.wallPost['userProfileImage'] != null
        ? CachedNetworkImageProvider(
      imagePathSetter(
        imageName: widget.wallPost['userProfileImage'],
        imageSize: "MEDIUM",
        requestingImageType: "PROFILE",
        setUserId: widget.wallPost['userId'].toString(),
      ),
    )
        : AssetImage('assets/profile_images.png');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: _profileImage,
            ),
            title: GestureDetector(
              onTap: () {
                callProfileScreen();

              },
              child: Text(
                widget.wallPost['userName'],
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(color: Colors.black26, fontSize: 11),
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  widget.wallPost['visibility'] == "PUBLIC"
                      ? Icons.public
                      : Icons.privacy_tip,
                  color: Colors.black26,
                  size: 20,
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                // Add your bottom sheet logic here
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandableText(widget.wallPost['contentText'].toString()),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(data: widget.wallPost),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: widget.wallPost['Media'] != null &&
                  widget.wallPost['Media'].length > 1
                  ? GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: widget.wallPost['Media'].length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: imagePathSetter(
                        imageName: widget.wallPost['Media'][index]['url'],
                        imageSize: "MEDIUM",
                        requestingImageType: "POST",
                        setUserId: widget.wallPost['userId'].toString(),
                      ),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
                  : Text('No media available'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onLongPress: () => _showReactionsPopup(context),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _likePost,
                      ),
                      Text("$likeCount", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.comment,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {},
                    ),
                    Text("Comment", style: TextStyle(color: Colors.black)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {},
                    ),
                    Text("Share", style: TextStyle(color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
