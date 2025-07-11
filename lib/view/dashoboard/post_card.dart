import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controller/api/api_controller.dart';
import '../../controller/config/image_path_setter.dart';
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
  String reactionType = "";
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> comments = [];
  List<dynamic> postLikes = [];

  @override
  void initState() {
    super.initState();
    _getComments(widget.wallPost['wallId'].toString());
    _getLikesOfPost();
    likeCount = widget.wallPost['likeCount'] ?? 0;
    isLiked = widget.wallPost['isLiked'] ?? false;
    print("widget.wallPost: ${widget.wallPost}");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _likePost() async {
    reactionType = reactionType.isEmpty ? "LIKE" : reactionType;

    print("reactionType: $reactionType");

    var _bodyData = {
      "type": "COMMENT",
      "itemId": widget.wallPost['wallId'],
      "reaction": "LIKE",
    };

    final response = await API_V1_call(
      url: "/api/interaction/like",
      body: _bodyData,
      method: "POST",
    );

    print("14 response.statusCode: ${response.statusCode}");
    print("14 response.statusCode: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error liking the post')));
    }
  }

  void _getLikesOfPost() async {
    var _bodyData = {
      "itemType": "COMMENT",
      "itemId": widget.wallPost['wallId'],
    };

    final response = await API_V1_call(
      url: "/api/interaction/likes",
      body: _bodyData,
      method: "POST",
    );

    if (response.statusCode == 200) {
      var data = [];

      final posts = jsonDecode(response.body)['data'];

      print("all posts: $posts");

      if (posts != null) {
        data = (posts as List).reversed.toList();
        // Proceed with `data`
      } else {
        print('Posts data is null');
      }

      if (mounted) {
        setState(() {
          postLikes = data;
        });
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error liking the post')));
    }
  }

  void _commentPost() async {
    var _bodyData = {"content": _commentController.text.toString()};

    final response = await API_V1_call(
      url: "/api/post/${widget.wallPost['wallId']}/comment",
      body: _bodyData,
      method: "POST",
    );

    if (response.statusCode == 200) {
      var data = [];

      final posts = jsonDecode(response.body)['data'];

      if (posts != null) {
        data = (posts as List).reversed.toList();
      } else {
        print('Posts data is null');
      }

      if (mounted) {
        setState(() {
          comments = data;
        });
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(backgroundColor: Colors.red, content: Text('Error liking the post',style: TextStyle(color: Colors.white))),
      // );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error liking the post')));
    }
  }

  void _getComments(String postId) async {
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(backgroundColor: Colors.purpleAccent ,content: Text('Commented on the post',style: TextStyle(color: Colors.white),)),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error Comment ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      print("Response Data ${jsonDecode(response.body)['data']}");
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
                  setState(() {
                    reactionType = "LIKE";
                  });
                  _likePost();
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  setState(() {
                    reactionType = "HEART";
                  });
                  _likePost();
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.emoji_emotions, color: Colors.yellow),
                onPressed: () {
                  setState(() {
                    reactionType = "HAHA";
                  });
                  _likePost();
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.emoji_emotions_sharp, color: Colors.red),
                onPressed: () {
                  setState(() {
                    reactionType = "ANGRY";
                  });
                  _likePost();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void callProfileScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ProfileScreen(
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
        // Add background color here
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 300,
                    child:
                        comments.isEmpty
                            ? Center(
                              child: Text(
                                'No comments yet.',
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                final DateTime commentDate = DateTime.parse(
                                  comment['createdAt'],
                                );
                                final String commentFormattedDate = timeago
                                    .format(commentDate);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withAlpha(30),
                                    // Background color
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ), // Curved corners
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          comment['userProfileImage'] != null
                                              ? CachedNetworkImageProvider(
                                                imagePathSetter(
                                                  imageName:
                                                      comment['userProfileImage'],
                                                  imageSize: "MEDIUM",
                                                  requestingImageType:
                                                      "PROFILE",
                                                  setUserId:
                                                      comment['userId']
                                                          .toString(),
                                                ),
                                              )
                                              : AssetImage(
                                                    'assets/profile_images.png',
                                                  )
                                                  as ImageProvider,
                                    ),
                                    title: Text(
                                      comment['userName'] ?? 'Unknown User',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['content'] ?? '',
                                          style: GoogleFonts.poppins(color: Colors.black,fontSize: 16),
                                        ),
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              commentFormattedDate,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Icon(
                                              Icons.thumb_up,
                                              color: Colors.black,
                                              size: 13,
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                // Handle reply action
                                                print("Reply to comment");
                                                // You can implement reply functionality here
                                              },
                                              child: Text(
                                                "Reply",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.black12,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 14.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.purpleAccent),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              _commentPost();
                              _commentController.clear();
                              _getComments(
                                widget.wallPost['wallId'].toString(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLikeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          // height: 400, // Set the desired height here
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 40,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 300, // Adjusted height for the comment list
                  child:
                      postLikes.isEmpty
                          ? Center(
                            child: Text(
                              'No comments yet.',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                          : ListView.builder(
                            itemCount: postLikes.length,
                            itemBuilder: (context, index) {
                              final comment = postLikes[index];
                              print("INK COMMENT: $comment");
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      comment['profilePicture'] != null ||
                                              comment['profilePicture'] != ""
                                          ? CachedNetworkImageProvider(
                                            imagePathSetter(
                                              imageName:
                                                  comment['profilePicture'],
                                              imageSize: "MEDIUM",
                                              requestingImageType: "PROFILE",
                                              setUserId:
                                                  comment['userId'].toString(),
                                            ),
                                          )
                                          : AssetImage(
                                                'assets/profile_images.png',
                                              )
                                              as ImageProvider,
                                ),
                                title: Text(
                                  comment['displayName'] ?? 'Unknown User',
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400, // Adjusted height to accommodate more icons
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share to',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4, // Number of icons per row
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: [
                    _buildShareIcon(Icons.facebook, 'Facebook', () {
                      // Add Facebook sharing logic
                      // Share.share('Check out this post: ${widget.wallPost['contentText']}', subject: 'Shared from My App');
                      Navigator.pop(context);
                    }),
                    _buildShareIcon(Icons.message, 'WhatsApp', () {
                      // Add WhatsApp sharing logic
                      // Share.share('Check out this post: ${widget.wallPost['contentText']}', subject: 'Shared from My App');
                      Navigator.pop(context);
                    }),
                    _buildShareIcon(Icons.alternate_email, 'Twitter', () {
                      // Add Twitter sharing logic
                      // Share.share('Check out this post: ${widget.wallPost['contentText']}', subject: 'Shared from My App');
                      Navigator.pop(context);
                    }),
                    _buildShareIcon(Icons.link, 'Copy Link', () {
                      // Add copy link logic
                      Navigator.pop(context);
                    }),
                    _buildShareIcon(Icons.email, 'Email', () {
                      // Add email sharing logic
                      Navigator.pop(context);
                    }),
                    _buildShareIcon(Icons.sms, 'SMS', () {
                      // Add SMS sharing logic
                      Navigator.pop(context);
                    }),
                    _buildShareIcon(Icons.more_horiz, 'More', () {
                      // Add more options logic
                      Navigator.pop(context);
                    }),
                    // Add more icons as needed
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.black),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime postDate = DateTime.parse(widget.wallPost['createdAt']);
    final String formattedDate = timeago.format(postDate);

    ImageProvider<Object>? _profileImage =
        widget.wallPost['userProfileImage'] != null
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
            leading: CircleAvatar(backgroundImage: _profileImage),
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
                    fontWeight: FontWeight.w500,
                  ),
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
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Section 1
                          ListTile(
                            title: Text(
                              "Interested",
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: Icon(
                              Icons.add_circle,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              print("Interested selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Not Interested",
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: Icon(
                              Icons.remove_circle,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              print("Not Interested selected");
                            },
                          ),
                          Divider(),
                          // Section 2
                          ListTile(
                            title: Text(
                              "Save Link",
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: Icon(Icons.save_alt, color: Colors.black),
                            onTap: () {
                              Navigator.pop(context);
                              print("Save Link selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Hide ad",
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: Icon(
                              Icons.hide_source,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              print("Hide ad selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Report ad",
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: Icon(Icons.report, color: Colors.black),
                            onTap: () {
                              Navigator.pop(context);
                              print("Report ad selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Why I am seeing this?",
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: Icon(
                              Icons.remove_red_eye,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              print("Why I am seeing this? selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Be notified about this post",
                              style: TextStyle(color: Colors.black),
                            ),
                            leading: Icon(Icons.post_add, color: Colors.black),
                            onTap: () {
                              Navigator.pop(context);
                              print("Be notified about this post selected");
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
                // Add your bottom sheet logic here
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandableText(widget.wallPost['contentText'].toString()),
          ),
          widget.wallPost['Media'] != null
              ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FullScreenImage(data: widget.wallPost),
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio:
                      widget.wallPost['Media'] != null &&
                              widget.wallPost['Media'].length == 1
                          ? 16 /
                              20 // Aspect ratio for single image (full width)
                          : 1 / 1, // Aspect ratio for grid (square images)
                  child:
                      widget.wallPost['Media'] != null &&
                              widget.wallPost['Media'].length > 0
                          ? widget.wallPost['Media'].length == 1
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: imagePathSetter(
                                    imageName:
                                        widget.wallPost['Media'][0]['url'],
                                    imageSize:
                                        "MEDIUM", // Use larger size for single image
                                    requestingImageType: "POST",
                                    setUserId:
                                        widget.wallPost['userId'].toString(),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              )
                              : GridView.builder(
                                padding: const EdgeInsets.all(8.0),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          widget.wallPost['Media'].length < 1
                                              ? 1
                                              : 2,
                                      // Show single column if less than 1, else 2
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                    ),
                                itemCount: widget.wallPost['Media'].length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: imagePathSetter(
                                        imageName:
                                            widget
                                                .wallPost['Media'][index]['url'],
                                        imageSize: "MEDIUM",
                                        requestingImageType: "POST",
                                        setUserId:
                                            widget.wallPost['userId']
                                                .toString(),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              )
                          : Text('No media available'),
                ),
              )
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _showLikeBottomSheet(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "${postLikes.length} Likes",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _getComments(widget.wallPost['wallId'].toString());
                    _showCommentBottomSheet(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "${comments.length} Comments",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                // Text("Comments", style: TextStyle(color: Colors.black))
              ],
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
                          isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color:
                              isLiked
                                  ? Colors.purpleAccent
                                  : Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _likePost,
                      ),
                      Text("$likeCount", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    _getComments(widget.wallPost['wallId'].toString());
                    _showCommentBottomSheet(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 10),
                      Text("Comment", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        _showShareBottomSheet(context);
                      },
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
