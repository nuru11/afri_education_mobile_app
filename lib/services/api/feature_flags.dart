import 'package:vector_academy/services/api/api.dart';
import 'package:vector_academy/utils/constants/constants.dart';

class FeatureFlagsService {
  final ApiClient _apiClient = ApiClient();

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
