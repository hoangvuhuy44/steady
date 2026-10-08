// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get screeningNext => 'Next';

  @override
  String get screeningGuidance => 'Habits to discuss with your care team';

  @override
  String get screeningTipDiabetes =>
      'Because you reported type 2 diabetes: choose water instead of sugary drinks and discuss meal portions and timing with your care team. Estimated macro targets do not replace carbohydrate targets set by your care team.';

  @override
  String get screeningTipSodium =>
      'Because you reported hypertension: compare sodium on food labels and use less salty sauce. Check with your clinician before using potassium-based salt substitutes.';

  @override
  String screeningProgress(int step) {
    return 'Step $step of 5';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get authIntro =>
      'Sign in to start your health screening and build your Steady routine.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailError => 'Enter a valid email address.';

  @override
  String get passwordError =>
      'Enter your password (at least 8 characters for a new account).';

  @override
  String get authError =>
      'Could not sign in. Check your details and connection, then try again.';

  @override
  String get authSignupError =>
      'Could not create an account. Check your details and try again.';

  @override
  String get authConfirmEmail =>
      'Check your email to confirm your account, then return here to sign in.';

  @override
  String get authConfiguration =>
      'Steady has not been connected to its sign-in service. Set up the connection before signing in.';

  @override
  String get authInitializationError =>
      'Could not start the sign-in service. Check your connection and restart Steady to try again.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get authOrEmail => 'or use email';

  @override
  String get authProvidersUnavailable =>
      'Some social sign-in options are not available yet. You can use email instead.';

  @override
  String get authBrowserOpened =>
      'Complete sign-in in your browser. If you closed it, select a sign-in option to try again.';

  @override
  String get authSocialError =>
      'Could not start social sign-in. Check your connection and try again, or use email.';

  @override
  String get authCredentialsError =>
      'Email or password is incorrect. Please try again.';

  @override
  String get authRateLimitError =>
      'Too many attempts. Please wait a few minutes and try again.';

  @override
  String get authNetworkError =>
      'Could not complete sign-in. Check your connection and try again.';

  @override
  String get authOffline =>
      'Connection interrupted. Your session is still open; please check your connection.';

  @override
  String get authSignOutError => 'Could not sign out. Please try again.';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get needAccount => 'New to Steady? Create an account';

  @override
  String get screeningTitle => 'Let’s understand your health';

  @override
  String get screeningIntro =>
      'Measurements → medical history → allergies and food preferences → training goal → review and menu.';

  @override
  String get screeningPrivacy =>
      'Your answers stay in memory for this session, are not uploaded, and are cleared when you sign out or close the app. You can choose not to share them.';

  @override
  String get screeningConditions => 'Conditions and allergies';

  @override
  String get screeningConditionsHelp =>
      'Select every condition you have been told you have. These are self-reported, not verified diagnoses. Leave empty only if you know of none.';

  @override
  String get screeningConditionsKnown =>
      'I can report my conditions (including none)';

  @override
  String get screeningAllergiesKnown =>
      'I can report my food allergies (including none)';

  @override
  String get screeningOtherAllergies =>
      'Other food allergies, not listed above';

  @override
  String get screeningTreatment => 'Treatment and eating needs';

  @override
  String get screeningTreatmentHelp =>
      'Select all that apply. Leave empty only if you know none apply. Optional details help explain why a specialist may be needed.';

  @override
  String get screeningTreatmentKnown =>
      'I can report my treatment and eating needs';

  @override
  String get screeningMedications => 'Current medicines (optional)';

  @override
  String get screeningOrders =>
      'Dietary instructions from your clinician (optional)';

  @override
  String get screeningKidneyStage =>
      'Kidney stage and dialysis schedule, if known (optional)';

  @override
  String get screeningLabNotes =>
      'Measured lab results: value, unit, date and source (optional)';

  @override
  String get screeningLabHelp =>
      'For kidney disease: eGFR, potassium and phosphorus; for diabetes: HbA1c. These notes are not interpreted or used to set nutrient limits.';

  @override
  String get screeningReview => 'Your screening result';

  @override
  String get screeningLifestyle => 'General lifestyle support';

  @override
  String get screeningMoreInformation => 'More information needed';

  @override
  String get screeningProfessional => 'Professional assessment needed';

  @override
  String get screeningReasonChild =>
      'Adult meal templates do not apply to children and adolescents.';

  @override
  String get screeningReasonTreatment =>
      'Your treatment, eating needs or recent health changes need an individual assessment.';

  @override
  String get screeningReasonComplex =>
      'A reported condition is outside Steady’s current scope for automatic meal templates.';

  @override
  String get screeningReasonOrders =>
      'Steady cannot validate or fulfil clinician-set dietary limits with its sample recipe data.';

  @override
  String get screeningReasonMedication =>
      'Medicine–food interactions need review. Steady does not change or interpret your medication.';

  @override
  String get screeningReasonAllergy =>
      'The sample catalogue cannot check the additional allergies you entered.';

  @override
  String get screeningReasonKidney =>
      'Kidney nutrition depends on stage, dialysis, medicines and measured results. Even complete notes do not unlock an automatic therapeutic plan.';

  @override
  String get screeningReasonWeightConflict =>
      'Automatic weight-loss planning is paused because cancer treatment, poor intake or unintended weight loss may change your nutrition priorities.';

  @override
  String get screeningReasonUnknown =>
      'Conditions, allergies or treatment are not yet known. General tracking is available; automatic meal templates remain paused.';

  @override
  String get screeningReasonLifestyle =>
      'You can use general habit support and illustrative meal templates. This result does not certify a meal as suitable for a medical condition.';

  @override
  String get screeningConsent =>
      'I agree to use these self-reported answers for support during this session.';

  @override
  String get screeningConsentError =>
      'Please agree to session use, or continue without sharing health details.';

  @override
  String get screeningDecline => 'Continue without sharing health details';

  @override
  String get screeningDeclined =>
      'Health details not shared. Automatic meal templates are paused.';

  @override
  String get screeningContinue => 'Continue to Steady';

  @override
  String get screeningEdit => 'Update health screening';

  @override
  String get screeningNote =>
      'Screening guides the app’s scope. It does not diagnose disease, prescribe a diet or replace your care team.';

  @override
  String get screeningPaused => 'Meal planning is paused';

  @override
  String get screeningSources => 'Evidence reviewed: 7 October 2026';

  @override
  String get conditionType1 => 'Type 1 diabetes';

  @override
  String get conditionType2 => 'Type 2 diabetes';

  @override
  String get conditionLung => 'COPD or chronic lung disease';

  @override
  String get conditionCancer => 'Cancer';

  @override
  String get conditionKidney => 'Chronic kidney disease';

  @override
  String get conditionTransplant => 'Organ or stem cell transplant';

  @override
  String get conditionObesity => 'Overweight or obesity';

  @override
  String get conditionHeart =>
      'Heart failure, coronary disease or cardiomyopathy';

  @override
  String get conditionStroke => 'Cerebrovascular disease or previous stroke';

  @override
  String get conditionDown => 'Down syndrome';

  @override
  String get conditionHiv => 'HIV/AIDS';

  @override
  String get conditionNeurological => 'Neurological disease or dementia';

  @override
  String get conditionBlood =>
      'Sickle cell disease, thalassaemia or chronic blood disorder';

  @override
  String get conditionAsthma => 'Asthma';

  @override
  String get conditionHypertension => 'Hypertension';

  @override
  String get conditionImmunodeficiency => 'Immunodeficiency';

  @override
  String get conditionFattyLiver => 'Metabolic fatty liver disease';

  @override
  String get conditionOtherLiver => 'Cirrhosis or other liver disease';

  @override
  String get conditionSubstance => 'Substance use disorder';

  @override
  String get conditionImmunosuppression =>
      'Corticosteroid or immunosuppressive treatment';

  @override
  String get conditionSystemic => 'Systemic disease (such as lupus)';

  @override
  String get conditionCongenital => 'Congenital or paediatric condition';

  @override
  String get conditionOther => 'Other condition or therapeutic diet';

  @override
  String get flagPregnancy => 'Pregnant or breastfeeding';

  @override
  String get flagEatingDisorder => 'Eating disorder';

  @override
  String get flagDialysis => 'Currently receiving dialysis';

  @override
  String get flagChemotherapy => 'Currently receiving chemotherapy';

  @override
  String get flagInsulin => 'Using insulin';

  @override
  String get flagSwallowing => 'Difficulty swallowing';

  @override
  String get flagWeightLoss => 'Recent unintended weight loss';

  @override
  String get flagPoorIntake => 'Poor appetite or difficulty eating enough';

  @override
  String get flagComplications => 'Severe complications or unstable disease';

  @override
  String get today => 'Today';

  @override
  String get checkIn => 'Check in';

  @override
  String get rewards => 'Rewards';

  @override
  String get profile => 'Profile';

  @override
  String get meals => 'Meals';

  @override
  String get movedToday => 'You moved today.';

  @override
  String get makeTodayCount => 'Make today count.';

  @override
  String get consistencyMessage =>
      'Keep showing up. Every active day brings you closer to your goal.';

  @override
  String get movementMessage =>
      'Walk, run, swim or choose an activity you enjoy. Start with a little movement today.';

  @override
  String get checkInComplete => 'Daily check-in complete';

  @override
  String get noActivity => 'No activity logged yet';

  @override
  String get anyMovement => 'Every bit of movement counts.';

  @override
  String get logAnother => 'Log another activity';

  @override
  String get thisWeek => 'Last 7 days';

  @override
  String get dayStreak => 'day streak';

  @override
  String get steadyPoints => 'Steady points';

  @override
  String get consistencyTip =>
      'Build a habit with activities you enjoy. Consistency earns points.';

  @override
  String get whatDidYouDo => 'What did you do today?';

  @override
  String get activity => 'Activity';

  @override
  String get duration => 'Duration';

  @override
  String get manualActivity =>
      'Log your activity and duration here. Your activity is recorded manually.';

  @override
  String get saveActivity => 'Save activity';

  @override
  String get walk => 'Walk';

  @override
  String get run => 'Run';

  @override
  String get cycle => 'Cycle';

  @override
  String get swim => 'Swim';

  @override
  String get gym => 'Gym';

  @override
  String get sport => 'Sport';

  @override
  String get mma => 'MMA';

  @override
  String get other => 'Other';

  @override
  String get rewardsIntro => 'Earn points by staying consistent.';

  @override
  String get previewRewards => 'Reward preview';

  @override
  String get recoveryDay => 'Recovery day';

  @override
  String get partnerPerk => 'Partner perk';

  @override
  String get steadyBadge => 'Steady badge';

  @override
  String get rewardsNote =>
      'These sample rewards are a preview. Redemption is not available yet.';

  @override
  String get member => 'Steady member';

  @override
  String get memberGoal => 'Goal: stay active consistently';

  @override
  String get weeklyTarget => 'Weekly target';

  @override
  String get fiveDays => '5 active days';

  @override
  String get reminders => 'Reminders';

  @override
  String get notConnected => 'Not connected yet';

  @override
  String get healthData => 'Health data';

  @override
  String get manualCheckIns => 'Activities entered manually';

  @override
  String get language => 'Language';

  @override
  String get languageHelp => 'Choose how Steady speaks to you.';

  @override
  String get systemLanguage => 'Device language';

  @override
  String get languageSaveError =>
      'Language changed for this session. Could not save your preference.';

  @override
  String get mealsTitle => 'Your meals, made simple';

  @override
  String get mealsIntro =>
      'Familiar Vietnamese dishes. A week planned around your routine.';

  @override
  String get setupTitle => 'Let’s plan your week';

  @override
  String get setupIntro =>
      'Three short steps to match your preferences, time and budget.';

  @override
  String get bodyGoal => 'About you';

  @override
  String get health => 'Health';

  @override
  String get preferences => 'Preferences';

  @override
  String get bodyGoalHelp => 'Start with your measurements and your goal.';

  @override
  String get age => 'Age';

  @override
  String get height => 'Height (cm)';

  @override
  String get weight => 'Weight (kg)';

  @override
  String get goal => 'Goal';

  @override
  String get dailyActivity => 'Usual activity level';

  @override
  String get balanced => 'Balanced eating';

  @override
  String get weightLoss => 'Support weight loss';

  @override
  String get muscle => 'Support muscle gain';

  @override
  String get sedentary => 'Mostly sedentary';

  @override
  String get lightActivity => 'Light: 1–2 sessions/week';

  @override
  String get moderateActivity => 'Moderate: 3–4 sessions/week';

  @override
  String get highActivity => 'High: 5+ sessions/week';

  @override
  String get cholesterolStatus => 'High cholesterol diagnosis';

  @override
  String get unknown => 'Not sure';

  @override
  String get confirmed => 'Confirmed by a clinician';

  @override
  String get notDiagnosed => 'Not diagnosed';

  @override
  String get healthHelp =>
      'Optional readings can be left blank. Enter measured results only; Steady does not diagnose or interpret them.';

  @override
  String get optionalReadings => 'Add blood pressure or lab results';

  @override
  String get optional => 'Optional';

  @override
  String get systolic => 'Systolic (mmHg)';

  @override
  String get diastolic => 'Diastolic (mmHg)';

  @override
  String get ldl => 'LDL (mmol/L)';

  @override
  String get hdl => 'HDL (mmol/L)';

  @override
  String get triglycerides => 'Triglycerides (mmol/L)';

  @override
  String get professionalLabel => 'I need a specialist diet';

  @override
  String get professionalHelp =>
      'Pregnancy, breastfeeding, kidney disease, an eating disorder or a prescribed therapeutic diet.';

  @override
  String get diet => 'Diet';

  @override
  String get omnivore => 'Varied diet';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get budget => 'Daily food budget (VND)';

  @override
  String get cookingTime => 'Max cooking time per meal (min)';

  @override
  String get allergens => 'Allergies & exclusions';

  @override
  String get allergensHelp =>
      'Selected ingredients stay excluded when you create or swap meals.';

  @override
  String get dislikes => 'Ingredients you prefer to skip';

  @override
  String get soy => 'Soy';

  @override
  String get fish => 'Fish';

  @override
  String get gluten => 'Gluten';

  @override
  String get milk => 'Milk';

  @override
  String get egg => 'Egg';

  @override
  String get peanut => 'Peanut';

  @override
  String get nuts => 'Tree nuts';

  @override
  String get shellfish => 'Shellfish';

  @override
  String get sesame => 'Sesame';

  @override
  String get consent => 'Use my details for this session’s meal plan';

  @override
  String get privacyNote =>
      'Your profile and plan stay in memory on this device. They are cleared when the app closes and are not sent to AI or a server.';

  @override
  String get createPlan => 'Create my 7-day plan';

  @override
  String get updatePlan => 'Update my plan';

  @override
  String get continueLabel => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get integerError => 'Enter a whole number';

  @override
  String get bloodPressurePairError =>
      'Enter both blood pressure readings, or leave both blank.';

  @override
  String get bloodPressureOrderError =>
      'Systolic pressure must be higher than diastolic pressure.';

  @override
  String get consentError =>
      'Please agree to use your details for this meal plan.';

  @override
  String get planReady => 'Your week is ready';

  @override
  String get planUpdated => 'Meal plan updated';

  @override
  String get yourWeek => 'Your 7-day plan';

  @override
  String get editProfile => 'Edit preferences';

  @override
  String get dailyBudget => 'Daily budget';

  @override
  String get estimatedCost => 'Estimated cost';

  @override
  String get energy => 'Energy';

  @override
  String get protein => 'Protein';

  @override
  String get fibre => 'Fibre';

  @override
  String get saturatedFat => 'Saturated fat';

  @override
  String get estimatedDaily => 'Estimated daily totals';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get preparation => 'Preparation';

  @override
  String get recipeDetails => 'Ingredients & recipe';

  @override
  String get swapMeal => 'Swap meal';

  @override
  String get noAlternatives => 'No alternatives available';

  @override
  String get swapTitle => 'Choose another dish';

  @override
  String get swapHelp =>
      'These dishes match your diet, exclusions, time and budget.';

  @override
  String get groceries => 'Shopping list';

  @override
  String get groceriesWeek => 'Shopping list · 7 days';

  @override
  String get groceriesHelp =>
      'Amounts for the whole week. Beans labelled “cooked” use cooked weight. Other weights refer to raw edible ingredients.';

  @override
  String get planNotes => 'About this sample plan';

  @override
  String get nutritionNote =>
      'Recipe nutrition and prices are estimates, not verified clinical data or live prices. Quantities scale with each portion; cooking time assumes small home batches. Sodium estimates exclude added salt/sauces: check labels and account for any seasoning. A sample menu does not guarantee therapeutic suitability or complete micronutrients.';

  @override
  String get personalisationNote =>
      'The layered configuration sets starting calorie/macro estimates. Portion sizes are matched to them while keeping allergies, diet, time and budget as hard constraints. Clinical restrictions override training preferences.';

  @override
  String get unsupportedTitle => 'A specialist plan is a better fit';

  @override
  String get unsupportedHelp =>
      'Automatic plans are unavailable for under-18s or people who need a therapeutic diet. Work with a nutrition professional for a suitable plan.';

  @override
  String get emptyPlanTitle => 'No matching plan yet';

  @override
  String get emptyPlanHelp =>
      'No menu meets all calorie, macro, allergy, food, time and budget requirements. Edit preferences; no constraint has been silently removed.';

  @override
  String get deletePlan => 'Delete profile & plan';

  @override
  String get deleteTitle => 'Delete your meal details?';

  @override
  String get deleteHelp =>
      'This clears your measurements, health readings, preferences and meal plan from this session. You can start again afterwards.';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Meal profile and plan deleted';

  @override
  String get close => 'Close';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get completed => 'Completed';

  @override
  String get notCompleted => 'No activity';

  @override
  String minutesValue(int count) {
    return '$count min';
  }

  @override
  String pointsValue(int count) {
    return '$count points';
  }

  @override
  String activitySaved(String activity, int points) {
    return '$activity logged. +$points points';
  }

  @override
  String rangeError(String min, String max) {
    return 'Enter a value from $min to $max';
  }

  @override
  String stepProgress(int step) {
    return 'Step $step of 3';
  }

  @override
  String dayNumber(int day) {
    return 'Day $day';
  }

  @override
  String mealSwapped(String meal) {
    return 'Changed to $meal';
  }

  @override
  String itemsCount(int count) {
    return '$count ingredients';
  }

  @override
  String get oatsIngredient => 'Oats';

  @override
  String get banana => 'Banana';

  @override
  String get soyMilk => 'Unsweetened soy milk';

  @override
  String get sweetPotato => 'Sweet potato';

  @override
  String get cookedSoybeans => 'Cooked soybeans';

  @override
  String get guava => 'Guava';

  @override
  String get mungBeans => 'Mung beans';

  @override
  String get brownRice => 'Brown rice';

  @override
  String get cookedRedBeans => 'Cooked red beans';

  @override
  String get cucumber => 'Cucumber';

  @override
  String get canolaOil => 'Canola oil';

  @override
  String get tilapia => 'Tilapia fillet';

  @override
  String get greens => 'Leafy greens';

  @override
  String get tofuIngredient => 'Tofu';

  @override
  String get tomato => 'Tomato';

  @override
  String get carrot => 'Carrot';

  @override
  String get chickenBreast => 'Skinless chicken breast';

  @override
  String get mushrooms => 'Mushrooms';

  @override
  String get oatsName => 'Banana oat porridge';

  @override
  String get oatsRecipe =>
      'Cook oats with soy milk and water for 5–7 minutes. Add banana. Do not add sugar.';

  @override
  String get sweetName => 'Sweet potato, soybeans & fruit';

  @override
  String get sweetRecipe =>
      'Steam sweet potato for 15–20 minutes. Serve with cooked soybeans and washed guava.';

  @override
  String get beanbreakfastName => 'Mung bean porridge & banana';

  @override
  String get beanbreakfastRecipe =>
      'Soak beans and rice beforehand. Cook in water until soft; use a pressure cooker to save time. Serve banana separately.';

  @override
  String get ricebreakfastName => 'Brown rice, red beans & cucumber';

  @override
  String get ricebreakfastRecipe =>
      'Use cooked rice and boiled beans. Reheat and serve with cucumber and canola oil.';

  @override
  String get fishName => 'Steamed fish, brown rice & greens';

  @override
  String get fishRecipe =>
      'Cook rice. Steam fish with ginger for 10–15 minutes until cooked. Boil greens and add canola oil. Seasonings and dipping sauces are counted separately.';

  @override
  String get tofuName => 'Tomato tofu & brown rice';

  @override
  String get tofuRecipe =>
      'Cook rice. Simmer tomatoes with a little water and oil, then add tofu. Serve with boiled greens. Avoid deep frying.';

  @override
  String get lentilName => 'Mung beans, rice & vegetables';

  @override
  String get lentilRecipe =>
      'Use soaked beans and cooked rice. Cook beans until soft, add carrot and greens, then mix with rice and oil.';

  @override
  String get chickenName => 'Pan-seared chicken, rice & greens';

  @override
  String get chickenRecipe =>
      'Cook rice. Pan-sear skinless chicken with oil until thoroughly cooked. Serve with steamed greens; limit bottled sauces.';

  @override
  String get beanDinnerName => 'Red beans, sweet potato & greens';

  @override
  String get beanDinnerRecipe =>
      'Steam sweet potato. Reheat cooked red beans and serve with boiled greens and canola oil.';

  @override
  String get fishDinnerName => 'Steamed fish, sweet potato & greens';

  @override
  String get fishDinnerRecipe =>
      'Steam sweet potato and fish until cooked, then boil greens. Use ginger and lime; dipping sauces are counted separately.';

  @override
  String get tofuDinnerName => 'Steamed tofu, mushrooms & brown rice';

  @override
  String get tofuDinnerRecipe =>
      'Steam tofu with mushrooms until hot and cooked. Serve with brown rice, greens and canola oil.';

  @override
  String get chickenDinnerName => 'Skinless chicken, sweet potato & greens';

  @override
  String get chickenDinnerRecipe =>
      'Steam sweet potato. Boil or pan-sear chicken until thoroughly cooked. Serve with boiled greens.';

  @override
  String get nutritionBodyMeasurements => 'Body measurements';

  @override
  String get nutritionBodyFat => 'Body fat (%)';

  @override
  String get nutritionBodyFatHelp =>
      'Optional: enter a measured value, or leave blank if unknown. Steady does not infer it from BMI.';

  @override
  String get nutritionSex => 'Sex used for energy estimation';

  @override
  String get nutritionSexHelp =>
      'The Mifflin–St Jeor equation uses sex, age, height and weight. If you skip sex, Steady will not invent a calorie target.';

  @override
  String get nutritionSexUnspecified => 'Skip energy estimation';

  @override
  String get nutritionSexFemale => 'Female';

  @override
  String get nutritionSexMale => 'Male';

  @override
  String get nutritionFoodSource => 'Food sources';

  @override
  String get nutritionFoodPattern => 'Food pattern';

  @override
  String get nutritionMacroStrategy => 'Macronutrient strategy';

  @override
  String get nutritionMealTiming => 'Meal schedule';

  @override
  String get nutritionEnergyStrategy => 'Energy strategy';

  @override
  String get nutritionTrainingGoal => 'Training and body goal';

  @override
  String get nutritionTrainingSessions => 'Resistance-training sessions/week';

  @override
  String get nutritionExperience => 'Training experience';

  @override
  String get nutritionBeginner => 'Beginner / returning';

  @override
  String get nutritionIntermediate => 'Intermediate';

  @override
  String get nutritionAdvanced => 'Advanced';

  @override
  String get nutritionGoalHealth => 'General health';

  @override
  String get nutritionGoalFatLoss => 'Lose fat, preserve muscle';

  @override
  String get nutritionGoalMuscle => 'Build muscle';

  @override
  String get nutritionGoalRecomp => 'Body recomposition';

  @override
  String get nutritionGoalPerformance => 'Strength / performance';

  @override
  String get nutritionGoalEndurance => 'Endurance';

  @override
  String get nutritionMaintenance => 'Maintenance';

  @override
  String get nutritionDeficit => 'Moderate cut';

  @override
  String get nutritionLeanBulk => 'Lean bulk';

  @override
  String get nutritionAggressiveBulk =>
      'Aggressive bulk (often called dirty bulk)';

  @override
  String get nutritionRecompEnergy => 'Recomp at maintenance';

  @override
  String get nutritionBalancedMacro => 'Balanced macros';

  @override
  String get nutritionHighProtein => 'High-protein balanced';

  @override
  String get nutritionLowCarb => 'Low carbohydrate';

  @override
  String get nutritionKeto => 'Ketogenic';

  @override
  String get nutritionLowFat => 'Lower fat';

  @override
  String get nutritionBalancedPattern => 'Varied whole foods';

  @override
  String get nutritionMediterranean => 'Mediterranean style';

  @override
  String get nutritionDash => 'DASH style';

  @override
  String get nutritionPaleo => 'Paleo';

  @override
  String get nutritionVegan => 'Vegan';

  @override
  String get nutritionThreeMeals => '3 meals/day';

  @override
  String get nutritionFourMeals => '3 meals + 1 snack';

  @override
  String get nutritionTimeRestricted => '16:8 — meals within 12:00–20:00';

  @override
  String get nutritionPreferenceHelp =>
      'Food sources, macros and meal timing are separate choices. Allergies and medical requirements always take priority.';

  @override
  String get nutritionGenerate => 'Finish and generate menu';

  @override
  String get nutritionConfiguration => 'Your nutrition configuration';

  @override
  String get nutritionMaintenanceEstimate => 'Estimated maintenance';

  @override
  String get nutritionDailyTarget => 'Starting daily target';

  @override
  String get nutritionCarbs => 'Carbohydrate';

  @override
  String get nutritionFat => 'Fat';

  @override
  String get nutritionSodium => 'Sodium';

  @override
  String get nutritionPortion => 'Portion multiplier';

  @override
  String get nutritionMedicalReview =>
      'Your medical answers require more information or professional review before automatic menu generation.';

  @override
  String get nutritionInvalidMeasurements =>
      'Check measurements and activity information before estimating a menu.';

  @override
  String get nutritionNeedSex =>
      'Energy estimation is skipped. Update the sex input to generate a menu matched to an estimated calorie target.';

  @override
  String get nutritionGoalConflict =>
      'The selected goal and energy strategy conflict. Choose a compatible strategy before generating a menu.';

  @override
  String get nutritionLowWeightReview =>
      'A deficit with a low weight-for-height needs professional assessment. Steady will not automatically create a cut plan.';

  @override
  String get nutritionKetoReview =>
      'Keto with your medical conditions or SGLT2 medication needs clinician review. No automatic keto menu will be generated.';

  @override
  String get nutritionBulkReview =>
      'Aggressive bulk with your reported medical conditions needs professional review. Choose a safer strategy with your care team.';

  @override
  String get nutritionPatternConflict =>
      'Paleo excludes the legumes and grains used by this plant-based catalogue. Change one preference; Steady will not silently ignore it.';

  @override
  String get nutritionEstimateUnavailable =>
      'These inputs produce an estimate outside Steady’s supported range. Update the information or seek professional assessment.';

  @override
  String get nutritionEstimateNote =>
      'Calories and macros are starting estimates, not a clinical prescription. Body fat is recorded separately and is not a diagnosis. Adjust using weight trends and training response.';

  @override
  String get nutritionBulkTradeoff =>
      'Aggressive bulk means a larger energy surplus, not lower-quality food. Faster weight gain can include more fat; it does not guarantee faster muscle growth.';

  @override
  String get nutritionTrainingNote =>
      'Muscle gain and recomp also depend on progressive resistance training and recovery. This menu cannot guarantee body-composition changes.';

  @override
  String get nutritionKetoPerformance =>
      'Keto is not the first recommendation for high-volume or high-intensity training. No performance advantage or ketosis is guaranteed.';

  @override
  String get nutritionVeganNote =>
      'A vegan menu needs attention to B12, iron, calcium, iodine and omega-3. This catalogue does not verify full micronutrient coverage.';

  @override
  String get flagSglt2 =>
      'Taking an SGLT2 inhibitor (such as dapagliflozin or empagliflozin)';

  @override
  String get snack => 'Snack';

  @override
  String get eggIngredient => 'Egg';

  @override
  String get avocadoIngredient => 'Avocado';

  @override
  String get tofuScrambleName => 'Tofu and vegetable scramble';

  @override
  String get tofuScrambleRecipe =>
      'Heat plain tofu and vegetables with oil. Use unseasoned tofu; do not add salty sauces.';

  @override
  String get eggPotatoName => 'Eggs, sweet potato and greens';

  @override
  String get eggPotatoRecipe =>
      'Cook eggs thoroughly. Steam sweet potato and greens; dress greens with oil. Do not add salt.';

  @override
  String get ketoEggName => 'Eggs and avocado';

  @override
  String get ketoEggRecipe =>
      'Boil eggs thoroughly. Serve with avocado and cucumber dressed with the full amount of oil listed in the ingredients; do not add salt.';

  @override
  String get ketoChickenName => 'Chicken and avocado salad';

  @override
  String get ketoChickenRecipe =>
      'Cook chicken and greens thoroughly. Serve with avocado, oil and lemon; do not add salty dressing.';

  @override
  String get ketoFishName => 'Steamed fish with non-starchy vegetables';

  @override
  String get ketoFishRecipe =>
      'Steam fish thoroughly and cook greens. Serve with oil and lemon; do not add salt or dipping sauce.';

  @override
  String get ketoTofuLunchName => 'Tofu and avocado';

  @override
  String get ketoTofuLunchRecipe =>
      'Cook unseasoned tofu. Serve with avocado, cucumber and oil; do not add salt.';

  @override
  String get ketoTofuDinnerName => 'Tofu, mushrooms and greens';

  @override
  String get ketoTofuDinnerRecipe =>
      'Cook tofu, mushrooms and greens with oil. Do not add salt or sauces.';

  @override
  String get soySnackName => 'Soybeans and guava';

  @override
  String get soySnackRecipe =>
      'Reheat cooked unsalted soybeans. Serve with washed guava.';

  @override
  String get eggSnackName => 'Eggs and cucumber';

  @override
  String get eggSnackRecipe =>
      'Cook eggs thoroughly. Serve with washed cucumber; do not add salt.';

  @override
  String get paleoChickenName => 'Chicken, sweet potato and greens';

  @override
  String get paleoChickenRecipe =>
      'Cook chicken thoroughly; steam sweet potato and greens. Dress the greens with the full amount of oil listed in the ingredients; do not add salt.';

  @override
  String get authInvalidConfiguration =>
      'The sign-in service configuration is invalid, or the key belongs to a different project. Update the configuration and restart the app.';
}
