import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ru'),
  ];

  /// No description provided for @haveSuggestionsOrFoundABug.
  ///
  /// In en, this message translates to:
  /// **'* have suggestions or found a bug?'**
  String get haveSuggestionsOrFoundABug;

  /// No description provided for @n0Slash68Clean.
  ///
  /// In en, this message translates to:
  /// **'0 / 68 clean'**
  String get n0Slash68Clean;

  /// No description provided for @n1HourHasPassed.
  ///
  /// In en, this message translates to:
  /// **'1 hour has passed'**
  String get n1HourHasPassed;

  /// No description provided for @n100percentOffline.
  ///
  /// In en, this message translates to:
  /// **'100% offline'**
  String get n100percentOffline;

  /// No description provided for @n100percentOfflineDatabase.
  ///
  /// In en, this message translates to:
  /// **'100% offline database'**
  String get n100percentOfflineDatabase;

  /// No description provided for @n100percentOfflineIntegrity.
  ///
  /// In en, this message translates to:
  /// **'100% offline integrity'**
  String get n100percentOfflineIntegrity;

  /// No description provided for @n100percentOfflineFirstZeroTrackersZeroDataCollection.
  ///
  /// In en, this message translates to:
  /// **'100% offline-first. zero trackers. zero data collection'**
  String get n100percentOfflineFirstZeroTrackersZeroDataCollection;

  /// No description provided for @n16WeekHabitActivityGrid.
  ///
  /// In en, this message translates to:
  /// **'16-week habit activity grid'**
  String get n16WeekHabitActivityGrid;

  /// No description provided for @n54321Grounding.
  ///
  /// In en, this message translates to:
  /// **'5-4-3-2-1 grounding'**
  String get n54321Grounding;

  /// No description provided for @n8LuxuryAppIconEditions.
  ///
  /// In en, this message translates to:
  /// **'8 luxury app icon editions'**
  String get n8LuxuryAppIconEditions;

  /// No description provided for @aFullScreenMindfulReminderThatTurnsYourPhoneIntoAnAwarenessAnchorThroughoutTheDay.
  ///
  /// In en, this message translates to:
  /// **'a full-screen mindful reminder that turns your phone into an awareness anchor throughout the day.'**
  String
  get aFullScreenMindfulReminderThatTurnsYourPhoneIntoAnAwarenessAnchorThroughoutTheDay;

  /// No description provided for @aNewHourHasPassedTakeAMindfulPauseAndReflect.
  ///
  /// In en, this message translates to:
  /// **'a new hour has passed. take a mindful pause and reflect.'**
  String get aNewHourHasPassedTakeAMindfulPauseAndReflect;

  /// No description provided for @aPrivacyFirstOfflineCleanStreakTrackerAndRelapseDiaryBuiltToEmpowerYourRecoveryJourney.
  ///
  /// In en, this message translates to:
  /// **'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.'**
  String
  get aPrivacyFirstOfflineCleanStreakTrackerAndRelapseDiaryBuiltToEmpowerYourRecoveryJourney;

  /// No description provided for @aQuietOfflineFirstWayToMarkMomentsTheSecondTheyHappen.
  ///
  /// In en, this message translates to:
  /// **'a quiet, offline-first way to mark moments the second they happen.'**
  String get aQuietOfflineFirstWayToMarkMomentsTheSecondTheyHappen;

  /// No description provided for @aQuietOfflineFirstWayToMarkMomentsTrackTimeAndInspectLogsOnYourTerms.
  ///
  /// In en, this message translates to:
  /// **'a quiet, offline-first way to mark moments, track time, and inspect logs on your terms.'**
  String
  get aQuietOfflineFirstWayToMarkMomentsTrackTimeAndInspectLogsOnYourTerms;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'about'**
  String get about;

  /// No description provided for @absolutelyNotekarIsOpenSourceAndOfflineFirstToGuaranteeMaximumTrustAndSafetyEveryCompiledReleaseIsAutomaticallyUploadedAndVerifiedCleanBy60plusAntiMalwareEnginesViaVirustotalYouCanInspectTheLiveScanReportUnderPrivacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.'**
  String
  get absolutelyNotekarIsOpenSourceAndOfflineFirstToGuaranteeMaximumTrustAndSafetyEveryCompiledReleaseIsAutomaticallyUploadedAndVerifiedCleanBy60plusAntiMalwareEnginesViaVirustotalYouCanInspectTheLiveScanReportUnderPrivacyAndSecurity;

  /// No description provided for @accentColorCategory.
  ///
  /// In en, this message translates to:
  /// **'accent color'**
  String get accentColorCategory;

  /// No description provided for @accentcolorcategory.
  ///
  /// In en, this message translates to:
  /// **'accentcolorcategory'**
  String get accentcolorcategory;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'accept'**
  String get accept;

  /// No description provided for @accessSplitPerAbiOptimizedBinariesAndGooglePlayAppbundlesDirectlyFromTheReleasePage.
  ///
  /// In en, this message translates to:
  /// **'access split-per-abi optimized binaries and google play appbundles directly from the release page.'**
  String
  get accessSplitPerAbiOptimizedBinariesAndGooglePlayAppbundlesDirectlyFromTheReleasePage;

  /// No description provided for @accessibilityCategory.
  ///
  /// In en, this message translates to:
  /// **'accessibility'**
  String get accessibilityCategory;

  /// No description provided for @accessibilitycategory.
  ///
  /// In en, this message translates to:
  /// **'accessibilitycategory'**
  String get accessibilitycategory;

  /// No description provided for @acknowledgeTheElapsedHour.
  ///
  /// In en, this message translates to:
  /// **'acknowledge the elapsed hour'**
  String get acknowledgeTheElapsedHour;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get active;

  /// No description provided for @activeIssueTracking.
  ///
  /// In en, this message translates to:
  /// **'active issue tracking'**
  String get activeIssueTracking;

  /// No description provided for @activeLauncherIcon.
  ///
  /// In en, this message translates to:
  /// **'active launcher icon'**
  String get activeLauncherIcon;

  /// No description provided for @activeProtection.
  ///
  /// In en, this message translates to:
  /// **'active protection'**
  String get activeProtection;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'activity'**
  String get activity;

  /// No description provided for @adaptiveEngine.
  ///
  /// In en, this message translates to:
  /// **'adaptive engine'**
  String get adaptiveEngine;

  /// No description provided for @adaptiveEngineAndPerformanceStatus.
  ///
  /// In en, this message translates to:
  /// **'adaptive engine and performance status'**
  String get adaptiveEngineAndPerformanceStatus;

  /// No description provided for @adaptiveEngineOverview.
  ///
  /// In en, this message translates to:
  /// **'adaptive engine overview'**
  String get adaptiveEngineOverview;

  /// No description provided for @addANote.
  ///
  /// In en, this message translates to:
  /// **'add a note'**
  String get addANote;

  /// No description provided for @addANoteToSave.
  ///
  /// In en, this message translates to:
  /// **'add a note to save'**
  String get addANoteToSave;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'add note'**
  String get addNote;

  /// No description provided for @addsACleanStreakCardToYourHomeScreenAndAdaptsHomeScreenWidgets.
  ///
  /// In en, this message translates to:
  /// **'adds a clean streak card to your home screen and adapts home screen widgets.'**
  String get addsACleanStreakCardToYourHomeScreenAndAdaptsHomeScreenWidgets;

  /// No description provided for @addsASubtleGlassLikeContainerBehindTheHomeToolbar.
  ///
  /// In en, this message translates to:
  /// **'adds a subtle glass-like container behind the home toolbar.'**
  String get addsASubtleGlassLikeContainerBehindTheHomeToolbar;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'afternoon'**
  String get afternoon;

  /// No description provided for @aggressiveBatteryCleanersOnLowEndDevicesCanKillNotekarInTheBackgroundDisableBatteryOptimizationToGuaranteeRemindersFire100percentOfTheTime.
  ///
  /// In en, this message translates to:
  /// **'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.'**
  String
  get aggressiveBatteryCleanersOnLowEndDevicesCanKillNotekarInTheBackgroundDisableBatteryOptimizationToGuaranteeRemindersFire100percentOfTheTime;

  /// No description provided for @alarmsPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'alarms permission required'**
  String get alarmsPermissionRequired;

  /// No description provided for @all21MilestonesFrom1DayTo10YearsRootedInNeuroscienceAddictionRecoveryResearchAndBehaviouralPsychologyNamesShownInYourCurrentTheme.
  ///
  /// In en, this message translates to:
  /// **'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.'**
  String
  get all21MilestonesFrom1DayTo10YearsRootedInNeuroscienceAddictionRecoveryResearchAndBehaviouralPsychologyNamesShownInYourCurrentTheme;

  /// No description provided for @allBuildsNowUndergoAutomatedCodeqlScansAndVirustotalChecksToEnsureVerificationAndSafety.
  ///
  /// In en, this message translates to:
  /// **'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.'**
  String
  get allBuildsNowUndergoAutomatedCodeqlScansAndVirustotalChecksToEnsureVerificationAndSafety;

  /// No description provided for @allMomentsInTheDatabaseWillBePermanentlyRemovedThisCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'all moments in the database will be permanently removed. this cannot be undone.'**
  String get allMomentsInTheDatabaseWillBePermanentlyRemovedThisCannotBeUndone;

  /// No description provided for @allSettingsWillBeRestoredToTheirInitialFactoryDefaultsYourSavedMomentsAndNotesWillRemainUntouched.
  ///
  /// In en, this message translates to:
  /// **'all settings will be restored to their initial factory defaults. your saved moments and notes will remain untouched.'**
  String
  get allSettingsWillBeRestoredToTheirInitialFactoryDefaultsYourSavedMomentsAndNotesWillRemainUntouched;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'all time'**
  String get allTime;

  /// No description provided for @allowAppInstallation.
  ///
  /// In en, this message translates to:
  /// **'allow app installation'**
  String get allowAppInstallation;

  /// No description provided for @allowAutoStartSettings.
  ///
  /// In en, this message translates to:
  /// **'allow auto-start settings'**
  String get allowAutoStartSettings;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'allow notifications'**
  String get allowNotifications;

  /// No description provided for @allowsNotekarToSendLoggingRemindersAndUpdateNotifications.
  ///
  /// In en, this message translates to:
  /// **'allows notekar to send logging reminders and update notifications.'**
  String get allowsNotekarToSendLoggingRemindersAndUpdateNotifications;

  /// No description provided for @amethyst.
  ///
  /// In en, this message translates to:
  /// **'amethyst'**
  String get amethyst;

  /// No description provided for @amethystNebula.
  ///
  /// In en, this message translates to:
  /// **'amethyst nebula'**
  String get amethystNebula;

  /// No description provided for @amoled.
  ///
  /// In en, this message translates to:
  /// **'amoled'**
  String get amoled;

  /// No description provided for @ancient.
  ///
  /// In en, this message translates to:
  /// **'ancient'**
  String get ancient;

  /// No description provided for @androidBackup.
  ///
  /// In en, this message translates to:
  /// **'android backup'**
  String get androidBackup;

  /// No description provided for @angry.
  ///
  /// In en, this message translates to:
  /// **'angry'**
  String get angry;

  /// No description provided for @animalKingdom.
  ///
  /// In en, this message translates to:
  /// **'animal kingdom'**
  String get animalKingdom;

  /// No description provided for @anxious.
  ///
  /// In en, this message translates to:
  /// **'anxious'**
  String get anxious;

  /// No description provided for @appIcon.
  ///
  /// In en, this message translates to:
  /// **'app icon'**
  String get appIcon;

  /// No description provided for @appIconCouldNotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'app icon could not be changed'**
  String get appIconCouldNotBeChanged;

  /// No description provided for @appIconsCategory.
  ///
  /// In en, this message translates to:
  /// **'app icons'**
  String get appIconsCategory;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'app language'**
  String get appLanguage;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'app lock'**
  String get appLock;

  /// No description provided for @appLockAndBiometrics.
  ///
  /// In en, this message translates to:
  /// **'app lock & biometrics'**
  String get appLockAndBiometrics;

  /// No description provided for @appLockAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'app lock & security'**
  String get appLockAndSecurity;

  /// No description provided for @appLockAppearsAfterTheNotificationPanel.
  ///
  /// In en, this message translates to:
  /// **'app lock appears after the notification panel'**
  String get appLockAppearsAfterTheNotificationPanel;

  /// No description provided for @appLockNeedsADeviceScreenLock.
  ///
  /// In en, this message translates to:
  /// **'app lock needs a device screen lock'**
  String get appLockNeedsADeviceScreenLock;

  /// No description provided for @appLockTiming.
  ///
  /// In en, this message translates to:
  /// **'app lock timing'**
  String get appLockTiming;

  /// No description provided for @appLockWillNotTurnOn.
  ///
  /// In en, this message translates to:
  /// **'app lock will not turn on'**
  String get appLockWillNotTurnOn;

  /// No description provided for @appNotices.
  ///
  /// In en, this message translates to:
  /// **'app notices'**
  String get appNotices;

  /// No description provided for @appNoticesAreNotAppearing.
  ///
  /// In en, this message translates to:
  /// **'app notices are not appearing'**
  String get appNoticesAreNotAppearing;

  /// No description provided for @appPreferencesAndTheme.
  ///
  /// In en, this message translates to:
  /// **'app preferences and theme'**
  String get appPreferencesAndTheme;

  /// No description provided for @appSwitcherObfuscation.
  ///
  /// In en, this message translates to:
  /// **'app switcher obfuscation'**
  String get appSwitcherObfuscation;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'app theme'**
  String get appTheme;

  /// No description provided for @appUsage.
  ///
  /// In en, this message translates to:
  /// **'app usage'**
  String get appUsage;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'app version'**
  String get appVersion;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'appearance'**
  String get appearance;

  /// No description provided for @appiconscategory.
  ///
  /// In en, this message translates to:
  /// **'appiconscategory'**
  String get appiconscategory;

  /// No description provided for @applicationBuildIdentifier.
  ///
  /// In en, this message translates to:
  /// **'application build identifier'**
  String get applicationBuildIdentifier;

  /// No description provided for @applyACustomAccentColorAcrossAllFluidInterfaceElements.
  ///
  /// In en, this message translates to:
  /// **'apply a custom accent color across all fluid interface elements.'**
  String get applyACustomAccentColorAcrossAllFluidInterfaceElements;

  /// No description provided for @applyingAppIcon.
  ///
  /// In en, this message translates to:
  /// **'applying app icon'**
  String get applyingAppIcon;

  /// No description provided for @armyEliteEveryCleanDayIsABattleFoughtAndWon.
  ///
  /// In en, this message translates to:
  /// **'army elite. every clean day is a battle fought and won.'**
  String get armyEliteEveryCleanDayIsABattleFoughtAndWon;

  /// No description provided for @asASmallOfflineFirstTimestampLoggerForRealWorkQuickTapsFocusedNotesAndExportsDevelopersCanInspect.
  ///
  /// In en, this message translates to:
  /// **'as a small, offline-first timestamp logger for real work: quick taps, focused notes, and exports developers can inspect.'**
  String
  get asASmallOfflineFirstTimestampLoggerForRealWorkQuickTapsFocusedNotesAndExportsDevelopersCanInspect;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @attachContextWithoutSlowingTheAppDown.
  ///
  /// In en, this message translates to:
  /// **'attach context without slowing the app down.'**
  String get attachContextWithoutSlowingTheAppDown;

  /// No description provided for @attackOnTitan.
  ///
  /// In en, this message translates to:
  /// **'attack on titan'**
  String get attackOnTitan;

  /// No description provided for @aurora.
  ///
  /// In en, this message translates to:
  /// **'aurora'**
  String get aurora;

  /// No description provided for @auroraBorealis.
  ///
  /// In en, this message translates to:
  /// **'aurora borealis'**
  String get auroraBorealis;

  /// No description provided for @autoStartAndBackgroundActivity.
  ///
  /// In en, this message translates to:
  /// **'auto-start & background activity'**
  String get autoStartAndBackgroundActivity;

  /// No description provided for @automatedSecurityScans.
  ///
  /// In en, this message translates to:
  /// **'automated security scans'**
  String get automatedSecurityScans;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'automatic'**
  String get automatic;

  /// No description provided for @availableLanguages.
  ///
  /// In en, this message translates to:
  /// **'available languages'**
  String get availableLanguages;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get back;

  /// No description provided for @backUpData.
  ///
  /// In en, this message translates to:
  /// **'back up data'**
  String get backUpData;

  /// No description provided for @backupExportCategory.
  ///
  /// In en, this message translates to:
  /// **'backup & export'**
  String get backupExportCategory;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'backup & restore'**
  String get backupAndRestore;

  /// No description provided for @backupFilenamePreview.
  ///
  /// In en, this message translates to:
  /// **'backup filename preview'**
  String get backupFilenamePreview;

  /// No description provided for @backupHasNoNewMoments.
  ///
  /// In en, this message translates to:
  /// **'backup has no new moments'**
  String get backupHasNoNewMoments;

  /// No description provided for @backupImportFailed.
  ///
  /// In en, this message translates to:
  /// **'backup import failed'**
  String get backupImportFailed;

  /// No description provided for @backupImportFoundNoNewMoments.
  ///
  /// In en, this message translates to:
  /// **'backup import found no new moments'**
  String get backupImportFoundNoNewMoments;

  /// No description provided for @backupReminderExportAFreshBackupSoon.
  ///
  /// In en, this message translates to:
  /// **'backup reminder: export a fresh backup soon'**
  String get backupReminderExportAFreshBackupSoon;

  /// No description provided for @backupStatus.
  ///
  /// In en, this message translates to:
  /// **'backup status'**
  String get backupStatus;

  /// No description provided for @backupexportcategory.
  ///
  /// In en, this message translates to:
  /// **'backupexportcategory'**
  String get backupexportcategory;

  /// No description provided for @batteryAndPerformanceStatus.
  ///
  /// In en, this message translates to:
  /// **'battery and performance status'**
  String get batteryAndPerformanceStatus;

  /// No description provided for @batteryOptimizationActive.
  ///
  /// In en, this message translates to:
  /// **'battery optimization active'**
  String get batteryOptimizationActive;

  /// No description provided for @ben10.
  ///
  /// In en, this message translates to:
  /// **'ben 10'**
  String get ben10;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'beta'**
  String get beta;

  /// No description provided for @betaFeature.
  ///
  /// In en, this message translates to:
  /// **'beta feature'**
  String get betaFeature;

  /// No description provided for @betaTrack.
  ///
  /// In en, this message translates to:
  /// **'beta track'**
  String get betaTrack;

  /// No description provided for @biometricLock.
  ///
  /// In en, this message translates to:
  /// **'biometric lock'**
  String get biometricLock;

  /// No description provided for @biometricsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'biometrics not available'**
  String get biometricsNotAvailable;

  /// No description provided for @biometricsOrSystemCredentials.
  ///
  /// In en, this message translates to:
  /// **'biometrics or system credentials'**
  String get biometricsOrSystemCredentials;

  /// No description provided for @bleach.
  ///
  /// In en, this message translates to:
  /// **'bleach'**
  String get bleach;

  /// No description provided for @blurAndTranslucency.
  ///
  /// In en, this message translates to:
  /// **'blur & translucency'**
  String get blurAndTranslucency;

  /// No description provided for @bored.
  ///
  /// In en, this message translates to:
  /// **'bored'**
  String get bored;

  /// No description provided for @boredom.
  ///
  /// In en, this message translates to:
  /// **'boredom'**
  String get boredom;

  /// No description provided for @boxBreathing.
  ///
  /// In en, this message translates to:
  /// **'box breathing'**
  String get boxBreathing;

  /// No description provided for @buildCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'build cache cleared'**
  String get buildCacheCleared;

  /// No description provided for @buildCacheSize.
  ///
  /// In en, this message translates to:
  /// **'build cache size'**
  String get buildCacheSize;

  /// No description provided for @buildDate.
  ///
  /// In en, this message translates to:
  /// **'build date'**
  String get buildDate;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'build number'**
  String get buildNumber;

  /// No description provided for @builtBy.
  ///
  /// In en, this message translates to:
  /// **'built by'**
  String get builtBy;

  /// No description provided for @bushidoCodeMasterOfTheSelf.
  ///
  /// In en, this message translates to:
  /// **'bushido code. master of the self.'**
  String get bushidoCodeMasterOfTheSelf;

  /// No description provided for @buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'buy me a coffee'**
  String get buyMeACoffee;

  /// No description provided for @canIRestoreDeletedMoments.
  ///
  /// In en, this message translates to:
  /// **'can i restore deleted moments?'**
  String get canIRestoreDeletedMoments;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @captureCategory.
  ///
  /// In en, this message translates to:
  /// **'capture'**
  String get captureCategory;

  /// No description provided for @captureCooldown.
  ///
  /// In en, this message translates to:
  /// **'capture cooldown'**
  String get captureCooldown;

  /// No description provided for @captureDelayAndCooldown.
  ///
  /// In en, this message translates to:
  /// **'capture delay & cooldown'**
  String get captureDelayAndCooldown;

  /// No description provided for @capturecategory.
  ///
  /// In en, this message translates to:
  /// **'capturecategory'**
  String get capturecategory;

  /// No description provided for @celticHighlandClanEarnYourPlaceCarryTheBanner.
  ///
  /// In en, this message translates to:
  /// **'celtic highland clan. earn your place, carry the banner.'**
  String get celticHighlandClanEarnYourPlaceCarryTheBanner;

  /// No description provided for @changeYourSecureInAppPasscode.
  ///
  /// In en, this message translates to:
  /// **'change your secure in-app passcode.'**
  String get changeYourSecureInAppPasscode;

  /// No description provided for @changelogTitle.
  ///
  /// In en, this message translates to:
  /// **'changelog'**
  String get changelogTitle;

  /// No description provided for @changelogtitle.
  ///
  /// In en, this message translates to:
  /// **'changelogtitle'**
  String get changelogtitle;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'check again'**
  String get checkAgain;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'checking for updates...'**
  String get checkingForUpdates;

  /// No description provided for @checksGithubReleasesOnlyWhenNeededZeroTelemetry.
  ///
  /// In en, this message translates to:
  /// **'checks github releases only when needed. zero telemetry.'**
  String get checksGithubReleasesOnlyWhenNeededZeroTelemetry;

  /// No description provided for @chessMastery.
  ///
  /// In en, this message translates to:
  /// **'chess mastery'**
  String get chessMastery;

  /// No description provided for @chooseASinglePrimaryIntentionForTheUpcomingHourBeforeContinuingYourTasks.
  ///
  /// In en, this message translates to:
  /// **'choose a single primary intention for the upcoming hour before continuing your tasks.'**
  String
  get chooseASinglePrimaryIntentionForTheUpcomingHourBeforeContinuingYourTasks;

  /// No description provided for @chooseHowNotekarStartsWhenYouOpenIt.
  ///
  /// In en, this message translates to:
  /// **'choose how notekar starts when you open it'**
  String get chooseHowNotekarStartsWhenYouOpenIt;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'choose language'**
  String get chooseLanguage;

  /// No description provided for @chooseMilestoneTheme.
  ///
  /// In en, this message translates to:
  /// **'choose milestone theme'**
  String get chooseMilestoneTheme;

  /// No description provided for @chooseTheNarrativeStyleForYourMilestoneNamesEachThemeIsPsychologicallyCuratedToMatchADifferentSelfImageAndMotivationStyle.
  ///
  /// In en, this message translates to:
  /// **'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.'**
  String
  get chooseTheNarrativeStyleForYourMilestoneNamesEachThemeIsPsychologicallyCuratedToMatchADifferentSelfImageAndMotivationStyle;

  /// No description provided for @chooseYourPreferredInterfaceLanguage.
  ///
  /// In en, this message translates to:
  /// **'choose your preferred interface language'**
  String get chooseYourPreferredInterfaceLanguage;

  /// No description provided for @civilianToTheOneAboveAll.
  ///
  /// In en, this message translates to:
  /// **'civilian to the one above all.'**
  String get civilianToTheOneAboveAll;

  /// No description provided for @clan.
  ///
  /// In en, this message translates to:
  /// **'clan'**
  String get clan;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get clear;

  /// No description provided for @clearAllMoments.
  ///
  /// In en, this message translates to:
  /// **'clear all moments'**
  String get clearAllMoments;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'clear cache'**
  String get clearCache;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'clear search'**
  String get clearSearch;

  /// No description provided for @clearTrash.
  ///
  /// In en, this message translates to:
  /// **'clear trash'**
  String get clearTrash;

  /// No description provided for @clinicalNeuroscienceTermsColdPreciseHonest.
  ///
  /// In en, this message translates to:
  /// **'clinical neuroscience terms. cold, precise, honest.'**
  String get clinicalNeuroscienceTermsColdPreciseHonest;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get close;

  /// No description provided for @codeGeass.
  ///
  /// In en, this message translates to:
  /// **'code geass'**
  String get codeGeass;

  /// No description provided for @colorAccent.
  ///
  /// In en, this message translates to:
  /// **'color accent'**
  String get colorAccent;

  /// No description provided for @commits.
  ///
  /// In en, this message translates to:
  /// **'commits'**
  String get commits;

  /// No description provided for @compactHistory.
  ///
  /// In en, this message translates to:
  /// **'compact history'**
  String get compactHistory;

  /// No description provided for @compactHistoryCannotBeEnabledWhileSingleMomentNumberingIsActiveDisableSingleNumbersToUseCompactRows.
  ///
  /// In en, this message translates to:
  /// **'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.'**
  String
  get compactHistoryCannotBeEnabledWhileSingleMomentNumberingIsActiveDisableSingleNumbersToUseCompactRows;

  /// No description provided for @compactHistoryMode.
  ///
  /// In en, this message translates to:
  /// **'compact history mode'**
  String get compactHistoryMode;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'configuration'**
  String get configuration;

  /// No description provided for @configureADedicated4DigitPasscode.
  ///
  /// In en, this message translates to:
  /// **'configure a dedicated 4-digit passcode.'**
  String get configureADedicated4DigitPasscode;

  /// No description provided for @configureSettings.
  ///
  /// In en, this message translates to:
  /// **'configure settings'**
  String get configureSettings;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get confirm;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmPasscode.
  ///
  /// In en, this message translates to:
  /// **'confirm passcode'**
  String get confirmPasscode;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'continue'**
  String get actionContinue;

  /// No description provided for @continueMindfully.
  ///
  /// In en, this message translates to:
  /// **'continue mindfully'**
  String get continueMindfully;

  /// No description provided for @continuous.
  ///
  /// In en, this message translates to:
  /// **'continuous'**
  String get continuous;

  /// No description provided for @contributeOnGithub.
  ///
  /// In en, this message translates to:
  /// **'contribute on github'**
  String get contributeOnGithub;

  /// No description provided for @cooldownPeriod.
  ///
  /// In en, this message translates to:
  /// **'cooldown period'**
  String get cooldownPeriod;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get copy;

  /// No description provided for @copyMoment.
  ///
  /// In en, this message translates to:
  /// **'copy moment'**
  String get copyMoment;

  /// No description provided for @correlationIntelligence.
  ///
  /// In en, this message translates to:
  /// **'correlation intelligence'**
  String get correlationIntelligence;

  /// No description provided for @cosmicExplorationEveryCleanDayIsLightYearsGained.
  ///
  /// In en, this message translates to:
  /// **'cosmic exploration. every clean day is light-years gained.'**
  String get cosmicExplorationEveryCleanDayIsLightYearsGained;

  /// No description provided for @couldNotOpenBackupFile.
  ///
  /// In en, this message translates to:
  /// **'could not open backup file'**
  String get couldNotOpenBackupFile;

  /// No description provided for @countOnSave.
  ///
  /// In en, this message translates to:
  /// **'count on save'**
  String get countOnSave;

  /// No description provided for @createQuickLocalBackup.
  ///
  /// In en, this message translates to:
  /// **'create quick local backup'**
  String get createQuickLocalBackup;

  /// No description provided for @crimson.
  ///
  /// In en, this message translates to:
  /// **'crimson'**
  String get crimson;

  /// No description provided for @currentMessage.
  ///
  /// In en, this message translates to:
  /// **'current message'**
  String get currentMessage;

  /// No description provided for @cursedSpiritToSatoruGojo.
  ///
  /// In en, this message translates to:
  /// **'cursed spirit to satoru gojo.'**
  String get cursedSpiritToSatoruGojo;

  /// No description provided for @customStartDate.
  ///
  /// In en, this message translates to:
  /// **'custom start date'**
  String get customStartDate;

  /// No description provided for @dailyLoggingReminder.
  ///
  /// In en, this message translates to:
  /// **'daily logging reminder'**
  String get dailyLoggingReminder;

  /// No description provided for @dailyNeuroscienceInsight.
  ///
  /// In en, this message translates to:
  /// **'daily neuroscience insight'**
  String get dailyNeuroscienceInsight;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'daily reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'daily reminder message'**
  String get dailyReminderMessage;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'daily reminders'**
  String get dailyReminders;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get dark;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'dark mode'**
  String get darkMode;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'data'**
  String get data;

  /// No description provided for @dataAndBackup.
  ///
  /// In en, this message translates to:
  /// **'data & backup'**
  String get dataAndBackup;

  /// No description provided for @dataConsumed.
  ///
  /// In en, this message translates to:
  /// **'data consumed'**
  String get dataConsumed;

  /// No description provided for @dataHealth.
  ///
  /// In en, this message translates to:
  /// **'data health'**
  String get dataHealth;

  /// No description provided for @databaseExport.
  ///
  /// In en, this message translates to:
  /// **'database export'**
  String get databaseExport;

  /// No description provided for @databaseIntegrity.
  ///
  /// In en, this message translates to:
  /// **'database integrity'**
  String get databaseIntegrity;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'day of month'**
  String get dayOfMonth;

  /// No description provided for @daysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'days of week'**
  String get daysOfWeek;

  /// No description provided for @deathNote.
  ///
  /// In en, this message translates to:
  /// **'death note'**
  String get deathNote;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get delete;

  /// No description provided for @deleteAllMoments.
  ///
  /// In en, this message translates to:
  /// **'delete all moments?'**
  String get deleteAllMoments;

  /// No description provided for @deleteBackup.
  ///
  /// In en, this message translates to:
  /// **'delete backup?'**
  String get deleteBackup;

  /// No description provided for @deleteCache.
  ///
  /// In en, this message translates to:
  /// **'delete cache'**
  String get deleteCache;

  /// No description provided for @deleteMoment.
  ///
  /// In en, this message translates to:
  /// **'delete moment'**
  String get deleteMoment;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'delete permanently'**
  String get deletePermanently;

  /// No description provided for @deletePermanently2.
  ///
  /// In en, this message translates to:
  /// **'delete permanently?'**
  String get deletePermanently2;

  /// No description provided for @deletedInMoment.
  ///
  /// In en, this message translates to:
  /// **'deleted in moment'**
  String get deletedInMoment;

  /// No description provided for @deletedOutMoment.
  ///
  /// In en, this message translates to:
  /// **'deleted out moment'**
  String get deletedOutMoment;

  /// No description provided for @deletedSingleMoment.
  ///
  /// In en, this message translates to:
  /// **'deleted single moment'**
  String get deletedSingleMoment;

  /// No description provided for @deletingCache.
  ///
  /// In en, this message translates to:
  /// **'deleting cache...'**
  String get deletingCache;

  /// No description provided for @demonSlayer.
  ///
  /// In en, this message translates to:
  /// **'demon slayer'**
  String get demonSlayer;

  /// No description provided for @dev.
  ///
  /// In en, this message translates to:
  /// **'dev'**
  String get dev;

  /// No description provided for @developerDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'developer diagnostics'**
  String get developerDiagnostics;

  /// No description provided for @developerKey.
  ///
  /// In en, this message translates to:
  /// **'developer key'**
  String get developerKey;

  /// No description provided for @developerOptions.
  ///
  /// In en, this message translates to:
  /// **'developer options'**
  String get developerOptions;

  /// No description provided for @deviceHealth.
  ///
  /// In en, this message translates to:
  /// **'device health'**
  String get deviceHealth;

  /// No description provided for @diagnosticsCategory.
  ///
  /// In en, this message translates to:
  /// **'diagnostics'**
  String get diagnosticsCategory;

  /// No description provided for @diagnosticsAndInternalEngineSettingsForDevelopers.
  ///
  /// In en, this message translates to:
  /// **'diagnostics and internal engine settings for developers.'**
  String get diagnosticsAndInternalEngineSettingsForDevelopers;

  /// No description provided for @diagnosticscategory.
  ///
  /// In en, this message translates to:
  /// **'diagnosticscategory'**
  String get diagnosticscategory;

  /// No description provided for @disableBatteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'disable battery optimization'**
  String get disableBatteryOptimization;

  /// No description provided for @disableCompactHistory.
  ///
  /// In en, this message translates to:
  /// **'disable compact history?'**
  String get disableCompactHistory;

  /// No description provided for @disableCountOnSave.
  ///
  /// In en, this message translates to:
  /// **'disable count on save?'**
  String get disableCountOnSave;

  /// No description provided for @disableReduceMotionFirst.
  ///
  /// In en, this message translates to:
  /// **'disable reduce motion first'**
  String get disableReduceMotionFirst;

  /// No description provided for @disableUseNumbersInSingle.
  ///
  /// In en, this message translates to:
  /// **'disable use numbers in single?'**
  String get disableUseNumbersInSingle;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get disabled;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'dismiss'**
  String get dismiss;

  /// No description provided for @displayCategory.
  ///
  /// In en, this message translates to:
  /// **'display'**
  String get displayCategory;

  /// No description provided for @displayAndTypography.
  ///
  /// In en, this message translates to:
  /// **'display & typography'**
  String get displayAndTypography;

  /// No description provided for @displaycategory.
  ///
  /// In en, this message translates to:
  /// **'displaycategory'**
  String get displaycategory;

  /// No description provided for @docs.
  ///
  /// In en, this message translates to:
  /// **'docs'**
  String get docs;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get done;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'download'**
  String get download;

  /// No description provided for @downloadAndInstall.
  ///
  /// In en, this message translates to:
  /// **'download & install'**
  String get downloadAndInstall;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'download failed'**
  String get downloadFailed;

  /// No description provided for @downloadFromGithub.
  ///
  /// In en, this message translates to:
  /// **'download from github'**
  String get downloadFromGithub;

  /// No description provided for @downloadSize.
  ///
  /// In en, this message translates to:
  /// **'download size:'**
  String get downloadSize;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'downloading update...'**
  String get downloadingUpdate;

  /// No description provided for @dragonBall.
  ///
  /// In en, this message translates to:
  /// **'dragon ball'**
  String get dragonBall;

  /// No description provided for @eRankSungJinwooToShadowMonarch.
  ///
  /// In en, this message translates to:
  /// **'e-rank sung jinwoo to shadow monarch.'**
  String get eRankSungJinwooToShadowMonarch;

  /// No description provided for @eastBlueCobyToThePirateKingGolDRoger.
  ///
  /// In en, this message translates to:
  /// **'east blue coby to the pirate king gol d. roger.'**
  String get eastBlueCobyToThePirateKingGolDRoger;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'edit'**
  String get edit;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'edit message'**
  String get editMessage;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'edit note'**
  String get editNote;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'email support'**
  String get emailSupport;

  /// No description provided for @emerald.
  ///
  /// In en, this message translates to:
  /// **'emerald'**
  String get emerald;

  /// No description provided for @emeraldForest.
  ///
  /// In en, this message translates to:
  /// **'emerald forest'**
  String get emeraldForest;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get empty;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'empty trash'**
  String get emptyTrash;

  /// No description provided for @emptyTrash2.
  ///
  /// In en, this message translates to:
  /// **'empty trash?'**
  String get emptyTrash2;

  /// No description provided for @enableCountOnSave.
  ///
  /// In en, this message translates to:
  /// **'enable count on save'**
  String get enableCountOnSave;

  /// No description provided for @enableShowSecondsFirst.
  ///
  /// In en, this message translates to:
  /// **'enable show seconds first'**
  String get enableShowSecondsFirst;

  /// No description provided for @enableSobrietyMode.
  ///
  /// In en, this message translates to:
  /// **'enable sobriety mode'**
  String get enableSobrietyMode;

  /// No description provided for @enableTimeReflection.
  ///
  /// In en, this message translates to:
  /// **'enable time reflection'**
  String get enableTimeReflection;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'enabled'**
  String get enabled;

  /// No description provided for @encryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'encrypted backup'**
  String get encryptedBackup;

  /// No description provided for @endpointUrl.
  ///
  /// In en, this message translates to:
  /// **'endpoint url'**
  String get endpointUrl;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'english'**
  String get english;

  /// No description provided for @enterPasscode.
  ///
  /// In en, this message translates to:
  /// **'enter passcode'**
  String get enterPasscode;

  /// No description provided for @enterReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'enter reminder message...'**
  String get enterReminderMessage;

  /// No description provided for @essentialFeatures.
  ///
  /// In en, this message translates to:
  /// **'essential features'**
  String get essentialFeatures;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'evening'**
  String get evening;

  /// No description provided for @every1Hour.
  ///
  /// In en, this message translates to:
  /// **'every 1 hour'**
  String get every1Hour;

  /// No description provided for @every1HourRecommended.
  ///
  /// In en, this message translates to:
  /// **'every 1 hour (recommended)'**
  String get every1HourRecommended;

  /// No description provided for @every14Days.
  ///
  /// In en, this message translates to:
  /// **'every 14 days'**
  String get every14Days;

  /// No description provided for @every15Minutes.
  ///
  /// In en, this message translates to:
  /// **'every 15 minutes'**
  String get every15Minutes;

  /// No description provided for @every2Hours.
  ///
  /// In en, this message translates to:
  /// **'every 2 hours'**
  String get every2Hours;

  /// No description provided for @every30Days.
  ///
  /// In en, this message translates to:
  /// **'every 30 days'**
  String get every30Days;

  /// No description provided for @every30Minutes.
  ///
  /// In en, this message translates to:
  /// **'every 30 minutes'**
  String get every30Minutes;

  /// No description provided for @every45Minutes.
  ///
  /// In en, this message translates to:
  /// **'every 45 minutes'**
  String get every45Minutes;

  /// No description provided for @every7Days.
  ///
  /// In en, this message translates to:
  /// **'every 7 days'**
  String get every7Days;

  /// No description provided for @everyTapRecordsAStandaloneMoment.
  ///
  /// In en, this message translates to:
  /// **'every tap records a standalone moment.'**
  String get everyTapRecordsAStandaloneMoment;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'export backup'**
  String get exportBackup;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'export csv'**
  String get exportCsv;

  /// No description provided for @exportFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'export failed. try again.'**
  String get exportFailedTryAgain;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'export json'**
  String get exportJson;

  /// No description provided for @exportLast7Days.
  ///
  /// In en, this message translates to:
  /// **'export last 7 days'**
  String get exportLast7Days;

  /// No description provided for @exportMilestoneCard.
  ///
  /// In en, this message translates to:
  /// **'export milestone card'**
  String get exportMilestoneCard;

  /// No description provided for @exportSavedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'export saved to downloads'**
  String get exportSavedToDownloads;

  /// No description provided for @exportImportAndManageYourDataBackups.
  ///
  /// In en, this message translates to:
  /// **'export, import, and manage your data backups.'**
  String get exportImportAndManageYourDataBackups;

  /// No description provided for @extendedDuration.
  ///
  /// In en, this message translates to:
  /// **'extended duration'**
  String get extendedDuration;

  /// No description provided for @externalNavigation.
  ///
  /// In en, this message translates to:
  /// **'external navigation'**
  String get externalNavigation;

  /// No description provided for @factoryReset.
  ///
  /// In en, this message translates to:
  /// **'factory reset'**
  String get factoryReset;

  /// No description provided for @failedToCreateLocalBackup.
  ///
  /// In en, this message translates to:
  /// **'failed to create local backup'**
  String get failedToCreateLocalBackup;

  /// No description provided for @failedToReadLocalBackupFile.
  ///
  /// In en, this message translates to:
  /// **'failed to read local backup file'**
  String get failedToReadLocalBackupFile;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'faq'**
  String get faq;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'fatigue'**
  String get fatigue;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'feedback'**
  String get feedback;

  /// No description provided for @feedbackAndBugReport.
  ///
  /// In en, this message translates to:
  /// **'feedback & bug report'**
  String get feedbackAndBugReport;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'french'**
  String get french;

  /// No description provided for @frequencyInterval.
  ///
  /// In en, this message translates to:
  /// **'frequency interval'**
  String get frequencyInterval;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'fri'**
  String get fri;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'friday'**
  String get friday;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'friends'**
  String get friends;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'full'**
  String get full;

  /// No description provided for @fullOnlinePolicy.
  ///
  /// In en, this message translates to:
  /// **'full online policy'**
  String get fullOnlinePolicy;

  /// No description provided for @fullOnlineTerms.
  ///
  /// In en, this message translates to:
  /// **'full online terms'**
  String get fullOnlineTerms;

  /// No description provided for @fullTitleAndPurpose.
  ///
  /// In en, this message translates to:
  /// **'full title & purpose'**
  String get fullTitleAndPurpose;

  /// No description provided for @fullmetalAlchemist.
  ///
  /// In en, this message translates to:
  /// **'fullmetal alchemist'**
  String get fullmetalAlchemist;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'german'**
  String get german;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'get started'**
  String get getStarted;

  /// No description provided for @gintama.
  ///
  /// In en, this message translates to:
  /// **'gintama'**
  String get gintama;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'github'**
  String get github;

  /// No description provided for @giveFeedback.
  ///
  /// In en, this message translates to:
  /// **'give feedback'**
  String get giveFeedback;

  /// No description provided for @googleDriveBackup.
  ///
  /// In en, this message translates to:
  /// **'google drive backup'**
  String get googleDriveBackup;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'got it'**
  String get gotIt;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'grant permission'**
  String get grantPermission;

  /// No description provided for @greekAndRomanGloryRiseFromMortalToOlympian.
  ///
  /// In en, this message translates to:
  /// **'greek and roman glory. rise from mortal to olympian.'**
  String get greekAndRomanGloryRiseFromMortalToOlympian;

  /// No description provided for @greyMatterToAlienX.
  ///
  /// In en, this message translates to:
  /// **'grey matter to alien x.'**
  String get greyMatterToAlienX;

  /// No description provided for @guides.
  ///
  /// In en, this message translates to:
  /// **'guides'**
  String get guides;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'happy'**
  String get happy;

  /// No description provided for @hardwareSecurity.
  ///
  /// In en, this message translates to:
  /// **'hardware security'**
  String get hardwareSecurity;

  /// No description provided for @hardwareBackedEncryption.
  ///
  /// In en, this message translates to:
  /// **'hardware-backed encryption'**
  String get hardwareBackedEncryption;

  /// No description provided for @harryPotter.
  ///
  /// In en, this message translates to:
  /// **'harry potter'**
  String get harryPotter;

  /// No description provided for @haveSuggestionsOrFoundABug2.
  ///
  /// In en, this message translates to:
  /// **'have suggestions or found a bug?'**
  String get haveSuggestionsOrFoundABug2;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'help'**
  String get help;

  /// No description provided for @helpAndUserGuides.
  ///
  /// In en, this message translates to:
  /// **'help & user guides'**
  String get helpAndUserGuides;

  /// No description provided for @hideAppContentInRecents.
  ///
  /// In en, this message translates to:
  /// **'hide app content in recents'**
  String get hideAppContentInRecents;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'hindi'**
  String get hindi;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'history'**
  String get historyTitle;

  /// No description provided for @holdForNotes.
  ///
  /// In en, this message translates to:
  /// **'hold for notes'**
  String get holdForNotes;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hourlyMindfulness.
  ///
  /// In en, this message translates to:
  /// **'hourly mindfulness'**
  String get hourlyMindfulness;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @howToUseItEffectively.
  ///
  /// In en, this message translates to:
  /// **'how to use it effectively'**
  String get howToUseItEffectively;

  /// No description provided for @htmlEditorToTuringAwardWinner.
  ///
  /// In en, this message translates to:
  /// **'html editor to turing award winner.'**
  String get htmlEditorToTuringAwardWinner;

  /// No description provided for @hunterXHunter.
  ///
  /// In en, this message translates to:
  /// **'hunter x hunter'**
  String get hunterXHunter;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'imperial'**
  String get imperial;

  /// No description provided for @imperialGold.
  ///
  /// In en, this message translates to:
  /// **'imperial gold'**
  String get imperialGold;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'import backup'**
  String get importBackup;

  /// No description provided for @importCancelled.
  ///
  /// In en, this message translates to:
  /// **'import cancelled'**
  String get importCancelled;

  /// No description provided for @importantNotice.
  ///
  /// In en, this message translates to:
  /// **'important notice'**
  String get importantNotice;

  /// No description provided for @inAppOtaUpdates.
  ///
  /// In en, this message translates to:
  /// **'in-app ota updates'**
  String get inAppOtaUpdates;

  /// No description provided for @inAppPin.
  ///
  /// In en, this message translates to:
  /// **'in-app pin'**
  String get inAppPin;

  /// No description provided for @inAppPinSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'in-app pin set successfully.'**
  String get inAppPinSetSuccessfully;

  /// No description provided for @inAppUpdateSetup.
  ///
  /// In en, this message translates to:
  /// **'in-app update setup'**
  String get inAppUpdateSetup;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'inactive'**
  String get inactive;

  /// No description provided for @inactivityAlerts.
  ///
  /// In en, this message translates to:
  /// **'inactivity alerts'**
  String get inactivityAlerts;

  /// No description provided for @inactivityReminder.
  ///
  /// In en, this message translates to:
  /// **'inactivity reminder'**
  String get inactivityReminder;

  /// No description provided for @incorrectPasscode.
  ///
  /// In en, this message translates to:
  /// **'incorrect passcode'**
  String get incorrectPasscode;

  /// No description provided for @installNow.
  ///
  /// In en, this message translates to:
  /// **'install now'**
  String get installNow;

  /// No description provided for @installationFailedToStart.
  ///
  /// In en, this message translates to:
  /// **'installation failed to start'**
  String get installationFailedToStart;

  /// No description provided for @integrityCheckFailedChecksumMismatch.
  ///
  /// In en, this message translates to:
  /// **'integrity check failed: checksum mismatch'**
  String get integrityCheckFailedChecksumMismatch;

  /// No description provided for @intelligentRiskRadar.
  ///
  /// In en, this message translates to:
  /// **'intelligent risk radar'**
  String get intelligentRiskRadar;

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'invalid backup file'**
  String get invalidBackupFile;

  /// No description provided for @isNotekarPrivate.
  ///
  /// In en, this message translates to:
  /// **'is notekar private?'**
  String get isNotekarPrivate;

  /// No description provided for @isNotekarSafeToUse.
  ///
  /// In en, this message translates to:
  /// **'is notekar safe to use?'**
  String get isNotekarSafeToUse;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'japanese'**
  String get japanese;

  /// No description provided for @jujutsuKaisen.
  ///
  /// In en, this message translates to:
  /// **'jujutsu kaisen'**
  String get jujutsuKaisen;

  /// No description provided for @july2026.
  ///
  /// In en, this message translates to:
  /// **'july 2026'**
  String get july2026;

  /// No description provided for @kingdom.
  ///
  /// In en, this message translates to:
  /// **'kingdom'**
  String get kingdom;

  /// No description provided for @konohamaruToTheSageOfSixPaths.
  ///
  /// In en, this message translates to:
  /// **'konohamaru to the sage of six paths.'**
  String get konohamaruToTheSageOfSixPaths;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @lastScan.
  ///
  /// In en, this message translates to:
  /// **'last scan'**
  String get lastScan;

  /// No description provided for @lateNight.
  ///
  /// In en, this message translates to:
  /// **'late night'**
  String get lateNight;

  /// No description provided for @lateNight2.
  ///
  /// In en, this message translates to:
  /// **'late_night'**
  String get lateNight2;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'learn more'**
  String get learnMore;

  /// No description provided for @legalAndOpenSourceNotices.
  ///
  /// In en, this message translates to:
  /// **'legal & open source notices'**
  String get legalAndOpenSourceNotices;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get less;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'licenses'**
  String get licenses;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get light;

  /// No description provided for @limitedConnectivity.
  ///
  /// In en, this message translates to:
  /// **'limited connectivity'**
  String get limitedConnectivity;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'link copied'**
  String get linkCopied;

  /// No description provided for @liveActivityTrackingDashboardFeaturingRealTimeMetricAnalysisHabitTrackingGridsActivityTrendsAndCorrelationIntelligenceCalculatedFromYourMoments.
  ///
  /// In en, this message translates to:
  /// **'live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.'**
  String
  get liveActivityTrackingDashboardFeaturingRealTimeMetricAnalysisHabitTrackingGridsActivityTrendsAndCorrelationIntelligenceCalculatedFromYourMoments;

  /// No description provided for @liveIconMotionLooksSlowOrDelayed.
  ///
  /// In en, this message translates to:
  /// **'live icon motion looks slow or delayed'**
  String get liveIconMotionLooksSlowOrDelayed;

  /// No description provided for @liveIconMotionWillNotTurnOn.
  ///
  /// In en, this message translates to:
  /// **'live icon motion will not turn on'**
  String get liveIconMotionWillNotTurnOn;

  /// No description provided for @loadOlderMoments.
  ///
  /// In en, this message translates to:
  /// **'load older moments'**
  String get loadOlderMoments;

  /// No description provided for @loadingDatabase.
  ///
  /// In en, this message translates to:
  /// **'loading database...'**
  String get loadingDatabase;

  /// No description provided for @localBackups.
  ///
  /// In en, this message translates to:
  /// **'local backups'**
  String get localBackups;

  /// No description provided for @localStorage.
  ///
  /// In en, this message translates to:
  /// **'local storage'**
  String get localStorage;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'location'**
  String get location;

  /// No description provided for @logAMomentInstantlyFromTheMainScreen.
  ///
  /// In en, this message translates to:
  /// **'log a moment instantly from the main screen.'**
  String get logAMomentInstantlyFromTheMainScreen;

  /// No description provided for @logAQuickMoment.
  ///
  /// In en, this message translates to:
  /// **'log a quick moment'**
  String get logAQuickMoment;

  /// No description provided for @logCurrentMoment.
  ///
  /// In en, this message translates to:
  /// **'log current moment'**
  String get logCurrentMoment;

  /// No description provided for @logging.
  ///
  /// In en, this message translates to:
  /// **'logging'**
  String get logging;

  /// No description provided for @loggingReminder.
  ///
  /// In en, this message translates to:
  /// **'logging reminder'**
  String get loggingReminder;

  /// No description provided for @loggingReminders.
  ///
  /// In en, this message translates to:
  /// **'logging reminders'**
  String get loggingReminders;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'logs'**
  String get logs;

  /// No description provided for @loneliness.
  ///
  /// In en, this message translates to:
  /// **'loneliness'**
  String get loneliness;

  /// No description provided for @lonely.
  ///
  /// In en, this message translates to:
  /// **'lonely'**
  String get lonely;

  /// No description provided for @lookBackAtTheLast60MinutesWithKindnessDidYouSpendItIntentionallyOrDidTimeSlipAwayAwarenessIsTheFirstStepToFreedom.
  ///
  /// In en, this message translates to:
  /// **'look back at the last 60 minutes with kindness. did you spend it intentionally, or did time slip away? awareness is the first step to freedom.'**
  String
  get lookBackAtTheLast60MinutesWithKindnessDidYouSpendItIntentionallyOrDidTimeSlipAwayAwarenessIsTheFirstStepToFreedom;

  /// No description provided for @magikarpToTheCreatorGodArceus.
  ///
  /// In en, this message translates to:
  /// **'magikarp to the creator god arceus.'**
  String get magikarpToTheCreatorGodArceus;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'manage'**
  String get manage;

  /// No description provided for @manageMomentNotes.
  ///
  /// In en, this message translates to:
  /// **'manage moment notes'**
  String get manageMomentNotes;

  /// No description provided for @manageSecurityPasscodeLockAndAppPrivacy.
  ///
  /// In en, this message translates to:
  /// **'manage security, passcode lock, and app privacy.'**
  String get manageSecurityPasscodeLockAndAppPrivacy;

  /// No description provided for @marvelUniverse.
  ///
  /// In en, this message translates to:
  /// **'marvel universe'**
  String get marvelUniverse;

  /// No description provided for @matsudaToTheShinigamiKing.
  ///
  /// In en, this message translates to:
  /// **'matsuda to the shinigami king.'**
  String get matsudaToTheShinigamiKing;

  /// No description provided for @medievalRoyaltyRiseFromSerfToSovereign.
  ///
  /// In en, this message translates to:
  /// **'medieval royalty. rise from serf to sovereign.'**
  String get medievalRoyaltyRiseFromSerfToSovereign;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get message;

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'midnight'**
  String get midnight;

  /// No description provided for @midnightObsidian.
  ///
  /// In en, this message translates to:
  /// **'midnight obsidian'**
  String get midnightObsidian;

  /// No description provided for @milestoneAchieved.
  ///
  /// In en, this message translates to:
  /// **'milestone achieved'**
  String get milestoneAchieved;

  /// No description provided for @milestoneBadges.
  ///
  /// In en, this message translates to:
  /// **'milestone badges'**
  String get milestoneBadges;

  /// No description provided for @milestonePeak.
  ///
  /// In en, this message translates to:
  /// **'milestone peak'**
  String get milestonePeak;

  /// No description provided for @milestoneTheme.
  ///
  /// In en, this message translates to:
  /// **'milestone theme'**
  String get milestoneTheme;

  /// No description provided for @milestoneUnlocked.
  ///
  /// In en, this message translates to:
  /// **'milestone unlocked!'**
  String get milestoneUnlocked;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'milestones'**
  String get milestones;

  /// No description provided for @minetaToAllMightPrime.
  ///
  /// In en, this message translates to:
  /// **'mineta to all might prime.'**
  String get minetaToAllMightPrime;

  /// No description provided for @minimalMomentOptions.
  ///
  /// In en, this message translates to:
  /// **'minimal moment options'**
  String get minimalMomentOptions;

  /// No description provided for @mit.
  ///
  /// In en, this message translates to:
  /// **'mit'**
  String get mit;

  /// No description provided for @moistureFarmerToTheChosenOne.
  ///
  /// In en, this message translates to:
  /// **'moisture farmer to the chosen one.'**
  String get moistureFarmerToTheChosenOne;

  /// No description provided for @momentOptions.
  ///
  /// In en, this message translates to:
  /// **'moment options'**
  String get momentOptions;

  /// No description provided for @momentSaved.
  ///
  /// In en, this message translates to:
  /// **'moment saved'**
  String get momentSaved;

  /// No description provided for @momentsCategory.
  ///
  /// In en, this message translates to:
  /// **'moments'**
  String get momentsCategory;

  /// No description provided for @momentscategory.
  ///
  /// In en, this message translates to:
  /// **'momentscategory'**
  String get momentscategory;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'mon'**
  String get mon;

  /// No description provided for @monasticJourneySilenceStillnessAndVows.
  ///
  /// In en, this message translates to:
  /// **'monastic journey. silence, stillness, and vows.'**
  String get monasticJourneySilenceStillnessAndVows;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'monday'**
  String get monday;

  /// No description provided for @monk.
  ///
  /// In en, this message translates to:
  /// **'monk'**
  String get monk;

  /// No description provided for @monthlyReminder.
  ///
  /// In en, this message translates to:
  /// **'monthly reminder'**
  String get monthlyReminder;

  /// No description provided for @monthlyReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'monthly reminder message'**
  String get monthlyReminderMessage;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'morning'**
  String get morning;

  /// No description provided for @motionSensorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'motion sensor unavailable'**
  String get motionSensorUnavailable;

  /// No description provided for @muggleToMerlin.
  ///
  /// In en, this message translates to:
  /// **'muggle to merlin.'**
  String get muggleToMerlin;

  /// No description provided for @murataToYoriichiTsugikuni.
  ///
  /// In en, this message translates to:
  /// **'murata to yoriichi tsugikuni.'**
  String get murataToYoriichiTsugikuni;

  /// No description provided for @myHeroAcademia.
  ///
  /// In en, this message translates to:
  /// **'my hero academia'**
  String get myHeroAcademia;

  /// No description provided for @naruto.
  ///
  /// In en, this message translates to:
  /// **'naruto'**
  String get naruto;

  /// No description provided for @navy.
  ///
  /// In en, this message translates to:
  /// **'navy'**
  String get navy;

  /// No description provided for @networkAndDataTransparency.
  ///
  /// In en, this message translates to:
  /// **'network & data transparency'**
  String get networkAndDataTransparency;

  /// No description provided for @networkMonitor.
  ///
  /// In en, this message translates to:
  /// **'network monitor'**
  String get networkMonitor;

  /// No description provided for @networkWarning.
  ///
  /// In en, this message translates to:
  /// **'network warning'**
  String get networkWarning;

  /// No description provided for @neuroscienceAndGrowth.
  ///
  /// In en, this message translates to:
  /// **'neuroscience & growth'**
  String get neuroscienceAndGrowth;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get next;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'night'**
  String get night;

  /// No description provided for @noInternetConnectionShowingCachedPreview.
  ///
  /// In en, this message translates to:
  /// **'no internet connection. showing cached preview.'**
  String get noInternetConnectionShowingCachedPreview;

  /// No description provided for @noLocalBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'no local backups found'**
  String get noLocalBackupsFound;

  /// No description provided for @noMatchingNotes.
  ///
  /// In en, this message translates to:
  /// **'no matching notes'**
  String get noMatchingNotes;

  /// No description provided for @noMessageSetWillShowDefaultReminder.
  ///
  /// In en, this message translates to:
  /// **'no message set (will show default reminder)'**
  String get noMessageSetWillShowDefaultReminder;

  /// No description provided for @noMoments.
  ///
  /// In en, this message translates to:
  /// **'no moments'**
  String get noMoments;

  /// No description provided for @noMomentsLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'no moments logged yet'**
  String get noMomentsLoggedYet;

  /// No description provided for @noNote.
  ///
  /// In en, this message translates to:
  /// **'no note'**
  String get noNote;

  /// No description provided for @noNotesFound.
  ///
  /// In en, this message translates to:
  /// **'no notes found'**
  String get noNotesFound;

  /// No description provided for @noRelapsesRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'no relapses recorded yet!'**
  String get noRelapsesRecordedYet;

  /// No description provided for @noRepositoryActivity.
  ///
  /// In en, this message translates to:
  /// **'no repository activity'**
  String get noRepositoryActivity;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'no results'**
  String get noResults;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'no results found'**
  String get noResultsFound;

  /// No description provided for @noSearchResultsFound.
  ///
  /// In en, this message translates to:
  /// **'no search results found'**
  String get noSearchResultsFound;

  /// No description provided for @noTracking.
  ///
  /// In en, this message translates to:
  /// **'no tracking'**
  String get noTracking;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get none;

  /// No description provided for @notSetUsingLastLogOrRelapseTag.
  ///
  /// In en, this message translates to:
  /// **'not set: using last log or relapse tag'**
  String get notSetUsingLastLogOrRelapseTag;

  /// No description provided for @noteCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'note copied to clipboard'**
  String get noteCopiedToClipboard;

  /// No description provided for @noteOnClick.
  ///
  /// In en, this message translates to:
  /// **'note on click'**
  String get noteOnClick;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'notekar'**
  String get appTitle;

  /// No description provided for @notekarBuildsUndergoAutomatedCodeqlScannerCompilationAndLocalVirustotalScansBinariesAreSignedWithOurOfficialCertificateToEnsureAbsoluteIntegrity.
  ///
  /// In en, this message translates to:
  /// **'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.'**
  String
  get notekarBuildsUndergoAutomatedCodeqlScannerCompilationAndLocalVirustotalScansBinariesAreSignedWithOurOfficialCertificateToEnsureAbsoluteIntegrity;

  /// No description provided for @notekarIsOffline.
  ///
  /// In en, this message translates to:
  /// **'notekar is offline'**
  String get notekarIsOffline;

  /// No description provided for @notekarStoresMomentsPrivatelyOnThisDeviceBackupsAreFilesYouControl.
  ///
  /// In en, this message translates to:
  /// **'notekar stores moments privately on this device. backups are files you control.'**
  String get notekarStoresMomentsPrivatelyOnThisDeviceBackupsAreFilesYouControl;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'notes'**
  String get notes;

  /// No description provided for @notificationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'notification permission needed'**
  String get notificationPermissionNeeded;

  /// No description provided for @numberedSingleMoments.
  ///
  /// In en, this message translates to:
  /// **'numbered single moments'**
  String get numberedSingleMoments;

  /// No description provided for @obsidianOnyx.
  ///
  /// In en, this message translates to:
  /// **'obsidian onyx'**
  String get obsidianOnyx;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @officialRepositoryMoved.
  ///
  /// In en, this message translates to:
  /// **'official repository moved'**
  String get officialRepositoryMoved;

  /// No description provided for @offlineAnalysisOfYourLoggedRelapseMomentsNoDataLeavesYourDevice.
  ///
  /// In en, this message translates to:
  /// **'offline analysis of your logged relapse moments. no data leaves your device.'**
  String get offlineAnalysisOfYourLoggedRelapseMomentsNoDataLeavesYourDevice;

  /// No description provided for @offlinePrivacyLog.
  ///
  /// In en, this message translates to:
  /// **'offline privacy log'**
  String get offlinePrivacyLog;

  /// No description provided for @offlineFirst.
  ///
  /// In en, this message translates to:
  /// **'offline-first'**
  String get offlineFirst;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get ok;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'okay'**
  String get okay;

  /// No description provided for @actionOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get actionOn;

  /// No description provided for @onePiece.
  ///
  /// In en, this message translates to:
  /// **'one piece'**
  String get onePiece;

  /// No description provided for @onlyMomentsTaggedHashrelapseResetTheStreakTurnOffToResetOnAnyNewLog.
  ///
  /// In en, this message translates to:
  /// **'only moments tagged #relapse reset the streak. turn off to reset on any new log.'**
  String
  get onlyMomentsTaggedHashrelapseResetTheStreakTurnOffToResetOnAnyNewLog;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get open;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'open link'**
  String get openLink;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'open settings'**
  String get openSettings;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'open source'**
  String get openSource;

  /// No description provided for @ourPhonesAreWithUsEverySingleHourOfTheDayInTheRushOfDailyLifeHoursFrequentlyDisappearIntoReactiveMultitaskingAndEndlessScrolling.
  ///
  /// In en, this message translates to:
  /// **'our phones are with us every single hour of the day. in the rush of daily life, hours frequently disappear into reactive multitasking and endless scrolling.'**
  String
  get ourPhonesAreWithUsEverySingleHourOfTheDayInTheRushOfDailyLifeHoursFrequentlyDisappearIntoReactiveMultitaskingAndEndlessScrolling;

  /// No description provided for @packageVerifiedAndReady.
  ///
  /// In en, this message translates to:
  /// **'package verified & ready'**
  String get packageVerifiedAndReady;

  /// No description provided for @passcodesDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'passcodes do not match'**
  String get passcodesDoNotMatch;

  /// No description provided for @peakRiskWindow.
  ///
  /// In en, this message translates to:
  /// **'peak risk window'**
  String get peakRiskWindow;

  /// No description provided for @permission.
  ///
  /// In en, this message translates to:
  /// **'permission.'**
  String get permission;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'personalization'**
  String get personalization;

  /// No description provided for @personalizeAndConfigureNotekarToFitYourSpecificWorkflow.
  ///
  /// In en, this message translates to:
  /// **'personalize and configure notekar to fit your specific workflow.'**
  String get personalizeAndConfigureNotekarToFitYourSpecificWorkflow;

  /// No description provided for @personalizedAppIcons.
  ///
  /// In en, this message translates to:
  /// **'personalized app icons'**
  String get personalizedAppIcons;

  /// No description provided for @phoenix.
  ///
  /// In en, this message translates to:
  /// **'phoenix'**
  String get phoenix;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'planned'**
  String get planned;

  /// No description provided for @pleaseWaitWhileAndroidRefreshesNotekar.
  ///
  /// In en, this message translates to:
  /// **'please wait while android refreshes notekar.'**
  String get pleaseWaitWhileAndroidRefreshesNotekar;

  /// No description provided for @pokemon.
  ///
  /// In en, this message translates to:
  /// **'pokemon'**
  String get pokemon;

  /// No description provided for @previewFullScreenAlert.
  ///
  /// In en, this message translates to:
  /// **'preview full-screen alert'**
  String get previewFullScreenAlert;

  /// No description provided for @previewInAppSheet.
  ///
  /// In en, this message translates to:
  /// **'preview in-app sheet'**
  String get previewInAppSheet;

  /// No description provided for @priestWillibaldToThorsTheTrollOfJom.
  ///
  /// In en, this message translates to:
  /// **'priest willibald to thors the troll of jom.'**
  String get priestWillibaldToThorsTheTrollOfJom;

  /// No description provided for @priorityBuild.
  ///
  /// In en, this message translates to:
  /// **'priority build'**
  String get priorityBuild;

  /// No description provided for @priorityRelease.
  ///
  /// In en, this message translates to:
  /// **'priority release'**
  String get priorityRelease;

  /// No description provided for @privacyAndOfflineModel.
  ///
  /// In en, this message translates to:
  /// **'privacy & offline model'**
  String get privacyAndOfflineModel;

  /// No description provided for @privacySecurityCategory.
  ///
  /// In en, this message translates to:
  /// **'privacy & security'**
  String get privacySecurityCategory;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyFirstStreakTrackingAndRelapseDiaryAllDataStaysOnYourDeviceExistingLogsAreNeverAltered.
  ///
  /// In en, this message translates to:
  /// **'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.'**
  String
  get privacyFirstStreakTrackingAndRelapseDiaryAllDataStaysOnYourDeviceExistingLogsAreNeverAltered;

  /// No description provided for @privacysecuritycategory.
  ///
  /// In en, this message translates to:
  /// **'privacysecuritycategory'**
  String get privacysecuritycategory;

  /// No description provided for @pureTitanToTheFounderYmirFritz.
  ///
  /// In en, this message translates to:
  /// **'pure titan to the founder ymir fritz.'**
  String get pureTitanToTheFounderYmirFritz;

  /// No description provided for @pushAlertsAndNotices.
  ///
  /// In en, this message translates to:
  /// **'push alerts & notices'**
  String get pushAlertsAndNotices;

  /// No description provided for @quickLocalBackupCreated.
  ///
  /// In en, this message translates to:
  /// **'quick local backup created'**
  String get quickLocalBackupCreated;

  /// No description provided for @ratio.
  ///
  /// In en, this message translates to:
  /// **'ratio'**
  String get ratio;

  /// No description provided for @realTimeMetrics.
  ///
  /// In en, this message translates to:
  /// **'real-time metrics'**
  String get realTimeMetrics;

  /// No description provided for @realTimeTrafficAudit.
  ///
  /// In en, this message translates to:
  /// **'real-time traffic audit'**
  String get realTimeTrafficAudit;

  /// No description provided for @rebirthThroughFireTheOldIsAshYouAreTheFlame.
  ///
  /// In en, this message translates to:
  /// **'rebirth through fire. the old is ash; you are the flame.'**
  String get rebirthThroughFireTheOldIsAshYouAreTheFlame;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'recent'**
  String get recent;

  /// No description provided for @recentMessages.
  ///
  /// In en, this message translates to:
  /// **'recent messages'**
  String get recentMessages;

  /// No description provided for @recentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'recently deleted'**
  String get recentlyDeleted;

  /// No description provided for @recommendedForStandardUsers.
  ///
  /// In en, this message translates to:
  /// **'recommended for standard users.'**
  String get recommendedForStandardUsers;

  /// No description provided for @refreshActivity.
  ///
  /// In en, this message translates to:
  /// **'refresh activity'**
  String get refreshActivity;

  /// No description provided for @remindIfInactiveFor.
  ///
  /// In en, this message translates to:
  /// **'remind if inactive for'**
  String get remindIfInactiveFor;

  /// No description provided for @reminderInterval.
  ///
  /// In en, this message translates to:
  /// **'reminder interval'**
  String get reminderInterval;

  /// No description provided for @reminderMessage.
  ///
  /// In en, this message translates to:
  /// **'reminder message'**
  String get reminderMessage;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'reminders'**
  String get reminders;

  /// No description provided for @remindersAndNotifications.
  ///
  /// In en, this message translates to:
  /// **'reminders & notifications'**
  String get remindersAndNotifications;

  /// No description provided for @reportABug.
  ///
  /// In en, this message translates to:
  /// **'report a bug'**
  String get reportABug;

  /// No description provided for @repositoryLinkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'repository link copied to clipboard'**
  String get repositoryLinkCopiedToClipboard;

  /// No description provided for @repositoryMoved.
  ///
  /// In en, this message translates to:
  /// **'repository moved'**
  String get repositoryMoved;

  /// No description provided for @requestAFeature.
  ///
  /// In en, this message translates to:
  /// **'request a feature'**
  String get requestAFeature;

  /// No description provided for @requiredForNotekarToInstallDownloadedApkUpdatesAutomatically.
  ///
  /// In en, this message translates to:
  /// **'required for notekar to install downloaded apk updates automatically.'**
  String get requiredForNotekarToInstallDownloadedApkUpdatesAutomatically;

  /// No description provided for @requiredToShowTheLoggingAlerts.
  ///
  /// In en, this message translates to:
  /// **'required to show the logging alerts.'**
  String get requiredToShowTheLoggingAlerts;

  /// No description provided for @resetCategory.
  ///
  /// In en, this message translates to:
  /// **'reset'**
  String get resetCategory;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'reset all data'**
  String get resetAllData;

  /// No description provided for @resetDaily.
  ///
  /// In en, this message translates to:
  /// **'reset daily'**
  String get resetDaily;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'reset data'**
  String get resetData;

  /// No description provided for @resetNumberingDaily.
  ///
  /// In en, this message translates to:
  /// **'reset numbering daily'**
  String get resetNumberingDaily;

  /// No description provided for @resetOnRelapseTagOnly.
  ///
  /// In en, this message translates to:
  /// **'reset on relapse tag only'**
  String get resetOnRelapseTagOnly;

  /// No description provided for @resetPinLock.
  ///
  /// In en, this message translates to:
  /// **'reset pin lock'**
  String get resetPinLock;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'reset settings'**
  String get resetSettings;

  /// No description provided for @resetSettingsOnly.
  ///
  /// In en, this message translates to:
  /// **'reset settings only'**
  String get resetSettingsOnly;

  /// No description provided for @resetcategory.
  ///
  /// In en, this message translates to:
  /// **'resetcategory'**
  String get resetcategory;

  /// No description provided for @restartsCountAt00EveryMidnightWhileKeepingPastHistoryIntact.
  ///
  /// In en, this message translates to:
  /// **'restarts count at 00 every midnight while keeping past history intact.'**
  String get restartsCountAt00EveryMidnightWhileKeepingPastHistoryIntact;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'restore'**
  String get restore;

  /// No description provided for @restoreAll.
  ///
  /// In en, this message translates to:
  /// **'restore all'**
  String get restoreAll;

  /// No description provided for @restoreAllMoments.
  ///
  /// In en, this message translates to:
  /// **'restore all moments?'**
  String get restoreAllMoments;

  /// No description provided for @restoreDeletedMoments.
  ///
  /// In en, this message translates to:
  /// **'restore deleted moments'**
  String get restoreDeletedMoments;

  /// No description provided for @restoreOrPermanentlyRemoveDeletedMoments.
  ///
  /// In en, this message translates to:
  /// **'restore or permanently remove deleted moments'**
  String get restoreOrPermanentlyRemoveDeletedMoments;

  /// No description provided for @retryDownload.
  ///
  /// In en, this message translates to:
  /// **'retry download'**
  String get retryDownload;

  /// No description provided for @reviewAndExport.
  ///
  /// In en, this message translates to:
  /// **'review and export'**
  String get reviewAndExport;

  /// No description provided for @reviewBackup.
  ///
  /// In en, this message translates to:
  /// **'review backup'**
  String get reviewBackup;

  /// No description provided for @reviewHistory.
  ///
  /// In en, this message translates to:
  /// **'review history'**
  String get reviewHistory;

  /// No description provided for @royalOcean.
  ///
  /// In en, this message translates to:
  /// **'royal ocean'**
  String get royalOcean;

  /// No description provided for @rpgSlashMinecraft.
  ///
  /// In en, this message translates to:
  /// **'rpg / minecraft'**
  String get rpgSlashMinecraft;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'russian'**
  String get russian;

  /// No description provided for @sMateVictimToMagnusCarlsen.
  ///
  /// In en, this message translates to:
  /// **'s mate victim to magnus carlsen.'**
  String get sMateVictimToMagnusCarlsen;

  /// No description provided for @sNew.
  ///
  /// In en, this message translates to:
  /// **'s new'**
  String get sNew;

  /// No description provided for @sNewInNotekar.
  ///
  /// In en, this message translates to:
  /// **'s new in notekar'**
  String get sNewInNotekar;

  /// No description provided for @sNew2.
  ///
  /// In en, this message translates to:
  /// **'s new:'**
  String get sNew2;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'sad'**
  String get sad;

  /// No description provided for @samurai.
  ///
  /// In en, this message translates to:
  /// **'samurai'**
  String get samurai;

  /// No description provided for @sapphire.
  ///
  /// In en, this message translates to:
  /// **'sapphire'**
  String get sapphire;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'sat'**
  String get sat;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'saturday'**
  String get saturday;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get save;

  /// No description provided for @saveAMoment.
  ///
  /// In en, this message translates to:
  /// **'save a moment'**
  String get saveAMoment;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'science'**
  String get science;

  /// No description provided for @seafaringOdysseyChartNewWatersAndNeverLookBack.
  ///
  /// In en, this message translates to:
  /// **'seafaring odyssey. chart new waters and never look back.'**
  String get seafaringOdysseyChartNewWatersAndNeverLookBack;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'search notes'**
  String get searchNotes;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'search settings'**
  String get searchSettings;

  /// No description provided for @searchSettings2.
  ///
  /// In en, this message translates to:
  /// **'search settings...'**
  String get searchSettings2;

  /// No description provided for @securePasscodeProtection.
  ///
  /// In en, this message translates to:
  /// **'secure passcode protection'**
  String get securePasscodeProtection;

  /// No description provided for @securityAndCryptographicUpgrade.
  ///
  /// In en, this message translates to:
  /// **'security & cryptographic upgrade'**
  String get securityAndCryptographicUpgrade;

  /// No description provided for @securityAndIntegrity.
  ///
  /// In en, this message translates to:
  /// **'security & integrity'**
  String get securityAndIntegrity;

  /// No description provided for @selectAThemeThatBestSuitsYourEnvironment.
  ///
  /// In en, this message translates to:
  /// **'select a theme that best suits your environment.'**
  String get selectAThemeThatBestSuitsYourEnvironment;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'select date'**
  String get selectDate;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'select date and time'**
  String get selectDateAndTime;

  /// No description provided for @selectForDuration.
  ///
  /// In en, this message translates to:
  /// **'select for duration'**
  String get selectForDuration;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'select time'**
  String get selectTime;

  /// No description provided for @selectYourPreferredInterfaceLanguageYouCanChangeThisAnytimeInSettings.
  ///
  /// In en, this message translates to:
  /// **'select your preferred interface language. you can change this anytime in settings.'**
  String
  get selectYourPreferredInterfaceLanguageYouCanChangeThisAnytimeInSettings;

  /// No description provided for @selectYourPreferredLanguageForTheApplication.
  ///
  /// In en, this message translates to:
  /// **'select your preferred language for the application.'**
  String get selectYourPreferredLanguageForTheApplication;

  /// No description provided for @sequentialSingleNumbering0099RequiresStandardRowSpacingToDisplay2DigitBadgesTurnOffCompactHistoryToEnableNumbersInSingleMode.
  ///
  /// In en, this message translates to:
  /// **'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.'**
  String
  get sequentialSingleNumbering0099RequiresStandardRowSpacingToDisplay2DigitBadgesTurnOffCompactHistoryToEnableNumbersInSingleMode;

  /// No description provided for @sessionsAreRecordedAsInAndOutPairs.
  ///
  /// In en, this message translates to:
  /// **'sessions are recorded as in and out pairs.'**
  String get sessionsAreRecordedAsInAndOutPairs;

  /// No description provided for @actionSet.
  ///
  /// In en, this message translates to:
  /// **'set'**
  String get actionSet;

  /// No description provided for @setOneFocusForNextHour.
  ///
  /// In en, this message translates to:
  /// **'set one focus for next hour'**
  String get setOneFocusForNextHour;

  /// No description provided for @setPasscode.
  ///
  /// In en, this message translates to:
  /// **'set passcode'**
  String get setPasscode;

  /// No description provided for @setSobrietyStartDate.
  ///
  /// In en, this message translates to:
  /// **'set sobriety start date'**
  String get setSobrietyStartDate;

  /// No description provided for @setUnrestricted.
  ///
  /// In en, this message translates to:
  /// **'set unrestricted'**
  String get setUnrestricted;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get settingsTitle;

  /// No description provided for @settingsRestored.
  ///
  /// In en, this message translates to:
  /// **'settings restored'**
  String get settingsRestored;

  /// No description provided for @sha256Hashes.
  ///
  /// In en, this message translates to:
  /// **'sha-256 hashes'**
  String get sha256Hashes;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'share'**
  String get share;

  /// No description provided for @shareCard.
  ///
  /// In en, this message translates to:
  /// **'share card'**
  String get shareCard;

  /// No description provided for @shareMilestonePeak.
  ///
  /// In en, this message translates to:
  /// **'share milestone peak'**
  String get shareMilestonePeak;

  /// No description provided for @shinpachiToUtsuro.
  ///
  /// In en, this message translates to:
  /// **'shinpachi to utsuro.'**
  String get shinpachiToUtsuro;

  /// No description provided for @shirleyToEmperorLelouchViBritannia.
  ///
  /// In en, this message translates to:
  /// **'shirley to emperor lelouch vi britannia.'**
  String get shirleyToEmperorLelouchViBritannia;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'show more'**
  String get showMore;

  /// No description provided for @showSeconds.
  ///
  /// In en, this message translates to:
  /// **'show seconds'**
  String get showSeconds;

  /// No description provided for @shows0099CountersInsteadOfStaticIconsInHistory.
  ///
  /// In en, this message translates to:
  /// **'shows 00–99 counters instead of static icons in history.'**
  String get shows0099CountersInsteadOfStaticIconsInHistory;

  /// No description provided for @showsSequentialNumbers0001OnTheTapPulseAnimation.
  ///
  /// In en, this message translates to:
  /// **'shows sequential numbers (00, 01...) on the tap pulse animation.'**
  String get showsSequentialNumbers0001OnTheTapPulseAnimation;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'signature'**
  String get signature;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'single'**
  String get single;

  /// No description provided for @singleMode.
  ///
  /// In en, this message translates to:
  /// **'single mode'**
  String get singleMode;

  /// No description provided for @singleMomentNumbering.
  ///
  /// In en, this message translates to:
  /// **'single moment numbering'**
  String get singleMomentNumbering;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get skip;

  /// No description provided for @smallerOptimizedApks.
  ///
  /// In en, this message translates to:
  /// **'smaller, optimized apks'**
  String get smallerOptimizedApks;

  /// No description provided for @smartBandwidthSaver.
  ///
  /// In en, this message translates to:
  /// **'smart bandwidth saver'**
  String get smartBandwidthSaver;

  /// No description provided for @sobrietyCompanion.
  ///
  /// In en, this message translates to:
  /// **'sobriety companion'**
  String get sobrietyCompanion;

  /// No description provided for @sobrietyTracker.
  ///
  /// In en, this message translates to:
  /// **'sobriety tracker'**
  String get sobrietyTracker;

  /// No description provided for @sobrietyTrackerAndMilestoneCards.
  ///
  /// In en, this message translates to:
  /// **'sobriety tracker & milestone cards'**
  String get sobrietyTrackerAndMilestoneCards;

  /// No description provided for @sobrietyTriggerAnalysis.
  ///
  /// In en, this message translates to:
  /// **'sobriety trigger analysis'**
  String get sobrietyTriggerAnalysis;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'social media'**
  String get socialMedia;

  /// No description provided for @socialMedia2.
  ///
  /// In en, this message translates to:
  /// **'social_media'**
  String get socialMedia2;

  /// No description provided for @softwareCreditsAndOpenSourceLegalNotices.
  ///
  /// In en, this message translates to:
  /// **'software credits and open source legal notices'**
  String get softwareCreditsAndOpenSourceLegalNotices;

  /// No description provided for @softwareLicenses.
  ///
  /// In en, this message translates to:
  /// **'software licenses'**
  String get softwareLicenses;

  /// No description provided for @softwareUpdate.
  ///
  /// In en, this message translates to:
  /// **'software update'**
  String get softwareUpdate;

  /// No description provided for @softwareUpdateAppNoticesChangelog.
  ///
  /// In en, this message translates to:
  /// **'software update, app notices, changelog'**
  String get softwareUpdateAppNoticesChangelog;

  /// No description provided for @soloLeveling.
  ///
  /// In en, this message translates to:
  /// **'solo leveling'**
  String get soloLeveling;

  /// No description provided for @soundAndChimeAlert.
  ///
  /// In en, this message translates to:
  /// **'sound & chime alert'**
  String get soundAndChimeAlert;

  /// No description provided for @space.
  ///
  /// In en, this message translates to:
  /// **'space'**
  String get space;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'spanish'**
  String get spanish;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'stable'**
  String get stable;

  /// No description provided for @stableBuild.
  ///
  /// In en, this message translates to:
  /// **'stable build'**
  String get stableBuild;

  /// No description provided for @starWars.
  ///
  /// In en, this message translates to:
  /// **'star wars'**
  String get starWars;

  /// No description provided for @startLogging.
  ///
  /// In en, this message translates to:
  /// **'start logging'**
  String get startLogging;

  /// No description provided for @startupMode.
  ///
  /// In en, this message translates to:
  /// **'startup mode'**
  String get startupMode;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'status'**
  String get status;

  /// No description provided for @storageErrorMomentNotSaved.
  ///
  /// In en, this message translates to:
  /// **'storage error: moment not saved'**
  String get storageErrorMomentNotSaved;

  /// No description provided for @streakMode.
  ///
  /// In en, this message translates to:
  /// **'streak mode'**
  String get streakMode;

  /// No description provided for @streakResetLogic.
  ///
  /// In en, this message translates to:
  /// **'streak reset logic'**
  String get streakResetLogic;

  /// No description provided for @streakShieldDeployedCleanStreakProtected.
  ///
  /// In en, this message translates to:
  /// **'streak shield deployed! clean streak protected.'**
  String get streakShieldDeployedCleanStreakProtected;

  /// No description provided for @stress.
  ///
  /// In en, this message translates to:
  /// **'stress'**
  String get stress;

  /// No description provided for @stressed.
  ///
  /// In en, this message translates to:
  /// **'stressed'**
  String get stressed;

  /// No description provided for @submitBugReportsFeatureRequestsAndFollowCodeChangesDirectlyInTheNewRepositoryIssueTracker.
  ///
  /// In en, this message translates to:
  /// **'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.'**
  String
  get submitBugReportsFeatureRequestsAndFollowCodeChangesDirectlyInTheNewRepositoryIssueTracker;

  /// No description provided for @suggestANewIdeaOrImprovement.
  ///
  /// In en, this message translates to:
  /// **'suggest a new idea or improvement.'**
  String get suggestANewIdeaOrImprovement;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'sun'**
  String get sun;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'sunday'**
  String get sunday;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'sunset'**
  String get sunset;

  /// No description provided for @supportAndCommunity.
  ///
  /// In en, this message translates to:
  /// **'support & community'**
  String get supportAndCommunity;

  /// No description provided for @survivalOfTheFittestTardigradeToMythicalDragon.
  ///
  /// In en, this message translates to:
  /// **'survival of the fittest. tardigrade to mythical dragon.'**
  String get survivalOfTheFittestTardigradeToMythicalDragon;

  /// No description provided for @switchingToBetaBuild.
  ///
  /// In en, this message translates to:
  /// **'switching to beta build...'**
  String get switchingToBetaBuild;

  /// No description provided for @switchingToStableBuild.
  ///
  /// In en, this message translates to:
  /// **'switching to stable build...'**
  String get switchingToStableBuild;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'system'**
  String get system;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'system default'**
  String get systemDefault;

  /// No description provided for @systemLock.
  ///
  /// In en, this message translates to:
  /// **'system lock'**
  String get systemLock;

  /// No description provided for @systemLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'system lock enabled'**
  String get systemLockEnabled;

  /// No description provided for @tShowThisWarningAgain.
  ///
  /// In en, this message translates to:
  /// **'t show this warning again'**
  String get tShowThisWarningAgain;

  /// No description provided for @tWorkingAsExpected.
  ///
  /// In en, this message translates to:
  /// **'t working as expected.'**
  String get tWorkingAsExpected;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'table'**
  String get table;

  /// No description provided for @takeAMindfulBreath.
  ///
  /// In en, this message translates to:
  /// **'take a mindful breath'**
  String get takeAMindfulBreath;

  /// No description provided for @takeThreeDeepBreaths.
  ///
  /// In en, this message translates to:
  /// **'take three deep breaths'**
  String get takeThreeDeepBreaths;

  /// No description provided for @tangerineCoral.
  ///
  /// In en, this message translates to:
  /// **'tangerine coral'**
  String get tangerineCoral;

  /// No description provided for @tapAnyIconBelowToSwitchStyle.
  ///
  /// In en, this message translates to:
  /// **'tap any icon below to switch style'**
  String get tapAnyIconBelowToSwitchStyle;

  /// No description provided for @tapAnyIconBelowToSwitchStyleYouCanChangeThisAnytimeInSettings.
  ///
  /// In en, this message translates to:
  /// **'tap any icon below to switch style. you can change this anytime in settings.'**
  String get tapAnyIconBelowToSwitchStyleYouCanChangeThisAnytimeInSettings;

  /// No description provided for @tapDelay.
  ///
  /// In en, this message translates to:
  /// **'tap delay'**
  String get tapDelay;

  /// No description provided for @tapToRecordAMomentHoldToAddANote.
  ///
  /// In en, this message translates to:
  /// **'tap to record a moment. hold to add a note.'**
  String get tapToRecordAMomentHoldToAddANote;

  /// No description provided for @tapToSave.
  ///
  /// In en, this message translates to:
  /// **'tap to save'**
  String get tapToSave;

  /// No description provided for @techCareer.
  ///
  /// In en, this message translates to:
  /// **'tech career'**
  String get techCareer;

  /// No description provided for @technicalStatsAboutYourDeviceAndTheAdaptiveEngine.
  ///
  /// In en, this message translates to:
  /// **'technical stats about your device and the adaptive engine.'**
  String get technicalStatsAboutYourDeviceAndTheAdaptiveEngine;

  /// No description provided for @teddyBearKonToYhwachTheAlmighty.
  ///
  /// In en, this message translates to:
  /// **'teddy bear kon to yhwach the almighty.'**
  String get teddyBearKonToYhwachTheAlmighty;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'terms of use'**
  String get termsOfUse;

  /// No description provided for @testAlertIn3sLockYourPhoneToTestFullScreenAlarm.
  ///
  /// In en, this message translates to:
  /// **'test alert in 3s: lock your phone to test full-screen alarm!'**
  String get testAlertIn3sLockYourPhoneToTestFullScreenAlarm;

  /// No description provided for @testFullScreenAlarmAlert.
  ///
  /// In en, this message translates to:
  /// **'test full-screen alarm alert'**
  String get testFullScreenAlarmAlert;

  /// No description provided for @testNow.
  ///
  /// In en, this message translates to:
  /// **'test now'**
  String get testNow;

  /// No description provided for @theCurrentFeaturesOnThisPageAreUnderBetaStage.
  ///
  /// In en, this message translates to:
  /// **'the current features on this page are under beta stage.'**
  String get theCurrentFeaturesOnThisPageAreUnderBetaStage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'theme'**
  String get theme;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'theme description'**
  String get themeDescription;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'theme mode'**
  String get themeMode;

  /// No description provided for @themeStyle.
  ///
  /// In en, this message translates to:
  /// **'theme style'**
  String get themeStyle;

  /// No description provided for @theseLanguagesArePlannedForFutureReleasesHelpTranslateNotekarOnGithub.
  ///
  /// In en, this message translates to:
  /// **'these languages are planned for future releases. help translate notekar on github.'**
  String
  get theseLanguagesArePlannedForFutureReleasesHelpTranslateNotekarOnGithub;

  /// No description provided for @theseSettingsDefineHowMomentsAreRecordedAndPreparedForExport.
  ///
  /// In en, this message translates to:
  /// **'these settings define how moments are recorded and prepared for export.'**
  String get theseSettingsDefineHowMomentsAreRecordedAndPreparedForExport;

  /// No description provided for @theseSettingsRefineTheInterfaceAestheticAndDoNotModifyYourSavedData.
  ///
  /// In en, this message translates to:
  /// **'these settings refine the interface aesthetic and do not modify your saved data.'**
  String
  get theseSettingsRefineTheInterfaceAestheticAndDoNotModifyYourSavedData;

  /// No description provided for @theseToolsAreIntendedForSystemMaintenanceAndTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'these tools are intended for system maintenance and troubleshooting.'**
  String get theseToolsAreIntendedForSystemMaintenanceAndTroubleshooting;

  /// No description provided for @thisBackupContainsNoMoments.
  ///
  /// In en, this message translates to:
  /// **'this backup contains no moments'**
  String get thisBackupContainsNoMoments;

  /// No description provided for @thisFeatureIsCurrentlyInActiveDevelopmentWhileFullyFunctionalAndSecureYouMayNoticeMinorAdjustmentsToTheLayoutOrPerformanceAsWeRefineTheExperienceAllCalculationsDataAndSecurityPoliciesRemainEntirelyLocalToYourDevice.
  ///
  /// In en, this message translates to:
  /// **'this feature is currently in active development. while fully functional and secure, you may notice minor adjustments to the layout or performance as we refine the experience. all calculations, data, and security policies remain entirely local to your device.'**
  String
  get thisFeatureIsCurrentlyInActiveDevelopmentWhileFullyFunctionalAndSecureYouMayNoticeMinorAdjustmentsToTheLayoutOrPerformanceAsWeRefineTheExperienceAllCalculationsDataAndSecurityPoliciesRemainEntirelyLocalToYourDevice;

  /// No description provided for @thisLanguageIsCurrentlyUnderDevelopmentYouCanHelpTranslateNotekarIntoYourNativeLanguageByContributingOnGithub.
  ///
  /// In en, this message translates to:
  /// **'this language is currently under development. you can help translate notekar into your native language by contributing on github.'**
  String
  get thisLanguageIsCurrentlyUnderDevelopmentYouCanHelpTranslateNotekarIntoYourNativeLanguageByContributingOnGithub;

  /// No description provided for @thisLocalBackupFileWillBeErasedPermanently.
  ///
  /// In en, this message translates to:
  /// **'this local backup file will be erased permanently.'**
  String get thisLocalBackupFileWillBeErasedPermanently;

  /// No description provided for @thisMomentWillBeErasedForever.
  ///
  /// In en, this message translates to:
  /// **'this moment will be erased forever.'**
  String get thisMomentWillBeErasedForever;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get thisWeek;

  /// No description provided for @thisWillPermanentlyDeleteAllMomentsInTheTrashThisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'this will permanently delete all moments in the trash. this action cannot be undone.'**
  String
  get thisWillPermanentlyDeleteAllMomentsInTheTrashThisActionCannotBeUndone;

  /// No description provided for @thisWillPermanentlyDeleteAllMomentsThisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'this will permanently delete all moments. this action cannot be undone.'**
  String get thisWillPermanentlyDeleteAllMomentsThisActionCannotBeUndone;

  /// No description provided for @thisWillReturnAllItemsCurrentlyInTheTrashToYourHistory.
  ///
  /// In en, this message translates to:
  /// **'this will return all items currently in the trash to your history.'**
  String get thisWillReturnAllItemsCurrentlyInTheTrashToYourHistory;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'thu'**
  String get thu;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'thursday'**
  String get thursday;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get time;

  /// No description provided for @timeBetweenMoments.
  ///
  /// In en, this message translates to:
  /// **'time between moments'**
  String get timeBetweenMoments;

  /// No description provided for @timeReflection.
  ///
  /// In en, this message translates to:
  /// **'time reflection'**
  String get timeReflection;

  /// No description provided for @timeReflectionAndHourlyMindfulness.
  ///
  /// In en, this message translates to:
  /// **'time reflection & hourly mindfulness'**
  String get timeReflectionAndHourlyMindfulness;

  /// No description provided for @timeReflectionAndMindfulness.
  ///
  /// In en, this message translates to:
  /// **'time reflection & mindfulness'**
  String get timeReflectionAndMindfulness;

  /// No description provided for @timeReflectionInterruptsAutopilotLivingAnHourlyChimeTransformsYourPhoneFromASourceOfDistractionIntoAMindfulAllyHelpingYouFeelThePassageOfTimeAndRegainConsciousControlOfYourDay.
  ///
  /// In en, this message translates to:
  /// **'time reflection interrupts autopilot living. an hourly chime transforms your phone from a source of distraction into a mindful ally, helping you feel the passage of time and regain conscious control of your day.'**
  String
  get timeReflectionInterruptsAutopilotLivingAnHourlyChimeTransformsYourPhoneFromASourceOfDistractionIntoAMindfulAllyHelpingYouFeelThePassageOfTimeAndRegainConsciousControlOfYourDay;

  /// No description provided for @timeReflectionInterval.
  ///
  /// In en, this message translates to:
  /// **'time reflection interval'**
  String get timeReflectionInterval;

  /// No description provided for @timeReflectionReminder.
  ///
  /// In en, this message translates to:
  /// **'time reflection reminder'**
  String get timeReflectionReminder;

  /// No description provided for @timeToLogAMoment.
  ///
  /// In en, this message translates to:
  /// **'time to log a moment!'**
  String get timeToLogAMoment;

  /// No description provided for @tired.
  ///
  /// In en, this message translates to:
  /// **'tired'**
  String get tired;

  /// No description provided for @toCaptureAnInsightGratitudeOrAchievementDirectlyIntoNotekar.
  ///
  /// In en, this message translates to:
  /// **'to capture an insight, gratitude, or achievement directly into notekar.'**
  String get toCaptureAnInsightGratitudeOrAchievementDirectlyIntoNotekar;

  /// No description provided for @toDownloadAndInstallSoftwareUpdatesDirectlyWithinNotekarPleaseConfigureTheFollowingSecuritySettings.
  ///
  /// In en, this message translates to:
  /// **'to download and install software updates directly within notekar, please configure the following security settings:'**
  String
  get toDownloadAndInstallSoftwareUpdatesDirectlyWithinNotekarPleaseConfigureTheFollowingSecuritySettings;

  /// No description provided for @toTriggerRemindersPreciselyWhenTheAppIsClosedNotekarRequiresTheAlarmsAndRemindersPermission.
  ///
  /// In en, this message translates to:
  /// **'to trigger reminders precisely when the app is closed, notekar requires the \"alarms & reminders\" permission.'**
  String
  get toTriggerRemindersPreciselyWhenTheAppIsClosedNotekarRequiresTheAlarmsAndRemindersPermission;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @tonpaToAdultGon.
  ///
  /// In en, this message translates to:
  /// **'tonpa to adult gon.'**
  String get tonpaToAdultGon;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'tools'**
  String get tools;

  /// No description provided for @topMood.
  ///
  /// In en, this message translates to:
  /// **'top mood'**
  String get topMood;

  /// No description provided for @topTrigger.
  ///
  /// In en, this message translates to:
  /// **'top trigger'**
  String get topTrigger;

  /// No description provided for @totalRelapses.
  ///
  /// In en, this message translates to:
  /// **'total relapses'**
  String get totalRelapses;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'total requests'**
  String get totalRequests;

  /// No description provided for @trackStartsAndStops.
  ///
  /// In en, this message translates to:
  /// **'track starts and stops'**
  String get trackStartsAndStops;

  /// No description provided for @transformYourHistoryWithSequential2DigitCounters0099DailyMidnightResetsAndAnIosStyleCalendar.
  ///
  /// In en, this message translates to:
  /// **'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.'**
  String
  get transformYourHistoryWithSequential2DigitCounters0099DailyMidnightResetsAndAnIosStyleCalendar;

  /// No description provided for @trashBin.
  ///
  /// In en, this message translates to:
  /// **'trash bin'**
  String get trashBin;

  /// No description provided for @trashIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'trash is empty'**
  String get trashIsEmpty;

  /// No description provided for @triggerAnalysis.
  ///
  /// In en, this message translates to:
  /// **'trigger analysis'**
  String get triggerAnalysis;

  /// No description provided for @triggerDiary.
  ///
  /// In en, this message translates to:
  /// **'trigger diary'**
  String get triggerDiary;

  /// No description provided for @triggersRemindersOnSpecificDaysOfTheWeek.
  ///
  /// In en, this message translates to:
  /// **'triggers reminders on specific days of the week.'**
  String get triggersRemindersOnSpecificDaysOfTheWeek;

  /// No description provided for @tryAgainInSeconds.
  ///
  /// In en, this message translates to:
  /// **'try again in seconds'**
  String get tryAgainInSeconds;

  /// No description provided for @tryAnotherKeyword.
  ///
  /// In en, this message translates to:
  /// **'try another keyword'**
  String get tryAnotherKeyword;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'tue'**
  String get tue;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'tuesday'**
  String get tuesday;

  /// No description provided for @turnOffAndEnable.
  ///
  /// In en, this message translates to:
  /// **'turn off & enable'**
  String get turnOffAndEnable;

  /// No description provided for @turnOffReducedMotionFirst.
  ///
  /// In en, this message translates to:
  /// **'turn off reduced motion first'**
  String get turnOffReducedMotionFirst;

  /// No description provided for @turnOffSingleNumbers.
  ///
  /// In en, this message translates to:
  /// **'turn off single numbers?'**
  String get turnOffSingleNumbers;

  /// No description provided for @tutorials.
  ///
  /// In en, this message translates to:
  /// **'tutorials'**
  String get tutorials;

  /// No description provided for @twoWay.
  ///
  /// In en, this message translates to:
  /// **'two-way'**
  String get twoWay;

  /// No description provided for @twoWayMode.
  ///
  /// In en, this message translates to:
  /// **'two-way mode'**
  String get twoWayMode;

  /// No description provided for @typeToSearchYourNotes.
  ///
  /// In en, this message translates to:
  /// **'type to search your notes...'**
  String get typeToSearchYourNotes;

  /// No description provided for @undetected.
  ///
  /// In en, this message translates to:
  /// **'undetected'**
  String get undetected;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'undo'**
  String get undo;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'upcoming'**
  String get upcoming;

  /// No description provided for @upcomingLanguages.
  ///
  /// In en, this message translates to:
  /// **'upcoming languages'**
  String get upcomingLanguages;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'update available'**
  String get updateAvailable;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'update check failed'**
  String get updateCheckFailed;

  /// No description provided for @updateTrack.
  ///
  /// In en, this message translates to:
  /// **'update track'**
  String get updateTrack;

  /// No description provided for @updatesAndNotices.
  ///
  /// In en, this message translates to:
  /// **'updates & notices'**
  String get updatesAndNotices;

  /// No description provided for @urgeSurfingAndGrounding.
  ///
  /// In en, this message translates to:
  /// **'urge surfing & grounding'**
  String get urgeSurfingAndGrounding;

  /// No description provided for @useFingerprintFaceOrSystemPin.
  ///
  /// In en, this message translates to:
  /// **'use fingerprint, face, or system pin.'**
  String get useFingerprintFaceOrSystemPin;

  /// No description provided for @useNumbersInSingle.
  ///
  /// In en, this message translates to:
  /// **'use numbers in single'**
  String get useNumbersInSingle;

  /// No description provided for @useSingleOrTwoWayModeBasedOnYourFlow.
  ///
  /// In en, this message translates to:
  /// **'use single or two-way mode based on your flow.'**
  String get useSingleOrTwoWayModeBasedOnYourFlow;

  /// No description provided for @velvetRuby.
  ///
  /// In en, this message translates to:
  /// **'velvet ruby'**
  String get velvetRuby;

  /// No description provided for @verifiedCleanOfMaliciousActivity.
  ///
  /// In en, this message translates to:
  /// **'verified clean of malicious activity'**
  String get verifiedCleanOfMaliciousActivity;

  /// No description provided for @verifiedSafe.
  ///
  /// In en, this message translates to:
  /// **'verified safe'**
  String get verifiedSafe;

  /// No description provided for @verifyingIntegrityChecksum.
  ///
  /// In en, this message translates to:
  /// **'verifying integrity checksum...'**
  String get verifyingIntegrityChecksum;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'version'**
  String get version;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'view'**
  String get view;

  /// No description provided for @viewAllMilestones.
  ///
  /// In en, this message translates to:
  /// **'view all milestones'**
  String get viewAllMilestones;

  /// No description provided for @viewFullLicenses.
  ///
  /// In en, this message translates to:
  /// **'view full licenses'**
  String get viewFullLicenses;

  /// No description provided for @viewNote.
  ///
  /// In en, this message translates to:
  /// **'view note'**
  String get viewNote;

  /// No description provided for @viewYourRelapsePatternInsightsTopMoodsAndPeakVulnerabilityWindows.
  ///
  /// In en, this message translates to:
  /// **'view your relapse pattern insights, top moods, and peak vulnerability windows.'**
  String get viewYourRelapsePatternInsightsTopMoodsAndPeakVulnerabilityWindows;

  /// No description provided for @vinlandSaga.
  ///
  /// In en, this message translates to:
  /// **'vinland saga'**
  String get vinlandSaga;

  /// No description provided for @virustotalSafetyScan.
  ///
  /// In en, this message translates to:
  /// **'virustotal safety scan'**
  String get virustotalSafetyScan;

  /// No description provided for @virustotalScan.
  ///
  /// In en, this message translates to:
  /// **'virustotal scan'**
  String get virustotalScan;

  /// No description provided for @vtReport.
  ///
  /// In en, this message translates to:
  /// **'vt report'**
  String get vtReport;

  /// No description provided for @warrior.
  ///
  /// In en, this message translates to:
  /// **'warrior'**
  String get warrior;

  /// No description provided for @weHaveOfficiallyMigratedOurCodebaseToANewHomeAllFutureReleasesUpdatesAndIssuesWillBeManagedHere.
  ///
  /// In en, this message translates to:
  /// **'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:'**
  String
  get weHaveOfficiallyMigratedOurCodebaseToANewHomeAllFutureReleasesUpdatesAndIssuesWillBeManagedHere;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'wed'**
  String get wed;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'wednesday'**
  String get wednesday;

  /// No description provided for @weeklyReminder.
  ///
  /// In en, this message translates to:
  /// **'weekly reminder'**
  String get weeklyReminder;

  /// No description provided for @weeklyReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'weekly reminder message'**
  String get weeklyReminderMessage;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'welcome'**
  String get welcome;

  /// No description provided for @welcomeToNotekar.
  ///
  /// In en, this message translates to:
  /// **'welcome to notekar'**
  String get welcomeToNotekar;

  /// No description provided for @wereYouAlreadyCleanBeforeInstallingSetYourActualStartDateHereThisOverridesAutomaticDetectionFromYourLogs.
  ///
  /// In en, this message translates to:
  /// **'were you already clean before installing? set your actual start date here. this overrides automatic detection from your logs.'**
  String
  get wereYouAlreadyCleanBeforeInstallingSetYourActualStartDateHereThisOverridesAutomaticDetectionFromYourLogs;

  /// No description provided for @whatsnewtitle.
  ///
  /// In en, this message translates to:
  /// **'whatsnewtitle'**
  String get whatsnewtitle;

  /// No description provided for @whenActiveYourPhoneWillWakeUpWithASoothingAlarmToneAndPresentAFullScreenReflectionPromptAtYourChosenFrequencyEvenIfTheScreenIsLocked.
  ///
  /// In en, this message translates to:
  /// **'when active, your phone will wake up with a soothing alarm tone and present a full-screen reflection prompt at your chosen frequency even if the screen is locked.'**
  String
  get whenActiveYourPhoneWillWakeUpWithASoothingAlarmToneAndPresentAFullScreenReflectionPromptAtYourChosenFrequencyEvenIfTheScreenIsLocked;

  /// No description provided for @whenLoggingAMomentWithSobrietyModeOnYouCanTagMoodBoredAnxiousLonelyAndTriggerSocialMediaLateNightTheseAreStoredAsHashtagsInTheNoteForFullBackwardsCompatibility.
  ///
  /// In en, this message translates to:
  /// **'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.'**
  String
  get whenLoggingAMomentWithSobrietyModeOnYouCanTagMoodBoredAnxiousLonelyAndTriggerSocialMediaLateNightTheseAreStoredAsHashtagsInTheNoteForFullBackwardsCompatibility;

  /// No description provided for @whenTheAlertWakesYourScreenPauseWhateverYouAreDoingInhaleDeeplyExhaleSlowlyAndGroundYourselfInThePresentMoment.
  ///
  /// In en, this message translates to:
  /// **'when the alert wakes your screen, pause whatever you are doing. inhale deeply, exhale slowly, and ground yourself in the present moment.'**
  String
  get whenTheAlertWakesYourScreenPauseWhateverYouAreDoingInhaleDeeplyExhaleSlowlyAndGroundYourselfInThePresentMoment;

  /// No description provided for @whyTimeReflection.
  ///
  /// In en, this message translates to:
  /// **'why time reflection?'**
  String get whyTimeReflection;

  /// No description provided for @wipe.
  ///
  /// In en, this message translates to:
  /// **'wipe'**
  String get wipe;

  /// No description provided for @withYourPhoneAlwaysWithYouPauseForAMomentReflectOnHowYouSpentYourLastHourAndDecideYourFocusForTheNext.
  ///
  /// In en, this message translates to:
  /// **'with your phone always with you, pause for a moment. reflect on how you spent your last hour, and decide your focus for the next.'**
  String
  get withYourPhoneAlwaysWithYouPauseForAMomentReflectOnHowYouSpentYourLastHourAndDecideYourFocusForTheNext;

  /// No description provided for @withYourPhoneAlwaysWithYouReceiveAMindfulChimeAndFullScreenReflectionPromptEveryHourOrChosenIntervalToReflectOnPassingTime.
  ///
  /// In en, this message translates to:
  /// **'with your phone always with you, receive a mindful chime and full-screen reflection prompt every hour or chosen interval to reflect on passing time.'**
  String
  get withYourPhoneAlwaysWithYouReceiveAMindfulChimeAndFullScreenReflectionPromptEveryHourOrChosenIntervalToReflectOnPassingTime;

  /// No description provided for @woodenShovelToCreativeModeGod.
  ///
  /// In en, this message translates to:
  /// **'wooden shovel to creative mode god.'**
  String get woodenShovelToCreativeModeGod;

  /// No description provided for @yamchaToTheOmniKingZeno.
  ///
  /// In en, this message translates to:
  /// **'yamcha to the omni-king zeno.'**
  String get yamchaToTheOmniKingZeno;

  /// No description provided for @yokiToTheUltimateTruth.
  ///
  /// In en, this message translates to:
  /// **'yoki to the ultimate truth.'**
  String get yokiToTheUltimateTruth;

  /// No description provided for @youAreUpToDate.
  ///
  /// In en, this message translates to:
  /// **'you are up to date'**
  String get youAreUpToDate;

  /// No description provided for @yourCleanStreakIsActiveAndRunning.
  ///
  /// In en, this message translates to:
  /// **'your clean streak is active and running.'**
  String get yourCleanStreakIsActiveAndRunning;

  /// No description provided for @yourDataIs100percentPrivateAndStaysOfflineOnThisDeviceEnablingThisDoesNotAlterAnyExistingLogs.
  ///
  /// In en, this message translates to:
  /// **'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.'**
  String
  get yourDataIs100percentPrivateAndStaysOfflineOnThisDeviceEnablingThisDoesNotAlterAnyExistingLogs;

  /// No description provided for @yourHomeScreenWillShowALiveStreakCardWithMilestoneBadgesTheHomeWidgetWillAdaptToShowResetAndDiaryButtons.
  ///
  /// In en, this message translates to:
  /// **'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.'**
  String
  get yourHomeScreenWillShowALiveStreakCardWithMilestoneBadgesTheHomeWidgetWillAdaptToShowResetAndDiaryButtons;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In en, this message translates to:
  /// **'your privacy matters'**
  String get yourPrivacyMatters;

  /// No description provided for @zeroTelemetryAndOfflineIntegrity.
  ///
  /// In en, this message translates to:
  /// **'zero telemetry & offline integrity'**
  String get zeroTelemetryAndOfflineIntegrity;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get currencySymbol;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get currencyCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
