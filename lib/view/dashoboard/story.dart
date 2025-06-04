// import 'package:flutter/material.dart';
//
// import 'widget/story_item_widget.dart';
//
// class StoriesList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 250,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 10,
//         itemBuilder: (context, index) => StoryItem(imageUrl: "https://randomuser.me/api/portraits/women/${45 + 1}.jpg"),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../controller/api/api_controller.dart';
import 'widget/empty_story_widget.dart';
import 'widget/story_item_widget.dart';

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
    final newStory = {
      "id": "0",
      "userId": "",
      "contentMediaType": "",
      "contentMediaUrl": "",
      "contentText": "Car Race",
      "createdAt": "2025-04-07T06:07:38.208623Z",
      "viewCount": 0,
      "displayName": "Parasuram",
      "profileUrl": "",
    };

    // Add the object to the _stories list
    setState(() {
      _stories.add(newStory);
    });

    var responseData = await API_V1_call(
      url: "/api/story/friends?includeOwn=true",
      method: "GET",
    );

    print('asd - Response: ${responseData.statusCode}');
    print('asd - Response: ${responseData.body}');

    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body)['data'] == null
          ? []
          : jsonDecode(responseData.body)['data'];
      print(responseData);
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
          height: 200,
          child:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _stories.isEmpty
                  ? EmptyStoryWidget()
                  : ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      return StoryItem(stories: _stories[index]);
                    },
                  ),
        ),
      ],
    );
  }
}
