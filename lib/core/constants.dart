class AppConstants {
  AppConstants._();

  static const String elderlyAppName   = 'Care Companion';
  static const String caregiverAppName = 'Care Companion';

  static const String usersCollection         = 'users';
  static const String medicationsCollection   = 'medications';
  static const String healthRecordsCollection = 'health_records';
  static const String alertsCollection        = 'alerts';
  static const String locationsCollection     = 'locations';
  static const String dailyActivityCollection = 'daily_activity';

  static const String medicationImagesPath = 'medications';
  static const String userPhotosPath       = 'users';
  static const String prescriptionsPath    = 'prescriptions';

  static const String roleElderly   = 'elderly';
  static const String roleCaregiver = 'caregiver';

  static const String alertEmergency        = 'emergency';
  static const String alertMissedMedication = 'missed_medication';
  static const String alertFall             = 'fall';
  static const String alertGeofence         = 'geofence';
  static const String alertInactivity       = 'inactivity';

  static const String healthBloodPressure = 'blood_pressure';
  static const String healthSugar         = 'sugar';
  static const String healthPulse         = 'pulse';

  static const double fallThresholdMagnitude   = 25.0;
  static const int    fallResponseDelaySeconds = 30;

  static const double geofenceRadiusMeters = 200.0;

  static const int inactivityThresholdMinutes = 120;

  static const String hiveMedicationsBox = 'medications_box';
  static const String hiveHealthBox      = 'health_box';
  static const String hiveUserBox        = 'user_box';
  static const String hiveSettingsBox    = 'settings_box';

  static const String prefFcmToken       = 'fcm_token';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefUserRole       = 'user_role';
  static const String prefFontSize       = 'font_size';

  static const Duration animFast     = Duration(milliseconds: 200);
  static const Duration animMedium   = Duration(milliseconds: 400);
  static const Duration animSlow     = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 900);

  static const double buttonHeightLarge  = 70.0;
  static const double buttonHeightMedium = 56.0;
  static const double fontSizeXL         = 28.0;
  static const double fontSizeLarge      = 22.0;
  static const double fontSizeMedium     = 18.0;
  static const double fontSizeSmall      = 16.0;
  static const double iconSizeLarge      = 36.0;
  static const double iconSizeMedium     = 28.0;
  static const double borderRadiusLarge  = 20.0;
  static const double borderRadiusMedium = 14.0;
  static const double borderRadiusSmall  = 10.0;

  static const double paddingXL     = 24.0;
  static const double paddingLarge  = 20.0;
  static const double paddingMedium = 16.0;
  static const double paddingSmall  = 12.0;
  static const double paddingXS     = 8.0;
  static const double gapLarge      = 20.0;
  static const double gapMedium     = 14.0;
  static const double gapSmall      = 10.0;
}