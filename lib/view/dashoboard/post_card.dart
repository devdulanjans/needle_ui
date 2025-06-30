import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:needle2/view/dashoboard/profile/user_profile.dart';
import 'package:needle2/view/dashoboard/profile/user_profile_details.dart' show UserListPage;
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
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    likeCount = widget.wallPost['likeCount'] ?? 0;
    isLiked = widget.wallPost['isLiked'] ?? false;
    print("widget.wallPost: ${widget.wallPost}");
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

  void _commentPost() async {

    var _bodyData = {
      "content":_commentController.text.toString()
    };

    // return;
    final response = await API_V1_call(
      url: "/api/post/${widget.wallPost['wallId']}/comment",
      body: _bodyData,
      // url: "/api/post/like/${widget.wallPost['id']}",
      method: "POST",
    );

    print("response.statusCode: ${response.statusCode}");
    print("response.statusCode: ${response.body}");

    if (response.statusCode == 200) {

      var data = [];

      final posts = jsonDecode(response.body)['data'];

      if (posts != null) {
        data = (posts as List).reversed.toList();
        // Proceed with `data`
      } else {
        print('Posts data is null');
      }

      if (mounted) {
        setState(() {
          comments = data;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commented on the post')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking the post')),
      );
    }
  }

  void _getComments(String postId) async{

    final response = await API_V1_call(
      url: "/api/post/comment/${postId}",
      method: "GET",
    );

    print("response.statusCode: ${response.statusCode}");
    print("Comment response.statusCode: ${response.body}");

    if (mounted) {
      setState(() {
        comments = jsonDecode(response.body)['data'] ?? [];
      });
    }
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commented on the post')),
      );
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

    // Map<String, dynamic> userData = {
    //   "id": widget.wallPost['userId'],
    //   "displayName": widget.wallPost['userName'],
    //   "email": widget.wallPost['userId'].toString() ?? "",
    //   "bio": widget.wallPost['userId'].toString() ?? "",
    //   "profilePicture": widget.wallPost['userProfilePicture'] ?? "",
    //   "coverImage": widget.wallPost['userProfilePicture'] ?? "",
    //   "mobileNo": widget.wallPost['userId'].toString() ?? "",
    // };
    //
    // LoggedUserProfile userProfile = LoggedUserProfile.fromJson(userData);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          // userProfile: userProfile,
          userId: widget.wallPost['userId'].toString(),
        ),
      ),
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 400, // Set the desired height here
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: comments.isEmpty
                      ? Center(child: Text('No comments yet.', style: TextStyle(color: Colors.black),))
                      : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: comment['userProfileImage'] != null
                              ? CachedNetworkImageProvider(
                            imagePathSetter(
                              imageName: comment['userProfileImage'],
                              imageSize: "MEDIUM",
                              requestingImageType: "PROFILE",
                              setUserId: comment['userId'].toString(),
                            ),
                          )
                              : AssetImage('assets/profile_images.png') as ImageProvider,
                        ),
                        title: Text(comment['userName'] ?? 'Unknown User',style: TextStyle(color: Colors.black)),
                        subtitle: Text(comment['content'] ?? '', style: TextStyle(color: Colors.black)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 100 - 32, // Adjusted for padding
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black54),
                            hintText: 'Add a comment...',
                            fillColor: Colors.black12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          autofocus: true,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            _commentPost();
                            _commentController.clear();
                            _getComments(widget.wallPost['wallId'].toString()); // Refresh comments
                          }
                        },
                        icon: Icon(Icons.send, color: Colors.purpleAccent),
                      ),
                    ],
                  ),
                    ),
              ],
            ),
          ),
        );
      },
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
          widget.wallPost['Media'] != null ?GestureDetector(
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
                  widget.wallPost['Media'].length > 0
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
          ):SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _getComments(widget.wallPost['wallId'].toString());
                  _showCommentBottomSheet(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "${widget.wallPost['totalComments'] ?? 0} Comments",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              // Text("Comments", style: TextStyle(color: Colors.black))
            ],
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
                      onPressed: () {
                        _getComments(widget.wallPost['wallId'].toString());
                        _showCommentBottomSheet(context);
                      },
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
