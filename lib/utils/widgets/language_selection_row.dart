import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';
// import 'package:my_ad/utils/translation_service/easy_localize.dart';

class LanguageSelectorRow extends StatelessWidget {
  final Map<Locale, String> languageNames;
  final void Function(Locale)? onLocaleChanged;

  const LanguageSelectorRow({
    super.key,
    required this.languageNames,
    this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return Row(
      children:
          languageNames.entries.map((entry) {
            final isSelected =
                currentLocale.languageCode == entry.key.languageCode &&
                (currentLocale.countryCode ?? '') ==
                    (entry.key.countryCode ?? '');
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () async {
                    await context.setLocale(entry.key);
                    if (onLocaleChanged != null) onLocaleChanged!(entry.key);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color:
                          isSelected ? Colors.blue.shade50 : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
