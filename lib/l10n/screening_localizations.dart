import '../screening/health_screening.dart';
import 'app_localizations.dart';

extension ScreeningLocalizations on AppLocalizations {
  String conditionName(HealthCondition value) => switch (value) {
    HealthCondition.type1Diabetes => conditionType1,
    HealthCondition.type2Diabetes => conditionType2,
    HealthCondition.lungDisease => conditionLung,
    HealthCondition.cancer => conditionCancer,
    HealthCondition.kidneyDisease => conditionKidney,
    HealthCondition.transplant => conditionTransplant,
    HealthCondition.obesity => conditionObesity,
    HealthCondition.heartDisease => conditionHeart,
    HealthCondition.stroke => conditionStroke,
    HealthCondition.downSyndrome => conditionDown,
    HealthCondition.hiv => conditionHiv,
    HealthCondition.neurologicalDisease => conditionNeurological,
    HealthCondition.bloodDisorder => conditionBlood,
    HealthCondition.asthma => conditionAsthma,
    HealthCondition.hypertension => conditionHypertension,
    HealthCondition.immunodeficiency => conditionImmunodeficiency,
    HealthCondition.fattyLiver => conditionFattyLiver,
    HealthCondition.otherLiverDisease => conditionOtherLiver,
    HealthCondition.substanceUse => conditionSubstance,
    HealthCondition.immunosuppressiveTherapy => conditionImmunosuppression,
    HealthCondition.systemicDisease => conditionSystemic,
    HealthCondition.congenitalDisease => conditionCongenital,
    HealthCondition.other => conditionOther,
  };
  String flagName(HealthFlag value) => switch (value) {
    HealthFlag.pregnantOrBreastfeeding => flagPregnancy,
    HealthFlag.eatingDisorder => flagEatingDisorder,
    HealthFlag.dialysis => flagDialysis,
    HealthFlag.chemotherapy => flagChemotherapy,
    HealthFlag.insulin => flagInsulin,
    HealthFlag.swallowingDifficulty => flagSwallowing,
    HealthFlag.unintendedWeightLoss => flagWeightLoss,
    HealthFlag.poorIntake => flagPoorIntake,
    HealthFlag.severeComplications => flagComplications,
    HealthFlag.sglt2Inhibitor => flagSglt2,
  };
  String decisionName(ScreeningDecision value) => switch (value) {
    ScreeningDecision.lifestyle => screeningLifestyle,
    ScreeningDecision.moreInformation => screeningMoreInformation,
    ScreeningDecision.professionalReview => screeningProfessional,
  };
  String screeningReason(String value) => switch (value) {
    'screeningReasonChild' => screeningReasonChild,
    'screeningReasonTreatment' => screeningReasonTreatment,
    'screeningReasonComplex' => screeningReasonComplex,
    'screeningReasonOrders' => screeningReasonOrders,
    'screeningReasonMedication' => screeningReasonMedication,
    'screeningReasonAllergy' => screeningReasonAllergy,
    'screeningReasonKidney' => screeningReasonKidney,
    'screeningReasonWeightConflict' => screeningReasonWeightConflict,
    'screeningReasonUnknown' => screeningReasonUnknown,
    'screeningReasonLifestyle' => screeningReasonLifestyle,
    'nutritionKetoReview' => nutritionKetoReview,
    'nutritionBulkReview' => nutritionBulkReview,
    _ => throw ArgumentError.value(value, 'screeningReason'),
  };
}
