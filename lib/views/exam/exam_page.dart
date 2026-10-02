import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/exam/exam_controller.dart';
import 'package:vector_academy/controllers/misc/downloads_controller.dart';
import 'package:vector_academy/models/exam.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/services.dart';
import 'package:vector_academy/utils/utils.dart';
import 'package:vector_academy/views/exam/exam_detail_page.dart';
import 'package:vector_academy/views/success_stories/success_stories_page.dart';
import 'package:vector_academy/views/success_stories/success_story_detail_page.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Exams',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Change this line
          actions: [
            IconButton(
              onPressed: () =>
                  showSearch(context: context, delegate: ExamSearchDelegate()),
              icon: Icon(Icons.search, color: Colors.black87),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const _ExamSuccessStoriesStrip(),
              Expanded(
                child: buildExamBrowseGrid(
                  context: context,
                  controller: controller,
                  groups: controller.categoryGroups,
                  onTap: (group) {
                    Get.to(
                      () => ExamSectionsPage(
                        categoryId: group.id,
                        categoryName: group.name,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamSuccessStoriesStrip extends StatefulWidget {
  const _ExamSuccessStoriesStrip();

  @override
  State<_ExamSuccessStoriesStrip> createState() =>
      _ExamSuccessStoriesStripState();
}

class _ExamSuccessStoriesStripState extends State<_ExamSuccessStoriesStrip> {
  List<SuccessStory> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      final stories = await SuccessStoriesService().getSuccessStories();
      if (!mounted) return;
      setState(() => _stories = stories.take(8).toList());
    } catch (e) {
      logger.w('Failed to load exam success stories: $e');
    }
  }

  void _openAll() {
    Get.to(() => const SuccessStoriesPage());
  }

  void _openStory(SuccessStory story) {
    Get.to(() => SuccessStoryDetailPage(story: story));
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Success Stories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openAll,
                  child: const Text('See all'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _stories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final story = _stories[index];
                return _SuccessStoryCard(
                  story: story,
                  onTap: () => _openStory(story),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessStoryCard extends StatelessWidget {
  const _SuccessStoryCard({required this.story, required this.onTap});

  final SuccessStory story;
  final VoidCallback onTap;

  String? get _photo {
    final image = story.image?.trim();
    if (image != null && image.isNotEmpty) return image;
    final studentPhoto = story.studentPhoto?.trim();
    if (studentPhoto != null && studentPhoto.isNotEmpty) return studentPhoto;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    final studentName = story.studentName?.trim();

    return SizedBox(
      width: 240,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: photo == null
                          ? const ColoredBox(
                              color: Color(0xFFF1F5F9),
                              child: Icon(
                                Icons.emoji_events_outlined,
                                color: Color(0xFF64748B),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: photo,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const ColoredBox(
                                    color: Color(0xFFF1F5F9),
                                    child: Icon(
                                      Icons.emoji_events_outlined,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          story.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        if (studentName != null && studentName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildExamSubjectCategories(
  BuildContext context,
  ExamController controller,
) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: controller.subjects.length,
        itemBuilder: (context, index) {
          final subject = controller.subjects[index];
          final isSelected = controller.selectedSubjectIndex == index;

          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                controller.selectSubject(index);
                logger.i("Clicked on subject: ${subject.name}");
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.grey[50],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(0xFF667eea).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_circle, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                      ],
                      Text(
                        subject.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
}

Widget _buildExamList(
  BuildContext context,
  ExamController controller, {
  List<Exam>? exams,
}) {
  final items = exams ?? controller.exams;
  if (controller.isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  if (controller.error != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error loading exams',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            controller.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.refreshExams(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  if (items.isEmpty) {
    return RefreshIndicator(
      onRefresh: controller.refreshExams,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  controller.isOffline
                      ? 'No downloaded exams'
                      : 'No exams available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  controller.isOffline
                      ? 'No downloaded exams are available offline'
                      : 'Check back later for new exams',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: controller.refreshExams,
    child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final exam = items[index];
        return GetBuilder<DownloadsController>(
          builder: (_) => _buildExamCard(context, exam, controller),
        );
      },
    ),
  );
}

Widget _buildExamCard(
  BuildContext context,
  Exam exam,
  ExamController controller,
) {
  final isCompleted = controller.completedExamIds.contains(exam.id);
  final questionCount = exam.totalQuestions ?? 0;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => controller.navigateToExamDetail(exam.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  exam.isLocked ? Icons.lock_outline : Icons.quiz_outlined,
                  size: 22,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$questionCount questions · ${exam.duration} min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (isCompleted || exam.isDownloaded || exam.isLocked) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (exam.isLocked)
                            const _ExamStatusChip(
                              label: 'Locked',
                              color: Color(0xFFB45309),
                              background: Color(0xFFFFF7ED),
                            ),
                          if (isCompleted)
                            const _ExamStatusChip(
                              label: 'Completed',
                              color: Color(0xFF15803D),
                              background: Color(0xFFF0FDF4),
                            ),
                          if (exam.isDownloaded)
                            const _ExamStatusChip(
                              label: 'Downloaded',
                              color: Color(0xFF15803D),
                              background: Color(0xFFF0FDF4),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              buildExamActionButton(exam, controller),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ExamStatusChip extends StatelessWidget {
  const _ExamStatusChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

Widget buildExamActionButton(Exam exam, ExamController controller) {
  if (exam.isLocked) {
    return ElevatedButton(
      onPressed: () => openExamPurchase(exam),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        minimumSize: Size(0, 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_open, size: 10, color: Colors.white),
          SizedBox(width: 3),
          Flexible(
            child: Text(
              "Unlock",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  if (exam.isLoadingQuestion) {
    // Downloading exam
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[100],
        foregroundColor: Colors.orange[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        minimumSize: Size(0, 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
            ),
          ),
          SizedBox(width: 3),
          Flexible(
            child: Text(
              "Loading",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  return const Icon(
    Icons.chevron_right_rounded,
    color: Color(0xFF94A3B8),
  );
}

class ExamSearchDelegate extends SearchDelegate<Exam?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final controller = Get.find<ExamController>();
    return FutureBuilder<List<Exam>>(
      future: controller.searchExams(query),
      builder: (context, snapshot) {
        return snapshot.data?.isEmpty ?? true
            ? _buildNoResultsState(context)
            : _buildSearchResults(context, snapshot.data!);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final controller = Get.find<ExamController>();
    final exams = controller.exams
        .where((exam) => exam.examCategory != null)
        .toList();
    return ListView.builder(
      itemCount: exams.length,
      itemBuilder: (context, index) =>
          _buildExamCard(context, exams[index], controller),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(child: Text('No results found'));
  }

  Widget _buildSearchResults(BuildContext context, List<Exam> exams) {
    final controller = Get.find<ExamController>();
    return ListView.builder(
      itemCount: exams.length,
      itemBuilder: (context, index) =>
          _buildExamCard(context, exams[index], controller),
    );
  }
}

Widget buildExamBrowseGrid({
  required BuildContext context,
  required ExamController controller,
  required List<ExamBrowseGroup> groups,
  required void Function(ExamBrowseGroup group) onTap,
  bool compact = false,
}) {
  if (controller.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (controller.error != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(controller.error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshExams,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  if (groups.isEmpty) {
    return RefreshIndicator(
      onRefresh: controller.refreshExams,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Center(
              child: Text(
                controller.isOffline
                    ? 'No downloaded exams'
                    : 'No exams available',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  if (compact) {
    return RefreshIndicator(
      onRefresh: controller.refreshExams,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: groups.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final group = groups[index];
          return _ExamSectionRow(group: group, onTap: () => onTap(group));
        },
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: controller.refreshExams,
    child: GridView.builder(
      clipBehavior: Clip.none,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _ExamBrowseCard(group: group, onTap: () => onTap(group));
      },
    ),
  );
}

class _ExamBrowseCard extends StatefulWidget {
  const _ExamBrowseCard({required this.group, required this.onTap});

  final ExamBrowseGroup group;
  final VoidCallback onTap;

  @override
  State<_ExamBrowseCard> createState() => _ExamBrowseCardState();
}

class _ExamBrowseCardState extends State<_ExamBrowseCard> {
  bool _imageFailed = false;

  bool get _hasThumbnail {
    final thumbnail = widget.group.thumbnail?.trim();
    return thumbnail != null && thumbnail.isNotEmpty && !_imageFailed;
  }

  String get _countLabel {
    final count = widget.group.count;
    return count == 1 ? '1 exam' : '$count exams';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _media()),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _countLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _media() {
    if (!_hasThumbnail) {
      return _iconArea();
    }

    return CachedNetworkImage(
      imageUrl: widget.group.thumbnail!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => _iconArea(showSpinner: true),
      errorWidget: (context, url, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_imageFailed) {
            setState(() => _imageFailed = true);
          }
        });
        return _iconArea();
      },
    );
  }

  Widget _iconArea({bool showSpinner = false}) {
    return ColoredBox(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.quiz_outlined,
                size: 32,
                color: Color(0xFF64748B),
              ),
      ),
    );
  }
}

class _ExamSectionRow extends StatelessWidget {
  const _ExamSectionRow({required this.group, required this.onTap});

  final ExamBrowseGroup group;
  final VoidCallback onTap;

  String get _countLabel {
    final count = group.count;
    return count == 1 ? '1 exam' : '$count exams';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    size: 22,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _countLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExamSectionsPage extends StatelessWidget {
  const ExamSectionsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int? categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            categoryName,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SafeArea(
          child: buildExamBrowseGrid(
            context: context,
            controller: controller,
            compact: true,
            groups: controller.sectionsForCategory(categoryId: categoryId),
            onTap: (group) {
              Get.to(
                () => ExamSectionExamsPage(
                  categoryId: categoryId,
                  categoryName: categoryName,
                  sectionId: group.id,
                  sectionName: group.name,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ExamSectionExamsPage extends StatelessWidget {
  const ExamSectionExamsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.sectionId,
    required this.sectionName,
  });

  final int? categoryId;
  final String categoryName;
  final int? sectionId;
  final String sectionName;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Section: $sectionName | $categoryName",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // buildExamSubjectCategories(context, controller),
              Expanded(
                child: _buildExamList(
                  context,
                  controller,
                  exams: controller.examsInSection(
                    categoryId: categoryId,
                    sectionId: sectionId,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
