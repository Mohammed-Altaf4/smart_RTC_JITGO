import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  final List<String> languages = [
    'English', 'हिंदी', 'தமிழ்', 'తెలుగు',
    'বাংলা', 'मराठी', 'മലയാളം', 'অসমীয়া',
  ];

  void _continue() async {
    if (selectedLanguage != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', selectedLanguage!);
      Navigator.pushReplacementNamed(context, '/login');
// Or your next screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MANA RTC")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Set your language to begin",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: languages.map((lang) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLanguage = lang;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedLanguage == lang ? Colors.orange[100] : Colors.grey[200],
                      border: Border.all(
                        color: selectedLanguage == lang ? Colors.orange : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(lang, style: const TextStyle(fontSize: 18)),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Continue"),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
