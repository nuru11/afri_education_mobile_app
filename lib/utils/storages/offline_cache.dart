import 'package:hive_flutter/hive_flutter.dart';
import 'package:vector_academy/models/models.dart';

class HiveNewsStorage {
  static const String _boxName = 'newsStorage';
  static const String _newsKey = 'news_items';
  static late Box<dynamic> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<dynamic>(_boxName);
    } else {
      _box = Hive.box<dynamic>(_boxName);
    }
  }

  Future<void> setNews(List<News> news) async {
    final jsonList = news.map((item) => item.toJson()).toList();
    await _box.put(_newsKey, jsonList);
  }

  Future<List<News>> getNews() async {
    final value = _box.get(_newsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    return value
        .whereType<Map>()
        .map((item) => News.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class HiveLeaderboardCacheStorage {
  static const String _boxName = 'leaderboardCacheStorage';
  static const String _competitionsKey = 'competitions';
  static const String _examsKey = 'leaderboard_exams';
  static late Box<dynamic> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<dynamic>(_boxName);
    } else {
      _box = Hive.box<dynamic>(_boxName);
    }
  }

  Future<void> setCompetitions(List<Map<String, dynamic>> competitions) async {
    await _box.put(_competitionsKey, competitions);
  }

  Future<List<Map<String, dynamic>>> getCompetitions() async {
    final value = _box.get(
      _competitionsKey,
      defaultValue: <dynamic>[],
    ) as List<dynamic>;
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> setExams(List<Exam> exams) async {
    final jsonList = exams.map((item) => item.toJson()).toList();
    await _box.put(_examsKey, jsonList);
  }

  Future<List<Exam>> getExams() async {
    final value = _box.get(_examsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    return value
        .whereType<Map>()
        .map((item) => Exam.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> setLeaderboardEntries({
    required String type,
    required int sourceId,
    required List<LeaderboardEntry> entries,
  }) async {
    final key = '${type}_$sourceId';
    final jsonList = entries.map((item) => item.toJson()).toList();
    await _box.put(key, jsonList);
  }

  Future<List<LeaderboardEntry>> getLeaderboardEntries({
    required String type,
    required int sourceId,
  }) async {
    final key = '${type}_$sourceId';
    final value = _box.get(key, defaultValue: <dynamic>[]) as List<dynamic>;
    return value
        .whereType<Map>()
        .map((item) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  String _userHomeScoresKey(int userId) => 'user_home_scores_$userId';

  Future<void> setUserHomeScores({
    required int userId,
    UserLeaderboardResult? result,
    required List<CompetetionExam> fallback,
  }) async {
    await _box.put(_userHomeScoresKey(userId), <String, dynamic>{
      'result': result == null ? null : _leaderboardResultToJson(result),
      'fallback': fallback.map((exam) => exam.toJson()).toList(),
    });
  }

  Future<void> clearUserHomeScores(int userId) async {
    await _box.delete(_userHomeScoresKey(userId));
  }

  Future<CachedUserHomeScores?> getUserHomeScores(int userId) async {
    final value = _box.get(_userHomeScoresKey(userId));
    if (value is! Map) {
      return null;
    }

    final payload = Map<String, dynamic>.from(value);
    UserLeaderboardResult? result;
    final rawResult = payload['result'];
    if (rawResult is Map) {
      try {
        result = UserLeaderboardResult.fromJson(
          _normalizeLeaderboardResultJson(rawResult),
        );
      } catch (_) {
        result = null;
      }
    }

    return CachedUserHomeScores(
      result: result,
      fallback: _readCompetitionExams(payload['fallback']),
    );
  }

  Map<String, dynamic> _leaderboardResultToJson(UserLeaderboardResult result) {
    final json = Map<String, dynamic>.from(result.toJson());
    json['exams'] = result.exams.map((exam) => exam.toJson()).toList();
    return json;
  }

  Map<String, dynamic> _normalizeLeaderboardResultJson(Map raw) {
    final json = Map<String, dynamic>.from(raw);
    final averageScore = json['average_score'];
    if (averageScore is num) {
      json['average_score'] = averageScore.toDouble();
    }
    final totalQuestions = json['total_questions'];
    if (totalQuestions is num) {
      json['total_questions'] = totalQuestions.toInt();
    }
    json['exams'] = _readCompetitionExams(json['exams'])
        .map((exam) => exam.toJson())
        .toList();
    return json;
  }

  List<CompetetionExam> _readCompetitionExams(dynamic raw) {
    if (raw is! List) {
      return [];
    }

    final exams = <CompetetionExam>[];
    for (final item in raw) {
      if (item is! Map) {
        continue;
      }
      try {
        exams.add(CompetetionExam.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        continue;
      }
    }
    return exams;
  }
}

class CachedUserHomeScores {
  const CachedUserHomeScores({required this.result, required this.fallback});

  final UserLeaderboardResult? result;
  final List<CompetetionExam> fallback;
}

class HiveReadingPlanStorage {
  static const String _boxName = 'readingPlanCacheStorage';
  static const String _documentsKey = 'reading_plan_documents';
  static late Box<dynamic> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<dynamic>(_boxName);
    } else {
      _box = Hive.box<dynamic>(_boxName);
    }
  }

  Future<void> setDocuments(List<ReadingPlanDocument> documents) async {
    final jsonList = documents.map((item) => item.toJson()).toList();
    await _box.put(_documentsKey, jsonList);
  }

  Future<List<ReadingPlanDocument>> getDocuments() async {
    final value =
        _box.get(_documentsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    return value
        .whereType<Map>()
        .map(
          (item) =>
              ReadingPlanDocument.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
