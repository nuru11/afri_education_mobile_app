import 'package:flutter/material.dart';
import 'package:vector_academy/components/ui/themes/light_theme.dart';
import 'package:vector_academy/models/parent_link.dart';

class ParentHeroCard extends StatelessWidget {
  const ParentHeroCard({super.key, required this.status});

  final ParentChildStatus status;

  @override
  Widget build(BuildContext context) {
    final chipColor = _accessColor(status);
    final name = status.displayName.trim();
    final initial = name.isEmpty
        ? 'S'
        : String.fromCharCode(name.runes.first).toUpperCase();
    final packages = status.activePackages.isEmpty
        ? 'No active package'
        : status.activePackages.join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryVariant],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grade ${status.gradeName ?? 'not set'} · Member since ${_formatDay(status.memberSince)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.learningLabel,
                  style: TextStyle(
                    color: chipColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            packages,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ParentSummaryGrid extends StatelessWidget {
  const ParentSummaryGrid({super.key, required this.overview});

  final ParentOverview overview;

  @override
  Widget build(BuildContext context) {
    final results = overview.examResults;
    final plans = overview.studyProgram.studyPlans;
    final reading = overview.studyProgram.readingPlans;
    final plansDone = plans.where((plan) => plan.isCompleted).length;
    final readingDone = reading.where((plan) => plan.isRead).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.insights_rounded,
                color: primaryColor,
                value: _averageLabel(results),
                label: 'Average score',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.quiz_rounded,
                color: infoColor,
                value: '${results.length}',
                label: 'Exams taken',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.event_note_rounded,
                color: successColor,
                value: plans.isEmpty ? '—' : '$plansDone/${plans.length}',
                label: 'Study plans',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.menu_book_rounded,
                color: warningColor,
                value: reading.isEmpty ? '—' : '$readingDone/${reading.length}',
                label: 'Reading',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ParentExamSection extends StatelessWidget {
  const ParentExamSection({super.key, required this.results});

  final List<ParentExamResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const _Section(
        title: 'Recent exams',
        child: _EmptyNote(message: 'No exam results yet.'),
      );
    }

    final chart = _latestForChart(results);
    final listed = [...results]..sort(_newestFirst);
    final subjects = _subjectScores(results);

    return Column(
      children: [
        _Section(
          title: 'Recent exams',
          child: _Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chart.length == results.length
                      ? 'Score on each exam'
                      : 'Latest ${chart.length} exams',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 156,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final result in chart)
                        Expanded(child: _ExamBar(result: result)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < listed.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _ExamRow(result: listed[i]),
                ],
              ],
            ),
          ),
        ),
        _Section(
          title: 'By subject',
          child: _Surface(
            child: Column(
              children: [
                for (var i = 0; i < subjects.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _SubjectBar(score: subjects[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ParentStudyPlansSection extends StatelessWidget {
  const ParentStudyPlansSection({super.key, required this.plans});

  final List<ParentStudyPlanSummary> plans;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const _Section(
        title: 'Study plans',
        child: _EmptyNote(message: 'No study plans yet.'),
      );
    }

    return _Section(
      title: 'Study plans',
      child: _Surface(
        child: Column(
          children: [
            for (var i = 0; i < plans.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _StudyPlanRow(plan: plans[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class ParentReadingSection extends StatelessWidget {
  const ParentReadingSection({super.key, required this.plans});

  final List<ParentReadingPlanSummary> plans;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const _Section(
        title: 'Reading',
        child: _EmptyNote(message: 'No reading plans yet.'),
      );
    }

    final read = plans.where((plan) => plan.isRead).length;
    final progress = plans.isEmpty ? 0.0 : read / plans.length;

    return _Section(
      title: 'Reading',
      child: _Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$read of ${plans.length} read',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: successColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ProgressBar(value: progress, color: successColor),
            const SizedBox(height: 14),
            for (var i = 0; i < plans.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ReadingRow(plan: plans[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class ParentPackagesSection extends StatelessWidget {
  const ParentPackagesSection({super.key, required this.packages});

  final List<ParentPackage> packages;

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return const _Section(
        title: 'Packages',
        child: _EmptyNote(message: 'No packages yet.'),
      );
    }

    return _Section(
      title: 'Packages',
      child: _Surface(
        child: Column(
          children: [
            for (var i = 0; i < packages.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _PackageRow(package: packages[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class ParentActivitySection extends StatelessWidget {
  const ParentActivitySection({super.key, required this.activity});

  final List<ParentActivity> activity;

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return const _Section(
        title: 'Activity',
        bottom: 0,
        child: _EmptyNote(message: 'No recent activity yet.'),
      );
    }

    return _Section(
      title: 'Activity',
      bottom: 0,
      child: _Surface(
        child: Column(
          children: [
            for (var i = 0; i < activity.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              _ActivityRow(item: activity[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final valueColor = value == '—' ? onSurfaceVariant : color;
    return _Surface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamBar extends StatelessWidget {
  const _ExamBar({required this.result});

  final ParentExamResult result;

  @override
  Widget build(BuildContext context) {
    final percent = _examPercent(result);
    final color = _scoreColor(percent);
    final barHeight = 100 * (percent / 100).clamp(0.06, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${percent.round()}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: barHeight,
            width: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatShortDay(result.attemptedAt),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  const _ExamRow({required this.result});

  final ParentExamResult result;

  @override
  Widget build(BuildContext context) {
    final percent = _examPercent(result);
    final color = _scoreColor(percent);
    final kind = result.kind == 'competition' ? 'Competition' : 'Practice';
    final detail = [
      if (result.subjectName != null && result.subjectName!.isNotEmpty)
        result.subjectName!,
      if (result.competitionName != null && result.competitionName!.isNotEmpty)
        result.competitionName!,
      kind,
      _formatDay(result.attemptedAt),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.examName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: onSurfaceVariant,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${result.correct}/${result.total}',
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ProgressBar(value: percent / 100, color: color),
      ],
    );
  }
}

class _SubjectBar extends StatelessWidget {
  const _SubjectBar({required this.score});

  final _SubjectScore score;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score.average);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                score.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${score.average.round()}%',
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ProgressBar(value: score.average / 100, color: color),
      ],
    );
  }
}

class _StudyPlanRow extends StatelessWidget {
  const _StudyPlanRow({required this.plan});

  final ParentStudyPlanSummary plan;

  @override
  Widget build(BuildContext context) {
    final color = _planColor(plan);
    final span = _planSpanDays(plan);
    final double? progress = span == null
        ? null
        : plan.isCompleted
        ? 1.0
        : (plan.completedDates.length / span).clamp(0.0, 1.0).toDouble();
    final subtitle = _planSubtitle(plan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                plan.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            _StatusChip(label: _planLabel(plan), color: color),
          ],
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: onSurfaceVariant, fontSize: 12),
          ),
        ],
        const SizedBox(height: 8),
        if (progress != null) ...[
          _ProgressBar(value: progress, color: color),
          const SizedBox(height: 6),
          Text(
            plan.isCompleted
                ? 'Completed'
                : '${plan.completedDates.length} of $span days',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ] else
          Text(
            '${plan.completedDates.length} days done',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
      ],
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.plan});

  final ParentReadingPlanSummary plan;

  @override
  Widget build(BuildContext context) {
    final color = plan.isRead ? successColor : onSurfaceVariant;
    return Row(
      children: [
        Icon(
          plan.isRead ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            plan.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (plan.openedAt != null)
          Text(
            _formatDay(plan.openedAt),
            style: const TextStyle(fontSize: 12, color: onSurfaceVariant),
          ),
      ],
    );
  }
}

class _PackageRow extends StatelessWidget {
  const _PackageRow({required this.package});

  final ParentPackage package;

  @override
  Widget build(BuildContext context) {
    final time = _packageTime(package);
    final color = time == null
        ? primaryColor
        : time.ended
        ? onSurfaceVariant
        : time.remainingDays <= 7
        ? warningColor
        : successColor;
    final detail = <String>[
      if (package.purchasedAt != null)
        'Bought ${_formatDay(package.purchasedAt)}',
      if (package.includesPlanner) 'Includes planner',
      if (time == null && package.durationDays > 0)
        '${package.durationDays} days',
      if (time != null) time.label,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(package.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (detail.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(color: onSurfaceVariant, fontSize: 12),
          ),
        ],
        if (time != null) ...[
          const SizedBox(height: 8),
          _ProgressBar(value: time.used, color: color),
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ParentActivity item;

  @override
  Widget build(BuildContext context) {
    final color = _activityColor(item.kind);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_activityIcon(item.kind), size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (item.detail.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  style: const TextStyle(color: onSurfaceVariant, fontSize: 13),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                _formatWhen(item.occurredAt),
                style: const TextStyle(color: onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.bottom = 16});

  final String title;
  final Widget child;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
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

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Text(message, style: const TextStyle(color: onSurfaceVariant)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 8,
        color: color,
        backgroundColor: color.withValues(alpha: 0.15),
      ),
    );
  }
}

class _SubjectScore {
  _SubjectScore(this.name);

  final String name;
  double sum = 0;
  int count = 0;

  double get average => count == 0 ? 0 : sum / count;
}

class _PackageTime {
  const _PackageTime({
    required this.used,
    required this.remainingDays,
    required this.ended,
  });

  final double used;
  final int remainingDays;
  final bool ended;

  String get label {
    if (ended) return 'Ended';
    if (remainingDays == 1) return '1 day left';
    return '$remainingDays days left';
  }
}

Color _scoreColor(double percentage) {
  if (percentage >= 80) return successColor;
  if (percentage >= 50) return warningColor;
  return errorColor;
}

Color _accessColor(ParentChildStatus status) {
  if (status.hasFullAccess) return successColor;
  if (status.isPremium) return primaryColor;
  return onSurfaceVariant;
}

Color _planColor(ParentStudyPlanSummary plan) {
  if (plan.isCompleted) return successColor;
  if (_isOverdue(plan)) return warningColor;
  return primaryColor;
}

String _planLabel(ParentStudyPlanSummary plan) {
  if (plan.isCompleted) return 'Completed';
  if (_isOverdue(plan)) return 'Past due';
  return 'In progress';
}

bool _isOverdue(ParentStudyPlanSummary plan) {
  final due = plan.dueDate;
  if (plan.isCompleted || due == null) return false;
  final dueDay = DateTime(due.year, due.month, due.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.isAfter(dueDay);
}

int? _planSpanDays(ParentStudyPlanSummary plan) {
  final start = plan.startDate;
  final end = plan.endDate;
  if (start == null || end == null) return null;
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);
  final days = endDay.difference(startDay).inDays + 1;
  if (days <= 0) return null;
  return days;
}

String _planSubtitle(ParentStudyPlanSummary plan) {
  final parts = <String>[
    if (plan.subject != null && plan.subject!.trim().isNotEmpty)
      plan.subject!.trim(),
    if (plan.startDate != null && plan.endDate != null)
      '${_formatDay(plan.startDate)} – ${_formatDay(plan.endDate)}',
    if (plan.dueDate != null) 'Due ${_formatDay(plan.dueDate)}',
  ];
  return parts.join(' · ');
}

double _examPercent(ParentExamResult result) {
  if (result.total <= 0) return 0;
  return (result.correct / result.total * 100).clamp(0, 100);
}

String _averageLabel(List<ParentExamResult> results) {
  var correct = 0;
  var total = 0;
  for (final result in results) {
    correct += result.correct;
    total += result.total;
  }
  if (total <= 0) return '—';
  return '${(correct / total * 100).round()}%';
}

List<ParentExamResult> _latestForChart(List<ParentExamResult> results) {
  final sorted = [...results]..sort(_newestFirst);
  return sorted.take(8).toList().reversed.toList();
}

int _newestFirst(ParentExamResult a, ParentExamResult b) {
  final ad = a.attemptedAt;
  final bd = b.attemptedAt;
  if (ad == null && bd == null) return 0;
  if (ad == null) return 1;
  if (bd == null) return -1;
  return bd.compareTo(ad);
}

List<_SubjectScore> _subjectScores(List<ParentExamResult> results) {
  final grouped = <String, _SubjectScore>{};
  for (final result in results) {
    final raw = result.subjectName?.trim();
    final name = raw == null || raw.isEmpty ? 'General' : raw;
    final entry = grouped.putIfAbsent(name, () => _SubjectScore(name));
    entry.sum += _examPercent(result);
    entry.count += 1;
  }
  final scores = grouped.values.toList()
    ..sort((a, b) => b.average.compareTo(a.average));
  return scores;
}

_PackageTime? _packageTime(ParentPackage package) {
  final purchased = package.purchasedAt;
  if (purchased == null || package.durationDays <= 0) return null;
  final start = DateTime(purchased.year, purchased.month, purchased.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final elapsed = today.difference(start).inDays;
  final usedDays = elapsed.clamp(0, package.durationDays).toInt();
  final remaining = package.durationDays - usedDays;
  return _PackageTime(
    used: usedDays / package.durationDays,
    remainingDays: remaining,
    ended: remaining <= 0,
  );
}

Color _activityColor(String kind) {
  switch (kind) {
    case 'exam':
      return primaryColor;
    case 'study_plan':
      return successColor;
    case 'reading':
      return warningColor;
    default:
      return onSurfaceVariant;
  }
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

String _formatShortDay(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$month/$day';
}

String _formatWhen(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDay(local)} $hour:$minute';
}
