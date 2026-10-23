import 'package:flutter/services.dart';

/// Load the actual shipped fonts; default widget-test Ahem hides glyph issues.
Future<void> loadBrandFonts() async {
  for (final family in ['Sora', 'Inter']) {
    await (FontLoader(family)..addFont(
          rootBundle.load('assets/fonts/${family.toLowerCase()}-variable.ttf'),
        ))
        .load();
  }
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}
