import 'package:flutter/services.dart';

class MacAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var rawHexCharacters = newValue.text
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toUpperCase();
    final previousRawHexCharacters = oldValue.text
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toUpperCase();

    // When deleting colon separators, remove the preceding hex character
    if (newValue.text.length < oldValue.text.length &&
        rawHexCharacters == previousRawHexCharacters &&
        rawHexCharacters.isNotEmpty) {
      rawHexCharacters = rawHexCharacters.substring(
        0,
        rawHexCharacters.length - 1,
      );
    }

    if (rawHexCharacters.length > 12) {
      rawHexCharacters = rawHexCharacters.substring(0, 12);
    }

    final formattedTextBuffer = StringBuffer();
    for (var index = 0; index < rawHexCharacters.length; index++) {
      if (index > 0 && index % 2 == 0) {
        formattedTextBuffer.write(':');
      }
      formattedTextBuffer.write(rawHexCharacters[index]);
    }

    final formattedText = formattedTextBuffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
