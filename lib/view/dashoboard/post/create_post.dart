import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CreatePostDialog extends StatefulWidget {
  @override
  _CreatePostDialogState createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        color: Colors.black.withValues(alpha: 0.1,),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          children: [
            _buildHeader(context),
            Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPostInput(),
                    if (_selectedImages.isNotEmpty) _buildImageGrid(),
                    _buildAttachmentOptions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Create Post',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.close),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _postController,
        maxLines: 5,
        minLines: 1,
        decoration: InputDecoration(
          hintText: "What's on your mind?",
          hintStyle: TextStyle(fontSize: 20.0, color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) => Stack(
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Add to Your Post', style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary)),
              Spacer(),
              ElevatedButton(
                onPressed: _selectedImages.isEmpty || _postController.text.isNotEmpty
                    ? _handlePost
                    : null,
                child: Text('Post',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentButton(
                icon: Icons.photo_library,
                label: 'Photo/Video',
                onPressed: _pickImages,
              ),
              // Add more buttons for other attachments if needed
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          SizedBox(width: 8),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  Future<XFile> normalizeImage(XFile xfile) async {
    final file = File(xfile.path);
    final bytes = await file.readAsBytes();

    final image = img.decodeImage(bytes);
    if (image == null) return xfile;

    // This auto-fixes EXIF rotation
    final fixedImage = img.bakeOrientation(image);

    final tempDir = await getTemporaryDirectory();
    final newPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newFile = File(newPath)
      ..writeAsBytesSync(img.encodeJpg(fixedImage, quality: 95));

    return XFile(newFile.path);
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 10) {
          _selectedImages = _selectedImages.sublist(0, 10);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum 10 images allowed')),
          );
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handlePost() async{
    // Handle post creation logic here
    final fixedImages = await Future.wait(
      _selectedImages.map((image) => normalizeImage(image)),
    );
    final newPost = {
      'text': _postController.text,
      'images': fixedImages.map((file) => file.path).toList(),
    };
    print(newPost); // Replace with actual post handling
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}

// Add this to your existing code where you want to trigger the post creation
// Example usage in your HomeFeed screen:
