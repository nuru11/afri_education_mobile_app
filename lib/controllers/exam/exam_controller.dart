import 'package:get/get.dart';
import 'package:vector_academy/views/exam/exam_detail_page.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/services.dart';
import 'package:vector_academy/utils/storages/storages.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vector_academy/utils/device/device.dart';
import 'package:vector_academy/utils/utils.dart';

class ExamController extends GetxController {
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
  Set<int> _completedExamIds = {};
  Set<int> get completedExamIds => _completedExamIds;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  int _selectedSubjectIndex = 0;
  int get selectedSubjectIndex => _selectedSubjectIndex;

  String? _error;
  String? get error => _error;

  @override
  void onInit() async {
    super.onInit();
    _user = await HiveUserStorage().getUser();
    loadExams();
    loadSubjects();
    _completedExamIds = await _hiveExamStorage.completedExamIds();

    HiveUserStorage().listen((event) {
      _user = event;
      loadExams();
    }, 'user');

    _internetConnection.onStatusChange.listen((event) {
      if (event == InternetStatus.connected) {
        loadExams();
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

    final subjectId =
        _subjects.isEmpty ||
            _selectedSubjectIndex < 0 ||
            _selectedSubjectIndex >= _subjects.length
        ? 0
        : _subjects[_selectedSubjectIndex].id;

    return exams.where((exam) {
      if (exam.examType == 'quiz') return false;
      if (subjectId != 0 && exam.subject?.id != subjectId) return false;
      if (_isOffline && !hasDownloadedExamContent(exam)) return false;
      return true;
    }).toList();
  }

  Future<void> loadExams() async {
    _isLoading = true;
    _error = null;
    update();

    _isOffline = !await _internetConnection.hasInternetAccess;

    try {
      if (!_isOffline) {
        final device = await UserDevice.getDeviceInfo(_user?.phoneNumber ?? '');
        final grade = _user?.grade;
        final exams_ = await _examService.getAvailableExams(
          device.id,
          gradeId: grade?.id,
        );
        await _hiveExamStorage.setExams(exams_);
      }
      _exams = await _visibleExams();
    } catch (e) {
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
    _exams = await _visibleExams();
    update();
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
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
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
