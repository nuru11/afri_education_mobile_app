import 'package:vector_academy/models/parent_link.dart';
import 'package:vector_academy/models/user.dart';
import 'package:vector_academy/services/api/api.dart';
import 'package:vector_academy/services/api/exceptions.dart';

class GuestParentLinkResult {
  const GuestParentLinkResult({
    required this.link,
    required this.auth,
  });

  final ParentLink link;
  final AuthResponse auth;
}

class ParentModeService {
  final ApiClient apiClient = ApiClient();

  Future<ParentLink?> currentLink() async {
    final response = await apiClient.get(
      '/app/parent-links/',
      authenticated: true,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data['link'] is Map) {
        return ParentLink.fromJson(
          Map<String, dynamic>.from(data['link'] as Map),
        );
      }
      return null;
    }
    throw ApiException(
      ApiErrorMessage.fromData(response.data) ?? 'Failed to load Parent Mode',
    );
  }

  Future<GuestParentLinkResult> guestRequest({
    required String childPhone,
    required String parentName,
    required String parentPhone,
    required String deviceId,
    required String appPackage,
  }) async {
    final response = await apiClient.post(
      '/app/parent-links/guest-request/',
      data: {
        'child_phone': childPhone,
        'parent_name': parentName,
        'parent_phone': parentPhone,
        'device_id': deviceId,
        'app_package': appPackage,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = Map<String, dynamic>.from(response.data as Map);
      return GuestParentLinkResult(
        link: ParentLink.fromJson(Map<String, dynamic>.from(data['link'] as Map)),
        auth: AuthResponse.fromJson({
          'user': data['user'],
          'tokens': data['tokens'],
        }),
      );
    }
    throw ApiException(
      ApiErrorMessage.fromData(response.data) ?? 'Failed to send the request',
    );
  }

  Future<ParentLink> requestLink(String phoneNumber) async {
    final response = await apiClient.post(
      '/app/parent-links/request/',
      data: {'phone_number': phoneNumber},
      authenticated: true,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ParentLink.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }
    throw ApiException(
      ApiErrorMessage.fromData(response.data) ?? 'Failed to send the request',
    );
  }

  Future<void> revokeLink(int linkId) async {
    final response = await apiClient.delete(
      '/app/parent-links/$linkId/',
      authenticated: true,
    );
    if (response.statusCode == 204 || response.statusCode == 200) return;
    throw ApiException(
      ApiErrorMessage.fromData(response.data) ?? 'Failed to update the link',
    );
  }

  Future<List<ParentLink>> incoming() async {
    final response = await apiClient.get(
      '/app/parent-links/incoming/',
      authenticated: true,
    );
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .whereType<Map>()
          .map((item) => ParentLink.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    throw ApiException(
      ApiErrorMessage.fromData(response.data) ?? 'Failed to load requests',
    );
  }

  Future<ParentLink> respond(int linkId, {required bool accept}) async {
    final action = accept ? 'accept' : 'reject';
    final response = await apiClient.post(
      '/app/parent-links/$linkId/$action/',
      authenticated: true,
    );
    if (response.statusCode == 200) {
      return ParentLink.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }
    throw ApiException(
      ApiErrorMessage.fromData(response.data) ?? 'Failed to respond',
    );
  }

  Future<ParentOverview> overview(int linkId, {required String deviceId}) async {
    final response = await apiClient.get(
      '/app/parent-links/$linkId/overview/',
      queryParameters: {'device_id': deviceId},
      authenticated: true,
    );
    if (response.statusCode == 200) {
      return ParentOverview.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }
    throw ApiException(
      ApiErrorMessage.fromData(response.data) ??
          'Failed to load learning overview',
    );
  }
}
