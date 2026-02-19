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
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant AI'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myGarden.
  ///
  /// In en, this message translates to:
  /// **'My Garden'**
  String get myGarden;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @identifyYourPlant.
  ///
  /// In en, this message translates to:
  /// **'Identify Your\nPlant'**
  String get identifyYourPlant;

  /// No description provided for @scanToIdentify.
  ///
  /// In en, this message translates to:
  /// **'Scan to identify species and\nget care recommendations'**
  String get scanToIdentify;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @scanAPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan a Plant'**
  String get scanAPlant;

  /// No description provided for @yourTasksForToday.
  ///
  /// In en, this message translates to:
  /// **'Your tasks for today'**
  String get yourTasksForToday;

  /// No description provided for @noPlantsInGardenYet.
  ///
  /// In en, this message translates to:
  /// **'No plants in your garden yet'**
  String get noPlantsInGardenYet;

  /// No description provided for @scanPlantToAdd.
  ///
  /// In en, this message translates to:
  /// **'Scan a plant to add it to your garden'**
  String get scanPlantToAdd;

  /// No description provided for @careGuide.
  ///
  /// In en, this message translates to:
  /// **'Care guide'**
  String get careGuide;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @watering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get watering;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @myGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Garden'**
  String get myGardenTitle;

  /// No description provided for @startYourPlantCollection.
  ///
  /// In en, this message translates to:
  /// **'Start your plant collection'**
  String get startYourPlantCollection;

  /// No description provided for @searchPlants.
  ///
  /// In en, this message translates to:
  /// **'Search plants...'**
  String get searchPlants;

  /// No description provided for @indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get indoor;

  /// No description provided for @outdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get outdoor;

  /// No description provided for @plants.
  ///
  /// In en, this message translates to:
  /// **'{count} plants'**
  String plants(int count);

  /// No description provided for @yourGardenAwaits.
  ///
  /// In en, this message translates to:
  /// **'Your garden awaits'**
  String get yourGardenAwaits;

  /// No description provided for @scanFirstPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan your first plant to start building\nyour personal plant collection'**
  String get scanFirstPlant;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @plant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plant;

  /// No description provided for @selectPlant.
  ///
  /// In en, this message translates to:
  /// **'Select plant'**
  String get selectPlant;

  /// No description provided for @remindMeAbout.
  ///
  /// In en, this message translates to:
  /// **'Remind me about'**
  String get remindMeAbout;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get setReminder;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @fertilizing.
  ///
  /// In en, this message translates to:
  /// **'Fertilizing'**
  String get fertilizing;

  /// No description provided for @noRemindersForDay.
  ///
  /// In en, this message translates to:
  /// **'No reminders for this day'**
  String get noRemindersForDay;

  /// No description provided for @tapAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add reminder\" to create one'**
  String get tapAddReminder;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String tasks(int count);

  /// No description provided for @searchReminders.
  ///
  /// In en, this message translates to:
  /// **'Search Reminders'**
  String get searchReminders;

  /// No description provided for @enterPlantName.
  ///
  /// In en, this message translates to:
  /// **'Enter plant name...'**
  String get enterPlantName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @upgradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Identify variety of plants and diagnose plants status'**
  String get upgradeDescription;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade now'**
  String get upgradeNow;

  /// No description provided for @manageGarden.
  ///
  /// In en, this message translates to:
  /// **'Manage garden'**
  String get manageGarden;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @reminderNotification.
  ///
  /// In en, this message translates to:
  /// **'Reminder Notification'**
  String get reminderNotification;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @plantIdentification.
  ///
  /// In en, this message translates to:
  /// **'Plant Identification'**
  String get plantIdentification;

  /// No description provided for @analyzingPlant.
  ///
  /// In en, this message translates to:
  /// **'Analyzing plant...'**
  String get analyzingPlant;

  /// No description provided for @poweredByGemini.
  ///
  /// In en, this message translates to:
  /// **'Powered by Gemini 2.5 Flash'**
  String get poweredByGemini;

  /// No description provided for @possibleMatches.
  ///
  /// In en, this message translates to:
  /// **'{count} Possible Matches'**
  String possibleMatches(int count);

  /// No description provided for @noPlantsIdentified.
  ///
  /// In en, this message translates to:
  /// **'No plants identified'**
  String get noPlantsIdentified;

  /// No description provided for @tryClearerPhoto.
  ///
  /// In en, this message translates to:
  /// **'Try taking a clearer photo'**
  String get tryClearerPhoto;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @bestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get bestMatch;

  /// No description provided for @addToGarden.
  ///
  /// In en, this message translates to:
  /// **'Add to Garden'**
  String get addToGarden;

  /// No description provided for @plantAddedToGarden.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your garden!'**
  String plantAddedToGarden(String name);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @alreadyInGarden.
  ///
  /// In en, this message translates to:
  /// **'This plant is already in your garden!'**
  String get alreadyInGarden;

  /// No description provided for @fetchingCareInfo.
  ///
  /// In en, this message translates to:
  /// **'Fetching care info...'**
  String get fetchingCareInfo;

  /// No description provided for @diagnosisReport.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Report'**
  String get diagnosisReport;

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get healthStatus;

  /// No description provided for @identifiedIssues.
  ///
  /// In en, this message translates to:
  /// **'Identified Issues'**
  String get identifiedIssues;

  /// No description provided for @careSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Care Suggestions'**
  String get careSuggestions;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved.'**
  String get allRightsReserved;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noPlantsFound.
  ///
  /// In en, this message translates to:
  /// **'No plants found'**
  String get noPlantsFound;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites!'**
  String get addedToFavorites;

  /// No description provided for @proTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips'**
  String get proTips;

  /// No description provided for @quickTips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get quickTips;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @careInstructions.
  ///
  /// In en, this message translates to:
  /// **'Care Instructions'**
  String get careInstructions;
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
      'that was used.');
}
