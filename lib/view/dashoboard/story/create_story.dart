import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controller/api/api_controller.dart';
import '../../../controller/auth_controller.dart';
import '../../main_screen.dart';
import '../home_feed.dart';

class CreateStoryPage extends StatefulWidget {
  @override
  _CreateStoryPageState createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool isLoading = false;
  String _selectedValue = "PUBLIC"; // Default value


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Story', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.navigate_before_sharp, color: Colors.black),
          onPressed: _backNavigator,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: isLoading == false?GestureDetector(
              onTap: _handlePost,
              child: Text(
                "Next",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ):CircularProgressIndicator(),
          ),
        ],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:10, left: 40.0),
              child: Container(
                width: 122,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Set the background color
                  borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 12), // Add padding inside the dropdown
                child: DropdownButton<String>(
                  value: _selectedValue,
                  hint: Text("SELECT VISIBILITY", style: TextStyle(color: Colors.grey)),
                  underline: SizedBox.shrink(), // Removes the underline
                  isExpanded: true, // Makes the dropdown take full width
                  items: [
                    DropdownMenuItem(
                      value: "PUBLIC",
                      child: Row(
                        children: [
                          Icon(Icons.public, color: Colors.black26,size: 16,),
                          SizedBox(width: 8),
                          Text("PUBLIC", style: TextStyle(color: Colors.grey,fontSize: 12)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "PRIVATE",
                      child: Row(
                        children: [
                          Icon(Icons.privacy_tip, color: Colors.black26,size: 16,),
                          SizedBox(width: 8),
                          Text("PRIVATE", style: TextStyle(color: Colors.grey,fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedValue = newValue!;
                    });
                  },
                ),
              ),
            ),
            _buildPostInput(),
            if (_selectedImages.isNotEmpty) _buildImageGrid(),
            _buildAttachmentOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: TextStyle(color: Colors.black),
        controller: _postController,
        maxLines: 10,
        minLines: 1,
        decoration: InputDecoration(
          hintText: "What's on your mind?",
          hintStyle: TextStyle(color: Colors.grey),
          // border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _selectedImages.length,
        itemBuilder:
            (context, index) => Stack(
          children: [
            Image.file(
              File(_selectedImages[index].path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentButton(
            icon: Icons.photo_library,
            label: 'Photo/Video',
            onPressed: _selectedImages.isEmpty ? () => _pickImages() : (){}, // Disable if an image is already selected
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages = [image]; // Replace the list with the single selected image
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _backNavigator() {
    Navigator.pop(context);
  }

  void _handlePost() async {

    setState(() {
      isLoading = true;
    });
    List<String> imagePaths = _selectedImages.map((file) => file.path).toList();
    var getImagePaths = _selectedImages;

    List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'];

    List<String?> mediaType = _selectedImages.map((file) {
      String extension = file.path.split('.').last.toLowerCase();
      if (imageExtensions.contains(extension)) {
        return 'IMAGE';
      } else if (videoExtensions.contains(extension)) {
        return 'VIDEO';
      } else {
        return 'UNSUPPORTED';
      }
    }).toList();

    String? userId = await getUserId();

    var bodyData = {
      'contentText': _postController.text,
      "contentMediaType":"IMAGE",
      'visibility': _selectedValue,
      'creatorId':userId
    };

    print("bodyData: $bodyData");
    print("mediaType: $mediaType");

    var responseData = await API_V1_Multipart_call_Story(
        method: "POST",
        url: "/api/story",
        filePaths: _selectedImages[0].path,
        body: bodyData,
        isHeader: true,
        mediaTypes: mediaType[0].toString() // Assuming you want to send the first media type
    );

    var allResponseData = jsonDecode(responseData);
    setState(() {
      isLoading = false;
    });

    print("allResponseData: $allResponseData");

    if (allResponseData['message'] == "story created successfully") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success", style: TextStyle(color: Colors.black)),
            content: Text(allResponseData['message'], style: TextStyle(color: Colors.black),),
            actions: [
              TextButton(
                onPressed: () async {
                  // Pop the dialog
                  Navigator.of(context).pop();
                  // Navigate to HomeFeed and trigger refresh
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                  // Optionally, you can also pop the CreateStoryPage if you don't want to return to it
                  // Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}