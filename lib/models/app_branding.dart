class AppBranding {
  final String appPackage;
  final String primaryColor;
  final String secondaryColor;
  final String headerBackgroundColor;
  final String backgroundColor;
  final String surfaceColor;

  AppBranding({
    required this.appPackage,
    required this.primaryColor,
    required this.secondaryColor,
    required this.headerBackgroundColor,
    required this.backgroundColor,
    required this.surfaceColor,
  });

  factory AppBranding.fromJson(Map<String, dynamic> json) {
    return AppBranding(
      appPackage: json['app_package'] as String? ?? '',
      primaryColor: json['primary_color'] as String? ?? '#6366F1',
      secondaryColor: json['secondary_color'] as String? ?? '#10B981',
      headerBackgroundColor:
          json['header_background_color'] as String? ?? '#FFFFFF',
      backgroundColor: json['background_color'] as String? ?? '#FFFFFF',
      surfaceColor: json['surface_color'] as String? ?? '#FAFAFA',
    );
  }
}
