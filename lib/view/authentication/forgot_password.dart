import 'dart:convert';

import 'package:flutter/material.dart';

import '../../controller/api/api_controller.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _email = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSignupForm(context),
                if (_isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
                  'Send Verification Code',
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
        ],
      ),
    );
  }

  Future<void> signupAction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });

      var bodyData = {
        "email": _email.text,
      };

      print(bodyData);
      var responseData = await API_V1_call(
        url: "/api/account/forgot-password?",
        method: "POST",
        body: bodyData,
        isHeader: false
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
            title: Text('Forgot Password', style: TextStyle(color: Colors.deepPurple),),
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