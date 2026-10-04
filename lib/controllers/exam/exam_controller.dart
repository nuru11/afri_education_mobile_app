import 'package:get/get.dart';
import 'package:vector_academy/views/exam/exam_detail_page.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/services.dart';
import 'package:vector_academy/utils/storages/storages.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vector_academy/utils/device/device.dart';
import 'package:vector_academy/utils/utils.dart';

class ExamBrowseGroup {
  final int? id;
  final String name;
  final int sortOrder;
  final int count;
  final String? thumbnail;
  final bool isLocked;

  const ExamBrowseGroup({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.count,
    this.thumbnail,
    this.isLocked = false,
  });
}

class ExamController extends GetxController {
  static const uncategorizedCategoryName = 'Uncategorized';
  static const generalSectionName = 'General';
  final ExamService _examService = ExamService();
  final HiveExamStorage _hiveExamStorage = HiveExamStorage();
  // Completion now handled within HiveExamStorage
  final InternetConnection _internetConnection = InternetConnection();
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _isOffline = false;
  bool get isOffline => _isOffline;
  User? _user;
  bool get hasFullAccessOverride =>
      hasFullAccessOverrideForPhone(_user?.phoneNumber);
  final Subject _allPlaceholderSubject = Subject(
    id: 0,
    name: 'All',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  List<Exam> _exams = [];
  List<Exam> get exams => _exams;
  List<ExamCategoryBrowse> _categories = [];
  bool _categoriesFromApi = false;
  Set<int> _completedExamIds = {};
  Set<int> get completedExamIds => _completedExamIds;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  int _selectedSubjectIndex = 0;
  int get selectedSubjectIndex => _selectedSubjectIndex;

  List<Grade> _grades = [];
  List<Grade> get grades => _grades;
  int _selectedGradeIndex = 0;
  int get selectedGradeIndex => _selectedGradeIndex;
  bool get showGradeTabs => _user == null && _grades.isNotEmpty;

  String? _error;
  String? get error => _error;

  int? get _effectiveGradeId {
    if (_user != null) return _user!.grade.id;
    if (_grades.isNotEmpty &&
        _selectedGradeIndex >= 0 &&
        _selectedGradeIndex < _grades.length) {
      return _grades[_selectedGradeIndex].id;
    }
    return null;
  }

  @override
  void onInit() async {
    super.onInit();
    _user = await HiveUserStorage().getUser();
    await _prepareGuestGrades();
    loadExams();
    loadSubjects();
    _completedExamIds = await _hiveExamStorage.completedExamIds();

    HiveUserStorage().listen((event) {
      _user = event;
      _onUserChanged();
    }, 'user');

    _internetConnection.onStatusChange.listen((event) {
      if (event == InternetStatus.connected) {
        _onReconnect();
      } else {
        _applyOfflineFilter();
      }
    });

    _hiveExamStorage.listen((_) {
      _syncVisibleExams();
    }, 'exams');

    HiveSubjectsStorage().listen((event) {
      _subjects = [_allPlaceholderSubject, ...event];
      update();
    }, 'subjects');
  }

  Future<void> _prepareGuestGrades() async {
    if (_user != null) {
      _grades = [];
      _selectedGradeIndex = 0;
      return;
    }
    await loadGrades();
  }

  Future<void> _onUserChanged() async {
    await _prepareGuestGrades();
    loadExams();
  }

  Future<void> _onReconnect() async {
    await _prepareGuestGrades();
    loadExams();
  }

  Future<void> loadGrades() async {
    if (_user != null) return;
    try {
      _grades = await GradeService().getGrades(backendAppPackage);
      if (_selectedGradeIndex >= _grades.length) {
        _selectedGradeIndex = 0;
      }
      update();
    } catch (e) {
      logger.e(e);
    }
  }

  void selectGrade(int index) {
    if (index == _selectedGradeIndex || index < 0 || index >= _grades.length) {
      return;
    }
    _selectedGradeIndex = index;
    update();
    loadExams();
  }

  Future<void> loadSubjects() async {
    final subjects = await HiveSubjectsStorage().read('subjects');
    _subjects = [_allPlaceholderSubject, ...subjects];
    update();
  }

  Future<void> _applyOfflineFilter() async {
    _isOffline = true;
    _exams = await _visibleExams();
    update();
  }

  Future<void> _syncVisibleExams() async {
    _exams = await _visibleExams();
    await _refreshCompletionBadges();
  }

  Future<List<Exam>> _visibleExams() async {
    final exams = await _hiveExamStorage.getExams();
    for (final exam in exams) {
      exam.isDownloaded = exam.questions.isNotEmpty;
    }

    return exams.where(_isExamScreenExam).toList();
  }

  Future<void> _restoreCachedCategories() async {
    final cached = await _hiveExamStorage.getExamCategories(_effectiveGradeId);
    if (cached.isEmpty) {
      _categories = [];
      _categoriesFromApi = false;
      return;
    }
    _categories = cached;
    _categoriesFromApi = true;
  }

  Future<void> loadExams() async {
    _isLoading = true;
    _error = null;
    update();

    _isOffline = !await _internetConnection.hasInternetAccess;

    try {
      if (!_isOffline) {
        final device = await UserDevice.getDeviceInfo(_user?.phoneNumber ?? '');
        final gradeId = _effectiveGradeId;
        try {
          final exams_ = await _examService.getAvailableExams(
            device.id,
            gradeId: gradeId,
          );
          await _hiveExamStorage.setExams(exams_);
        } catch (e) {
          // Keep exams already stored on the device.
        }
        try {
          _categories = await _examService.getExamCategories(
            gradeId: gradeId,
            deviceId: device.id,
          );
          _categoriesFromApi = true;
          await _hiveExamStorage.setExamCategories(gradeId, _categories);
        } catch (e) {
          await _restoreCachedCategories();
        }
      } else {
        await _restoreCachedCategories();
      }
      _exams = await _visibleExams();
    } catch (e) {
      if (!_categoriesFromApi) {
        await _restoreCachedCategories();
      }
      _exams = await _visibleExams();
    } finally {
      _isLoading = false;
      await _refreshCompletionBadges();
      update();
    }
  }

  Future<void> _refreshCompletionBadges() async {
    _completedExamIds = await _hiveExamStorage.completedExamIds();
    update();
  }

  Future<void> refreshCompletionBadges() async {
    await _refreshCompletionBadges();
  }

  Future<void> selectSubject(int index) async {
    _selectedSubjectIndex = index;
    update();
  }

  bool _isExamScreenExam(Exam exam) {
    if (exam.examType == 'quiz') return false;
    final mode = exam.modeType.toLowerCase();
    return mode == 'practice' || mode == 'exam_mode' || mode == 'both';
  }

  int get _selectedSubjectId {
    if (_subjects.isEmpty ||
        _selectedSubjectIndex < 0 ||
        _selectedSubjectIndex >= _subjects.length) {
      return 0;
    }
    return _subjects[_selectedSubjectIndex].id;
  }

  List<ExamBrowseGroup> get categoryGroups {
    if (!_categoriesFromApi) return _groupsFor(null);
    return [
      for (final category in _categories)
        ExamBrowseGroup(
          id: category.id,
          name: category.name,
          sortOrder: category.sortOrder,
          count: _countExams(categoryId: category.id),
          thumbnail: category.thumbnail,
        ),
    ];
  }

  List<ExamBrowseGroup> sectionsForCategory({int? categoryId}) {
    if (!_categoriesFromApi || categoryId == null) {
      return _groupsFor(categoryId, sections: true);
    }
    ExamCategoryBrowse? category;
    for (final item in _categories) {
      if (item.id == categoryId) {
        category = item;
        break;
      }
    }
    final groups = <ExamBrowseGroup>[
      for (final section in category?.sections ?? const <ExamGrouping>[])
        ExamBrowseGroup(
          id: section.id,
          name: section.name,
          sortOrder: section.sortOrder,
          count: _countExams(categoryId: categoryId, sectionId: section.id),
          isLocked: section.isLocked,
        ),
    ];
    final unsectioned = _countExams(categoryId: categoryId, unsectioned: true);
    if (unsectioned > 0) {
      groups.add(
        ExamBrowseGroup(
          id: null,
          name: generalSectionName,
          sortOrder: 1 << 20,
          count: unsectioned,
        ),
      );
    }
    return groups;
  }

  int _countExams({
    required int categoryId,
    int? sectionId,
    bool unsectioned = false,
  }) {
    return _exams.where((exam) {
      if (exam.examCategory?.id != categoryId) return false;
      if (unsectioned) return exam.section == null;
      if (sectionId == null) return true;
      return exam.section?.id == sectionId;
    }).length;
  }

  List<ExamBrowseGroup> _groupsFor(int? categoryId, {bool sections = false}) {
    final groups = <String, ExamBrowseGroup>{};
    final counts = <String, int>{};
    for (final exam in _exams) {
      if (exam.examCategory == null) continue;
      if (sections) {
        final matchesCategory = categoryId == null
            ? exam.examCategory == null
            : exam.examCategory?.id == categoryId;
        if (!matchesCategory) continue;
      }
      final grouping = sections ? exam.section : exam.examCategory;
      final fallbackName = sections
          ? generalSectionName
          : uncategorizedCategoryName;
      final key = grouping == null
          ? fallbackName
          : '${sections ? 's' : 'c'}-${grouping.id}';
      counts[key] = (counts[key] ?? 0) + 1;
      groups[key] = ExamBrowseGroup(
        id: grouping?.id,
        name: grouping?.name ?? fallbackName,
        sortOrder: grouping?.sortOrder ?? 1 << 20,
        count: counts[key]!,
        thumbnail: sections ? null : grouping?.thumbnail,
      );
    }
    final list = groups.values.toList()
      ..sort((a, b) {
        final order = a.sortOrder.compareTo(b.sortOrder);
        if (order != 0) return order;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return list;
  }

  List<Exam> examsInSection({int? categoryId, int? sectionId}) {
    final subjectId = _selectedSubjectId;
    return _exams.where((exam) {
      if (exam.examCategory == null) return false;
      final matchesCategory = categoryId == null
          ? exam.examCategory == null
          : exam.examCategory?.id == categoryId;
      if (!matchesCategory) return false;
      final matchesSection = sectionId == null
          ? exam.section == null
          : exam.section?.id == sectionId;
      if (!matchesSection) return false;
      if (subjectId != 0 && exam.subject?.id != subjectId) return false;
      return true;
    }).toList();
  }

  void startExam(int examId) {
    if (!requireAuth()) return;
    Get.to(
      () => ExamDetailPage(exam: _exams.firstWhere((e) => e.id == examId)),
    );
  }

  void navigateToExamDetail(int examId) {
    if (!requireAuth()) return;
    Get.to(
      () => ExamDetailPage(exam: _exams.firstWhere((e) => e.id == examId)),
    );
  }

  Future<void> refreshExams() async {
    await loadExams();
  }

  Future<void> refreshExamDownloadStatus() async {
    _exams = await _visibleExams();
    update();
  }

  Future<List<Exam>> searchExams(String query) async {
    return _exams
        .where(
          (e) =>
              e.examCategory != null &&
              e.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  bool isExamLocked(Exam exam) {
    if (hasFullAccessOverride) {
      return false;
    }
    if (hasDownloadedExamContent(exam)) {
      return false;
    }
    return exam.isLocked;
  }
}
