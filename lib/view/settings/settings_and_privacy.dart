import 'package:flutter/material.dart';

import '../../controller/auth_controller.dart';
import '../authentication/login_new.dart';
import 'account_deletion.dart';

class SettingsPrivacyPage extends StatefulWidget {
  @override
  State<SettingsPrivacyPage> createState() => _SettingsPrivacyPageState();
}

class _SettingsPrivacyPageState extends State<SettingsPrivacyPage> {
  bool isLoading = false;

  Future<void> logOutCall() async {
    setState(() {
      isLoading = true;
    });
    await logeOut();

    Future.delayed(Duration(seconds: 2), (){
      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Settings & Privacy',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  SettingsSection(
                    title: "Account",
                    items: [
                      SettingsItem(
                        icon: Icons.person,
                        label: "Personal Information",
                      ),
                      SettingsItem(
                        icon: Icons.lock,
                        label: "Password & Security",
                      ),
                      SettingsItem(icon: Icons.email, label: "Email"),
                    ],
                  ),
                  SettingsSection(
                    title: "Security",
                    items: [
                      SettingsItem(
                        icon: Icons.phonelink_lock,
                        label: "Two-Factor Authentication",
                      ),
                      SettingsItem(icon: Icons.security, label: "Login Alerts"),
                    ],
                  ),
                  SettingsSection(
                    title: "Preferences",
                    items: [
                      SettingsItem(icon: Icons.language, label: "Language"),
                      SettingsItem(icon: Icons.dark_mode, label: "Dark Mode"),
                      SettingsItem(
                        icon: Icons.notifications,
                        label: "Notification Settings",
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: "Authantication",
                    items: [
                      SettingsItem(
                        icon: Icons.delete,
                        label: "Delete Account",
                        onTap: () {
                          _navigateToPage(AccountDeletionPage());
                        },
                      ),
                      SettingsItem(
                        icon: Icons.logout,
                        label: "Log Out",
                        onTap: logOutCall,
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ...items.map((item) => item),
        Divider(height: 1),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  SettingsItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: Colors.purple),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
