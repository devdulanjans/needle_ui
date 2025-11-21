import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../../controller/api/api_controller.dart';
import '../../../../../controller/auth_controller.dart';
import '../../../../../controller/config/image_path_setter.dart';
import '../../../post_card.dart';
import '../../../widget/common_seperator.dart';

class UserDefinedPost extends StatefulWidget {
  final userDisplayName;
  final userId;
  final userImage;
  const UserDefinedPost({this.userDisplayName, this.userId,this.userImage, super.key});

  @override
  State<UserDefinedPost> createState() => _UserDefinedPostState();
}

class _UserDefinedPostState extends State<UserDefinedPost> {

  bool isLoading = false;
  bool isPage = false;
  List<dynamic> _allPostData = [];

  Future<void> _getUserPost() async {
    if (!mounted) return; // Ensure the widget is still in the tree

    setState(() {
      isLoading = true;
    });

    try {
      String postType = await getProfileType(type: 2) ?? "user";
      String apiUrl = postType == "user" ? "/api/post/$postType" : "/api/$postType/posts";
      isPage = postType == "user" ? false : true;
      final responseData = await API_V1_call(
        url: "$apiUrl/${widget.userId}?page=0&limit=100",
        method: "GET",
        isHeader: true,
      );


      if (responseData.statusCode == 200) {
        var data = [];
        dynamic posts;

        if(postType == "user"){
          posts = jsonDecode(responseData.body)['data'];
        }else if(postType == "page"){
          posts = jsonDecode(responseData.body)['data']['posts'];
        }


        if (posts != null) {
          data = (posts as List).reversed.toList();
          // Proceed with `data`
        } else {
          print('Posts data is null');
        }

        if (mounted) {
          setState(() {
            _allPostData = data;
            _allPostData.sort((a, b) {
              final dateA = DateTime.parse(a["updatedAt"]);
              final dateB = DateTime.parse(b["updatedAt"]);
              return dateB.compareTo(dateA); // newest first
            });
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching posts')),
          );
        }
      }

    } catch (e) {
      print("Error calling API: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserPost();
  }

  @override
  Widget build(BuildContext context) {
    print("CheckUserImage-USER-DEFINED:${widget.userImage}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8,),
        Container(
          child: Column(
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.edit_calendar_outlined, size: 25, color: Colors.purple),
                        SizedBox(width: 5,),
                        Text(
                          "Write Post",
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.black54,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.image, size: 25, color: Colors.purple),
                        SizedBox(width: 5,),
                        Text(
                          "Share Photo",
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),

            ],
          ),
        ),
        SizedBox(height: 8,),
        Separator(),

        Container(
          width: MediaQuery.of(context).size.width,
          height: 400,
          child: ListView.builder(
            itemBuilder: (context, index) {
              if(isPage){
                _allPostData[index]['userName'] = widget.userDisplayName;
                _allPostData[index]['userProfileImage'] = widget.userImage;
                _allPostData[index]['userProfileId'] =  (_allPostData[index]['createdBy'] ?? 0);
                _allPostData[index]['imageRequestType'] =  "PAGEPROFILE";
                _allPostData[index]['isPage'] =  true;
                _allPostData[index]['contentText'] =  (_allPostData[index]['content'] ?? "");
              }else{
                _allPostData[index]['userProfileId'] =  _allPostData[index]['creatorId'];
                _allPostData[index]['imageRequestType'] =  "PROFILE";
                _allPostData[index]['isPage'] =  false;
              }
              return PostCard(_allPostData[index]);
            },
            itemCount: _allPostData.length,
          ),
        ),
      ],
    );
  }
}
