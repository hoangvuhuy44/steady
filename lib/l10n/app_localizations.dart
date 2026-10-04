import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @movedToday.
  ///
  /// In en, this message translates to:
  /// **'You moved today.'**
  String get movedToday;

  /// No description provided for @makeTodayCount.
  ///
  /// In en, this message translates to:
  /// **'Make today count.'**
  String get makeTodayCount;

  /// No description provided for @consistencyMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep showing up. Every active day brings you closer to your goal.'**
  String get consistencyMessage;

  /// No description provided for @movementMessage.
  ///
  /// In en, this message translates to:
  /// **'Walk, run, swim or choose an activity you enjoy. Start with a little movement today.'**
  String get movementMessage;

  /// No description provided for @checkInComplete.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in complete'**
  String get checkInComplete;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity logged yet'**
  String get noActivity;

  /// No description provided for @anyMovement.
  ///
  /// In en, this message translates to:
  /// **'Every bit of movement counts.'**
  String get anyMovement;

  /// No description provided for @logAnother.
  ///
  /// In en, this message translates to:
  /// **'Log another activity'**
  String get logAnother;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get thisWeek;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// No description provided for @steadyPoints.
  ///
  /// In en, this message translates to:
  /// **'Steady points'**
  String get steadyPoints;

  /// No description provided for @consistencyTip.
  ///
  /// In en, this message translates to:
  /// **'Build a habit with activities you enjoy. Consistency earns points.'**
  String get consistencyTip;

  /// No description provided for @whatDidYouDo.
  ///
  /// In en, this message translates to:
  /// **'What did you do today?'**
  String get whatDidYouDo;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @manualActivity.
  ///
  /// In en, this message translates to:
  /// **'Log your activity and duration here. Your activity is recorded manually.'**
  String get manualActivity;

  /// No description provided for @saveActivity.
  ///
  /// In en, this message translates to:
  /// **'Save activity'**
  String get saveActivity;

  /// No description provided for @walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get walk;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @swim.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get swim;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @mma.
  ///
  /// In en, this message translates to:
  /// **'MMA'**
  String get mma;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @rewardsIntro.
  ///
  /// In en, this message translates to:
  /// **'Earn points by staying consistent.'**
  String get rewardsIntro;

  /// No description provided for @previewRewards.
  ///
  /// In en, this message translates to:
  /// **'Reward preview'**
  String get previewRewards;

  /// No description provided for @recoveryDay.
  ///
  /// In en, this message translates to:
  /// **'Recovery day'**
  String get recoveryDay;

  /// No description provided for @partnerPerk.
  ///
  /// In en, this message translates to:
  /// **'Partner perk'**
  String get partnerPerk;

  /// No description provided for @steadyBadge.
  ///
  /// In en, this message translates to:
  /// **'Steady badge'**
  String get steadyBadge;

  /// No description provided for @rewardsNote.
  ///
  /// In en, this message translates to:
  /// **'These sample rewards are a preview. Redemption is not available yet.'**
  String get rewardsNote;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Steady member'**
  String get member;

  /// No description provided for @memberGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: stay active consistently'**
  String get memberGoal;

  /// No description provided for @weeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Weekly target'**
  String get weeklyTarget;

  /// No description provided for @fiveDays.
  ///
  /// In en, this message translates to:
  /// **'5 active days'**
  String get fiveDays;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected yet'**
  String get notConnected;

  /// No description provided for @healthData.
  ///
  /// In en, this message translates to:
  /// **'Health data'**
  String get healthData;

  /// No description provided for @manualCheckIns.
  ///
  /// In en, this message translates to:
  /// **'Activities entered manually'**
  String get manualCheckIns;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose how Steady speaks to you.'**
  String get languageHelp;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get systemLanguage;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Language changed for this session. Could not save your preference.'**
  String get languageSaveError;

  /// No description provided for @mealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your meals, made simple'**
  String get mealsTitle;

  /// No description provided for @mealsIntro.
  ///
  /// In en, this message translates to:
  /// **'Familiar Vietnamese dishes. A week planned around your routine.'**
  String get mealsIntro;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s plan your week'**
  String get setupTitle;

  /// No description provided for @setupIntro.
  ///
  /// In en, this message translates to:
  /// **'Three short steps to match your preferences, time and budget.'**
  String get setupIntro;

  /// No description provided for @bodyGoal.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get bodyGoal;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @bodyGoalHelp.
  ///
  /// In en, this message translates to:
  /// **'Start with your measurements and your goal.'**
  String get bodyGoalHelp;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @dailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Usual activity level'**
  String get dailyActivity;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced eating'**
  String get balanced;

  /// No description provided for @weightLoss.
  ///
  /// In en, this message translates to:
  /// **'Support weight loss'**
  String get weightLoss;

  /// No description provided for @muscle.
  ///
  /// In en, this message translates to:
  /// **'Support muscle gain'**
  String get muscle;

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Mostly sedentary'**
  String get sedentary;

  /// No description provided for @lightActivity.
  ///
  /// In en, this message translates to:
  /// **'Light: 1–2 sessions/week'**
  String get lightActivity;

  /// No description provided for @moderateActivity.
  ///
  /// In en, this message translates to:
  /// **'Moderate: 3–4 sessions/week'**
  String get moderateActivity;

  /// No description provided for @highActivity.
  ///
  /// In en, this message translates to:
  /// **'High: 5+ sessions/week'**
  String get highActivity;

  /// No description provided for @cholesterolStatus.
  ///
  /// In en, this message translates to:
  /// **'High cholesterol diagnosis'**
  String get cholesterolStatus;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get unknown;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by a clinician'**
  String get confirmed;

  /// No description provided for @notDiagnosed.
  ///
  /// In en, this message translates to:
  /// **'Not diagnosed'**
  String get notDiagnosed;

  /// No description provided for @healthHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional readings can be left blank. Enter measured results only; Steady does not diagnose or interpret them.'**
  String get healthHelp;

  /// No description provided for @optionalReadings.
  ///
  /// In en, this message translates to:
  /// **'Add blood pressure or lab results'**
  String get optionalReadings;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic (mmHg)'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic (mmHg)'**
  String get diastolic;

  /// No description provided for @ldl.
  ///
  /// In en, this message translates to:
  /// **'LDL (mmol/L)'**
  String get ldl;

  /// No description provided for @hdl.
  ///
  /// In en, this message translates to:
  /// **'HDL (mmol/L)'**
  String get hdl;

  /// No description provided for @triglycerides.
  ///
  /// In en, this message translates to:
  /// **'Triglycerides (mmol/L)'**
  String get triglycerides;

  /// No description provided for @professionalLabel.
  ///
  /// In en, this message translates to:
  /// **'I need a specialist diet'**
  String get professionalLabel;

  /// No description provided for @professionalHelp.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy, breastfeeding, kidney disease, an eating disorder or a prescribed therapeutic diet.'**
  String get professionalHelp;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @omnivore.
  ///
  /// In en, this message translates to:
  /// **'Varied diet'**
  String get omnivore;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Daily food budget (VND)'**
  String get budget;

  /// No description provided for @cookingTime.
  ///
  /// In en, this message translates to:
  /// **'Max cooking time per meal (min)'**
  String get cookingTime;

  /// No description provided for @allergens.
  ///
  /// In en, this message translates to:
  /// **'Allergies & exclusions'**
  String get allergens;

  /// No description provided for @allergensHelp.
  ///
  /// In en, this message translates to:
  /// **'Selected ingredients stay excluded when you create or swap meals.'**
  String get allergensHelp;

  /// No description provided for @dislikes.
  ///
  /// In en, this message translates to:
  /// **'Ingredients you prefer to skip'**
  String get dislikes;

  /// No description provided for @soy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get soy;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @gluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get gluten;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @egg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get egg;

  /// No description provided for @peanut.
  ///
  /// In en, this message translates to:
  /// **'Peanut'**
  String get peanut;

  /// No description provided for @nuts.
  ///
  /// In en, this message translates to:
  /// **'Tree nuts'**
  String get nuts;

  /// No description provided for @shellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get shellfish;

  /// No description provided for @sesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get sesame;

  /// No description provided for @consent.
  ///
  /// In en, this message translates to:
  /// **'Use my details for this session’s meal plan'**
  String get consent;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your profile and plan stay in memory on this device. They are cleared when the app closes and are not sent to AI or a server.'**
  String get privacyNote;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create my 7-day plan'**
  String get createPlan;

  /// No description provided for @updatePlan.
  ///
  /// In en, this message translates to:
  /// **'Update my plan'**
  String get updatePlan;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @integerError.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get integerError;

  /// No description provided for @bloodPressurePairError.
  ///
  /// In en, this message translates to:
  /// **'Enter both blood pressure readings, or leave both blank.'**
  String get bloodPressurePairError;

  /// No description provided for @bloodPressureOrderError.
  ///
  /// In en, this message translates to:
  /// **'Systolic pressure must be higher than diastolic pressure.'**
  String get bloodPressureOrderError;

  /// No description provided for @consentError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to use your details for this meal plan.'**
  String get consentError;

  /// No description provided for @planReady.
  ///
  /// In en, this message translates to:
  /// **'Your week is ready'**
  String get planReady;

  /// No description provided for @planUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal plan updated'**
  String get planUpdated;

  /// No description provided for @yourWeek.
  ///
  /// In en, this message translates to:
  /// **'Your 7-day plan'**
  String get yourWeek;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit preferences'**
  String get editProfile;

  /// No description provided for @dailyBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily budget'**
  String get dailyBudget;

  /// No description provided for @estimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost'**
  String get estimatedCost;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @fibre.
  ///
  /// In en, this message translates to:
  /// **'Fibre'**
  String get fibre;

  /// No description provided for @saturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Saturated fat'**
  String get saturatedFat;

  /// No description provided for @estimatedDaily.
  ///
  /// In en, this message translates to:
  /// **'Estimated daily totals'**
  String get estimatedDaily;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @preparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparation;

  /// No description provided for @recipeDetails.
  ///
  /// In en, this message translates to:
  /// **'Ingredients & recipe'**
  String get recipeDetails;

  /// No description provided for @swapMeal.
  ///
  /// In en, this message translates to:
  /// **'Swap meal'**
  String get swapMeal;

  /// No description provided for @noAlternatives.
  ///
  /// In en, this message translates to:
  /// **'No alternatives available'**
  String get noAlternatives;

  /// No description provided for @swapTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose another dish'**
  String get swapTitle;

  /// No description provided for @swapHelp.
  ///
  /// In en, this message translates to:
  /// **'These dishes match your diet, exclusions, time and budget.'**
  String get swapHelp;

  /// No description provided for @groceries.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get groceries;

  /// No description provided for @groceriesWeek.
  ///
  /// In en, this message translates to:
  /// **'Shopping list · 7 days'**
  String get groceriesWeek;

  /// No description provided for @groceriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Amounts for the whole week. Beans labelled “cooked” use cooked weight. Other weights refer to raw edible ingredients.'**
  String get groceriesHelp;

  /// No description provided for @planNotes.
  ///
  /// In en, this message translates to:
  /// **'About this sample plan'**
  String get planNotes;

  /// No description provided for @nutritionNote.
  ///
  /// In en, this message translates to:
  /// **'Fixed portions with estimated nutrition and prices. Snacks, drinks and condiments are excluded. Check package labels and cross-contact risks for allergies.'**
  String get nutritionNote;

  /// No description provided for @personalisationNote.
  ///
  /// In en, this message translates to:
  /// **'Measurements and lab readings are recorded but do not set calorie needs or treatment. Muscle support ranks protein; weight loss does not reduce portions. This sample plan is not a personalised or therapeutic diet.'**
  String get personalisationNote;

  /// No description provided for @unsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'A specialist plan is a better fit'**
  String get unsupportedTitle;

  /// No description provided for @unsupportedHelp.
  ///
  /// In en, this message translates to:
  /// **'Automatic plans are unavailable for under-18s or people who need a therapeutic diet. Work with a nutrition professional for a suitable plan.'**
  String get unsupportedHelp;

  /// No description provided for @emptyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching plan yet'**
  String get emptyPlanTitle;

  /// No description provided for @emptyPlanHelp.
  ///
  /// In en, this message translates to:
  /// **'Try a higher budget, more cooking time or fewer disliked ingredients. Allergy exclusions will stay in place.'**
  String get emptyPlanHelp;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete profile & plan'**
  String get deletePlan;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your meal details?'**
  String get deleteTitle;

  /// No description provided for @deleteHelp.
  ///
  /// In en, this message translates to:
  /// **'This clears your measurements, health readings, preferences and meal plan from this session. You can start again afterwards.'**
  String get deleteHelp;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Meal profile and plan deleted'**
  String get deleted;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @notCompleted.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get notCompleted;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesValue(int count);

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} points'**
  String pointsValue(int count);

  /// No description provided for @activitySaved.
  ///
  /// In en, this message translates to:
  /// **'{activity} logged. +{points} points'**
  String activitySaved(String activity, int points);

  /// No description provided for @rangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a value from {min} to {max}'**
  String rangeError(String min, String max);

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3'**
  String stepProgress(int step);

  /// No description provided for @dayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayNumber(int day);

  /// No description provided for @mealSwapped.
  ///
  /// In en, this message translates to:
  /// **'Changed to {meal}'**
  String mealSwapped(String meal);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients'**
  String itemsCount(int count);

  /// No description provided for @oatsIngredient.
  ///
  /// In en, this message translates to:
  /// **'Oats'**
  String get oatsIngredient;

  /// No description provided for @banana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get banana;

  /// No description provided for @soyMilk.
  ///
  /// In en, this message translates to:
  /// **'Unsweetened soy milk'**
  String get soyMilk;

  /// No description provided for @sweetPotato.
  ///
  /// In en, this message translates to:
  /// **'Sweet potato'**
  String get sweetPotato;

  /// No description provided for @cookedSoybeans.
  ///
  /// In en, this message translates to:
  /// **'Cooked soybeans'**
  String get cookedSoybeans;

  /// No description provided for @guava.
  ///
  /// In en, this message translates to:
  /// **'Guava'**
  String get guava;

  /// No description provided for @mungBeans.
  ///
  /// In en, this message translates to:
  /// **'Mung beans'**
  String get mungBeans;

  /// No description provided for @brownRice.
  ///
  /// In en, this message translates to:
  /// **'Brown rice'**
  String get brownRice;

  /// No description provided for @cookedRedBeans.
  ///
  /// In en, this message translates to:
  /// **'Cooked red beans'**
  String get cookedRedBeans;

  /// No description provided for @cucumber.
  ///
  /// In en, this message translates to:
  /// **'Cucumber'**
  String get cucumber;

  /// No description provided for @canolaOil.
  ///
  /// In en, this message translates to:
  /// **'Canola oil'**
  String get canolaOil;

  /// No description provided for @tilapia.
  ///
  /// In en, this message translates to:
  /// **'Tilapia fillet'**
  String get tilapia;

  /// No description provided for @greens.
  ///
  /// In en, this message translates to:
  /// **'Leafy greens'**
  String get greens;

  /// No description provided for @tofuIngredient.
  ///
  /// In en, this message translates to:
  /// **'Tofu'**
  String get tofuIngredient;

  /// No description provided for @tomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get tomato;

  /// No description provided for @carrot.
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get carrot;

  /// No description provided for @chickenBreast.
  ///
  /// In en, this message translates to:
  /// **'Skinless chicken breast'**
  String get chickenBreast;

  /// No description provided for @mushrooms.
  ///
  /// In en, this message translates to:
  /// **'Mushrooms'**
  String get mushrooms;

  /// No description provided for @oatsName.
  ///
  /// In en, this message translates to:
  /// **'Banana oat porridge'**
  String get oatsName;

  /// No description provided for @oatsRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook oats with soy milk and water for 5–7 minutes. Add banana. Do not add sugar.'**
  String get oatsRecipe;

  /// No description provided for @sweetName.
  ///
  /// In en, this message translates to:
  /// **'Sweet potato, soybeans & fruit'**
  String get sweetName;

  /// No description provided for @sweetRecipe.
  ///
  /// In en, this message translates to:
  /// **'Steam sweet potato for 15–20 minutes. Serve with cooked soybeans and washed guava.'**
  String get sweetRecipe;

  /// No description provided for @beanbreakfastName.
  ///
  /// In en, this message translates to:
  /// **'Mung bean porridge & banana'**
  String get beanbreakfastName;

  /// No description provided for @beanbreakfastRecipe.
  ///
  /// In en, this message translates to:
  /// **'Soak beans and rice beforehand. Cook in water until soft; use a pressure cooker to save time. Serve banana separately.'**
  String get beanbreakfastRecipe;

  /// No description provided for @ricebreakfastName.
  ///
  /// In en, this message translates to:
  /// **'Brown rice, red beans & cucumber'**
  String get ricebreakfastName;

  /// No description provided for @ricebreakfastRecipe.
  ///
  /// In en, this message translates to:
  /// **'Use cooked rice and boiled beans. Reheat and serve with cucumber and canola oil.'**
  String get ricebreakfastRecipe;

  /// No description provided for @fishName.
  ///
  /// In en, this message translates to:
  /// **'Steamed fish, brown rice & greens'**
  String get fishName;

  /// No description provided for @fishRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook rice. Steam fish with ginger for 10–15 minutes until cooked. Boil greens and add canola oil. Seasonings and dipping sauces are counted separately.'**
  String get fishRecipe;

  /// No description provided for @tofuName.
  ///
  /// In en, this message translates to:
  /// **'Tomato tofu & brown rice'**
  String get tofuName;

  /// No description provided for @tofuRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook rice. Simmer tomatoes with a little water and oil, then add tofu. Serve with boiled greens. Avoid deep frying.'**
  String get tofuRecipe;

  /// No description provided for @lentilName.
  ///
  /// In en, this message translates to:
  /// **'Mung beans, rice & vegetables'**
  String get lentilName;

  /// No description provided for @lentilRecipe.
  ///
  /// In en, this message translates to:
  /// **'Use soaked beans and cooked rice. Cook beans until soft, add carrot and greens, then mix with rice and oil.'**
  String get lentilRecipe;

  /// No description provided for @chickenName.
  ///
  /// In en, this message translates to:
  /// **'Pan-seared chicken, rice & greens'**
  String get chickenName;

  /// No description provided for @chickenRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook rice. Pan-sear skinless chicken with oil until thoroughly cooked. Serve with steamed greens; limit bottled sauces.'**
  String get chickenRecipe;

  /// No description provided for @beanDinnerName.
  ///
  /// In en, this message translates to:
  /// **'Red beans, sweet potato & greens'**
  String get beanDinnerName;

  /// No description provided for @beanDinnerRecipe.
  ///
  /// In en, this message translates to:
  /// **'Steam sweet potato. Reheat cooked red beans and serve with boiled greens and canola oil.'**
  String get beanDinnerRecipe;

  /// No description provided for @fishDinnerName.
  ///
  /// In en, this message translates to:
  /// **'Steamed fish, sweet potato & greens'**
  String get fishDinnerName;

  /// No description provided for @fishDinnerRecipe.
  ///
  /// In en, this message translates to:
  /// **'Steam sweet potato and fish until cooked, then boil greens. Use ginger and lime; dipping sauces are counted separately.'**
  String get fishDinnerRecipe;

  /// No description provided for @tofuDinnerName.
  ///
  /// In en, this message translates to:
  /// **'Steamed tofu, mushrooms & brown rice'**
  String get tofuDinnerName;

  /// No description provided for @tofuDinnerRecipe.
  ///
  /// In en, this message translates to:
  /// **'Steam tofu with mushrooms until hot and cooked. Serve with brown rice, greens and canola oil.'**
  String get tofuDinnerRecipe;

  /// No description provided for @chickenDinnerName.
  ///
  /// In en, this message translates to:
  /// **'Skinless chicken, sweet potato & greens'**
  String get chickenDinnerName;

  /// No description provided for @chickenDinnerRecipe.
  ///
  /// In en, this message translates to:
  /// **'Steam sweet potato. Boil or pan-sear chicken until thoroughly cooked. Serve with boiled greens.'**
  String get chickenDinnerRecipe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
