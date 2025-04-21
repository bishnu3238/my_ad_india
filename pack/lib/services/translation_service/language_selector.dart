// File: language_selector.dart
import 'package:flutter/material.dart';
import 'easy_localize_extensions.dart';

class LanguageSelector extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final Widget? title;
  final bool showCountryFlags;
  final void Function(Locale)? onLocaleSelected;

  const LanguageSelector({
    Key? key,
    required this.languageNames,
    this.title,
    this.showCountryFlags = true,
    this.onLocaleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: languageNames.length,
      itemBuilder: (context, index) {
        final locale = languageNames.keys.elementAt(index);
        final name = languageNames[locale]!;

        return ListTile(
          leading: showCountryFlags ? _buildFlag(locale) : null,
          title: Text(name),
          onTap: () async {
            await context.setLocale(locale);
            if (onLocaleSelected != null) {
              onLocaleSelected!(locale);
            }
          },
          trailing: context.locale.languageCode == locale.languageCode
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
        );
      },
    );
  }

  Widget _buildFlag(Locale locale) {
    final String countryCode = locale.countryCode?.toUpperCase() ?? locale.languageCode.toUpperCase();

    return Text(
      getCountryFlag(countryCode),
      style: TextStyle(fontSize: 24),
    );
  }

  String getCountryFlag(String countryCode) {
    // Convert country code to emoji flag
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}
