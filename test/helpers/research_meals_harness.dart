import 'package:flutter/material.dart';
import 'package:steady/l10n/app_localizations.dart';
import 'package:steady/research/research_meals_screen.dart';
import 'package:steady/state/steady_store.dart';
import 'package:steady/theme/steady_theme.dart';

/// An explicit research entry point that is never shipped in the MVP UI.
class ResearchMealsHarness extends StatelessWidget {
  const ResearchMealsHarness({
    super.key,
    required this.store,
    this.locale = const Locale('en'),
  });

  final SteadyStore store;
  final Locale locale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: SteadyTheme.light(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (_, _) => ResearchMealsScreen(store: store),
        ),
      ),
    ),
  );
}
