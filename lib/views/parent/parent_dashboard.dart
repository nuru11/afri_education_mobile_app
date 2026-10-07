import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/components/ui/themes/light_theme.dart';
import 'package:vector_academy/controllers/parent/parent_mode_controller.dart';
import 'package:vector_academy/utils/auth_guard.dart';
import 'package:vector_academy/utils/snackbar_utils.dart'
    hide errorColor, infoColor, primaryColor, successColor, warningColor;
import 'package:vector_academy/views/parent/parent_dashboard_visuals.dart';
import 'package:vector_academy/views/parent/parent_request_sheet.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParentModeController>(
      builder: (controller) {
        final overview = controller.overview;
        final childName =
            overview?.status.displayName ??
            controller.link?.childName ??
            'your child';
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black87,
            title: Text(
              childName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: controller.loading
                    ? null
                    : controller.refreshOverview,
                icon: const Icon(Icons.refresh),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'leave') {
                    await controller.leaveParentMode();
                    maybePromptParentRequests(force: true);
                  } else if (value == 'unlink') {
                    await _confirmUnlink(context, controller);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'leave',
                    child: Text('Leave Parent Mode'),
                  ),
                  PopupMenuItem(value: 'unlink', child: Text('Unlink child')),
                ],
              ),
            ],
          ),
          body: controller.loading && overview == null
              ? const Center(child: CircularProgressIndicator())
              : overview == null
              ? _OverviewMessage(
                  message:
                      controller.error ?? 'Learning overview is unavailable.',
                  onRetry: controller.refreshOverview,
                )
              : RefreshIndicator(
                  onRefresh: controller.refreshOverview,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _BuyForChildButton(
                        childName: childName,
                        onPressed: () {
                          final phone = controller.link?.childPhone ?? '';
                          if (phone.isEmpty) return;
                          openLockedGiftCheckout(phone);
                        },
                      ),
                      if (controller.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: errorColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.error!,
                              style: const TextStyle(color: errorColor),
                            ),
                          ),
                        ),
                      ParentHeroCard(status: overview.status),
                      const SizedBox(height: 16),
                      ParentSummaryGrid(overview: overview),
                      const SizedBox(height: 16),
                      ParentExamSection(results: overview.examResults),
                      ParentStudyPlansSection(
                        plans: overview.studyProgram.studyPlans,
                      ),
                      ParentReadingSection(
                        plans: overview.studyProgram.readingPlans,
                      ),
                      ParentPackagesSection(
                        packages: overview.studyProgram.packages,
                      ),
                      ParentActivitySection(activity: overview.activity),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _confirmUnlink(
    BuildContext context,
    ParentModeController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unlink child'),
        content: const Text(
          'This removes the link. You will need a new acceptance before you can view their progress again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.cancelOrUnlink();
    if (controller.error != null) {
      AppSnackbar.showError('Parent Mode', controller.error!);
    }
  }
}

class _BuyForChildButton extends StatelessWidget {
  const _BuyForChildButton({required this.childName, required this.onPressed});

  final String childName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text('Buy for $childName'),
        ),
      ),
    );
  }
}

class _OverviewMessage extends StatelessWidget {
  const _OverviewMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
