/// Per-app branding and backend identity. Add a new entry here for each flavor.
class FlavorValues {
  const FlavorValues({
    required this.appTitle,
    required this.backendAppPackage,
    required this.logoAsset,
    required this.supportTelegramHandle,
    required this.supportTelegramUrl,
    required this.supportPhoneNumber,
    required this.supportEmail,
  });

  final String appTitle;
  final String backendAppPackage;
  final String logoAsset;
  final String supportTelegramHandle;
  final String supportTelegramUrl;
  final String supportPhoneNumber;
  final String supportEmail;
}

const _flavorName = String.fromEnvironment(
  'FLAVOR',
  defaultValue: 'vector_academy',
);

const _flavors = <String, FlavorValues>{
  'vector_academy': FlavorValues(
    appTitle: 'Entrance Tricks',
    backendAppPackage: 'com.vector_academy.app',
    logoAsset: 'assets/images/logo.png',
    supportTelegramHandle: '@entrance_tricks_admin',
    supportTelegramUrl: 'https://t.me/entrance_tricks_admin',
    supportPhoneNumber: '0920308061',
    supportEmail: 'entrancetricks@gmail.com',
  ),
  'exitexam': FlavorValues(
    appTitle: 'Ethio Exit Exam',
    backendAppPackage: 'com.ethioexitexam.app',
    logoAsset: 'assets/images/logo_exitexam.png',
    supportTelegramHandle: '@Ethio_ExitExam',
    supportTelegramUrl: 'https://t.me/Ethio_ExitExam',
    supportPhoneNumber: '0994311719',
    supportEmail: 'Ethioexitexamhub@gmail.com',
  ),
  'remedial': FlavorValues(
    appTitle: 'Remedial Tricks',
    backendAppPackage: 'com.remedial_tricks.app',
    logoAsset: 'assets/images/logo_remedial.png',
    supportTelegramHandle: '@remedial_tricks',
    supportTelegramUrl: 'https://t.me/remedial_tricks_admin',
    supportPhoneNumber: '0927052140',
    supportEmail: 'remedialtricks@gmail.com',
  ),
  'ministry': FlavorValues(
    appTitle: 'Ministry Tricks',
    backendAppPackage: 'com.ministry_tricks.app',
    logoAsset: 'assets/images/logo_ministry.png',
    supportTelegramHandle: '@Ministry_tricks',
    supportTelegramUrl: 'https://t.me/Ministry_tricks',
    supportPhoneNumber: '0950478932',
    supportEmail: 'Ministrytricks@gmail.com',
  ),
};

/// Active flavor configuration for the current build.
class FlavorConfig {
  FlavorConfig._();

  static final FlavorValues current =
      _flavors[_flavorName] ?? _flavors['vector_academy']!;

  static String get flavorName => _flavorName;

  static String get appTitle => current.appTitle;

  static String get backendAppPackage => current.backendAppPackage;

  static String get logoAsset => current.logoAsset;

  static String get supportTelegramHandle => current.supportTelegramHandle;

  static String get supportTelegramUrl => current.supportTelegramUrl;

  static String get supportPhoneNumber => current.supportPhoneNumber;

  static String get supportEmail => current.supportEmail;

  static const _parentModeFlavors = {'vector_academy', 'ministry'};
  static const _parentModePackages = {
    'com.vector_academy.app',
    'com.ministry_tricks.app',
  };

  /// Entrance today, and Ministry once that flavor uses its backend package.
  static bool get supportsParentMode =>
      _parentModeFlavors.contains(flavorName) ||
      _parentModePackages.contains(backendAppPackage);
}
