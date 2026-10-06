import 'package:vector_academy/utils/storages/storages.dart';
import 'package:vector_academy/utils/storages/app_header.dart';
import 'package:vector_academy/utils/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:vector_academy/services/auth.dart';
import 'package:vector_academy/services/core.dart';
import 'package:vector_academy/services/api/grades.dart';
import 'package:vector_academy/services/notification_service.dart'
    as local_notif;
import 'package:flutter_tex/flutter_tex.dart';
import 'package:vector_academy/controllers/parent/parent_mode_controller.dart';
import 'package:vector_academy/flavors/flavor_config.dart';

Future<void> initialize() async {
  await TeXRenderingServer.start();
  await Hive.initFlutter();
  await HiveChaptersStorage().init();
  await HiveSubjectsStorage().init();
  await HiveAuthStorage().init();
  await HiveUserStorage().init();
  await HiveDeviceStorage().init();
  await HiveExamStorage().init();
  await HiveQuizzesStorage().init();
  await HiveNoteStorage().init();
  await HiveVideoStorage().init();
  await HiveStudyPlanStorage().init();
  await HiveAppHeaderStorage().init();
  await HiveNewsStorage().init();
  await HiveLeaderboardCacheStorage().init();
  await HiveReadingPlanStorage().init();
  await Get.putAsync(() async {
    final auth = AuthService();
    await auth.loadUser();
    return auth;
  });
  Get.put(CoreService());
  Get.put(GradeService());

  await ConfigPreference.init();
  await _keepExistingParentOnParentHome();
  Get.put(ParentModeController());

  // Register notification service (permissions requested in-context from Study Planner)
  await local_notif.LocalNotificationService.initializePlugin();
  Get.put(local_notif.LocalNotificationService());

  logger.i('Initilizing The application');
}

/// Accounts that already turned Parent Mode on skip the first-launch choice.
Future<void> _keepExistingParentOnParentHome() async {
  if (!FlavorConfig.supportsParentMode) return;
  if (ConfigPreference.getAppAudience() != null) return;
  final userId = Get.find<AuthService>().user.value?.id;
  if (userId == null || !ConfigPreference.isParentModeEnabled(userId)) return;
  await ConfigPreference.setAppAudience(AppAudience.parent);
}
