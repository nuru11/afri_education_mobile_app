import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/subject/subject_controller.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/navigation_utils.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(SubjectController());
    return GetBuilder<SubjectController>(
      builder: (controller) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Modern Top Bar
                _buildModernTopBar(context, controller),

                // Subject List Section
                Expanded(child: _buildModernSubjectList(context, controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTopBar(
    BuildContext context,
    SubjectController controller,
  ) {
    final gradeName = controller.user?.grade.name ?? 'Grade Unknown';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // Modern Back Button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => safePop(context: context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Grade Name with Modern Typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gradeName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select your subject',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          // Decorative Element
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSubjectList(
    BuildContext context,
    SubjectController controller,
  ) {
    if (controller.isLoading) {
      return _buildModernLoadingState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1, // Increased from 1.0 to 1.1
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: controller.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = controller.subjects[index];
                    return _buildModernSubjectCard(
                      context,
                      subject,
                      controller,
                      index,
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

  Widget _buildModernLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading subjects...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSubjectCard(
    BuildContext context,
    Subject subject,
    SubjectController controller,
    int index,
  ) {
    final subjectColor = _getSubjectGradient(subject.name);
    final isLocked = controller.isSubjectLocked(subject);
    final progress = _calculateSubjectProgress(subject, isLocked);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () => controller.navigateToSubjectDetail(subject.id),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: subjectColor,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: subjectColor[0].withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // Additional decorative elements
                      Positioned(
                        bottom: -10,
                        left: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // Main Content
                      Padding(
                        padding: const EdgeInsets.all(16), // Reduced from 20
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Subject Icon with Modern Design and Progress Ring
                            Stack(
                              children: [
                                Container(
                                  width: 50, // Further reduced from 60
                                  height: 50, // Further reduced from 60
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ), // Reduced from 16
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _getSubjectIcon(subject.name),
                                    size: 24, // Reduced from 30
                                    color: Colors.white,
                                  ),
                                ),
                                // Progress indicator
                                if (!isLocked && progress > 0)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 16, // Reduced from 18
                                      height: 16, // Reduced from 18
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5, // Reduced from 2
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${(progress * 100).round()}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 6, // Reduced from 7
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12), // Reduced from 16
                            // Subject Name
                            Flexible(
                              // Wrap in Flexible to prevent overflow
                              child: Text(
                                subject.name,
                                style: TextStyle(
                                  fontSize: 14, // Reduced from 16
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 6,
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 4), // Reduced from 6
                            // Chapters Count with Modern Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, // Reduced from 10
                                vertical: 3, // Reduced from 4
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Reduced from 10
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: 0.5,
                                  ), // Increased opacity
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${subject.chapters.length} Chapters',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10, // Reduced from 11
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Progress bar for unlocked subjects
                            if (!isLocked && progress > 0) ...[
                              const SizedBox(height: 6), // Reduced from 8
                              Container(
                                height: 2, // Reduced from 3
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    1,
                                  ), // Reduced from 2
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        1,
                                      ), // Reduced from 2
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Lock Overlay for Locked Subjects
                      if (isLocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Preview',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Premium badge for locked subjects
                      if (isLocked)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getSubjectGradient(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'english':
        return [
          const Color(0xFFff6b6b),
          const Color(0xFFee5a52),
        ]; // Darker red gradient
      case 'maths':
      case 'mathematics':
        return [
          const Color(0xFF4ecdc4),
          const Color(0xFF44a08d),
        ]; // Darker teal gradient
      case 'physics':
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case 'chemistry':
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      case 'biology':
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case 'geography':
        return [
          const Color(0xFF56ab2f),
          const Color(0xFFa8e6cf),
        ]; // Darker green gradient
      case 'history':
        return [const Color(0xFFfa709a), const Color(0xFFfee140)];
      default:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
  }

  IconData _getSubjectIcon(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'english':
        return Icons.language_rounded;
      case 'maths':
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'physics':
        return Icons.science_rounded;
      case 'chemistry':
        return Icons.science_outlined;
      case 'biology':
        return Icons.eco_rounded;
      case 'geography':
        return Icons.map_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  double _calculateSubjectProgress(Subject subject, bool isLocked) {
    // This is a mock calculation - in a real app, you'd calculate based on
    // completed chapters, watched videos, etc.
    if (isLocked) return 0.0;

    // For demo purposes, return a random progress between 0 and 1
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return random / 100.0;
  }
}
