import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:needle2/controller/auth_controller.dart';

import '../../controller/api/api_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'pirunthaparasuram@gmail.com');
  final _passwordController = TextEditingController(text: '123456789');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        // color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                // SizedBox(height: 20),
                _buildForm(context),
                SizedBox(height: 30),
                _buildSocialLogin(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        SizedBox(height: 50),
        Image.asset('assets/logo.png',width: 100,),
        SizedBox(height: 50)
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email, color: Colors.white70),
            ),
            validator: (value) => value!.contains('@') ? null : 'Invalid email',
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock, color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) => value!.length >= 6 ? null : 'Min 6 characters',
          ),
          SizedBox(height: 25),
          _isLoading == false ? ElevatedButton(
            onPressed: () {
              loginAction(context);
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
                Text('Sign In', style: TextStyle(fontSize: 18,color: Theme.of(context).colorScheme.surface)),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward,color: Theme.of(context).colorScheme.surface,),
              ],
            ),
          ):CircularProgressIndicator(),
          TextButton(
            onPressed: () {},
            child: Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("New here?", style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text('Create Account', style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Future<void> loginAction(BuildContext context) async {
  //   // Navigator.pushNamed(context, '/main');
  //   // return;
  //   if (_formKey.currentState!.validate()) {
  //     //sasof82100@oziere.com
  //     var bodyData = {
  //       "email":_emailController.text,
  //       "password":_passwordController.text
  //     };
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     var responseData = await API_V1_call(url: "/api/access/signin",method: "POST",body:bodyData);
  //     var responseDecode = json.decode(responseData.body);
  //     print("responsData: ${responseDecode['message'].toString()}");
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Sign In Status', style: TextStyle(color: Colors.deepPurple),),
  //           content: Text(responseDecode['message'].toString(), style: TextStyle(color: Colors.deepPurple)),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 if (responseDecode['message'].toString() == 'LogIn Success') {
  //                   Navigator.pushNamed(context, '/main');
  //                 }
  //               },
  //               child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //
  //   }
  // }


  Future<void> loginAction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var responseDecode = await LoginAPICAll();

      if (responseDecode['message'].toString() == 'LogIn Success') {

        await saveTokens(
          accessToken: responseDecode['data']['accessToken'],
          refreshToken: responseDecode['data']['refreshToken'],
          userId: responseDecode['data']['userId'].toString(),
          email: responseDecode['data']['email'].toString(),
          bio: responseDecode['data']['bio'].toString(),
          displayName: responseDecode['data']['displayName'].toString(),
          mobileNo: responseDecode['data']['mobileNo'].toString(),
          profilePicture: responseDecode['data']['profilePicture'].toString(),
          coverImage: responseDecode['data']['coverImage'].toString()
        );

        Navigator.pushNamed(context, '/main');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sign In Status', style: TextStyle(color: Colors.deepPurple)),
              content: Text(responseDecode['message'].toString(), style: TextStyle(color: Colors.deepPurple)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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

  Future<dynamic> LoginAPICAll() async {
    var bodyData = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };
    setState(() {
      _isLoading = true;
    });
    var responseData = await API_V1_call(
      url: "/api/access/signin",
      method: "POST",
      body: bodyData,
      isHeader: false
    );
    var responseDecode = json.decode(responseData.body);
    print("responseData: ${responseDecode['message'].toString()}");
    setState(() {
      _isLoading = false;
    });
    return responseDecode;
  }

  Widget _buildSocialLogin(BuildContext context) {
    return Column(
      children: [
        Text('or continue with', style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        )),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              color: Colors.redAccent,
              onPressed: () {},
            ),
            SizedBox(width: 20),
            _buildSocialButton(
              icon: Icons.apple,
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: 30, color: color),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}