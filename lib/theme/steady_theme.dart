import 'package:flutter/material.dart';

import 'steady_colors.dart';
import 'steady_motion.dart';
import 'steady_radii.dart';
import 'steady_spacing.dart';
import 'steady_typography.dart';

class SteadyTheme {
  static ThemeData light() {
    const colors = ColorScheme.light(
      primary: SteadyColors.deepCoreBlue,
      onPrimary: SteadyColors.white,
      primaryContainer: SteadyColors.softCloud,
      onPrimaryContainer: SteadyColors.deepCoreBlue,
      secondary: SteadyColors.aquaTeal,
      onSecondary: SteadyColors.ink,
      secondaryContainer: SteadyColors.freshMint,
      onSecondaryContainer: SteadyColors.ink,
      tertiary: SteadyColors.flowCyan,
      onTertiary: SteadyColors.ink,
      tertiaryContainer: SteadyColors.softCloud,
      onTertiaryContainer: SteadyColors.deepCoreBlue,
      error: SteadyColors.error,
      onError: SteadyColors.white,
      errorContainer: SteadyColors.errorSurface,
      onErrorContainer: SteadyColors.error,
      surface: SteadyColors.white,
      onSurface: SteadyColors.ink,
      onSurfaceVariant: SteadyColors.muted,
      surfaceContainerLowest: SteadyColors.white,
      surfaceContainerLow: SteadyColors.softCloud,
      surfaceContainer: SteadyColors.softCloud,
      surfaceContainerHigh: SteadyColors.softCloud,
      surfaceContainerHighest: SteadyColors.border,
      outline: SteadyColors.muted,
      outlineVariant: SteadyColors.border,
      inverseSurface: SteadyColors.ink,
      onInverseSurface: SteadyColors.white,
      inversePrimary: SteadyColors.freshMint,
      surfaceTint: SteadyColors.white,
      primaryFixed: SteadyColors.freshMint,
      primaryFixedDim: SteadyColors.aquaTeal,
      onPrimaryFixed: SteadyColors.ink,
      onPrimaryFixedVariant: SteadyColors.ink,
      secondaryFixed: SteadyColors.freshMint,
      secondaryFixedDim: SteadyColors.aquaTeal,
      onSecondaryFixed: SteadyColors.ink,
      onSecondaryFixedVariant: SteadyColors.ink,
      tertiaryFixed: SteadyColors.flowCyan,
      tertiaryFixedDim: SteadyColors.flowCyan,
      onTertiaryFixed: SteadyColors.ink,
      onTertiaryFixedVariant: SteadyColors.ink,
      shadow: SteadyColors.ink,
      scrim: SteadyColors.ink,
    );
    const controlShape = RoundedRectangleBorder(
      borderRadius: SteadyRadii.controlBorder,
    );
    const cardShape = RoundedRectangleBorder(
      borderRadius: SteadyRadii.cardBorder,
      side: BorderSide(color: SteadyColors.border),
    );
    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: SteadySpacing.xl,
          vertical: SteadySpacing.md,
        ),
      ),
      shape: const WidgetStatePropertyAll(controlShape),
      textStyle: WidgetStatePropertyAll(
        SteadyTypography.body(16, weight: FontWeight.w600),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? const BorderSide(color: SteadyColors.ink, width: 3)
            : null,
      ),
      animationDuration: SteadyMotion.duration,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: 'Inter',
      textTheme: SteadyTypography.textTheme,
      scaffoldBackgroundColor: SteadyColors.softCloud,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: SteadyColors.softCloud,
        foregroundColor: SteadyColors.ink,
        surfaceTintColor: SteadyColors.white,
        elevation: 0,
        titleTextStyle: SteadyTypography.heading(20),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: SteadyColors.white,
        surfaceTintColor: SteadyColors.white,
        indicatorColor: SteadyColors.freshMint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          SteadyTypography.body(12, weight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? SteadyColors.ink
                : SteadyColors.muted,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: SteadyColors.white,
        surfaceTintColor: SteadyColors.white,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: cardShape,
      ),
      filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: buttonStyle.copyWith(
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? SteadyColors.border
                  : SteadyColors.deepCoreBlue,
              width: states.contains(WidgetState.focused) ? 3 : 1,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: buttonStyle),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SteadyColors.softCloud,
        labelStyle: SteadyTypography.body(16)
            .copyWith(color: SteadyColors.muted),
        contentPadding: const EdgeInsets.all(SteadySpacing.lg),
        errorMaxLines: 4,
        border: const OutlineInputBorder(
          borderRadius: SteadyRadii.controlBorder,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: SteadyRadii.controlBorder,
          borderSide: BorderSide(color: SteadyColors.muted),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: SteadyRadii.controlBorder,
          borderSide: BorderSide(color: SteadyColors.deepCoreBlue, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: SteadyRadii.controlBorder,
          borderSide: BorderSide(color: SteadyColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: SteadyRadii.controlBorder,
          borderSide: BorderSide(color: SteadyColors.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SteadyColors.white,
        selectedColor: SteadyColors.freshMint,
        disabledColor: SteadyColors.softCloud,
        labelStyle: SteadyTypography.body(14, weight: FontWeight.w500),
        checkmarkColor: SteadyColors.ink,
        side: const BorderSide(color: SteadyColors.muted),
        shape: controlShape,
        padding: const EdgeInsets.all(SteadySpacing.sm),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: SteadyColors.deepCoreBlue,
        textColor: SteadyColors.ink,
        titleTextStyle: SteadyTypography.heading(16),
        subtitleTextStyle: SteadyTypography.body(14)
            .copyWith(color: SteadyColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SteadySpacing.xl,
          vertical: SteadySpacing.sm,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: SteadyColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: SteadyColors.white,
          fontSize: 16,
          height: 1.5,
        ),
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SteadyColors.deepCoreBlue,
        linearTrackColor: SteadyColors.border,
        circularTrackColor: SteadyColors.border,
        linearMinHeight: 8,
        borderRadius: SteadyRadii.pillBorder,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: SteadyColors.deepCoreBlue,
        inactiveTrackColor: SteadyColors.border,
        thumbColor: SteadyColors.deepCoreBlue,
      ),
      dividerTheme: const DividerThemeData(color: SteadyColors.border),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: controlShape,
        collapsedShape: controlShape,
        iconColor: SteadyColors.deepCoreBlue,
        textColor: SteadyColors.ink,
      ),
    );
  }
}
