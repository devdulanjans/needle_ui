
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../../controller/api/api_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../../controller/config/image_path_setter.dart';
import '../widget/empty_story_widget.dart';
import '../widget/story_item_widget.dart';

class StoriesList extends StatefulWidget {
  @override
  _StoriesListState createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  List<dynamic> _stories = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchStories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      _fetchStories();
    }
  }

  Future<void> _fetchStories() async {

    var _userName = await getUserName();
    var _userId = await getUserId();
    var _imageUrl = await getUserProfilePicture();

    var prof_image= imagePathSetter(
      imageName: _imageUrl,
      imageSize: "THUMBNAIL",
      requestingImageType: "PROFILE",
      setUserId: _userId,
    );

    print("prof_image: ${prof_image}");

    final newStory = {
      "id": "0",
      "userId": _userId,
      "contentMediaType": "",
      "contentMediaUrl": _imageUrl,
      "contentText": _userName,
      "createdAt": "",
      "viewCount": 0,
      "displayName": _userName,
      "profileUrl": prof_image,
    };

    // Add the object to the _stories list
    setState(() {
      _stories.add(newStory);
    });

    var responseData = await API_V1_call(
      url: "/api/story/friends?includeOwn=true",
      method: "GET",
    );

    print("STORY FETCH: ${responseData.body}");

    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body)['data'] == null
          ? []
          : jsonDecode(responseData.body)['data'];

      setState(() {
        _stories.addAll(data);
        _isLoading = false;
      });

    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching stories')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _stories.isEmpty
                  ? EmptyStoryWidget()
                  : ListView.builder(
                    // controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _stories.length,

                    itemBuilder: (context, index) {
                      return StoryItem(stories: _stories[index], allStories: _stories.cast<Map<String, dynamic>>());
                    },
                  ),
        ),
      ],
    );
  }
}
