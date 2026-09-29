import 'package:get/get.dart';
import 'package:vector_academy/flavors/flavor_config.dart';
import 'package:vector_academy/models/parent_link.dart';
import 'package:vector_academy/services/api/exceptions.dart';
import 'package:vector_academy/services/api/parent_mode.dart';
import 'package:vector_academy/services/auth.dart';
import 'package:vector_academy/utils/storages/config.dart';

class ParentModeController extends GetxController {
  final ParentModeService _service = ParentModeService();

  bool loading = false;
  bool submitting = false;
  bool bootstrapped = false;
  bool modeEnabled = false;
  String? error;
  ParentLink? link;
  ParentOverview? overview;

  bool get showDashboardLoading =>
      FlavorConfig.supportsParentMode && modeEnabled && !bootstrapped;

  bool get showDashboard =>
      FlavorConfig.supportsParentMode &&
      modeEnabled &&
      bootstrapped &&
      link?.isAccepted == true;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthService>();
    _applyLocalFlag(auth.user.value?.id);
    ever(auth.user, (user) {
      _applyLocalFlag(user?.id);
      update();
      bootstrap();
    });
    bootstrap();
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
      if (modeEnabled && link?.isAccepted == true) {
        overview = await _service.overview(link!.id);
      } else if (modeEnabled) {
        modeEnabled = false;
        await ConfigPreference.setParentModeEnabled(user.id, false);
        overview = null;
      }
    } catch (e) {
      error = ApiErrorMessage.from(e);
    } finally {
      loading = false;
      bootstrapped = true;
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
      overview = null;
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
      await leaveParentMode(updateUi: false);
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
    modeEnabled = true;
    await ConfigPreference.setParentModeEnabled(user.id, true);
    loading = true;
    update();
    try {
      overview = await _service.overview(current.id);
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
    modeEnabled = false;
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
        overview = await _service.overview(link!.id);
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
