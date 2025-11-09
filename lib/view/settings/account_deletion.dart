import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../controller/api/api_controller.dart';
import '../../controller/auth_controller.dart';
import '../authentication/login_new.dart';

class AccountDeletionPage extends StatefulWidget {

  const AccountDeletionPage({Key? key}) : super(key: key);

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otherReasonController = TextEditingController();

  String? _selectedReason;
  bool _isLoading = false;
  bool _isTempDeactive = true; // Default to temporary

  final String _apiUrl = "https://yourapi.com/api/account/deactivate";

  final List<String> _reasons = [
    "I am taking a break",
    "I have privacy concerns",
    "Too many notifications",
    "I found a better app",
    "I want to start over",
    "I no longer use this service",
    "Too much time spent here",
    "I have multiple accounts",
    "I’m not satisfied with the app",
    "Other",
  ];

  Future<void> _submitDeletion() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a reason")),
      );
      return;
    }

    String reasonToSend = _selectedReason == "Other"
        ? _otherReasonController.text.trim()
        : _selectedReason!;

    if (_selectedReason == "Other" && reasonToSend.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your reason")),
      );
      return;
    }

    dynamic userId = await getUserId();
    var bodyData = {
      "userId": int.parse(userId),
      "isTempDeactive": _isTempDeactive,
      "reason": reasonToSend,
    };
    print("bodyData: $bodyData");
    setState(() => _isLoading = true);

    try {
      var responseData = await API_V1_call(
        url: "/api/user/deactivate/${int.parse(userId)}",
        method: "POST",
        body: bodyData,
        isHeader: true,
      );

      await logeOut();

      Future.delayed(Duration(seconds: 2), (){

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });

      setState(() => _isLoading = false);

      if (responseData.statusCode == 200) {
        String successMessage = _isTempDeactive
            ? "Your account has been temporarily deactivated."
            : "Your account has been permanently deleted.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${responseData.body}")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Deletion",style: TextStyle(color: Colors.black)),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.black,)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose deletion type:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("Temporary Deactivation", style: TextStyle(color: Colors.black),),
                        value: true,
                        groupValue: _isTempDeactive,
                        onChanged: (value) {
                          setState(() {
                            _isTempDeactive = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("Permanent Deletion",style: TextStyle(color: Colors.black),),
                        value: false,
                        groupValue: _isTempDeactive,
                        onChanged: (value) {
                          setState(() {
                            _isTempDeactive = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Select a reason:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Reason",
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.6), width: 1.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                dropdownColor: Colors.white,
                hint: const Text(
                  "Select a reason",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                items: _reasons
                    .map(
                      (reason) => DropdownMenuItem(
                    value: reason,
                    child: Text(reason, style: const TextStyle(color: Colors.black)),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
              ),

              const SizedBox(height: 16),
              if (_selectedReason == "Other")
                TextFormField(
                  controller: _otherReasonController,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Please specify your reason",
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: "Type your reason here...",
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.black.withOpacity(0.6), width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDeletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Delete Account",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
