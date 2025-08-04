import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "User";
  String email = "user@example.com";

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      email = prefs.getString('email') ?? 'user@example.com';
    });
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all stored preferences
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Account")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 40,
            child: Text(username.isNotEmpty ? username[0] : 'U',
                style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 10),
          Center(child: Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Center(child: Text(email, style: const TextStyle(color: Colors.grey))),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Change Language"),
            onTap: () {
              Navigator.pushNamed(context, '/language'); // Or show dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              // Navigate to settings screen or show coming soon
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy & Terms"),
            onTap: () {
              // Show a bottom sheet or navigate
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("Send Feedback"),
            onTap: () {
              // Use mailto: or a feedback form
            },
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}
