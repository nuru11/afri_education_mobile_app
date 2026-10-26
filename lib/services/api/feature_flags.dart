import 'package:vector_academy/flavors/flavor_config.dart';
import 'package:vector_academy/services/api/api.dart';
import 'package:vector_academy/utils/constants/constants.dart';
import 'package:vector_academy/utils/storages/config.dart';

class FeatureFlagsService {
  final ApiClient _apiClient = ApiClient();

  /// Loads the admin parent-mode switch before the first route is chosen.
  /// A failed request keeps the last saved value. With no saved value, parent
  /// mode stays available on Entrance and Ministry.
  Future<void> loadParentMode(String appPackage) async {
    FlavorConfig.remoteParentModeEnabled =
        ConfigPreference.getCachedShowParentMode();
    try {
      final response = await _apiClient.get(
        '/app/feature-flags/',
        authenticated: false,
        queryParameters: {
          'app_package': appPackage,
          'platform': is_ios ? 'ios' : 'android',
        },
      );
      final data = response.data;
      if (response.statusCode == 200 &&
          data is Map &&
          data.containsKey('show_parent_mode')) {
        final show = data['show_parent_mode'] == true;
        FlavorConfig.remoteParentModeEnabled = show;
        await ConfigPreference.setCachedShowParentMode(show);
      }
    } catch (_) {}
  }

  /// Missing row, unknown package, and request failures all hide the button.
  /// Platform follows the compile-time [is_ios] switch, not the device OS.
  Future<bool> showAgentButton(String appPackage) async {
    try {
      final response = await _apiClient.get(
        '/app/feature-flags/',
        authenticated: false,
        queryParameters: {
          'app_package': appPackage,
          'platform': is_ios ? 'ios' : 'android',
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['show_agent_button'] == true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
