import 'package:flutter/widgets.dart';

/// Small feature vocabulary, following the app's existing vi/en UI pattern.
String foodText(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
