import 'package:flutter/material.dart';
import 'player_entry_screen.dart';
import '../i18n.dart';

class MatchTitleScreen extends StatefulWidget {
  const MatchTitleScreen({super.key});

  @override
  State<MatchTitleScreen> createState() => _MatchTitleScreenState();
}

class _MatchTitleScreenState extends State<MatchTitleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedLanguage = 'pl';

  final Map<String, String> _languages = {
    'pl': 'Polski',
    'en': 'English',
  };

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.t(_selectedLanguage, 'app_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                I18n.t(_selectedLanguage, 'enter_match_title'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: I18n.t(_selectedLanguage, 'enter_match_title'),
                  border: const OutlineInputBorder(),
                  hintText: I18n.t(_selectedLanguage, 'match_title_hint'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return I18n.t(_selectedLanguage, 'please_enter_match_title');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: I18n.t(_selectedLanguage, 'language'),
                  border: const OutlineInputBorder(),
                ),
                items: _languages.entries.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedLanguage = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerEntryScreen(
                          matchTitle: _titleController.text,
                          language: _selectedLanguage,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(I18n.t(_selectedLanguage, 'next'), style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
