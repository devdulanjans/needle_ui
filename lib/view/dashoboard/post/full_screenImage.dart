// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// import '../../../controller/config/image_path_setter.dart';
//
// class FullScreenImage extends StatefulWidget {
//   final Map<String, dynamic> data;
//
//   FullScreenImage({required this.data});
//
//   @override
//   _FullScreenImageState createState() => _FullScreenImageState();
// }
//
// class _FullScreenImageState extends State<FullScreenImage> {
//   late PageController _pageController;
//   late ValueNotifier<int> _currentIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     print("WIFE CENTER DATA: ${widget.data}");
//     _pageController = PageController();
//     _currentIndex = ValueNotifier<int>(0);
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _currentIndex.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaList = widget.data['Media'];
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(Icons.close),
//         ),
//         title: ValueListenableBuilder<int>(
//           valueListenable: _currentIndex,
//           builder: (context, index, _) {
//             return Text('${index + 1} / ${mediaList.length}');
//           },
//         ),
//         centerTitle: true,
//       ),
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: mediaList.length > 1
//                   ? PageView.builder(
//                 controller: _pageController,
//                 itemCount: mediaList.length,
//                 onPageChanged: (index) {
//                   _currentIndex.value = index;
//                 },
//                 itemBuilder: (context, index) {
//                   return Column(
//                     children: [
//                       Text(mediaList[index]['url'].toString(), style: TextStyle(color: Colors.white),),
//                       Text(widget.data['creatorId'].toString(), style: TextStyle(color: Colors.white),),
//                       CachedNetworkImage(
//                         // imageUrl: 'https://www.bigfootdigital.co.uk/wp-content/uploads/2020/07/image-optimisation-scaled.jpg',
//                         imageUrl: imagePathSetter(
//                           imageName: mediaList[index]['url'],
//                           imageSize: "FULL",
//                           requestingImageType: "POST",
//                           setUserId: widget.data['creatorId'].toString(),
//                         ),
//                         fit: BoxFit.contain,
//                       ),
//                       SingleChildScrollView(child: Text(widget.data['contentText'].toString(), style: TextStyle(color: Colors.white),)),
//                     ],
//                   );
//                 },
//               )
//                   : CachedNetworkImage(
//                 imageUrl: imagePathSetter(
//                   imageName: mediaList[0]['url'],
//                   imageSize: "FULL",
//                   requestingImageType: "POST",
//                   setUserId: widget.data['creatorId'].toString(),
//                 ),
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     _showBottomSheet(context);
//                   },
//                   child: Text("Like", style: TextStyle(color: Colors.white)),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     _showBottomSheet(context);
//                   },
//                   child: Text("Comment", style: TextStyle(color: Colors.white)),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     _showBottomSheet(context);
//                   },
//                   child: Text("Share", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Share Post",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildShareOption(Icons.facebook, "Facebook"),
//                   _buildShareOption(Icons.call, "WhatsApp"),
//                   _buildShareOption(Icons.email, "Email"),
//                 ],
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text("Close"),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildShareOption(IconData icon, String label) {
//     return Column(
//       children: [
//         Icon(icon, size: 32, color: Colors.blue),
//         SizedBox(height: 8),
//         Text(label),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../controller/config/image_path_setter.dart';

class FullScreenImage extends StatefulWidget {
  final Map<String, dynamic> data;

  FullScreenImage({required this.data});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late PageController _pageController;
  late ValueNotifier<int> _currentIndex;
  late TransformationController _transformationController;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndex = ValueNotifier<int>(0);
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      if (_isZoomed) {
        _transformationController.value = Matrix4.identity(); // Reset zoom
      } else {
        _transformationController.value = Matrix4.identity()..scale(2.0); // Zoom in
      }
      _isZoomed = !_isZoomed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.data['Media'];
    final likeCount = widget.data['likeCount'] ?? 0;
    final shareCount = widget.data['shareCount'] ?? 0;
    final comments = widget.data['comments'] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.close),
        ),
        title: ValueListenableBuilder<int>(
          valueListenable: _currentIndex,
          builder: (context, index, _) {
            return Text('${index + 1} / ${mediaList.length}');
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: mediaList.length > 1
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: mediaList.length,
                      onPageChanged: (index) {
                        _currentIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onDoubleTap: _handleDoubleTap,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            panEnabled: true,
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: CachedNetworkImage(
                              imageUrl: imagePathSetter(
                                imageName: mediaList[index]['url'],
                                imageSize: "FULL",
                                requestingImageType: "POST",
                                setUserId: widget.data['creatorId'].toString(),
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    )
                  : GestureDetector(
                      onDoubleTap: _handleDoubleTap,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: imagePathSetter(
                            imageName: mediaList[0]['url'],
                            imageSize: "FULL",
                            requestingImageType: "POST",
                            setUserId: widget.data['creatorId'].toString(),
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Like and Share Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    likeCount != 0?Text('Likes: $likeCount', style: TextStyle(color: Colors.white)):Text(''),
                    shareCount != 0?Text('Shares: $shareCount', style: TextStyle(color: Colors.white)):Text(''),
                    comments.length != 0?Text('Comments:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)):Text(''),
                    SizedBox(height: 8),
                  ],
                ),
                // SizedBox(height: 8),
                // Comments Section

                comments.isNotEmpty
                    ? Container(
                  height: 100, // Adjust height as needed
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          comments[index],
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                )
                    : Text(''),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    // _showBottomSheet(context);
                  },
                  onLongPress: (){

                  },
                  child: Row(children: [
                      Icon(Icons.thumb_up_sharp, color: Colors.white,),
                      SizedBox(width: 5,),
                      Text("Like", style: TextStyle(color: Colors.white))
                  ]),
                ),
                TextButton(
                  onPressed: () {
                    _showBottomSheet(context);
                  },
                  child: Row(children: [
                    Icon(Icons.comment, color: Colors.white,),
                    SizedBox(width: 5,),
                    Text("Comment", style: TextStyle(color: Colors.white))
                  ]),
                ),
                TextButton(
                  onPressed: () {
                    _showBottomSheet(context);
                  },
                  child: Row(children: [
                    Icon(Icons.share, color: Colors.white,),
                    SizedBox(width: 5,),
                    Text("Share", style: TextStyle(color: Colors.white))
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Share Post",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareOption(Icons.facebook, "Facebook"),
                  _buildShareOption(Icons.call, "WhatsApp"),
                  _buildShareOption(Icons.email, "Email"),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}