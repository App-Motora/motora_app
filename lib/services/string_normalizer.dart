import 'package:diacritic/diacritic.dart';

class StringNormalizer {
  const StringNormalizer._();

  static String normalize(String? value) {
    if (value == null || value.isEmpty) return '';

    return removeDiacritics(value.toLowerCase());
  }

  static String simplificarString(String? value) => normalize(value);
}
