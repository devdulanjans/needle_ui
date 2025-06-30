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
  const UserDefinedPost({this.userDisplayName, this.userId, super.key});

  @override
  State<UserDefinedPost> createState() => _UserDefinedPostState();
}

class _UserDefinedPostState extends State<UserDefinedPost> {

  bool isLoading = false;
  List<dynamic> _allPostData = [];

  Future<void> _getUserPost() async {
    if (!mounted) return; // Ensure the widget is still in the tree

    setState(() {
      isLoading = true;
    });

    try {

      final responseData = await API_V1_call(
        url: "/api/post/user/${widget.userId}?page=0&limit=20",
        method: "GET",
        isHeader: true,
      );

      if (responseData.statusCode == 200) {
        var data = [];

        final posts = jsonDecode(responseData.body)['data'];

        if (posts != null) {
          data = (posts as List).reversed.toList();
          // Proceed with `data`
        } else {
          print('Posts data is null');
        }

        if (mounted) {
          setState(() {
            _allPostData = data;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8,),
        Container(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, size: 25, color: Colors.purple),
                  SizedBox(width: 5,),
                  Text(
                    "${widget.userDisplayName}'s Posts",
                    style: TextStyle(
                      fontSize: 16,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
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
              return PostCard(_allPostData[index]);
            },
            itemCount: _allPostData.length,
          ),
        ),
      ],
    );
  }
}
