import 'package:flutter/material.dart';

import 'page_name.dart';

class ProfileSelectionPage extends StatefulWidget {
  @override
  _ProfileSelectionPageState createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  String _selectedOption = ''; // Default selected option

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
        padding: const EdgeInsets.all(16.0),
        // Keep padding for the overall content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // Wrap the content that should scroll in an Expanded widget
              child: SingleChildScrollView(
                // Allow content to scroll if it overflows
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your profile type:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOption = "Personal Profile";
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Or any other color you prefer
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          border: Border.all(
                            color:
                                _selectedOption == 'Personal Profile'
                                    ? Colors
                                        .purpleAccent // Change to your desired color
                                    : Colors.grey, // Default border color
                            width:
                                _selectedOption == 'Personal Profile'
                                    ? 2.0
                                    : 1.5, // Specify the border width
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        child: Center(
                          child: ListTile(
                            trailing: Radio<String>(
                              value: 'Personal Profile',
                              groupValue: _selectedOption,
                              onChanged: (value) {
                                print("value: $value");
                                setState(() {
                                  _selectedOption = value!;
                                });
                              },
                            ),
                            title: Text(
                              'Personal Profile',
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              'use another personal profile to explore the Needle',
                              style: TextStyle(color: Colors.black38),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.black26,
                              child: Icon(Icons.manage_accounts),
                            ),
                            // ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOption = "Business Profile";
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Or any other color you prefer
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          border: Border.all(
                            color:
                                _selectedOption == 'Business Profile'
                                    ? Colors
                                        .purpleAccent // Change to your desired color
                                    : Colors.grey, // Default border color
                            width:
                                _selectedOption == 'Business Profile'
                                    ? 2.0
                                    : 1.5, // Specify the border width
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        child: Center(
                          child: ListTile(
                            trailing: Radio<String>(
                              value: 'Business Profile',

                              groupValue: _selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOption = value!;
                                });
                              },
                            ),
                            title: Text(
                              'Business Profile',
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              'Build a public presence for your business or promote your brand or business',
                              style: TextStyle(color: Colors.black38),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.black26,
                              child: Icon(Icons.business),
                            ),
                            // ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Keep SizedBox before the button
            if (_selectedOption.isNotEmpty)
              SizedBox(
                // Ensure the button takes the full width
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.purple,
                    ), // Set the background color to purple
                  ),
                  onPressed: () {
                    print('Selected Option: $_selectedOption');
                    _selectedOption == 'Personal Profile'
                        ? ""
                        : Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => PageName()),
                        );
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
