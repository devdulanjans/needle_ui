import 'dart:convert';

import 'package:flutter/material.dart';

import '../../controller/api/api_controller.dart';
import '../../controller/auth_controller.dart';
import 'page_finish.dart';

class PageCategory extends StatefulWidget {
  String pageName;

  PageCategory({super.key, required this.pageName});

  @override
  State<PageCategory> createState() => _PageCategoryState();
}

class _PageCategoryState extends State<PageCategory> {
  String? _selectedCategory;
  final List<String> _categories = [
    // Business & Brand
    "Advertising/Marketing",
    "Agriculture",
    "Apparel & Clothing",
    "Automotive",
    "Beauty, Cosmetic & Personal Care",
    "Construction Company",
    "Consulting Agency",
    "Education Website",
    "Engineering Service",
    "Event Planner",
    "Financial Services",
    "Health/Beauty",
    "Home Improvement",
    "Information Technology Company",
    "Internet Company",
    "Local Service",
    "Media/News Company",
    "Non-Governmental Organization (NGO)",
    "Nonprofit Organization",
    "Product/Service",
    "Real Estate",
    "Software Company",
    "Travel Company",

    // Local Business
    "Bakery",
    "Bar",
    "Cafe",
    "Grocery Store",
    "Hotel",
    "Local Business",
    "Pharmacy",
    "Restaurant",
    "Shopping & Retail",
    "Spa",
    "Tattoo & Piercing Shop",

    // Public Figure
    "Actor",
    "Artist",
    "Athlete",
    "Blogger",
    "Chef",
    "Coach",
    "Comedian",
    "Doctor",
    "Entrepreneur",
    "Gamer",
    "Journalist",
    "Model",
    "Musician/Band",
    "Photographer",
    "Politician",
    "Public Figure",
    "Teacher",
    "Writer",

    // Entertainment & Media
    "Arts & Entertainment",
    "Book & Magazine",
    "Movie",
    "Music",
    "News & Media Website",
    "Podcast",
    "Radio Station",
    "Sports Team",
    "TV Network",
    "Video Creator",

    // Organization
    "Charity Organization",
    "Church",
    "Community Organization",
    "Government Organization",
    "Nonprofit Organization",
    "Religious Organization",
    "School",
    "University",
  ];

  Future<void> createPage() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => FinishPage(
              page_id: 1,
              page_name: widget.pageName,
              page_details: "data",
              selectedCategory: _selectedCategory!,
            ),
      ),
    );
    return;

    var _userId = await getUserId();

    var bodyData = {
      "displayName": widget.pageName,
      "bio": "",
      "ownerId": int.parse(_userId.toString()),
      "category": _selectedCategory,
      "profilePicture": "",
      "coverPicture": "",
    };

    print("bodyData: $bodyData");
    // return;

    var responseData = await API_V1_call(
      url: "/api/page",
      method: "POST",
      body: bodyData,
      isHeader: true,
    );

    print("responseData.statusCode: ${responseData.body}");
    print("responseData.statusCode 1: ${responseData.statusCode}");

    if (responseData.statusCode == 201) {
      final data =
          jsonDecode(responseData.body)['data'] == null
              ? []
              : jsonDecode(responseData.body)['data'];
      print("1122 - responseData: $responseData");
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder:
      //         (context) => FinishPage(
      //           page_id: 1,
      //           page_name: widget.pageName,
      //           page_details: data,
      //         ),
      //   ),
      // );

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Error fetching stories')));
    } else {
      // Handle error
      setState(() {
        // _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'error storing data',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

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
              "What category best describe ${widget.pageName}",
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
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Category',
                    style: TextStyle(color: Colors.purple),
                  ),
                  value: _selectedCategory,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.purple),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items:
                      _categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ),
            ),
            Spacer(), // Pushes the button to the bottom
            if (_selectedCategory != null && _selectedCategory!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15.0),
                child: Text(
                  "By Creating a page, you agree to our Terms, Data Policy and Cookies Policy. You may receive SMS notifications from us and can opt out at any time.",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            SizedBox(height: 10),
            if (_selectedCategory != null && _selectedCategory!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                // Add some padding at the bottom
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        print("_selectedCategory: $_selectedCategory");
                        createPage();
                        // Handle Next button press
                      },
                      child: Text(
                        'Create',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.purple, // Button background color
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
}
