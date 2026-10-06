import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/parent/parent_mode_controller.dart';
import 'package:vector_academy/models/parent_link.dart';
import 'package:vector_academy/utils/auth_guard.dart';
import 'package:vector_academy/utils/snackbar_utils.dart';
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
                          child: Text(
                            controller.error!,
                            style: const TextStyle(color: Color(0xFFEF4444)),
                          ),
                        ),
                      _Section(
                        title: 'Account status',
                        child: _StatusSection(status: overview.status),
                      ),
                      _Section(
                        title: 'Study program',
                        child: _ProgramSection(program: overview.studyProgram),
                      ),
                      _Section(
                        title: 'Exam results',
                        child: _ResultsSection(results: overview.examResults),
                      ),
                      _Section(
                        title: 'Learning and exam activity',
                        child: _ActivitySection(activity: overview.activity),
                      ),
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
  const _BuyForChildButton({
    required this.childName,
    required this.onPressed,
  });

  final String childName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: child,
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.status});

  final ParentChildStatus status;

  @override
  Widget build(BuildContext context) {
    final packages = status.activePackages.isEmpty
        ? 'No active package'
        : status.activePackages.join(', ');
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line('Name', status.displayName),
          _line('Grade', status.gradeName ?? 'Not set'),
          _line('Learning status', status.learningLabel),
          _line('Packages', packages),
          _line('Member since', _formatDay(status.memberSince)),
        ],
      ),
    );
  }
}

class _ProgramSection extends StatelessWidget {
  const _ProgramSection({required this.program});

  final ParentStudyProgram program;

  @override
  Widget build(BuildContext context) {
    if (program.packages.isEmpty &&
        program.studyPlans.isEmpty &&
        program.readingPlans.isEmpty) {
      return const _Card(child: Text('No study program yet.'));
    }
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (program.packages.isNotEmpty) ...[
            const Text(
              'Packages',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final package in program.packages)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${package.name} · ${package.durationDays} days · bought ${_formatDay(package.purchasedAt)}',
                ),
              ),
          ],
          if (program.studyPlans.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Study plans',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final plan in program.studyPlans)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${plan.title}${plan.subject == null || plan.subject!.isEmpty ? '' : ' · ${plan.subject}'} · ${plan.isCompleted ? 'Completed' : 'In progress'} · ${plan.completedDates.length} days done',
                ),
              ),
          ],
          if (program.readingPlans.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Reading plans',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final plan in program.readingPlans)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${plan.title} · ${plan.isRead ? 'Read' : 'Not read'}',
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({required this.results});

  final List<ParentExamResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const _Card(child: Text('No exam results yet.'));
    }
    return _Card(
      child: Column(
        children: [
          for (final result in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.examName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          [
                            if (result.subjectName != null) result.subjectName!,
                            if (result.competitionName != null)
                              result.competitionName!,
                            result.kind == 'competition'
                                ? 'Competition'
                                : 'Practice',
                            _formatDay(result.attemptedAt),
                          ].join(' · '),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${result.correct}/${result.total}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.activity});

  final List<ParentActivity> activity;

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return const _Card(child: Text('No recent activity yet.'));
    }
    return _Card(
      child: Column(
        children: [
          for (final item in activity)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _activityIcon(item.kind),
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item.detail} · ${_formatWhen(item.occurredAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _line(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

IconData _activityIcon(String kind) {
  switch (kind) {
    case 'exam':
      return Icons.quiz_outlined;
    case 'study_plan':
      return Icons.event_note_outlined;
    case 'reading':
      return Icons.menu_book_outlined;
    default:
      return Icons.history;
  }
}

String _formatDay(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _formatWhen(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDay(local)} $hour:$minute';
}
