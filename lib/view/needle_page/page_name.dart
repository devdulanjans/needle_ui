import 'package:flutter/material.dart';

import 'page_catagory.dart';

class PageName extends StatefulWidget {
  const PageName({super.key});

  @override
  State<PageName> createState() => _PageNameState();
}

class _PageNameState extends State<PageName> {
  String _pageName = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Get started with a Page",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Use the name of your business, brand or organization, or a name that helps explain your page",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                pageLearnMoreBottomSheet(context);
              },
              child: Text(
                "Learn More",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              style: TextStyle(
                color: Colors.black, // Set the text color to black
              ),
              onChanged: (value) {
                setState(() { _pageName = value; });
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Border color when enabled
                  borderRadius: BorderRadius.circular(10), // Curved corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple), // Border color when focused
                  borderRadius: BorderRadius.circular(10), // Curved corners
                ),
                hintText: 'Page Name', // Optional hint text
                hintStyle: TextStyle(color: Colors.purple)
              ),
            ),
            Spacer(), // Pushes the button to the bottom
            if (_pageName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0), // Add some padding at the bottom
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        print("_pageName: $_pageName");
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PageCategory(pageName: _pageName,),
                          ),
                        );

                        // Handle Next button press
                      },
                      child: Text('Next', style: TextStyle(color: Colors.white, fontSize: 16),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, // Button background color
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> pageLearnMoreBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400, // Adjust height as needed
          child: Column(
            children: <Widget>[
              // Image.network( // Replace with your image asset or network URL
              //   'https://via.placeholder.com/400x150', // Example image
              //   fit: BoxFit.cover,
              //   height: 150,
              //   width: double.infinity,
              // ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Information Point 1'),
                onTap: () {
                  // Handle tap
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings Option 2'),
                onTap: () {
                  // Handle tap
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help & Support 3'),
                onTap: () {
                  // Handle tap
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
