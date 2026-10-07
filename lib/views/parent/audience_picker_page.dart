import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/parent/parent_mode_controller.dart';
import 'package:vector_academy/flavors/flavor_config.dart';
import 'package:vector_academy/utils/auth_guard.dart';
import 'package:vector_academy/utils/storages/config.dart';

class AudiencePickerPage extends StatelessWidget {
  const AudiencePickerPage({super.key});

  Future<void> _choose(AppAudience audience) async {
    final parentMode = Get.find<ParentModeController>();
    await parentMode.chooseAudience(audience);
    goToStartupRoute();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(FlavorConfig.logoAsset, height: 96),
              const SizedBox(height: 28),
              Text(
                'Who is using ${FlavorConfig.appTitle}?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose once. You can switch later from your profile.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              _AudienceChoice(
                icon: Icons.school_outlined,
                title: 'Student',
                body: 'Study, take exams, and use your own account.',
                onTap: () => _choose(AppAudience.student),
              ),
              const SizedBox(height: 12),
              _AudienceChoice(
                icon: Icons.family_restroom,
                title: 'Parent',
                body:
                    'Link your child\'s phone, follow their exams and results, and buy courses for them.',
                onTap: () => _choose(AppAudience.parent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudienceChoice extends StatelessWidget {
  const _AudienceChoice({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(color: Colors.grey[700], height: 1.35),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}
