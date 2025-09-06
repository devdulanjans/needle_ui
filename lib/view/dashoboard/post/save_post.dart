import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../post_card.dart';

class SavePost extends StatefulWidget {
  const SavePost({super.key});

  @override
  State<SavePost> createState() => _SavePostState();
}

class _SavePostState extends State<SavePost> {
  List<dynamic> savedPosts = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedPostsJson = prefs.getString('savedPosts');
    if (savedPostsJson != null) {
      setState(() {
        savedPosts = jsonDecode(savedPostsJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts', style: TextStyle(color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
      ),
      body:
          savedPosts.isNotEmpty
              ? ListView.builder(
                itemCount: savedPosts.length,
                itemBuilder: (context, index) {
                  final post = savedPosts[index];
                  return PostCard(post);
                },
              )
              : const Center(
                child: Text(
                  'No saved posts available.',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
    );
  }
}
