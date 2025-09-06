import 'dart:convert';

import 'package:flutter/material.dart';

import '../../controller/api/api_controller.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 40),
                // _buildProfilePicture(),
                // SizedBox(height: 30),
                _buildSignupForm(context),
                if (_isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                dialogBackgroundColor: Colors.red, // Set background color to red
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _dob.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day}";
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white12, // 🔴 Background color added here
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white70),
            SizedBox(width: 10),
            Text(
              _selectedDate != null
                  ? "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}"
                  : 'Date Of Birth',
              style: TextStyle(color: Colors.white,fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(Icons.male, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // ❌ No border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // ❌ No border when focused
        ),
        filled: true, // ✅ Optional: adds background color if desired
        fillColor: Colors.white12, // Optional background color
      ),
      style: TextStyle(color: Colors.black), // Set unselected text color to white
      items: [
        DropdownMenuItem(
          value: 'M',
          child: Text('Male', style: TextStyle(color: Colors.black),),

        ),
        DropdownMenuItem(
          value: 'F',
          child: Text('Female',  style: TextStyle(color: Colors.black)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
            ),
          ),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.edit, size: 20, color: Color(0xFF6A1B9A)),
        ),
      ],
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 20),
          TextFormField(
            controller: _firstName,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'First Name',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.person, color: Colors.white70),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _lastName,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Last Name',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.person, color: Colors.white70),
            ),
          ),
          SizedBox(height: 20),
          buildDatePickerField(context),
          SizedBox(height: 20),
          TextFormField(
            controller: _email,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email, color: Colors.white70),
            ),
          ),
          SizedBox(height: 20),
          buildGenderDropdown(),
          SizedBox(height: 20),
          TextFormField(
            controller: _password,
            obscureText: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock, color: Colors.white70),
            ),
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value!;
                  });
                },
              ),
              Text(
                'I agree to the Terms and Conditions',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              signupAction(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              minimumSize: Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'By signing up, you agree to our Terms of Service and Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> signupAction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_isChecked) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error', style: TextStyle(color: Colors.black)),
              content: Text('You must agree to the Terms and Conditions to proceed.', style: TextStyle(color: Colors.black)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      var displayName = _firstName.text + " " + _lastName.text;

      var bodyData = {
        "email": _email.text,
        "password": _password.text,
        "displayName": displayName,
        "firstName":_firstName.text,
        "lastName":_lastName.text,
        "dob":_dob.text,
        "gender":"1"
      };

      print(bodyData);
      var responseData = await API_V1_call(
        url: "/api/account/signup",
        method: "POST",
        body: bodyData,
      );
      // print("responseDecode: "+responseData.body.toString());
      var responseDecode = json.decode(responseData.body);
      print(responseData);

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sign Up', style: TextStyle(color: Colors.deepPurple),),
            content: Text(responseDecode['message'].toString(), style: TextStyle(color: Colors.deepPurple)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (responseDecode['message'].toString() == 'LogIn Success') {
                    Navigator.pushNamed(context, '/main');
                  }
                },
                child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
              ),
            ],
          );
        },
      );
    }
  }
}