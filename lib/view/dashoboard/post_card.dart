import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controller/actions/comment_action_controller.dart';
import '../../controller/api/api_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/config/image_path_setter.dart';
import '../../controller/friend_api.dart';
import '../widget/expandableText.dart';
import 'post/full_screenImage.dart';
import 'profile/profile.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> wallPost;
  final VoidCallback? onPostDeleted;
  final bool isUserDefined;

  PostCard(this.wallPost, {this.onPostDeleted,required this.isUserDefined});

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
  bool isPage = false;
  String loggedUserId = "";

  @override
  void initState() {
    super.initState();
    checkProfileType();
    print("widget.wallPost['wallId'].toString(): ${widget.wallPost}");
    if((widget.wallPost['isPage'] ?? false) && widget.isUserDefined){
      _getComments(widget.wallPost['id'].toString(),type: 1);
    }else{
      _getComments(widget.wallPost['wallId'].toString(),type: 11);
    }

    _getLikesOfPost();
    likeCount = widget.wallPost['likeCount'] ?? 0;
    isLiked = widget.wallPost['isLiked'] ?? false;
    pickLoggedUser();
    print("widget.wallPost: ${widget.wallPost}");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }


  Future<void> checkProfileType()async{

    var profileType = await getProfileType(type: 2) ?? "user";
    if(profileType == "user"){
      isPage = false;
    }else if(profileType == "page"){
      isPage = true;
    }

    print("CheckProfileType:${isPage}");
  }



  Future<void> pickLoggedUser() async {
    loggedUserId = (await getUserId())!;
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
    String url = "";
    print("CheckWallPost-${widget.wallPost.toString()}");
    if(isPage && widget.isUserDefined){
      url = "/api/page/post/comment/${widget.wallPost['id'].toString()}";
    }else{
      url = "/api/post/${widget.wallPost['postId']}/comment";
    }


    final response = await API_V1_call(
      url: url,
      body: _bodyData,
      method: "POST",
    );

    print("response.body:-Comment-- ${response.body}");

    if (response.statusCode == 200) {
      var data = [];

      final posts = jsonDecode(response.body)['data'];

      print("Comments of posts: $posts");

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

  void _getComments(String postId,{int type = 1}) async {
    String apiUrl = "";

    if(isPage && widget.isUserDefined){
      apiUrl = "/api/page/post/comment/${postId}";
    }else{
      apiUrl = "/api/post/comment/${postId}";
    }


    final response = await API_V1_call(
      url: apiUrl,
      method: "GET",
    );

    print("REP post Id: ${[postId]} -- Type:$type");
    print("API CALL: /api/post/comment/${postId}");

    print("response.statusCode: ${response.statusCode}");
    print("Comment response.statusCode: ${response.body}");

    if (mounted) {
      setState(() {
        comments = jsonDecode(response.body)['data'] ?? [];
      });
    }
    print("response.statusCode comments: ${response.statusCode}");
    if (response.statusCode == 200) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(backgroundColor: Colors.purpleAccent ,content: Text('Commented on the post',style: TextStyle(color: Colors.white),)),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error Comment DC',
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
              profileType: widget.wallPost['profileType'],
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.comment_bank,
                                    color: Colors.black12,
                                    size: 100,
                                  ),
                                  Text(
                                    'No comments yet.',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
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
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        comment['profilePicture'] != null
                                            ? CachedNetworkImageProvider(
                                              imagePathSetter(
                                                imageName:
                                                    comment['profilePicture'],
                                                imageSize: "MEDIUM",
                                                requestingImageType: "PROFILE",
                                                setUserId:
                                                    comment['creatorId']
                                                        .toString(),
                                              ),
                                            )
                                            : AssetImage(
                                                  'assets/profile_images.png',
                                                )
                                                as ImageProvider,
                                  ),
                                  title: InkWell(
                                    onLongPress: () {
                                      print("comment: ${comment}");
                                      // return;
                                      CommentActionController.showCommentOptions(
                                        context,
                                        comment['content'],
                                        comment['creatorId'].toString(),
                                        comment['id'].toString(),
                                        () {
                                          String postId= isPage && widget.isUserDefined ? widget.wallPost['id'].toString() : widget.wallPost['wallId'].toString();
                                          _getComments(postId,type: 2
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent.withAlpha(
                                          30,
                                        ),
                                        // Background color
                                        borderRadius: BorderRadius.circular(
                                          0.0,
                                        ), // Curved corners
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Navigate to profile screen
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => ProfileScreen(
                                                        userId:
                                                            comment['creatorId']
                                                                .toString(),
                                                        profileType:
                                                            comment['profileType'],
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              comment['displayName'] ??
                                                  'Unknown User',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            comment['content'] ?? '',
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  subtitle: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        commentFormattedDate,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        "Like",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      SizedBox(width: 15),
                                      GestureDetector(
                                        onTap: () {
                                          // Handle reply action
                                          print("Reply to comment");
                                          // You can implement reply functionality here
                                        },
                                        child: Text(
                                          "Reply",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
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
                                borderRadius: BorderRadius.circular(0.0),
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
                                widget.wallPost['postId'].toString(),
                                type: 3
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
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
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

  void savePost() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing list of saved posts
    final String? savedPostsJson = prefs.getString('savedPosts');
    List<dynamic> savedPosts =
        savedPostsJson != null ? jsonDecode(savedPostsJson) : [];

    // It's crucial to compare posts by a unique identifier, like 'wallId'.
    // Assuming 'wallId' is unique for each post.
    String currentPostId = widget.wallPost['wallId'].toString();

    // Check if the new post already exists in the list
    if (!savedPosts.any((post) => post['wallId'].toString() == currentPostId)) {
      savedPosts.add(
        widget.wallPost, // Add the new post if it's not a duplicate
      ); // Add the new post if it's not a duplicate
      await prefs.setString(
        'savedPosts',
        jsonEncode(savedPosts),
      ); // Save the updated list
      print("Post added and saved locally: ${widget.wallPost}");
    } else {
      print("Duplicate post. Not saved.");
    }
  }

  void removePost() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          content: Text(
            "Are you sure you want to delete this post?",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("OK", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                final response = await API_V1_call(
                  url: "/api/post/${widget.wallPost['wallId'].toString()}",
                  method: "DELETE",
                );
                print("REMOVE RESPONSE: ${response.body}");
                if (response.statusCode == 200 &&
                    widget.onPostDeleted != null) {
                  widget.onPostDeleted!();
                }
              },
            ),
          ],
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
                requestingImageType: widget.wallPost['imageRequestType'],
                setUserId: widget.wallPost['userProfileId'].toString(),
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
                  builder: (c) {
                    return Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible: loggedUserId != widget.wallPost['userId'].toString(),
                            child: ListTile(
                              title: Text(
                                "Block User",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              leading: Icon(
                                Icons.block,
                                color: Colors.black,
                              ),
                              onTap: () async{
                                Navigator.pop(c);
                                print("Blocking User - ${widget.wallPost['userId'].toString()}");
                                bool result = await blockUser(widget.wallPost['userId'].toString());
                                if(result){
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('User blocked successfully.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.purple.shade100,),);
                                }else{
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('User blocked failed.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.red.shade100,),);
                                }
                              },
                            ),
                          ),

                          // Section 1
                          ListTile(
                            title: Text(
                              "Interested",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(
                              Icons.add_circle,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(c);
                              print("Interested selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Not Interested",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(
                              Icons.remove_circle,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(c);
                              print("Not Interested selected");
                            },
                          ),
                          // Divider(),
                          // Section 2
                          ListTile(
                            title: Text(
                              "Save Link",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(Icons.save_alt, color: Colors.black),
                            onTap: () {
                              savePost();
                              Navigator.pop(c);
                              print("Save Link selected");
                            },
                          ),
                          loggedUserId == widget.wallPost['userId'].toString()
                              ? ListTile(
                                title: Text(
                                  "Move To Bin",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.remove_circle,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  removePost();
                                  // It's generally better to pop the navigator *after* the async operation if it depends on the context,
                                  // but since showDialog creates a new route, popping it here is fine.
                                  // Navigator.pop(context);
                                },
                              )
                              : SizedBox(height: 0),
                          ListTile(
                            title: Text(
                              "Hide ad",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(
                              Icons.hide_source,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(c);
                              print("Hide ad selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Report ad",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(Icons.report, color: Colors.black),
                            onTap: () {
                              Navigator.pop(c);
                              print("Report ad selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Why I am seeing this?",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(
                              Icons.remove_red_eye,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(c);
                              print("Why I am seeing this? selected");
                            },
                          ),
                          ListTile(
                            title: Text(
                              "Be notified about this post",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(Icons.post_add, color: Colors.black),
                            onTap: () {
                              Navigator.pop(c);
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
                                borderRadius: BorderRadius.circular(0.0),
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
                                scrollDirection: Axis.horizontal,

                                padding: const EdgeInsets.all(8.0),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                    ),
                                itemCount: widget.wallPost['Media'].length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
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
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                     String postId= isPage && widget.isUserDefined ? widget.wallPost['id'].toString() : widget.wallPost['wallId'].toString();
                    _getComments(postId,type: 4);
                    _showCommentBottomSheet(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "${comments.length} Comments",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                      ),
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
                      Text("$likeCount", style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                      ),),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    String postId= isPage && widget.isUserDefined ? widget.wallPost['id'].toString() : widget.wallPost['wallId'].toString();
                    _getComments(postId,type: 5);
                    _showCommentBottomSheet(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 10),
                      Text("Comment",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    //log("CheckPostId:${widget.wallPost.toString()}");
                    String postId = isPage && widget.isUserDefined ? (widget.wallPost['id'] ?? "").toString() : (widget.wallPost['postId'] ?? "").toString();
                    print("CheckPostShare:-IsPage-${isPage} --PostId-${postId}--${widget.wallPost['postId']}");
                    showShareOptions(context,(postId));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 5,),
                      Text("Share", style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                      ),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePostInternally(String postId) async {

    try {
      int pId = int.tryParse(postId) ?? -1;
      print("CheckPostShare:${pId}");
      if(pId != -1){

        String apiUrl = "";
        if(isPage){
          apiUrl = "/api/page/post/share/$pId";
        }else{
          apiUrl = "/api/post/share/$pId";
        }


        final responseData = await API_V1_call(
          url: "$apiUrl",
          method: "GET",
          isHeader: true,
        );

        if (responseData.statusCode == 200) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Post shared successfully.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.purple.shade100,),);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Post sharing failed.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.red.shade100,),);
        }
      }else{
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post sharing failed.',style: TextStyle(color: Colors.black),),backgroundColor: Colors.red.shade100,),);
      }


    } catch (e) {
      print("Error calling API: $e");
    }
  }

  void showShareOptions(BuildContext context,String postId) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share,color: Colors.purple,),
                title: Text("Share inside app",style: TextStyle(color: Colors.black),),
                onTap: () {
                  Navigator.pop(context);
                  _sharePostInternally(postId);

                },
              ),
              ListTile(
                leading: Icon(Icons.send,color: Colors.purple,),
                title: Text("Share externally",style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'check out my website https://example.com',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}








