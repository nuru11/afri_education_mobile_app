import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/subject/chapter_detail_controller.dart';
import 'package:vector_academy/views/tabs/video_tab.dart';
import 'package:vector_academy/views/tabs/notes_tab.dart';
import 'package:vector_academy/utils/navigation_utils.dart';
import 'package:vector_academy/views/tabs/quiz_tab.dart';

class ChapterDetail extends StatelessWidget {
  const ChapterDetail({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChapterDetailController());
    return GetBuilder<ChapterDetailController>(
      builder: (controller) => DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildModernHeader(context, controller),
                _buildModernTabBar(context),
              ];
            },
            body: controller.isLoading
                ? _buildLoadingState(context)
                : TabBarView(children: [VideoTab(), NotesTab(), QuizTab()]),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(
    BuildContext context,
    ChapterDetailController controller,
  ) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 200, // Reduced from 200
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => safePop(context: context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      actions: [],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
                theme.colorScheme.secondary.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 60, 20, 16), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Chapter Progress - Made more compact
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16), // Reduced radius
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 14,
                        ), // Smaller icon
                        SizedBox(width: 4), // Reduced spacing
                        Text(
                          'Chapter Progress',
                          style: theme.textTheme.labelSmall?.copyWith(
                            // Smaller text
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12), // Reduced spacing
                  // Chapter Title - Made more compact
                  Text(
                    controller.chapterTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      // Reduced from headlineLarge
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1, // Reduced line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8), // Reduced spacing
                  // Chapter Stats - Made more compact
                  Wrap(
                    spacing: 8, // Reduced spacing
                    runSpacing: 4, // Reduced run spacing
                    children: [
                      _buildStatChip(
                        context,
                        Icons.play_circle_outline,
                        '${controller.videos.length} Videos',
                        Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildStatChip(
                        context,
                        Icons.description_outlined,
                        '${controller.notes.length} Notes',
                        Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildStatChip(
                        context,
                        Icons.quiz_outlined,
                        '${controller.quizzes.length} Quizzes',
                        Colors.white.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String text,
    Color backgroundColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // Reduced radius
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14), // Smaller icon
          SizedBox(width: 4), // Reduced spacing
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                // Smaller text
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10, // Explicitly smaller font
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: _ModernTabBarDelegate(
        TabBar(
          tabs: [
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_outline, size: 20), // Smaller icon
                  SizedBox(height: 2), // Reduced spacing
                  Text(
                    'Videos',
                    style: TextStyle(fontSize: 12),
                  ), // Smaller text
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 20), // Smaller icon
                  SizedBox(height: 2), // Reduced spacing
                  Text('Notes', style: TextStyle(fontSize: 12)), // Smaller text
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.quiz_outlined, size: 20), // Smaller icon
                  SizedBox(height: 2), // Reduced spacing
                  Text('Quiz', style: TextStyle(fontSize: 12)), // Smaller text
                ],
              ),
            ),
          ],
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2, // Reduced weight
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12, // Smaller font
          ),
          unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12, // Smaller font
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading Chapter Content...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _ModernTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 12; // Reduced padding

  @override
  double get maxExtent => _tabBar.preferredSize.height + 12; // Reduced padding

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ), // Reduced padding
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
