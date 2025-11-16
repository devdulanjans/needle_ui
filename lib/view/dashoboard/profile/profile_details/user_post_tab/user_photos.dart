import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../controller/api/api_controller.dart';
import '../../../../../controller/config/image_path_setter.dart';

class UserPhotos extends StatefulWidget {
  final userDisplayName;
  final userId;

  const UserPhotos({this.userId, this.userDisplayName, super.key});

  @override
  State<UserPhotos> createState() => _UserPhotosState();
}

class _UserPhotosState extends State<UserPhotos> {
  bool isLoading = false;
  List<dynamic> _allPostData = [];

  Future<void> _getUserPost() async {
    if (!mounted) return; // Ensure the widget is still in the tree

    setState(() {
      isLoading = true;
    });

    try {

      final responseData = await API_V1_call(
        url: "/api/post/user/${widget.userId}?page=0&limit=100",
        method: "GET",
        isHeader: true,
      );

      print("responseData.statusCode: ${responseData.statusCode}");

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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0,left: 8.0),
      child: _allPostData
              .where((post) => post['Media'] != null && post['Media'].isNotEmpty)
              .toList()
              .isNotEmpty
          ? GridView.builder(
              shrinkWrap: true, // Ensures the GridView doesn't take infinite height
              physics: NeverScrollableScrollPhysics(), // Prevents scrolling inside the GridView
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _allPostData
                  .where((post) => post['Media'] != null && post['Media'].isNotEmpty)
                  .length,
              itemBuilder: (context, index) {
                final postWithMedia = _allPostData
                    .where((post) => post['Media'] != null && post['Media'].isNotEmpty)
                    .toList()[index];
                final media = postWithMedia['Media'];
                print("media - ${index}: ${media}");
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: imagePathSetter(
                      imageName: media[0]['url'], // Assuming the first media item is an image
                      imageSize: "MEDIUM",
                      requestingImageType: "POST",
                      setUserId: postWithMedia['userId'].toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                );
              }
            )
          : Center(
              child: Text(
                "",
                style: TextStyle(color: Colors.black),
              ),
            ),
    );
  }
}
