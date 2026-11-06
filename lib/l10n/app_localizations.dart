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

  /// No description provided for @brandSlogan.
  ///
  /// In en, this message translates to:
  /// **'Movement. Consistency. Progress.'**
  String get brandSlogan;

  /// No description provided for @activityLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading activity history…'**
  String get activityLoading;

  /// No description provided for @activitySaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get activitySaving;

  /// No description provided for @activityLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load activity history. Your saved data is kept. Try again before logging an activity.'**
  String get activityLoadError;

  /// No description provided for @activitySaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save this activity. Your choices are kept. Tap Save activity to try again.'**
  String get activitySaveError;

  /// No description provided for @activityRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get activityRetry;

  /// No description provided for @screeningNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get screeningNext;

  /// No description provided for @screeningGuidance.
  ///
  /// In en, this message translates to:
  /// **'Habits to discuss with your care team'**
  String get screeningGuidance;

  /// No description provided for @screeningTipDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Because you reported type 2 diabetes: choose water instead of sugary drinks and discuss meal portions and timing with your care team. Estimated macro targets do not replace carbohydrate targets set by your care team.'**
  String get screeningTipDiabetes;

  /// No description provided for @screeningTipSodium.
  ///
  /// In en, this message translates to:
  /// **'Because you reported hypertension: compare sodium on food labels and use less salty sauce. Check with your clinician before using potassium-based salt substitutes.'**
  String get screeningTipSodium;

  /// No description provided for @screeningProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 5'**
  String screeningProgress(int step);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @authIntro.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use your account. You can cancel and continue checking in as a guest.'**
  String get authIntro;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailError;

  /// No description provided for @passwordError.
  ///
  /// In en, this message translates to:
  /// **'Enter your password (at least 8 characters for a new account).'**
  String get passwordError;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your details and connection, then try again.'**
  String get authError;

  /// No description provided for @authSignupError.
  ///
  /// In en, this message translates to:
  /// **'Could not create an account. Check your details and try again.'**
  String get authSignupError;

  /// No description provided for @authConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account, then return here to sign in.'**
  String get authConfirmEmail;

  /// No description provided for @authConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not configured. Home and check-ins are available as a guest.'**
  String get authConfiguration;

  /// No description provided for @authInitializationError.
  ///
  /// In en, this message translates to:
  /// **'Could not start sign-in. You can continue using Home and check-ins, or restart Steady to retry sign-in.'**
  String get authInitializationError;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @authOrEmail.
  ///
  /// In en, this message translates to:
  /// **'or use email'**
  String get authOrEmail;

  /// No description provided for @authProvidersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some social sign-in options are not available yet. You can use email instead.'**
  String get authProvidersUnavailable;

  /// No description provided for @authBrowserOpened.
  ///
  /// In en, this message translates to:
  /// **'Complete sign-in in your browser. If you closed it, select a sign-in option to try again.'**
  String get authBrowserOpened;

  /// No description provided for @authSocialError.
  ///
  /// In en, this message translates to:
  /// **'Could not start social sign-in. Check your connection and try again, or use email.'**
  String get authSocialError;

  /// No description provided for @authCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect. Please try again.'**
  String get authCredentialsError;

  /// No description provided for @authRateLimitError.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes and try again.'**
  String get authRateLimitError;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete sign-in. Check your connection and try again.'**
  String get authNetworkError;

  /// No description provided for @authOffline.
  ///
  /// In en, this message translates to:
  /// **'Connection interrupted. Your session is still open; please check your connection.'**
  String get authOffline;

  /// No description provided for @authSignOutError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out. Please try again.'**
  String get authSignOutError;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @needAccount.
  ///
  /// In en, this message translates to:
  /// **'New to Steady? Create an account'**
  String get needAccount;

  /// No description provided for @screeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s understand your health'**
  String get screeningTitle;

  /// No description provided for @screeningIntro.
  ///
  /// In en, this message translates to:
  /// **'Measurements → medical history → allergies and food preferences → training goal → review and menu.'**
  String get screeningIntro;

  /// No description provided for @screeningPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your answers stay in memory for this session, are not uploaded, and are cleared when you sign out or close the app. You can choose not to share them.'**
  String get screeningPrivacy;

  /// No description provided for @screeningConditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions and allergies'**
  String get screeningConditions;

  /// No description provided for @screeningConditionsHelp.
  ///
  /// In en, this message translates to:
  /// **'Select every condition you have been told you have. These are self-reported, not verified diagnoses. Leave empty only if you know of none.'**
  String get screeningConditionsHelp;

  /// No description provided for @screeningConditionsKnown.
  ///
  /// In en, this message translates to:
  /// **'I can report my conditions (including none)'**
  String get screeningConditionsKnown;

  /// No description provided for @screeningAllergiesKnown.
  ///
  /// In en, this message translates to:
  /// **'I can report my food allergies (including none)'**
  String get screeningAllergiesKnown;

  /// No description provided for @screeningOtherAllergies.
  ///
  /// In en, this message translates to:
  /// **'Other food allergies, not listed above'**
  String get screeningOtherAllergies;

  /// No description provided for @screeningTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment and eating needs'**
  String get screeningTreatment;

  /// No description provided for @screeningTreatmentHelp.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply. Leave empty only if you know none apply. Optional details help explain why a specialist may be needed.'**
  String get screeningTreatmentHelp;

  /// No description provided for @screeningTreatmentKnown.
  ///
  /// In en, this message translates to:
  /// **'I can report my treatment and eating needs'**
  String get screeningTreatmentKnown;

  /// No description provided for @screeningMedications.
  ///
  /// In en, this message translates to:
  /// **'Current medicines (optional)'**
  String get screeningMedications;

  /// No description provided for @screeningOrders.
  ///
  /// In en, this message translates to:
  /// **'Dietary instructions from your clinician (optional)'**
  String get screeningOrders;

  /// No description provided for @screeningKidneyStage.
  ///
  /// In en, this message translates to:
  /// **'Kidney stage and dialysis schedule, if known (optional)'**
  String get screeningKidneyStage;

  /// No description provided for @screeningLabNotes.
  ///
  /// In en, this message translates to:
  /// **'Measured lab results: value, unit, date and source (optional)'**
  String get screeningLabNotes;

  /// No description provided for @screeningLabHelp.
  ///
  /// In en, this message translates to:
  /// **'For kidney disease: eGFR, potassium and phosphorus; for diabetes: HbA1c. These notes are not interpreted or used to set nutrient limits.'**
  String get screeningLabHelp;

  /// No description provided for @screeningReview.
  ///
  /// In en, this message translates to:
  /// **'Your screening result'**
  String get screeningReview;

  /// No description provided for @screeningLifestyle.
  ///
  /// In en, this message translates to:
  /// **'General lifestyle support'**
  String get screeningLifestyle;

  /// No description provided for @screeningMoreInformation.
  ///
  /// In en, this message translates to:
  /// **'More information needed'**
  String get screeningMoreInformation;

  /// No description provided for @screeningProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional assessment needed'**
  String get screeningProfessional;

  /// No description provided for @screeningReasonChild.
  ///
  /// In en, this message translates to:
  /// **'Adult meal templates do not apply to children and adolescents.'**
  String get screeningReasonChild;

  /// No description provided for @screeningReasonTreatment.
  ///
  /// In en, this message translates to:
  /// **'Your treatment, eating needs or recent health changes need an individual assessment.'**
  String get screeningReasonTreatment;

  /// No description provided for @screeningReasonComplex.
  ///
  /// In en, this message translates to:
  /// **'A reported condition is outside Steady’s current scope for automatic meal templates.'**
  String get screeningReasonComplex;

  /// No description provided for @screeningReasonOrders.
  ///
  /// In en, this message translates to:
  /// **'Steady cannot validate or fulfil clinician-set dietary limits with its sample recipe data.'**
  String get screeningReasonOrders;

  /// No description provided for @screeningReasonMedication.
  ///
  /// In en, this message translates to:
  /// **'Medicine–food interactions need review. Steady does not change or interpret your medication.'**
  String get screeningReasonMedication;

  /// No description provided for @screeningReasonAllergy.
  ///
  /// In en, this message translates to:
  /// **'The sample catalogue cannot check the additional allergies you entered.'**
  String get screeningReasonAllergy;

  /// No description provided for @screeningReasonKidney.
  ///
  /// In en, this message translates to:
  /// **'Kidney nutrition depends on stage, dialysis, medicines and measured results. Even complete notes do not unlock an automatic therapeutic plan.'**
  String get screeningReasonKidney;

  /// No description provided for @screeningReasonWeightConflict.
  ///
  /// In en, this message translates to:
  /// **'Automatic weight-loss planning is paused because cancer treatment, poor intake or unintended weight loss may change your nutrition priorities.'**
  String get screeningReasonWeightConflict;

  /// No description provided for @screeningReasonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Conditions, allergies or treatment are not yet known. General tracking is available; automatic meal templates remain paused.'**
  String get screeningReasonUnknown;

  /// No description provided for @screeningReasonLifestyle.
  ///
  /// In en, this message translates to:
  /// **'You can use general habit support and illustrative meal templates. This result does not certify a meal as suitable for a medical condition.'**
  String get screeningReasonLifestyle;

  /// No description provided for @screeningConsent.
  ///
  /// In en, this message translates to:
  /// **'I agree to use these self-reported answers for support during this session.'**
  String get screeningConsent;

  /// No description provided for @screeningConsentError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to session use, or continue without sharing health details.'**
  String get screeningConsentError;

  /// No description provided for @screeningDecline.
  ///
  /// In en, this message translates to:
  /// **'Continue without sharing health details'**
  String get screeningDecline;

  /// No description provided for @screeningDeclined.
  ///
  /// In en, this message translates to:
  /// **'Health details not shared. Automatic meal templates are paused.'**
  String get screeningDeclined;

  /// No description provided for @screeningContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to Steady'**
  String get screeningContinue;

  /// No description provided for @screeningEdit.
  ///
  /// In en, this message translates to:
  /// **'Update health screening'**
  String get screeningEdit;

  /// No description provided for @screeningNote.
  ///
  /// In en, this message translates to:
  /// **'Screening guides the app’s scope. It does not diagnose disease, prescribe a diet or replace your care team.'**
  String get screeningNote;

  /// No description provided for @screeningPaused.
  ///
  /// In en, this message translates to:
  /// **'Meal planning is paused'**
  String get screeningPaused;

  /// No description provided for @screeningSources.
  ///
  /// In en, this message translates to:
  /// **'Evidence reviewed: 7 October 2026'**
  String get screeningSources;

  /// No description provided for @conditionType1.
  ///
  /// In en, this message translates to:
  /// **'Type 1 diabetes'**
  String get conditionType1;

  /// No description provided for @conditionType2.
  ///
  /// In en, this message translates to:
  /// **'Type 2 diabetes'**
  String get conditionType2;

  /// No description provided for @conditionLung.
  ///
  /// In en, this message translates to:
  /// **'COPD or chronic lung disease'**
  String get conditionLung;

  /// No description provided for @conditionCancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get conditionCancer;

  /// No description provided for @conditionKidney.
  ///
  /// In en, this message translates to:
  /// **'Chronic kidney disease'**
  String get conditionKidney;

  /// No description provided for @conditionTransplant.
  ///
  /// In en, this message translates to:
  /// **'Organ or stem cell transplant'**
  String get conditionTransplant;

  /// No description provided for @conditionObesity.
  ///
  /// In en, this message translates to:
  /// **'Overweight or obesity'**
  String get conditionObesity;

  /// No description provided for @conditionHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart failure, coronary disease or cardiomyopathy'**
  String get conditionHeart;

  /// No description provided for @conditionStroke.
  ///
  /// In en, this message translates to:
  /// **'Cerebrovascular disease or previous stroke'**
  String get conditionStroke;

  /// No description provided for @conditionDown.
  ///
  /// In en, this message translates to:
  /// **'Down syndrome'**
  String get conditionDown;

  /// No description provided for @conditionHiv.
  ///
  /// In en, this message translates to:
  /// **'HIV/AIDS'**
  String get conditionHiv;

  /// No description provided for @conditionNeurological.
  ///
  /// In en, this message translates to:
  /// **'Neurological disease or dementia'**
  String get conditionNeurological;

  /// No description provided for @conditionBlood.
  ///
  /// In en, this message translates to:
  /// **'Sickle cell disease, thalassaemia or chronic blood disorder'**
  String get conditionBlood;

  /// No description provided for @conditionAsthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get conditionAsthma;

  /// No description provided for @conditionHypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension'**
  String get conditionHypertension;

  /// No description provided for @conditionImmunodeficiency.
  ///
  /// In en, this message translates to:
  /// **'Immunodeficiency'**
  String get conditionImmunodeficiency;

  /// No description provided for @conditionFattyLiver.
  ///
  /// In en, this message translates to:
  /// **'Metabolic fatty liver disease'**
  String get conditionFattyLiver;

  /// No description provided for @conditionOtherLiver.
  ///
  /// In en, this message translates to:
  /// **'Cirrhosis or other liver disease'**
  String get conditionOtherLiver;

  /// No description provided for @conditionSubstance.
  ///
  /// In en, this message translates to:
  /// **'Substance use disorder'**
  String get conditionSubstance;

  /// No description provided for @conditionImmunosuppression.
  ///
  /// In en, this message translates to:
  /// **'Corticosteroid or immunosuppressive treatment'**
  String get conditionImmunosuppression;

  /// No description provided for @conditionSystemic.
  ///
  /// In en, this message translates to:
  /// **'Systemic disease (such as lupus)'**
  String get conditionSystemic;

  /// No description provided for @conditionCongenital.
  ///
  /// In en, this message translates to:
  /// **'Congenital or paediatric condition'**
  String get conditionCongenital;

  /// No description provided for @conditionOther.
  ///
  /// In en, this message translates to:
  /// **'Other condition or therapeutic diet'**
  String get conditionOther;

  /// No description provided for @flagPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnant or breastfeeding'**
  String get flagPregnancy;

  /// No description provided for @flagEatingDisorder.
  ///
  /// In en, this message translates to:
  /// **'Eating disorder'**
  String get flagEatingDisorder;

  /// No description provided for @flagDialysis.
  ///
  /// In en, this message translates to:
  /// **'Currently receiving dialysis'**
  String get flagDialysis;

  /// No description provided for @flagChemotherapy.
  ///
  /// In en, this message translates to:
  /// **'Currently receiving chemotherapy'**
  String get flagChemotherapy;

  /// No description provided for @flagInsulin.
  ///
  /// In en, this message translates to:
  /// **'Using insulin'**
  String get flagInsulin;

  /// No description provided for @flagSwallowing.
  ///
  /// In en, this message translates to:
  /// **'Difficulty swallowing'**
  String get flagSwallowing;

  /// No description provided for @flagWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Recent unintended weight loss'**
  String get flagWeightLoss;

  /// No description provided for @flagPoorIntake.
  ///
  /// In en, this message translates to:
  /// **'Poor appetite or difficulty eating enough'**
  String get flagPoorIntake;

  /// No description provided for @flagComplications.
  ///
  /// In en, this message translates to:
  /// **'Severe complications or unstable disease'**
  String get flagComplications;

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
  /// **'Recipes'**
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
  /// **'Last 7 days, including today'**
  String get thisWeek;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// No description provided for @totalMovementMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total active minutes'**
  String get totalMovementMinutes;

  /// No description provided for @activityTargetReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get activityTargetReached;

  /// No description provided for @activityTargetInProgress.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get activityTargetInProgress;

  /// No description provided for @activeDaysProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/5 active days'**
  String activeDaysProgress(int count);

  /// No description provided for @streakRule.
  ///
  /// In en, this message translates to:
  /// **'A streak counts consecutive active days. If you have not logged today, a streak ending yesterday stays until the end of today. Missing a full day resets it. The 5/7 goal counts active days, regardless of your streak.'**
  String get streakRule;

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
  /// **'5 active days in the last 7 days'**
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
  /// **'Recipe nutrition and prices are estimates, not verified clinical data or live prices. Quantities scale with each portion; cooking time assumes small home batches. Sodium estimates exclude added salt/sauces: check labels and account for any seasoning. A sample menu does not guarantee therapeutic suitability or complete micronutrients.'**
  String get nutritionNote;

  /// No description provided for @personalisationNote.
  ///
  /// In en, this message translates to:
  /// **'The layered configuration sets starting calorie/macro estimates. Portion sizes are matched to them while keeping allergies, diet, time and budget as hard constraints. Clinical restrictions override training preferences.'**
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
  /// **'No menu meets all calorie, macro, allergy, food, time and budget requirements. Edit preferences; no constraint has been silently removed.'**
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
  /// **'{activity} logged · {minutes} minutes'**
  String activitySaved(String activity, int minutes);

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

  /// No description provided for @nutritionBodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Body measurements'**
  String get nutritionBodyMeasurements;

  /// No description provided for @nutritionBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat (%)'**
  String get nutritionBodyFat;

  /// No description provided for @nutritionBodyFatHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional: enter a measured value, or leave blank if unknown. Steady does not infer it from BMI.'**
  String get nutritionBodyFatHelp;

  /// No description provided for @nutritionSex.
  ///
  /// In en, this message translates to:
  /// **'Sex used for energy estimation'**
  String get nutritionSex;

  /// No description provided for @nutritionSexHelp.
  ///
  /// In en, this message translates to:
  /// **'The Mifflin–St Jeor equation uses sex, age, height and weight. If you skip sex, Steady will not invent a calorie target.'**
  String get nutritionSexHelp;

  /// No description provided for @nutritionSexUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Skip energy estimation'**
  String get nutritionSexUnspecified;

  /// No description provided for @nutritionSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get nutritionSexFemale;

  /// No description provided for @nutritionSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get nutritionSexMale;

  /// No description provided for @nutritionFoodSource.
  ///
  /// In en, this message translates to:
  /// **'Food sources'**
  String get nutritionFoodSource;

  /// No description provided for @nutritionFoodPattern.
  ///
  /// In en, this message translates to:
  /// **'Food pattern'**
  String get nutritionFoodPattern;

  /// No description provided for @nutritionMacroStrategy.
  ///
  /// In en, this message translates to:
  /// **'Macronutrient strategy'**
  String get nutritionMacroStrategy;

  /// No description provided for @nutritionMealTiming.
  ///
  /// In en, this message translates to:
  /// **'Meal schedule'**
  String get nutritionMealTiming;

  /// No description provided for @nutritionEnergyStrategy.
  ///
  /// In en, this message translates to:
  /// **'Energy strategy'**
  String get nutritionEnergyStrategy;

  /// No description provided for @nutritionTrainingGoal.
  ///
  /// In en, this message translates to:
  /// **'Training and body goal'**
  String get nutritionTrainingGoal;

  /// No description provided for @nutritionTrainingSessions.
  ///
  /// In en, this message translates to:
  /// **'Resistance-training sessions/week'**
  String get nutritionTrainingSessions;

  /// No description provided for @nutritionExperience.
  ///
  /// In en, this message translates to:
  /// **'Training experience'**
  String get nutritionExperience;

  /// No description provided for @nutritionBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner / returning'**
  String get nutritionBeginner;

  /// No description provided for @nutritionIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get nutritionIntermediate;

  /// No description provided for @nutritionAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get nutritionAdvanced;

  /// No description provided for @nutritionGoalHealth.
  ///
  /// In en, this message translates to:
  /// **'General health'**
  String get nutritionGoalHealth;

  /// No description provided for @nutritionGoalFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Lose fat, preserve muscle'**
  String get nutritionGoalFatLoss;

  /// No description provided for @nutritionGoalMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get nutritionGoalMuscle;

  /// No description provided for @nutritionGoalRecomp.
  ///
  /// In en, this message translates to:
  /// **'Body recomposition'**
  String get nutritionGoalRecomp;

  /// No description provided for @nutritionGoalPerformance.
  ///
  /// In en, this message translates to:
  /// **'Strength / performance'**
  String get nutritionGoalPerformance;

  /// No description provided for @nutritionGoalEndurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get nutritionGoalEndurance;

  /// No description provided for @nutritionMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get nutritionMaintenance;

  /// No description provided for @nutritionDeficit.
  ///
  /// In en, this message translates to:
  /// **'Moderate cut'**
  String get nutritionDeficit;

  /// No description provided for @nutritionLeanBulk.
  ///
  /// In en, this message translates to:
  /// **'Lean bulk'**
  String get nutritionLeanBulk;

  /// No description provided for @nutritionAggressiveBulk.
  ///
  /// In en, this message translates to:
  /// **'Aggressive bulk (often called dirty bulk)'**
  String get nutritionAggressiveBulk;

  /// No description provided for @nutritionRecompEnergy.
  ///
  /// In en, this message translates to:
  /// **'Recomp at maintenance'**
  String get nutritionRecompEnergy;

  /// No description provided for @nutritionBalancedMacro.
  ///
  /// In en, this message translates to:
  /// **'Balanced macros'**
  String get nutritionBalancedMacro;

  /// No description provided for @nutritionHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High-protein balanced'**
  String get nutritionHighProtein;

  /// No description provided for @nutritionLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low carbohydrate'**
  String get nutritionLowCarb;

  /// No description provided for @nutritionKeto.
  ///
  /// In en, this message translates to:
  /// **'Ketogenic'**
  String get nutritionKeto;

  /// No description provided for @nutritionLowFat.
  ///
  /// In en, this message translates to:
  /// **'Lower fat'**
  String get nutritionLowFat;

  /// No description provided for @nutritionBalancedPattern.
  ///
  /// In en, this message translates to:
  /// **'Varied whole foods'**
  String get nutritionBalancedPattern;

  /// No description provided for @nutritionMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean style'**
  String get nutritionMediterranean;

  /// No description provided for @nutritionDash.
  ///
  /// In en, this message translates to:
  /// **'DASH style'**
  String get nutritionDash;

  /// No description provided for @nutritionPaleo.
  ///
  /// In en, this message translates to:
  /// **'Paleo'**
  String get nutritionPaleo;

  /// No description provided for @nutritionVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get nutritionVegan;

  /// No description provided for @nutritionThreeMeals.
  ///
  /// In en, this message translates to:
  /// **'3 meals/day'**
  String get nutritionThreeMeals;

  /// No description provided for @nutritionFourMeals.
  ///
  /// In en, this message translates to:
  /// **'3 meals + 1 snack'**
  String get nutritionFourMeals;

  /// No description provided for @nutritionTimeRestricted.
  ///
  /// In en, this message translates to:
  /// **'16:8 — meals within 12:00–20:00'**
  String get nutritionTimeRestricted;

  /// No description provided for @nutritionPreferenceHelp.
  ///
  /// In en, this message translates to:
  /// **'Food sources, macros and meal timing are separate choices. Allergies and medical requirements always take priority.'**
  String get nutritionPreferenceHelp;

  /// No description provided for @nutritionGenerate.
  ///
  /// In en, this message translates to:
  /// **'Finish and generate menu'**
  String get nutritionGenerate;

  /// No description provided for @nutritionConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Your nutrition configuration'**
  String get nutritionConfiguration;

  /// No description provided for @nutritionMaintenanceEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated maintenance'**
  String get nutritionMaintenanceEstimate;

  /// No description provided for @nutritionDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Starting daily target'**
  String get nutritionDailyTarget;

  /// No description provided for @nutritionCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrate'**
  String get nutritionCarbs;

  /// No description provided for @nutritionFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutritionFat;

  /// No description provided for @nutritionSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutritionSodium;

  /// No description provided for @nutritionPortion.
  ///
  /// In en, this message translates to:
  /// **'Portion multiplier'**
  String get nutritionPortion;

  /// No description provided for @nutritionMedicalReview.
  ///
  /// In en, this message translates to:
  /// **'Your medical answers require more information or professional review before automatic menu generation.'**
  String get nutritionMedicalReview;

  /// No description provided for @nutritionInvalidMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Check measurements and activity information before estimating a menu.'**
  String get nutritionInvalidMeasurements;

  /// No description provided for @nutritionNeedSex.
  ///
  /// In en, this message translates to:
  /// **'Energy estimation is skipped. Update the sex input to generate a menu matched to an estimated calorie target.'**
  String get nutritionNeedSex;

  /// No description provided for @nutritionGoalConflict.
  ///
  /// In en, this message translates to:
  /// **'The selected goal and energy strategy conflict. Choose a compatible strategy before generating a menu.'**
  String get nutritionGoalConflict;

  /// No description provided for @nutritionLowWeightReview.
  ///
  /// In en, this message translates to:
  /// **'A deficit with a low weight-for-height needs professional assessment. Steady will not automatically create a cut plan.'**
  String get nutritionLowWeightReview;

  /// No description provided for @nutritionKetoReview.
  ///
  /// In en, this message translates to:
  /// **'Keto with your medical conditions or SGLT2 medication needs clinician review. No automatic keto menu will be generated.'**
  String get nutritionKetoReview;

  /// No description provided for @nutritionBulkReview.
  ///
  /// In en, this message translates to:
  /// **'Aggressive bulk with your reported medical conditions needs professional review. Choose a safer strategy with your care team.'**
  String get nutritionBulkReview;

  /// No description provided for @nutritionPatternConflict.
  ///
  /// In en, this message translates to:
  /// **'Paleo excludes the legumes and grains used by this plant-based catalogue. Change one preference; Steady will not silently ignore it.'**
  String get nutritionPatternConflict;

  /// No description provided for @nutritionEstimateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'These inputs produce an estimate outside Steady’s supported range. Update the information or seek professional assessment.'**
  String get nutritionEstimateUnavailable;

  /// No description provided for @nutritionEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'Calories and macros are starting estimates, not a clinical prescription. Body fat is recorded separately and is not a diagnosis. Adjust using weight trends and training response.'**
  String get nutritionEstimateNote;

  /// No description provided for @nutritionBulkTradeoff.
  ///
  /// In en, this message translates to:
  /// **'Aggressive bulk means a larger energy surplus, not lower-quality food. Faster weight gain can include more fat; it does not guarantee faster muscle growth.'**
  String get nutritionBulkTradeoff;

  /// No description provided for @nutritionTrainingNote.
  ///
  /// In en, this message translates to:
  /// **'Muscle gain and recomp also depend on progressive resistance training and recovery. This menu cannot guarantee body-composition changes.'**
  String get nutritionTrainingNote;

  /// No description provided for @nutritionKetoPerformance.
  ///
  /// In en, this message translates to:
  /// **'Keto is not the first recommendation for high-volume or high-intensity training. No performance advantage or ketosis is guaranteed.'**
  String get nutritionKetoPerformance;

  /// No description provided for @nutritionVeganNote.
  ///
  /// In en, this message translates to:
  /// **'A vegan menu needs attention to B12, iron, calcium, iodine and omega-3. This catalogue does not verify full micronutrient coverage.'**
  String get nutritionVeganNote;

  /// No description provided for @flagSglt2.
  ///
  /// In en, this message translates to:
  /// **'Taking an SGLT2 inhibitor (such as dapagliflozin or empagliflozin)'**
  String get flagSglt2;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @eggIngredient.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get eggIngredient;

  /// No description provided for @avocadoIngredient.
  ///
  /// In en, this message translates to:
  /// **'Avocado'**
  String get avocadoIngredient;

  /// No description provided for @tofuScrambleName.
  ///
  /// In en, this message translates to:
  /// **'Tofu and vegetable scramble'**
  String get tofuScrambleName;

  /// No description provided for @tofuScrambleRecipe.
  ///
  /// In en, this message translates to:
  /// **'Heat plain tofu and vegetables with oil. Use unseasoned tofu; do not add salty sauces.'**
  String get tofuScrambleRecipe;

  /// No description provided for @eggPotatoName.
  ///
  /// In en, this message translates to:
  /// **'Eggs, sweet potato and greens'**
  String get eggPotatoName;

  /// No description provided for @eggPotatoRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook eggs thoroughly. Steam sweet potato and greens; dress greens with oil. Do not add salt.'**
  String get eggPotatoRecipe;

  /// No description provided for @ketoEggName.
  ///
  /// In en, this message translates to:
  /// **'Eggs and avocado'**
  String get ketoEggName;

  /// No description provided for @ketoEggRecipe.
  ///
  /// In en, this message translates to:
  /// **'Boil eggs thoroughly. Serve with avocado and cucumber dressed with the full amount of oil listed in the ingredients; do not add salt.'**
  String get ketoEggRecipe;

  /// No description provided for @ketoChickenName.
  ///
  /// In en, this message translates to:
  /// **'Chicken and avocado salad'**
  String get ketoChickenName;

  /// No description provided for @ketoChickenRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook chicken and greens thoroughly. Serve with avocado, oil and lemon; do not add salty dressing.'**
  String get ketoChickenRecipe;

  /// No description provided for @ketoFishName.
  ///
  /// In en, this message translates to:
  /// **'Steamed fish with non-starchy vegetables'**
  String get ketoFishName;

  /// No description provided for @ketoFishRecipe.
  ///
  /// In en, this message translates to:
  /// **'Steam fish thoroughly and cook greens. Serve with oil and lemon; do not add salt or dipping sauce.'**
  String get ketoFishRecipe;

  /// No description provided for @ketoTofuLunchName.
  ///
  /// In en, this message translates to:
  /// **'Tofu and avocado'**
  String get ketoTofuLunchName;

  /// No description provided for @ketoTofuLunchRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook unseasoned tofu. Serve with avocado, cucumber and oil; do not add salt.'**
  String get ketoTofuLunchRecipe;

  /// No description provided for @ketoTofuDinnerName.
  ///
  /// In en, this message translates to:
  /// **'Tofu, mushrooms and greens'**
  String get ketoTofuDinnerName;

  /// No description provided for @ketoTofuDinnerRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook tofu, mushrooms and greens with oil. Do not add salt or sauces.'**
  String get ketoTofuDinnerRecipe;

  /// No description provided for @soySnackName.
  ///
  /// In en, this message translates to:
  /// **'Soybeans and guava'**
  String get soySnackName;

  /// No description provided for @soySnackRecipe.
  ///
  /// In en, this message translates to:
  /// **'Reheat cooked unsalted soybeans. Serve with washed guava.'**
  String get soySnackRecipe;

  /// No description provided for @eggSnackName.
  ///
  /// In en, this message translates to:
  /// **'Eggs and cucumber'**
  String get eggSnackName;

  /// No description provided for @eggSnackRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook eggs thoroughly. Serve with washed cucumber; do not add salt.'**
  String get eggSnackRecipe;

  /// No description provided for @paleoChickenName.
  ///
  /// In en, this message translates to:
  /// **'Chicken, sweet potato and greens'**
  String get paleoChickenName;

  /// No description provided for @paleoChickenRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cook chicken thoroughly; steam sweet potato and greens. Dress the greens with the full amount of oil listed in the ingredients; do not add salt.'**
  String get paleoChickenRecipe;

  /// No description provided for @authInvalidConfiguration.
  ///
  /// In en, this message translates to:
  /// **'The sign-in service configuration is invalid, or the key belongs to a different project. Update the configuration and restart the app.'**
  String get authInvalidConfiguration;

  /// No description provided for @mealsSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up meals'**
  String get mealsSetup;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @localActivityStorage.
  ///
  /// In en, this message translates to:
  /// **'Activity logs are saved on this device, separately for guests and each account. No server backup or sync is available.'**
  String get localActivityStorage;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe ideas'**
  String get recipesTitle;

  /// No description provided for @recipesIntro.
  ///
  /// In en, this message translates to:
  /// **'Browse recipes for everyday cooking. No health details or sign-in needed.'**
  String get recipesIntro;

  /// No description provided for @recipesFilters.
  ///
  /// In en, this message translates to:
  /// **'Recipe filters'**
  String get recipesFilters;

  /// No description provided for @recipesMealType.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get recipesMealType;

  /// No description provided for @recipesAll.
  ///
  /// In en, this message translates to:
  /// **'All meals'**
  String get recipesAll;

  /// No description provided for @recipesCookingTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated cooking time'**
  String get recipesCookingTime;

  /// No description provided for @recipesAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get recipesAnyTime;

  /// No description provided for @recipesWithinMinutes.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} min'**
  String recipesWithinMinutes(int count);

  /// No description provided for @recipesEstimatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'About {count} min'**
  String recipesEstimatedMinutes(int count);

  /// No description provided for @recipesAllergyFilter.
  ///
  /// In en, this message translates to:
  /// **'Avoid allergy labels'**
  String get recipesAllergyFilter;

  /// No description provided for @recipesAllergyLimit.
  ///
  /// In en, this message translates to:
  /// **'This filter only excludes recipes with the selected labels. Labels may be incomplete and do not cover substitutions, sauces or cross-contact. Results are not confirmed safe for allergies. Check ingredients and product labels yourself.'**
  String get recipesAllergyLimit;

  /// No description provided for @recipesAvoidIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients to avoid'**
  String get recipesAvoidIngredients;

  /// No description provided for @recipesClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get recipesClearFilters;

  /// No description provided for @recipesResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String recipesResultCount(int count);

  /// No description provided for @recipesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching recipes'**
  String get recipesEmptyTitle;

  /// No description provided for @recipesEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Your filters are kept. Change a selection or clear the filters to browse more recipes.'**
  String get recipesEmptyHelp;

  /// No description provided for @recipesSampleQuantities.
  ///
  /// In en, this message translates to:
  /// **'Amounts belong to this sample recipe, not a personal serving recommendation. Beans labelled “cooked” use cooked weight; other amounts refer to raw edible ingredients.'**
  String get recipesSampleQuantities;
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
