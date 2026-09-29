class ParentLink {
  final int id;
  final String status;
  final String parentName;
  final String parentPhone;
  final String childName;
  final String childPhone;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  const ParentLink({
    required this.id,
    required this.status,
    required this.parentName,
    required this.parentPhone,
    required this.childName,
    required this.childPhone,
    this.createdAt,
    this.respondedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  factory ParentLink.fromJson(Map<String, dynamic> json) {
    return ParentLink(
      id: json['id'] as int,
      status: json['status'] as String? ?? '',
      parentName: json['parent_name'] as String? ?? '',
      parentPhone: json['parent_phone'] as String? ?? '',
      childName: json['child_name'] as String? ?? '',
      childPhone: json['child_phone'] as String? ?? '',
      createdAt: _parseDate(json['created_at']),
      respondedAt: _parseDate(json['responded_at']),
    );
  }
}

class ParentOverview {
  final int linkId;
  final ParentChildStatus status;
  final ParentStudyProgram studyProgram;
  final List<ParentExamResult> examResults;
  final List<ParentActivity> activity;

  const ParentOverview({
    required this.linkId,
    required this.status,
    required this.studyProgram,
    required this.examResults,
    required this.activity,
  });

  factory ParentOverview.fromJson(Map<String, dynamic> json) {
    final results = json['exam_results'];
    final events = json['activity'];
    return ParentOverview(
      linkId: json['link_id'] as int,
      status: ParentChildStatus.fromJson(
        Map<String, dynamic>.from(json['status'] as Map),
      ),
      studyProgram: ParentStudyProgram.fromJson(
        Map<String, dynamic>.from(json['study_program'] as Map),
      ),
      examResults: results is List
          ? results
                .map(
                  (item) => ParentExamResult.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      activity: events is List
          ? events
                .map(
                  (item) => ParentActivity.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class ParentChildStatus {
  final String firstName;
  final String lastName;
  final String? gradeName;
  final bool isPremium;
  final bool hasFullAccess;
  final DateTime? memberSince;
  final List<String> activePackages;

  const ParentChildStatus({
    required this.firstName,
    required this.lastName,
    required this.gradeName,
    required this.isPremium,
    required this.hasFullAccess,
    required this.memberSince,
    required this.activePackages,
  });

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Student' : name;
  }

  String get learningLabel {
    if (hasFullAccess) return 'Full access';
    if (isPremium) return 'Premium';
    return 'Free';
  }

  factory ParentChildStatus.fromJson(Map<String, dynamic> json) {
    final packages = json['active_packages'];
    return ParentChildStatus(
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      gradeName: json['grade_name'] as String?,
      isPremium: json['is_premium'] == true,
      hasFullAccess: json['has_full_access'] == true,
      memberSince: _parseDate(json['member_since']),
      activePackages: packages is List
          ? packages.map((item) => item.toString()).toList()
          : const [],
    );
  }
}

class ParentStudyProgram {
  final List<ParentPackage> packages;
  final List<ParentStudyPlanSummary> studyPlans;
  final List<ParentReadingPlanSummary> readingPlans;

  const ParentStudyProgram({
    required this.packages,
    required this.studyPlans,
    required this.readingPlans,
  });

  factory ParentStudyProgram.fromJson(Map<String, dynamic> json) {
    final packages = json['packages'];
    final plans = json['study_plans'];
    final reading = json['reading_plans'];
    return ParentStudyProgram(
      packages: packages is List
          ? packages
                .map(
                  (item) => ParentPackage.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      studyPlans: plans is List
          ? plans
                .map(
                  (item) => ParentStudyPlanSummary.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      readingPlans: reading is List
          ? reading
                .map(
                  (item) => ParentReadingPlanSummary.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class ParentPackage {
  final String name;
  final int durationDays;
  final DateTime? purchasedAt;
  final bool includesPlanner;

  const ParentPackage({
    required this.name,
    required this.durationDays,
    required this.purchasedAt,
    required this.includesPlanner,
  });

  factory ParentPackage.fromJson(Map<String, dynamic> json) {
    return ParentPackage(
      name: json['name'] as String? ?? '',
      durationDays: json['duration_days'] as int? ?? 0,
      purchasedAt: _parseDate(json['purchased_at']),
      includesPlanner: json['includes_planner'] == true,
    );
  }
}

class ParentStudyPlanSummary {
  final String title;
  final String? subject;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final bool isCompleted;
  final List<String> completedDates;

  const ParentStudyPlanSummary({
    required this.title,
    required this.subject,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.isCompleted,
    required this.completedDates,
  });

  factory ParentStudyPlanSummary.fromJson(Map<String, dynamic> json) {
    final dates = json['completed_dates'];
    return ParentStudyPlanSummary(
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String?,
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      dueDate: _parseDate(json['due_date']),
      isCompleted: json['is_completed'] == true,
      completedDates: dates is List
          ? dates.map((item) => item.toString()).toList()
          : const [],
    );
  }
}

class ParentReadingPlanSummary {
  final String title;
  final bool isRead;
  final DateTime? openedAt;

  const ParentReadingPlanSummary({
    required this.title,
    required this.isRead,
    required this.openedAt,
  });

  factory ParentReadingPlanSummary.fromJson(Map<String, dynamic> json) {
    return ParentReadingPlanSummary(
      title: json['title'] as String? ?? '',
      isRead: json['is_read'] == true,
      openedAt: _parseDate(json['opened_at']),
    );
  }
}

class ParentExamResult {
  final String kind;
  final int examId;
  final String examName;
  final String? subjectName;
  final String? competitionName;
  final int correct;
  final int total;
  final int score;
  final DateTime? attemptedAt;

  const ParentExamResult({
    required this.kind,
    required this.examId,
    required this.examName,
    required this.subjectName,
    required this.competitionName,
    required this.correct,
    required this.total,
    required this.score,
    required this.attemptedAt,
  });

  factory ParentExamResult.fromJson(Map<String, dynamic> json) {
    return ParentExamResult(
      kind: json['kind'] as String? ?? 'practice',
      examId: json['exam_id'] as int? ?? 0,
      examName: json['exam_name'] as String? ?? '',
      subjectName: json['subject_name'] as String?,
      competitionName: json['competition_name'] as String?,
      correct: json['correct'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      attemptedAt: _parseDate(json['attempted_at']),
    );
  }
}

class ParentActivity {
  final String kind;
  final String title;
  final String detail;
  final DateTime? occurredAt;

  const ParentActivity({
    required this.kind,
    required this.title,
    required this.detail,
    required this.occurredAt,
  });

  factory ParentActivity.fromJson(Map<String, dynamic> json) {
    return ParentActivity(
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      occurredAt: _parseDate(json['occurred_at']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
