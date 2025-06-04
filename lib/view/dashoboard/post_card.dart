// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:timeago/timeago.dart' as timeago;
//
// import '../../controller/config/image_path_setter.dart';
// import '../../model/postCustomObject.dart';
// import '../widget/expandableText.dart';
// import 'post/full_screenImage.dart';
// import 'profile/profile.dart';
//
// class PostCard extends StatelessWidget {
//   PostCard(this.wallPOst);
//
//   Map<String, dynamic> wallPOst;
//
//   Icon setICon(context, iconStatus){
//     if(iconStatus == "PUBLIC"){
//       return Icon(
//         Icons.public,
//         color: Colors.black26,
//         size: 20,
//       );
//     } else {
//       return Icon(
//         Icons.privacy_tip,
//         color: Colors.black26,
//       );
//     }
//
//   }
//
//   void exampleApiCall() {
//     print("API called!");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final DateTime postDate = DateTime.parse(wallPOst['createdAt']);
//     final String formattedDate = timeago.format(postDate);
//
//     ImageProvider<Object>? _profileImage = wallPOst['userProfileImage'] != null
//         ? CachedNetworkImageProvider(
//         imagePathSetter(
//           imageName: wallPOst['userProfileImage'],
//           imageSize: "MEDIUM",
//           requestingImageType: "POST",
//           setUserId: wallPOst['userId'].toString(),
//         ),
//         // "https://ms3-needle.blr1.cdn.digitaloceanspaces.com/3/PROFILE/THUMBNAIL/${wallPOst['userProfileImage']}"
//     )
//         : AssetImage('assets/profile_images.png');
//
//     List<PostCustomObject> objectList = [
//       PostCustomObject(
//         icon: Icon(Icons.add_circle, color: Colors.black,),
//         name: "Interested",
//         description: "More of your post will be like this",
//         apiCall: exampleApiCall,
//       ),
//       PostCustomObject(
//         icon: Icon(Icons.remove_circle, color: Colors.black,),
//         name: "Not Interested",
//         description: "More of your post will not be like this",
//         apiCall: exampleApiCall,
//       ),
//       PostCustomObject(
//         icon: Icon(Icons.info, color: Colors.black,),
//         name: "Info",
//         description: "App information",
//         apiCall: exampleApiCall,
//       ),
//     ];
//
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: _profileImage,
//             ),
//             title: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => ProfileScreen(
//                             // userProfile: _results[index]
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     wallPOst['userName'],
//                     style: GoogleFonts.poppins(
//                             textStyle: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             subtitle: Row(
//               children: [
//                 Text(
//                   formattedDate,
//                   style: GoogleFonts.poppins(
//                     textStyle: TextStyle(color: Colors.black26,fontSize: 11),),
//                 ),
//                 SizedBox(width: 5),
//                 setICon(context, wallPOst['visibility'])
//               ],
//             ),
//             trailing: IconButton(
//               icon: Icon(
//                 Icons.more_vert,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                   ),
//                   builder: (context) {
//                     return Container(
//                       height: MediaQuery.of(context).size.height, // 4/3 of the screen height
//                       padding: const EdgeInsets.all(16.0),
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: objectList.length, // Display 10 elements
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: (){
//                               objectList[index].apiCall;
//                             },
//                             child: ListTile(
//                               leading: objectList[index].icon,
//                               title: Text(objectList[index].name, style: TextStyle(color: Colors.black)),
//                               subtitle: Text(objectList[index].description, style: TextStyle(color: Colors.black38)),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//               left: 16,
//               right: 16,
//               top: 8,
//               bottom: 8,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 //
//                 ExpandableText(wallPOst['contentText'].toString())
//
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => FullScreenImage(data: wallPOst),
//                 ),
//               );
//             },
//             child: AspectRatio(
//               aspectRatio: 16 / 9,
//               child: wallPOst['Media'] != null && wallPOst['Media'].length > 1
//                   ? GridView.builder(
//                 padding: const EdgeInsets.all(8.0),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2, // Number of columns
//                   crossAxisSpacing: 8.0, // Horizontal spacing
//                   mainAxisSpacing: 8.0, // Vertical spacing
//                 ),
//                 itemCount: wallPOst['Media'].length,
//                 itemBuilder: (context, index) {
//                   return ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0), // Rounded corners
//                     child: CachedNetworkImage(
//                       imageUrl:
//                       imagePathSetter(
//                         imageName: wallPOst['Media'][index]['url'],
//                         imageSize: "MEDIUM",
//                         requestingImageType: "POST",
//                         setUserId: wallPOst['userId'].toString(),
//                       ),
//                       //'https://ms3-needle.blr1.cdn.digitaloceanspaces.com/3/POST/MEDIUM/${wallPOst['Media'][index]['url']}',
//                       fit: BoxFit.cover,
//                     ),
//                   );
//                 },
//               )
//                   : Text('asd'),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.favorite_border,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                       onPressed: () {
//                         print('object');
//                       },
//                     ),
//                     Text("Like", style: TextStyle(color: Colors.black)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.comment,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                       onPressed: () {},
//                     ),
//                     Text("Comment", style: TextStyle(color: Colors.black)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.share,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                       onPressed: () {},
//                     ),
//                     Text("Share", style: TextStyle(color: Colors.black)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Text('Post caption goes here...'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controller/api/api_controller.dart';
import '../../controller/config/image_path_setter.dart';
import '../../model/postCustomObject.dart';
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

  @override
  Widget build(BuildContext context) {
    final DateTime postDate = DateTime.parse(widget.wallPost['createdAt']);
    final String formattedDate = timeago.format(postDate);

    ImageProvider<Object>? _profileImage = widget.wallPost['userProfileImage'] != null
        ? CachedNetworkImageProvider(
            imagePathSetter(
              imageName: widget.wallPost['userProfileImage'],
              imageSize: "MEDIUM",
              requestingImageType: "POST",
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
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
