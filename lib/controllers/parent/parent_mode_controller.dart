import 'package:get/get.dart';
import 'package:vector_academy/flavors/flavor_config.dart';
import 'package:vector_academy/models/parent_link.dart';
import 'package:vector_academy/services/api/exceptions.dart';
import 'package:vector_academy/services/api/parent_mode.dart';
import 'package:vector_academy/services/auth.dart';
import 'package:vector_academy/utils/device/device.dart';
import 'package:vector_academy/utils/storages/config.dart';

class ParentModeController extends GetxController {
  final ParentModeService _service = ParentModeService();

  bool loading = false;
  bool submitting = false;
  bool bootstrapped = false;
  bool modeEnabled = false;
  AppAudience? audience;
  String? error;
  ParentLink? link;
  ParentOverview? overview;

  bool get isParentAudience =>
      FlavorConfig.supportsParentMode && audience == AppAudience.parent;

  bool get showDashboardLoading =>
      FlavorConfig.supportsParentMode &&
      !bootstrapped &&
      (modeEnabled || isParentAudience);

  bool get showDashboard =>
      FlavorConfig.supportsParentMode &&
      bootstrapped &&
      link?.isAccepted == true &&
      (modeEnabled || isParentAudience);

  /// Parent-audience users stay on the link, waiting, or sign-in screen
  /// until the student accepts.
  bool get showParentShell => isParentAudience && !showDashboard;

  @override
  void onInit() {
    super.onInit();
    audience = ConfigPreference.getAppAudience();
    final auth = Get.find<AuthService>();
    _applyLocalFlag(auth.user.value?.id);
    ever(auth.user, (user) {
      _applyLocalFlag(user?.id);
      update();
      bootstrap();
    });
    bootstrap();
  }

  Future<void> chooseAudience(AppAudience value) async {
    audience = value;
    await ConfigPreference.setAppAudience(value);
    if (value == AppAudience.student) {
      modeEnabled = false;
      final user = Get.find<AuthService>().user.value;
      if (user != null) {
        await ConfigPreference.setParentModeEnabled(user.id, false);
      }
    }
    update();
    await bootstrap();
  }

  void _applyLocalFlag(int? userId) {
    if (!FlavorConfig.supportsParentMode || userId == null) {
      modeEnabled = false;
      return;
    }
    modeEnabled = ConfigPreference.isParentModeEnabled(userId);
  }

  Future<void> bootstrap() async {
    if (!FlavorConfig.supportsParentMode) {
      bootstrapped = true;
      update();
      return;
    }
    audience = ConfigPreference.getAppAudience();
    final user = Get.find<AuthService>().user.value;
    if (user == null) {
      link = null;
      overview = null;
      modeEnabled = false;
      bootstrapped = true;
      update();
      return;
    }

    loading = true;
    error = null;
    update();
    try {
      link = await _service.currentLink();
      final parentHome = audience == AppAudience.parent;
      if (link?.isAccepted == true && (modeEnabled || parentHome)) {
        modeEnabled = true;
        await ConfigPreference.setParentModeEnabled(user.id, true);
        if (!parentHome) {
          audience = AppAudience.parent;
          await ConfigPreference.setAppAudience(AppAudience.parent);
        }
        overview = await _overviewFor(link!.id);
      } else {
        overview = null;
        if (modeEnabled) {
          modeEnabled = false;
          await ConfigPreference.setParentModeEnabled(user.id, false);
        }
      }
    } catch (e) {
      error = ApiErrorMessage.from(e);
    } finally {
      loading = false;
      bootstrapped = true;
      update();
    }
  }

  Future<String> _parentDeviceId(String phone) async {
    final saved = ConfigPreference.getParentLinkDeviceId();
    if (saved != null) return saved;
    final device = await UserDevice.getDeviceInfo(phone);
    return device.id;
  }

  Future<ParentOverview> _overviewFor(int linkId) async {
    final phone = Get.find<AuthService>().user.value?.phoneNumber ?? '';
    final deviceId = await _parentDeviceId(phone);
    return _service.overview(linkId, deviceId: deviceId);
  }

  Future<bool> requestGuestLink({
    required String childPhone,
    required String parentName,
    required String parentPhone,
  }) async {
    final child = normalizeParentPhone(childPhone);
    final phone = normalizeParentPhone(parentPhone);
    final name = parentName.trim();
    if (!RegExp(r'^(7|9)\d{8}$').hasMatch(child) ||
        !RegExp(r'^(7|9)\d{8}$').hasMatch(phone)) {
      error = 'Enter a valid phone number.';
      update();
      return false;
    }
    if (name.isEmpty) {
      error = 'Enter your name.';
      update();
      return false;
    }
    if (child == phone) {
      error = 'Use a different phone number from your child.';
      update();
      return false;
    }
    submitting = true;
    error = null;
    update();
    try {
      final device = await UserDevice.getDeviceInfo(phone);
      await ConfigPreference.setParentLinkDeviceId(device.id);
      final result = await _service.guestRequest(
        childPhone: child,
        parentName: name,
        parentPhone: phone,
        deviceId: device.id,
        appPackage: FlavorConfig.backendAppPackage,
      );
      final auth = Get.find<AuthService>();
      await auth.saveAuthToken(result.auth.tokens);
      await auth.saveUser(result.auth.user);
      link = result.link;
      audience = AppAudience.parent;
      await ConfigPreference.setAppAudience(AppAudience.parent);
      if (link?.isAccepted == true) {
        modeEnabled = true;
        await ConfigPreference.setParentModeEnabled(result.auth.user.id, true);
        overview = await _overviewFor(link!.id);
      } else {
        overview = null;
      }
      return true;
    } catch (e) {
      error = ApiErrorMessage.from(e);
      return false;
    } finally {
      submitting = false;
      update();
    }
  }

  Future<bool> requestLink(String rawPhone) async {
    final phone = normalizeParentPhone(rawPhone);
    if (!RegExp(r'^(7|9)\d{8}$').hasMatch(phone)) {
      error = 'Enter a valid phone number.';
      update();
      return false;
    }
    submitting = true;
    error = null;
    update();
    try {
      link = await _service.requestLink(phone);
      if (link?.isAccepted == true) {
        final user = Get.find<AuthService>().user.value;
        modeEnabled = true;
        if (user != null) {
          await ConfigPreference.setParentModeEnabled(user.id, true);
        }
        overview = await _overviewFor(link!.id);
      } else {
        overview = null;
      }
      return true;
    } catch (e) {
      error = ApiErrorMessage.from(e);
      return false;
    } finally {
      submitting = false;
      update();
    }
  }

  Future<void> cancelOrUnlink() async {
    final current = link;
    if (current == null) return;
    submitting = true;
    error = null;
    update();
    try {
      await _service.revokeLink(current.id);
      link = null;
      overview = null;
      modeEnabled = false;
      final user = Get.find<AuthService>().user.value;
      if (user != null) {
        await ConfigPreference.setParentModeEnabled(user.id, false);
      }
    } catch (e) {
      error = ApiErrorMessage.from(e);
    } finally {
      submitting = false;
      update();
    }
  }

  Future<void> openDashboard() async {
    final user = Get.find<AuthService>().user.value;
    final current = link;
    if (user == null || current == null || !current.isAccepted) return;
    audience = AppAudience.parent;
    modeEnabled = true;
    await ConfigPreference.setAppAudience(AppAudience.parent);
    await ConfigPreference.setParentModeEnabled(user.id, true);
    loading = true;
    update();
    try {
      overview = await _overviewFor(current.id);
      error = null;
    } catch (e) {
      error = ApiErrorMessage.from(e);
    } finally {
      loading = false;
      update();
    }
    Get.until((route) => route.settings.name == '/home');
  }

  Future<void> leaveParentMode({bool updateUi = true}) async {
    final user = Get.find<AuthService>().user.value;
    audience = AppAudience.student;
    modeEnabled = false;
    await ConfigPreference.setAppAudience(AppAudience.student);
    if (user != null) {
      await ConfigPreference.setParentModeEnabled(user.id, false);
    }
    if (updateUi) update();
  }

  Future<void> refreshOverview() async {
    final current = link;
    if (current == null || !current.isAccepted) {
      await bootstrap();
      return;
    }
    loading = true;
    error = null;
    update();
    try {
      link = await _service.currentLink();
      if (link?.isAccepted == true) {
        overview = await _overviewFor(link!.id);
      } else {
        overview = null;
        await leaveParentMode(updateUi: false);
      }
    } catch (e) {
      error = ApiErrorMessage.from(e);
    } finally {
      loading = false;
      update();
    }
  }

  Future<List<ParentLink>> loadIncoming() => _service.incoming();

  Future<void> respondToRequest(int linkId, {required bool accept}) async {
    await _service.respond(linkId, accept: accept);
  }
}

String normalizeParentPhone(String raw) {
  var phone = raw.trim().replaceAll(' ', '').replaceAll('-', '');
  if (phone.startsWith('+251')) {
    phone = phone.substring(4);
  } else if (phone.startsWith('251') && phone.length == 12) {
    phone = phone.substring(3);
  } else if (phone.startsWith('0') && phone.length == 10) {
    phone = phone.substring(1);
  }
  return phone;
}
