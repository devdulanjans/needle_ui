import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../controller/api/api_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/config/image_path_setter.dart';
import '../../model/logged_user_profile_model.dart';
import '../global_search.dart';
import 'post/create_post_2.dart';
import 'post_card.dart';
import 'profile/profile.dart';
import 'story/story.dart';

class HomeFeed extends StatefulWidget {
  final bool refreshStories;
  const HomeFeed({super.key, this.refreshStories = false});
  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<dynamic> _allPostData = [];
  String _profileImage = "";
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _getAllPost(page: _currentPage);
    profileData();
    // if (widget.refreshStories) {
    //   // Call your story fetching function here, for example:
    //   // _fetchStories();
    // }
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
      _searchResults = [];
    });

    try {
      final response = await API_V1_call(
        url: "/api/user/search?searchKeyword=$query",
        method: "GET",
      );

      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body)['data'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        setState(() {
          _searchResults = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching search results')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> profileData()async{
    var _userId = await getUserId();
    var _imageUrl = await getUserProfilePicture();

    setState(() {

      if(_imageUrl != null && _imageUrl.isNotEmpty){
        _profileImage = imagePathSetter(
          imageName: _imageUrl,
          imageSize: "THUMBNAIL",
          requestingImageType: "PROFILE",
          setUserId: _userId,
        );

      } else {
        _profileImage = "";
      }

    });

    print("PROFILE IMAGE: $_profileImage");

  }

  Future<void> _getAllPost({int page = 0, int limit = 30}) async {
    print("SCROLLING");
    if (_isFetchingMore) return;
    setState(() {
      _isFetchingMore = true;
    });

    var responseData = await API_V1_call(
      url: "/api/post/all?page=$page&limit=$limit",
      method: "GET",
    );

    if (responseData.statusCode == 200) {
      var data = [];

      final posts = jsonDecode(responseData.body)['data']['posts'];
      print("123 - Posts data: $posts");
      if (posts != null) {
        data = (posts as List);
      } else {
        print('Posts data is null');
      }

      // setState(() {
      //   if (page == 0) {
      //     _allPostData = data;
      //   } else {
      //     _allPostData.addAll(data);
      //   }
      //   _currentPage = page;
      //   _isFetchingMore = false;
      // });

      setState(() {
        if (page == 0) {
          _allPostData = data;
            // ..sort((a, b) => DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));
        } else {
          _allPostData.addAll(data);
          // _allPostData.sort((a, b) => DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));
        }
        _currentPage = page;
        _isFetchingMore = false;
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching posts')),
      );
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  void removeElement(int index) {
    print("11223 - REMOVE SELECTED ITEM: $index");
    setState(() {
      _allPostData.removeAt(index);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isFetchingMore) {
        _getAllPost(page: _currentPage + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/logo.png", height: 40),
            ),
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                 // Open search and reset after it's popped
                  await showSearch(
                    context: context,
                    delegate: DataSearch(search: _search),
                  );
                  setState(() {
                    _searchResults = [];
                    _searchQuery = '';
                  });
                },
              ),
            ],
          ),
          // Divider(height: 1, color: Colors.black12),
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 0, bottom: 10),
            color: Colors.white,
            child: Center(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: (_profileImage.isNotEmpty && Uri.tryParse(_profileImage)?.hasAbsolutePath == true)
                      ? NetworkImage(_profileImage)
                      : AssetImage("assets/profile_images.png") as ImageProvider,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.image,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostPage(),
                      ),
                    );
                  },
                ),
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostPage(),
                      ),
                    );
                  },
                  child: Text(
                    "What's on your mind?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 10, color: Colors.black12,thickness: 3,),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isFetchingMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _getAllPost(page: _currentPage + 1);
                  return true;
                }
                return false;
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: StoriesList()),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (context, index) => PostCard(_allPostData[index],onPostDeleted: () => removeElement(index)),
                        childCount: _allPostData.length),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


