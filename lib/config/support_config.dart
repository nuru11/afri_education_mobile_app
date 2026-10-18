import 'package:vector_academy/flavors/flavor_config.dart';

String get supportTelegramHandle => FlavorConfig.supportTelegramHandle;
String get supportTelegramUrl => FlavorConfig.supportTelegramUrl;
String get supportPhoneNumber => FlavorConfig.supportPhoneNumber;
String get supportPhoneUrl => 'tel:$supportPhoneNumber';
String get supportEmail => FlavorConfig.supportEmail;
String get supportEmailUrl {
  final subject = Uri.encodeComponent('${FlavorConfig.appTitle} Support');
  return 'mailto:$supportEmail?subject=$subject';
}
const supportWebsiteHost = 'entrancetricks.com';
const supportWebsiteUrl = 'https://entrancetricks.com';
