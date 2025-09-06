import 'dart:convert';

import 'package:flutter/material.dart';

import '../../controller/api/api_controller.dart';
import '../../controller/auth_controller.dart';
import 'page_profile_image_set.dart';

class FinishPage extends StatefulWidget {
  int page_id;
  String page_name;
  var page_details;
  String selectedCategory;

  FinishPage({
    super.key,
    required this.page_id,
    required this.page_name,
    required this.page_details,
    required this.selectedCategory,
  });

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  String _selectedOption = "";
  String openingHoursStatus = "1";
  TextEditingController bioTextController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  void callProfileImagePage(int pageId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PageProfileImageSet(
              page_id: pageId,
              page_name: widget.page_name,
              selectedCategory: widget.selectedCategory,
              bio: bioTextController.text,
            ),
      ),
    );
  }

  Future<void> createPage() async {
    var _userId = await getUserId();

    var bodyData = <String, Object?>{
      "displayName": widget.page_name ?? "",
      "bio": bioTextController.text ?? "",
      "ownerId": int.parse(_userId.toString()),
      "category": widget.selectedCategory ?? "",
      "profilePicture": "",
      "coverPicture": "",
      "website": websiteController.text ?? "",
      "email": emailController.text ?? "",
      "contactNumber": phoneNumberController.text ?? "",
      "address": {
        "street": addressController.text ?? "",
        "city": cityController.text ?? "",
        "state": stateController.text ?? "",
        "country": countryController.text ?? "",
        "zipCode": zipCodeController.text ?? "",
      },
      "openHoursStatus": int.parse(openingHoursStatus) ?? "",
      "standardHours": [],
    };

    // var bodyData = <String, Object?>{
    //   "displayName": "First Page",
    //   "bio": "sfbgg",
    //   "ownerId": 1,
    //   "category": "BUSINESS",
    //   "profilePicture": "",
    //   "coverPicture": "",
    //   "website": "https://example.com",
    //   "email": "info@example.com",
    //   "contactNumber": "+1234567890",
    //   "address": {
    //     "street": "123 Main St",
    //     "city": "Metropolis",
    //     "state": "Central",
    //     "country": "Countryland",
    //     "zipCode": "12345"
    //   },
    //   "openHoursStatus": 3,
    //   "standardHours": [
    //     {
    //       "dayOfWeek": 1,
    //       "openTime": "09:00",
    //       "closeTime": "17:00",
    //       "isClosed": false
    //     },
    //     {
    //       "dayOfWeek": 2,
    //       "openTime": "09:00",
    //       "closeTime": "17:00",
    //       "isClosed": false
    //     },
    //     {
    //       "dayOfWeek": 0,
    //       "openTime": "",
    //       "closeTime": "",
    //       "isClosed": true
    //     }
    //   ]
    // };

    print("bodyData: $bodyData");

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
      print("1122 - responseData: $data");
      callProfileImagePage(data['id']);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching stories')));
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
    print("DATA SET: ${widget.page_details}");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(
                        context,
                      ).size.height, // Ensures the Column has a minimum height
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Finish setting up your Page",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Success! you've created your ${widget.page_name} page. Now you can add more details to make it stand out.",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(height: 20),

                      //general section
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            radius: 18,
                            child: Icon(Icons.info, color: Colors.black),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "General",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: bioTextController,
                        style: TextStyle(
                          color: Colors.black, // Set the text color to black
                        ),
                        onChanged: (value) {
                          // setState(() { _pageName = value; });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            // Border color when enabled
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.purple.shade300,
                            ),
                            // Border color when focused
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          hintText: 'Bio', // Optional hint text
                          hintStyle: TextStyle(color: Colors.purple),
                        ),
                      ),
                      SizedBox(height: 20),

                      //contact section
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            radius: 18,
                            child: Icon(
                              Icons.quick_contacts_mail_sharp,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "Contact",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: Colors.black, // Set the text color to black
                        ),
                        onChanged: (value) {
                          // setState(() { _pageName = value; });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            // Border color when enabled
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                            // Border color when focused
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          hintText: 'Website', // Optional hint text
                          hintStyle: TextStyle(color: Colors.purple),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: Colors.black, // Set the text color to black
                        ),
                        onChanged: (value) {
                          // setState(() { _pageName = value; });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            // Border color when enabled
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                            // Border color when focused
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          hintText: 'Email', // Optional hint text
                          hintStyle: TextStyle(color: Colors.purple),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: Colors.black, // Set the text color to black
                        ),
                        onChanged: (value) {
                          // setState(() { _pageName = value; });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            // Border color when enabled
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                            // Border color when focused
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          hintText: 'Phone number', // Optional hint text
                          hintStyle: TextStyle(color: Colors.purple),
                        ),
                      ),
                      SizedBox(height: 20),

                      //location section
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            radius: 18,
                            child: Icon(
                              Icons.quick_contacts_mail_sharp,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "Contact",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: Colors.black, // Set the text color to black
                        ),
                        onChanged: (value) {
                          // setState(() { _pageName = value; });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            // Border color when enabled
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                            // Border color when focused
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          hintText: 'Address', // Optional hint text
                          hintStyle: TextStyle(color: Colors.purple),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: Colors.black, // Set the text color to black
                        ),
                        onChanged: (value) {
                          // setState(() { _pageName = value; });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            // Border color when enabled
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                            // Border color when focused
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          hintText: 'City/town', // Optional hint text
                          hintStyle: TextStyle(color: Colors.purple),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: Colors.black, // Set the text color to black
                        ),
                        onChanged: (value) {
                          // setState(() { _pageName = value; });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            // Border color when enabled
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                            // Border color when focused
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Curved corners
                          ),
                          hintText: 'Postcode', // Optional hint text
                          hintStyle: TextStyle(color: Colors.purple),
                        ),
                      ),
                      SizedBox(height: 20),

                      //hours section
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            radius: 18,
                            child: Icon(
                              Icons.access_time_filled_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "Hours",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedOption = "no hours available";
                            openingHoursStatus = "1";
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Center(
                            child: ListTile(
                              trailing: Radio<String>(
                                value: 'no hours available',
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  print("value: $value");
                                  setState(() {
                                    _selectedOption = value!;
                                    openingHoursStatus = "1";
                                  });
                                },
                              ),
                              title: Text(
                                'No hours available',
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                "Don't show any hours",
                                style: TextStyle(color: Colors.black38),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedOption = "always open";
                            openingHoursStatus = "2";
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Center(
                            child: ListTile(
                              trailing: Radio<String>(
                                value: 'always open',
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  print("value: $value");
                                  setState(() {
                                    _selectedOption = value!;
                                  });
                                },
                              ),
                              title: Text(
                                'Always Open',
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                "You're open 24 hours every day",
                                style: TextStyle(color: Colors.black38),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedOption = "no hours open";
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Center(
                            child: ListTile(
                              trailing: Radio<String>(
                                value: 'no hours open',
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  print("value: $value");
                                  setState(() {
                                    _selectedOption = value!;
                                  });
                                },
                              ),
                              title: Text(
                                'Standard hours',
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                "Enter your specific hours",
                                style: TextStyle(color: Colors.black38),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      Spacer(),
                      SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              width: MediaQuery.of(context).size.width - 30,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15.0),
                    child: Text(
                      "By Creating a page, you agree to our Terms, Data Policy and Cookies Policy. You may receive SMS notifications from us and can opt out at any time.",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    // Add some padding at the bottom
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            // callProfileImagePage();
                            createPage();
                          },
                          child: Text(
                            'Next',
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
          ),
        ],
      ),
    );
  }
}
