import 'package:flutter/material.dart';
import '../main.dart';

class Language {
  final String name;
  final String nativeName;
  final String flag;
  final String code;

  Language({
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.code,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedCode = 'en';

  final List<Language> _languages = [
    Language(name: 'English', nativeName: 'English', flag: '🇬🇧', code: 'en'),
    Language(name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳', code: 'vi'),
  ];

  @override
  void initState() {
    super.initState();
    // Get current locale from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = LocaleProviderInherited.maybeOf(context);
      if (provider != null) {
        setState(() {
          _selectedCode = provider.locale.languageCode;
        });
      }
    });
  }

  void _selectLanguage(Language language) {
    setState(() {
      _selectedCode = language.code;
    });

    // Apply the locale change
    final locale = Locale(language.code);
    MyApp.setLocale(context, locale);

    // Return the language name for display in profile
    Navigator.pop(context, language.nativeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Language List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = _selectedCode == language.code;

                  return GestureDetector(
                    onTap: () => _selectLanguage(language),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF90EE90).withValues(alpha: 0.1)
                            : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF90EE90)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Flag
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                language.flag,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Language Names
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language.nativeName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF90EE90)
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  language.name,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Check Icon
                          if (isSelected)
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF90EE90),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 18,
                              ),
                            )
                          else
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[600]!,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
