// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:vector_academy/components/components.dart';
// import 'package:vector_academy/controllers/controllers.dart';
// import "package:vector_academy/models/models.dart";
// import "package:vector_academy/utils/utils.dart";
// import "package:vector_academy/services/services.dart";
// import 'package:vector_academy/views/views.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HomeDashboard extends StatelessWidget {
//   HomeDashboard({super.key});

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     Get.put(HomeDashboardController());
//     Get.put(NavigationDrawerController());
//     Get.put(NotificationsController());

//     return GetBuilder<HomeDashboardController>(
//       builder: (controller) => Scaffold(
//         key: _scaffoldKey,
//         backgroundColor: Colors.white,
//         drawer: _buildNavigationDrawer(context),
//         body: SafeArea(
//           child: Column(
//             children: [
//               _buildTopBar(context, controller),
//               // _buildPromotionalBanner(context, controller),
//               _buildHomeSearchBar(context, controller),
//               if (controller.hasSearchQuery)
//                 Expanded(child: _buildGroupedSearchResults(context, controller))
//               else ...[
//                 _buildFeaturedUpdatesBar(context, controller),
//                 Expanded(child: _buildSubjectSelection(context, controller)),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHomeSearchBar(
//     BuildContext context,
//     HomeDashboardController controller,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
//       child: SearchTextField(
//         controller: controller.homeSearchController,
//         hint: 'Search chapters, exams, videos, worksheets...',
//         onChanged: controller.updateSearchQuery,
//         onClear: controller.clearSearch,
//       ),
//     );
//   }

//   Widget _buildTopBar(
//     BuildContext context,
//     HomeDashboardController controller,
//   ) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () {
//               _scaffoldKey.currentState?.openDrawer();
//             },
//             icon: Icon(Icons.menu, color: Colors.black87),
//             padding: EdgeInsets.zero,
//             constraints: BoxConstraints(),
//             mouseCursor: SystemMouseCursors.click,
//           ),

//           Spacer(),

//           Row(
//             children: [
//               IconButton(
//                 onPressed: () async {
//                   final dynamicTelegramLink = controller.appHeader?.link?.trim();
//                   final targetTelegramLink =
//                       (dynamicTelegramLink != null &&
//                           dynamicTelegramLink.isNotEmpty)
//                       ? dynamicTelegramLink
//                       : 'https://t.me/entrance_tricks';

//                   if (!await launchUrl(Uri.parse(targetTelegramLink))) {
//                     throw Exception('Could not launch $targetTelegramLink');
//                   }
//                 },
//                 icon: Icon(Icons.telegram, color: Colors.blue[600], size: 35,),
//                 padding: EdgeInsets.zero,
//                 constraints: BoxConstraints(),
//                 mouseCursor: SystemMouseCursors.click,
//               ),
//               // SizedBox(width: 2),
//               GetBuilder<NotificationsController>(
//                 builder: (notificationsController) => Stack(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Get.to(() => NotificationsPage());
//                       },
//                       icon: Icon(
//                         Icons.notifications_outlined,
//                         color: Colors.black87,
//                       ),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                       mouseCursor: SystemMouseCursors.click,
//                     ),
//                     if (notificationsController.unreadCount > 0)
//                       Positioned(
//                         right: 8,
//                         top: 8,
//                         child: Container(
//                           width: 16,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: Colors.red[600],
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Text(
//                               '${notificationsController.unreadCount > 9 ? "9+" : notificationsController.unreadCount}',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ignore: unused_element
//   Widget _buildPromotionalBanner(
//     BuildContext context,
//     HomeDashboardController controller,
//   ) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             controller.appHeader?.gradientStart != null
//                 ? Color(
//                     int.parse(
//                       (controller.appHeader!.gradientStart!).replaceAll(
//                         '#',
//                         '0xFF',
//                       ),
//                     ),
//                   )
//                 : Colors.blue,
//             controller.appHeader?.gradientEnd != null
//                 ? Color(
//                     int.parse(
//                       (controller.appHeader!.gradientEnd!).replaceAll(
//                         '#',
//                         '0xFF',
//                       ),
//                     ),
//                   )
//                 : Colors.blue.shade700,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   controller.appHeader?.text ?? 'Ethio Remedial Tricks!',
//                   style: TextStyle(
//                     color: controller.appHeader?.textColor != null
//                         ? Color(
//                             int.parse(
//                               (controller.appHeader!.textColor!).replaceAll(
//                                 '#',
//                                 '0xFF',
//                               ),
//                             ),
//                           )
//                         : Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 if (controller.appHeader?.showTagLineText == true)
//                   Text(
//                     controller.appHeader?.tagLineText ?? 'For HighSchool Class',
//                     style: TextStyle(
//                       color: controller.appHeader?.tagLineTextColor != null
//                           ? Color(
//                               int.parse(
//                                 (controller.appHeader!.tagLineTextColor!)
//                                     .replaceAll('#', '0xFF'),
//                               ),
//                             )
//                           : Colors.white.withValues(alpha: 0.9),
//                       fontSize: 16,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: IconButton(
//               onPressed: () async {
//                 if (!await launchUrl(
//                   Uri.parse(
//                     controller.appHeader?.link ??
//                         'https://t.me/entrance_tricks',
//                   ),
//                 )) {}
//               },
//               icon: Icon(Icons.telegram, size: 40, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeaturedUpdatesBar(
//     BuildContext context,
//     HomeDashboardController controller,
//   ) {
//     final featuredUpdates = controller.featuredUpdates;
//     final isLoading =
//         controller.isFeaturedUpdatesLoading && featuredUpdates.isEmpty;

//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: const Color(0xFFCBD5E1).withValues(alpha: 0.9),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE2E8F0),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.campaign_rounded,
//                   size: 20,
//                   color: Color(0xFF334155),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Latest News & Exams',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       'Newest posts and exams from admin',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                     ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 tooltip: 'Refresh updates',
//                 onPressed: () => controller.loadFeaturedUpdates(showLoader: false),
//                 style: IconButton.styleFrom(
//                   backgroundColor: const Color(0xFFE2E8F0),
//                 ),
//                 icon: const Icon(
//                   Icons.refresh_rounded,
//                   size: 20,
//                   color: Color(0xFF334155),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (isLoading)
//             const SizedBox(
//               height: 90,
//               child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
//             )
//           else if (featuredUpdates.isEmpty)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
//               ),
//               child: Text(
//                 'No recent updates yet.',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           if (!isLoading && featuredUpdates.isNotEmpty)
//             SizedBox(
//               height: MediaQuery.sizeOf(context).width >= 768 ? 136 : 126,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: featuredUpdates.length,
//                 separatorBuilder: (_, index) => const SizedBox(width: 10),
//                 itemBuilder: (context, index) => _buildFeaturedUpdateCard(
//                   context,
//                   featuredUpdates[index],
//                   controller,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeaturedUpdateCard(
//     BuildContext context,
//     FeaturedUpdateItem item,
//     HomeDashboardController controller,
//   ) {
//     final screenWidth = MediaQuery.sizeOf(context).width;
//     final isCompact = screenWidth < 360;
//     final isTablet = screenWidth >= 768;
//     final cardWidth =
//         (screenWidth * (isCompact ? 0.82 : 0.72)).clamp(220.0, isTablet ? 340.0 : 300.0).toDouble();
//     final cardPadding = isCompact ? 10.0 : 12.0;
//     final titleFontSize = isCompact ? 13.0 : 14.0;
//     final metaFontSize = isCompact ? 10.0 : 11.0;

//     final isNews = item.type == FeaturedUpdateType.news;
//     final label = isNews ? 'News' : 'Exam';
//     final chipColor = isNews ? const Color(0xFF1D4ED8) : const Color(0xFF0F766E);
//     final accentColor = isNews ? const Color(0xFFDBEAFE) : const Color(0xFFCCFBF1);

//     return GestureDetector(
//       onTap: () => controller.openFeaturedUpdate(item),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Container(
//           width: cardWidth,
//           padding: EdgeInsets.all(cardPadding),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: const Color(0xFFE2E8F0)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.04),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 6,
//                     height: 22,
//                     decoration: BoxDecoration(
//                       color: chipColor,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: accentColor,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         color: chipColor.withValues(alpha: 0.95),
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   Flexible(
//                     child: Text(
//                       toAgoDate(item.createdAt),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       textAlign: TextAlign.right,
//                       style: TextStyle(fontSize: metaFontSize, color: Colors.grey[600]),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 item.title,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: titleFontSize,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF0F172A),
//                 ),
//               ),
//               Row(
//                 children: [
//                   if (item.subjectName != null && item.subjectName!.isNotEmpty)
//                     Expanded(
//                       child: Text(
//                         item.subjectName!,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     )
//                   else
//                     const Spacer(),
//                   Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: 14,
//                     color: Colors.grey[700],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSubjectSelection(
//     BuildContext context,
//     HomeDashboardController controller,
//   ) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Subject Selection',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 10),
//           Expanded(
//             child: controller.isLoading
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           strokeWidth: 3,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.blue,
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'Loading subjects...',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : RefreshIndicator(
//                     onRefresh: () async {
//                       await controller.loadSubjects();
//                       await controller.loadFeaturedUpdates(showLoader: false);
//                     },
//                     color: Colors.blue,
//                     backgroundColor: Colors.white,
//                     strokeWidth: 2.5,
//                     child: ListView.builder(
//                       physics: AlwaysScrollableScrollPhysics(
//                         parent: BouncingScrollPhysics(),
//                       ),
//                       itemCount: controller.subjects.length,
//                       itemBuilder: (context, index) {
//                         final subject = controller.subjects[index];
//                         return _buildSubjectCard(context, subject, controller);
//                       },
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroupedSearchResults(
//     BuildContext context,
//     HomeDashboardController controller,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Search Results',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Results for "${controller.searchQuery}"',
//             style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: !controller.hasAnySearchResult
//                 ? _buildSearchEmptyState()
//                 : ListView(
//                     physics: const BouncingScrollPhysics(),
//                     children: [
//                       _buildChapterResultsSection(controller),
//                       _buildExamResultsSection(controller),
//                       _buildVideoResultsSection(controller),
//                       _buildWorksheetResultsSection(controller),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchEmptyState() {
//     return Center(
//       child: Text(
//         'No matches found. Try another keyword.',
//         style: TextStyle(
//           fontSize: 14,
//           color: Colors.grey[600],
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildChapterResultsSection(HomeDashboardController controller) {
//     if (controller.chapterResults.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return _buildSearchSectionCard(
//       title: 'Chapters',
//       icon: Icons.menu_book_rounded,
//       children: controller.chapterResults.map((chapter) {
//         final subjectName = controller.getSubjectNameForChapter(chapter.id);
//         return _buildSearchResultTile(
//           title: chapter.name,
//           subtitle:
//               '$subjectName • Chapter ${chapter.chapterNumber}${(chapter.description ?? '').isNotEmpty ? ' • ${chapter.description}' : ''}',
//           icon: Icons.article_outlined,
//           onTap: () => controller.openChapterSearchResult(chapter),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildExamResultsSection(HomeDashboardController controller) {
//     if (controller.examResults.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return _buildSearchSectionCard(
//       title: 'Exams',
//       icon: Icons.quiz_rounded,
//       children: controller.examResults.map((exam) {
//         return _buildSearchResultTile(
//           title: exam.name,
//           subtitle:
//               '${exam.subject?.name ?? 'General'} • ${exam.examType.toUpperCase()}',
//           icon: Icons.assignment_outlined,
//           onTap: () => controller.openExam(exam.id),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildVideoResultsSection(HomeDashboardController controller) {
//     if (controller.videoResults.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return _buildSearchSectionCard(
//       title: 'Videos',
//       icon: Icons.play_circle_outline_rounded,
//       children: controller.videoResults.map((video) {
//         final chapterName = controller.getChapterNameById(video.chapter);
//         final subjectName = controller.getSubjectNameForChapter(video.chapter);
//         return _buildSearchResultTile(
//           title: video.title,
//           subtitle: '$subjectName • $chapterName',
//           icon: Icons.ondemand_video_outlined,
//           onTap: () => controller.openVideoSearchResult(video),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildWorksheetResultsSection(HomeDashboardController controller) {
//     if (controller.worksheetResults.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return _buildSearchSectionCard(
//       title: 'Worksheets',
//       icon: Icons.description_outlined,
//       children: controller.worksheetResults.map((worksheet) {
//         final chapterName = worksheet.chapter != null
//             ? controller.getChapterNameById(worksheet.chapter!)
//             : 'Unknown chapter';
//         final subjectName = worksheet.chapter != null
//             ? controller.getSubjectNameForChapter(worksheet.chapter!)
//             : 'General';
//         return _buildSearchResultTile(
//           title: worksheet.title,
//           subtitle: '$subjectName • $chapterName',
//           icon: Icons.note_alt_outlined,
//           onTap: () => controller.openWorksheetSearchResult(worksheet),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildSearchSectionCard({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: Colors.black87),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchResultTile({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         margin: const EdgeInsets.only(bottom: 6),
//         decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//         child: Row(
//           children: [
//             Icon(icon, size: 18, color: Colors.grey[700]),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[500]),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSubjectCard(
//     BuildContext context,
//     Subject subject,
//     HomeDashboardController controller,
//   ) {
//     final isLocked = subject.isLocked;
//     final totalChapters = subject.chapters.length;

//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => controller.selectSubject(subject.id),
//           borderRadius: BorderRadius.circular(20),
//           child: MouseRegion(
//             cursor: SystemMouseCursors.click,
//             child: Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: isLocked ? Colors.grey[50] : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: isLocked
//                       ? Colors.grey.withValues(alpha: 0.3)
//                       : _getGradeIconColor(subject.name).withValues(alpha: 0.2),
//                   width: isLocked ? 1 : 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: isLocked
//                         ? Colors.grey.withValues(alpha: 0.05)
//                         : _getGradeIconColor(
//                             subject.name,
//                           ).withValues(alpha: 0.1),
//                     blurRadius: isLocked ? 5 : 15,
//                     offset: Offset(0, isLocked ? 2 : 6),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Stack(
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: isLocked
//                               ? Colors.grey[300]
//                               : _getGradeIconColor(subject.name),
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: isLocked
//                                   ? Colors.grey.withValues(alpha: 0.2)
//                                   : _getGradeIconColor(
//                                       subject.name,
//                                     ).withValues(alpha: 0.3),
//                               blurRadius: 8,
//                               offset: Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: subject.icon != null && subject.icon!.isNotEmpty
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: CachedNetworkImage(
//                                   imageUrl: subject.icon!,
//                                   width: 60,
//                                   height: 60,
//                                   fit: BoxFit.cover,
//                                   placeholder: (context, url) => Center(
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                         isLocked
//                                             ? Colors.grey[600]!
//                                             : Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   errorWidget: (context, url, error) {
//                                     logger.e(error);
//                                     return Icon(
//                                       _getGradeIcon(subject.name),
//                                       size: 30,
//                                       color: isLocked
//                                           ? Colors.grey[600]
//                                           : Colors.white,
//                                     );
//                                   },
//                                 ),
//                               )
//                             : Icon(
//                                 _getGradeIcon(subject.name),
//                                 size: 30,
//                                 color: isLocked
//                                     ? Colors.grey[600]
//                                     : Colors.white,
//                               ),
//                       ),

//                       if (isLocked)
//                         Positioned(
//                           top: 0,
//                           right: 0,
//                           child: Container(
//                             width: 20,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               color: Colors.orange,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.white, width: 2),
//                             ),
//                             child: Icon(
//                               Icons.lock,
//                               size: 10,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),

//                   SizedBox(width: 16),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 subject.name,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: isLocked
//                                       ? Colors.grey[600]
//                                       : Colors.black87,
//                                 ),
//                               ),
//                             ),
//                             if (isLocked)
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.orange.withValues(alpha: 0.1),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   'Locked',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.orange[700],
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),

//                         SizedBox(height: 6),

//                         if (subject.description != null &&
//                             subject.description!.isNotEmpty)
//                           Text(
//                             subject.description!,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: isLocked
//                                   ? Colors.grey[500]
//                                   : Colors.grey[600],
//                               height: 1.3,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),

//                         SizedBox(height: 8),

//                         Row(
//                           children: [
//                             Icon(
//                               Icons.menu_book,
//                               size: 16,
//                               color: isLocked
//                                   ? Colors.grey[400]
//                                   : _getGradeIconColor(subject.name),
//                             ),
//                             SizedBox(width: 6),
//                             Text(
//                               '$totalChapters Chapters',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: isLocked
//                                     ? Colors.grey[500]
//                                     : Colors.grey[700],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: isLocked
//                         ? Colors.grey[400]
//                         : _getGradeIconColor(subject.name),
//                     size: 20,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getGradeIconColor(String gradeName) {
//     switch (gradeName.toLowerCase()) {
//       case 'grade 6':
//         return Colors.red;
//       case 'grade 8':
//         return Colors.black87;
//       case 'grade 9':
//         return Colors.orange;
//       case 'grade 10':
//         return Colors.red;
//       case 'grade 11':
//         return Colors.purple;
//       default:
//         return Colors.blue;
//     }
//   }

//   IconData _getGradeIcon(String gradeName) {
//     switch (gradeName.toLowerCase()) {
//       case 'grade 6':
//         return Icons.book;
//       case 'grade 8':
//         return Icons.library_books;
//       case 'grade 9':
//         return Icons.library_books;
//       case 'grade 10':
//         return Icons.library_books;
//       case 'grade 11':
//         return Icons.library_books;
//       default:
//         return Icons.school;
//     }
//   }

//   Widget _buildNavigationDrawer(BuildContext context) {
//     final coreService = Get.find<CoreService>();
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.white, Colors.grey[50]!],
//           ),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).padding.top + 20,
//                 left: 20,
//                 right: 20,
//                 bottom: 20,
//               ),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Colors.blue[600]!, Colors.blue[800]!],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.withValues(alpha: 0.3),
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.15),
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(
//                         color: Colors.white.withValues(alpha: 0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Welcome back,',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.white70,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           coreService.authService.user.value?.firstName ??
//                               'User',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 2),
//                         Text(
//                           coreService.authService.user.value?.phoneNumber ?? '',
//                           style: TextStyle(fontSize: 12, color: Colors.white60),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 physics: BouncingScrollPhysics(),
//                 children: [
//                   _buildSectionHeader('Main Navigation'),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.home_rounded,
//                     title: 'Home',
//                     subtitle: 'Dashboard & Overview',
//                     onTap: () {
//                       Get.find<MainNavigationController>().changeIndex(0);
//                     },
//                     isSelected:
//                         Get.find<MainNavigationController>().currentIndex == 0,
//                   ),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.quiz_rounded,
//                     title: 'Exams',
//                     subtitle: 'Practice & Mock Tests',
//                     onTap: () {
//                       Get.find<MainNavigationController>().changeIndex(1);
//                     },
//                     isSelected:
//                         Get.find<MainNavigationController>().currentIndex == 1,
//                   ),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.article_rounded,
//                     title: 'News',
//                     subtitle: 'Latest Updates',
//                     onTap: () {
//                       Get.find<MainNavigationController>().changeIndex(2);
//                     },
//                     isSelected:
//                         Get.find<MainNavigationController>().currentIndex == 2,
//                   ),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.person_rounded,
//                     title: 'Profile',
//                     subtitle: 'Account & Settings',
//                     onTap: () {
//                       Navigator.of(context).pop(); // Close drawer
//                       Get.to(() => ProfilePage());
//                     },
//                     isSelected: false,
//                   ),
//                   // SizedBox(height: 20),
//                   // _buildSectionHeader('Payments'),
//                   // _buildModernDrawerMenuItem(
//                   //   icon: Icons.payment_rounded,
//                   //   title: 'Payments',
//                   //   subtitle: 'View your payments',
//                   //   onTap: () => Get.toNamed(VIEWS.payments.path),
//                   // ),
//                   // SizedBox(height: 20),
//                   // _buildModernDrawerMenuItem(
//                   //   icon: Icons.history_rounded,
//                   //   title: 'Payment History',
//                   //   subtitle: 'View your payment history',
//                   //   onTap: () => Get.toNamed(VIEWS.paymentHistory.path),
//                   // ),

//                   SizedBox(height: 20),

//                   _buildSectionHeader('Study Materials'),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.book_rounded,
//                     title: 'Subjects',
//                     subtitle: 'Browse all subjects',
//                     onTap: () => Get.toNamed(VIEWS.subjects.path),
//                   ),

//                   SizedBox(height: 20),

//                   _buildSectionHeader('Tools & Features'),

//                   _buildModernDrawerMenuItem(
//                     icon: Icons.download_rounded,
//                     title: 'Downloads',
//                     subtitle: 'Offline content',
//                     onTap: () => Get.toNamed(VIEWS.downloads.path),
//                   ),

//                   SizedBox(height: 20),

//                   _buildSectionHeader('Support'),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.help_outline_rounded,
//                     title: 'FAQ',
//                     subtitle: 'Frequently asked questions',
//                     onTap: () => Get.toNamed(VIEWS.faq.path),
//                   ),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.headset_mic_rounded,
//                     title: 'Support',
//                     subtitle: 'Get help & support',
//                     onTap: () => Get.toNamed(VIEWS.support.path),
//                   ),
//                   _buildModernDrawerMenuItem(
//                     icon: Icons.info_outline_rounded,
//                     title: 'About',
//                     subtitle: 'App information',
//                     onTap: () => Get.toNamed(VIEWS.about.path),
//                   ),

//                   SizedBox(height: 20),

//                   _buildModernDrawerMenuItem(
//                     icon: Icons.logout_rounded,
//                     title: 'Logout',
//                     subtitle: 'Sign out of your account',
//                     onTap: () {
//                       Get.find<NavigationDrawerController>().logout();
//                     },
//                     isDestructive: true,
//                   ),

//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: Colors.grey[600],
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildModernDrawerMenuItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     bool isSelected = false,
//     bool isDestructive = false,
//   }) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//       decoration: BoxDecoration(
//         color: isSelected
//             ? Colors.blue.withValues(alpha: 0.1)
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         border: isSelected
//             ? Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1)
//             : null,
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         leading: Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: isDestructive
//                 ? Colors.red.withValues(alpha: 0.1)
//                 : isSelected
//                 ? Colors.blue.withValues(alpha: 0.2)
//                 : Colors.grey.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: isDestructive
//                 ? Colors.red[600]
//                 : isSelected
//                 ? Colors.blue[600]
//                 : Colors.grey[600],
//             size: 20,
//           ),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//             color: isDestructive
//                 ? Colors.red[600]
//                 : isSelected
//                 ? Colors.blue[600]
//                 : Colors.grey[800],
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[500],
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         trailing: isSelected
//             ? Container(
//                 padding: EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[600],
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Icon(Icons.check, color: Colors.white, size: 12),
//               )
//             : Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 color: Colors.grey[400],
//                 size: 14,
//               ),
//         onTap: onTap,
//       ),
//     );
//   }
// }


///////////////////////////////////////////////////


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/components/components.dart';
import 'package:vector_academy/controllers/controllers.dart';
import "package:vector_academy/models/models.dart";
import "package:vector_academy/services/services.dart";
import 'package:vector_academy/views/views.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDashboard extends StatelessWidget {
  HomeDashboard({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Get.put(HomeDashboardController());
    Get.put(NavigationDrawerController());
    Get.put(NotificationsController());

    return GetBuilder<HomeDashboardController>(
      builder: (controller) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: _buildNavigationDrawer(context),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, controller),
              // _buildPromotionalBanner(context, controller),
              if (controller.hasSearchQuery)
                Expanded(child: _buildGroupedSearchResults(context, controller))
              else
                Expanded(child: _buildSubjectSelection(context, controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: Icon(Icons.menu, color: Colors.black87),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            mouseCursor: SystemMouseCursors.click,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SearchTextField(
              controller: controller.homeSearchController,
              hint: 'Search courses, exams...',
              compact: true,
              onChanged: controller.updateSearchQuery,
              onClear: controller.clearSearch,
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final dynamicTelegramLink = controller.appHeader?.link?.trim();
                  final targetTelegramLink =
                      (dynamicTelegramLink != null &&
                          dynamicTelegramLink.isNotEmpty)
                      ? dynamicTelegramLink
                      : 'https://t.me/entrance_tricks';

                  if (!await launchUrl(Uri.parse(targetTelegramLink))) {
                    throw Exception('Could not launch $targetTelegramLink');
                  }
                },
                icon: Icon(Icons.telegram, color: Colors.blue[600], size: 35,),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                mouseCursor: SystemMouseCursors.click,
              ),
              // SizedBox(width: 2),
              GetBuilder<NotificationsController>(
                builder: (notificationsController) => Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.to(() => NotificationsPage());
                      },
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      mouseCursor: SystemMouseCursors.click,
                    ),
                    if (notificationsController.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${notificationsController.unreadCount > 9 ? "9+" : notificationsController.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPromotionalBanner(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            controller.appHeader?.gradientStart != null
                ? Color(
                    int.parse(
                      (controller.appHeader!.gradientStart!).replaceAll(
                        '#',
                        '0xFF',
                      ),
                    ),
                  )
                : Colors.blue,
            controller.appHeader?.gradientEnd != null
                ? Color(
                    int.parse(
                      (controller.appHeader!.gradientEnd!).replaceAll(
                        '#',
                        '0xFF',
                      ),
                    ),
                  )
                : Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.appHeader?.text ?? 'Ethio Entrance Tricks!',
                  style: TextStyle(
                    color: controller.appHeader?.textColor != null
                        ? Color(
                            int.parse(
                              (controller.appHeader!.textColor!).replaceAll(
                                '#',
                                '0xFF',
                              ),
                            ),
                          )
                        : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                if (controller.appHeader?.showTagLineText == true)
                  Text(
                    controller.appHeader?.tagLineText ?? 'For HighSchool Class',
                    style: TextStyle(
                      color: controller.appHeader?.tagLineTextColor != null
                          ? Color(
                              int.parse(
                                (controller.appHeader!.tagLineTextColor!)
                                    .replaceAll('#', '0xFF'),
                              ),
                            )
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse(
                    controller.appHeader?.link ??
                        'https://t.me/entrance_tricks',
                  ),
                )) {}
              },
              icon: Icon(Icons.telegram, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  ({double width, double height}) _featuredUpdateCardSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;
    final isTablet = screenWidth >= 768;
    final width = (screenWidth * (isCompact ? 0.34 : 0.30))
        .clamp(128.0, isTablet ? 168.0 : 152.0)
        .toDouble();
    return (width: width, height: width / 0.92);
  }

  Widget _buildFeaturedUpdatesBar(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    final featuredUpdates = controller.featuredUpdates;
    final isLoading =
        controller.isFeaturedUpdatesLoading && featuredUpdates.isEmpty;
    final cardSize = _featuredUpdateCardSize(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCBD5E1).withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  size: 16,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Latest News',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh updates',
                onPressed: () => controller.loadFeaturedUpdates(showLoader: false),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE2E8F0),
                  minimumSize: const Size(32, 32),
                  padding: const EdgeInsets.all(6),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            SizedBox(
              height: cardSize.height,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            )
          else if (featuredUpdates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Text(
                'No recent updates yet.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (!isLoading && featuredUpdates.isNotEmpty)
            SizedBox(
              height: cardSize.height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featuredUpdates.length,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) => SizedBox(
                  width: cardSize.width,
                  height: cardSize.height,
                  child: _buildFeaturedUpdateCard(
                    context,
                    featuredUpdates[index],
                    controller,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedUpdateCard(
    BuildContext context,
    FeaturedUpdateItem item,
    HomeDashboardController controller,
  ) {
    final theme = Theme.of(context);
    final isNews = item.type == FeaturedUpdateType.news;
    final label = isNews ? 'News' : 'Exam';
    final chipColor = isNews ? const Color(0xFF1D4ED8) : const Color(0xFF0F766E);
    final accentColor = isNews ? const Color(0xFFDBEAFE) : const Color(0xFFCCFBF1);
    final imageUrl = item.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    Widget thumbnailFallback() {
      return Container(
        color: chipColor.withValues(alpha: 0.1),
        child: Center(
          child: Icon(
            isNews ? Icons.article_outlined : Icons.quiz_outlined,
            color: chipColor,
            size: 28,
          ),
        ),
      );
    }

    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: chipColor.withValues(alpha: 0.08),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              thumbnailFallback(),
                        )
                      : thumbnailFallback(),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: chipColor.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.openFeaturedUpdate(item),
        borderRadius: BorderRadius.circular(10),
        child: card,
      ),
    );
  }

  Widget _buildGradeTabs(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.grades.length,
        itemBuilder: (context, index) {
          final grade = controller.grades[index];
          final isSelected = controller.selectedGradeIndex == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => controller.selectGrade(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
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
                            color: const Color(0xFF667eea).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      grade.name,
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
          );
        },
      ),
    );
  }

  Widget _buildSubjectSelection(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    final isInitialLoading =
        controller.isLoading && controller.subjects.isEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadGrades();
        await controller.loadSubjects();
        await controller.loadFeaturedUpdates(showLoader: false);
      },
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _buildFeaturedUpdatesBar(context, controller),
          ),
          if (controller.showGradeTabs)
            SliverToBoxAdapter(
              child: _buildGradeTabs(context, controller),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Subject Selection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          if (isInitialLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading subjects...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.subjects.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No subjects available yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = controller.subjects[index];
                    return _CourseTile(
                      subject: subject,
                      onTap: () => controller.selectSubject(subject.id),
                    );
                  },
                  childCount: controller.subjects.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupedSearchResults(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Results for "${controller.searchQuery}"',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: !controller.hasAnySearchResult
                ? _buildSearchEmptyState()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildChapterResultsSection(controller),
                      _buildExamResultsSection(controller),
                      _buildVideoResultsSection(controller),
                      _buildWorksheetResultsSection(controller),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Text(
        'No matches found. Try another keyword.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChapterResultsSection(HomeDashboardController controller) {
    if (controller.chapterResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Chapters',
      icon: Icons.menu_book_rounded,
      children: controller.chapterResults.map((chapter) {
        final subjectName = controller.getSubjectNameForChapter(chapter.id);
        return _buildSearchResultTile(
          title: chapter.name,
          subtitle:
              '$subjectName • Chapter ${chapter.chapterNumber}${(chapter.description ?? '').isNotEmpty ? ' • ${chapter.description}' : ''}',
          icon: Icons.article_outlined,
          onTap: () => controller.openChapterSearchResult(chapter),
        );
      }).toList(),
    );
  }

  Widget _buildExamResultsSection(HomeDashboardController controller) {
    if (controller.examResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Exams',
      icon: Icons.quiz_rounded,
      children: controller.examResults.map((exam) {
        return _buildSearchResultTile(
          title: exam.name,
          subtitle:
              '${exam.subject?.name ?? 'General'} • ${exam.examType.toUpperCase()}',
          icon: Icons.assignment_outlined,
          onTap: () => controller.openExam(exam.id),
        );
      }).toList(),
    );
  }

  Widget _buildVideoResultsSection(HomeDashboardController controller) {
    if (controller.videoResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Videos',
      icon: Icons.play_circle_outline_rounded,
      children: controller.videoResults.map((video) {
        final chapterName = controller.getChapterNameById(video.chapter);
        final subjectName = controller.getSubjectNameForChapter(video.chapter);
        return _buildSearchResultTile(
          title: video.title,
          subtitle: '$subjectName • $chapterName',
          icon: Icons.ondemand_video_outlined,
          onTap: () => controller.openVideoSearchResult(video),
        );
      }).toList(),
    );
  }

  Widget _buildWorksheetResultsSection(HomeDashboardController controller) {
    if (controller.worksheetResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Worksheets',
      icon: Icons.description_outlined,
      children: controller.worksheetResults.map((worksheet) {
        final chapterName = worksheet.chapter != null
            ? controller.getChapterNameById(worksheet.chapter!)
            : 'Unknown chapter';
        final subjectName = worksheet.chapter != null
            ? controller.getSubjectNameForChapter(worksheet.chapter!)
            : 'General';
        return _buildSearchResultTile(
          title: worksheet.title,
          subtitle: '$subjectName • $chapterName',
          icon: Icons.note_alt_outlined,
          onTap: () => controller.openWorksheetSearchResult(worksheet),
        );
      }).toList(),
    );
  }

  Widget _buildSearchSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSearchResultTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final coreService = Get.find<CoreService>();
    final isAuthenticated = coreService.authService.isAuthenticated;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAuthenticated ? 'Welcome back,' : 'Welcome,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          isAuthenticated
                              ? (coreService.authService.user.value?.firstName ??
                                  'User')
                              : 'Guest',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          isAuthenticated
                              ? (coreService.authService.user.value?.phoneNumber ??
                                  '')
                              : 'Sign up to purchase courses',
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10),
                physics: BouncingScrollPhysics(),
                children: [
                  _buildSectionHeader('Main Navigation'),
                  _buildModernDrawerMenuItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    subtitle: 'Dashboard & Overview',
                    onTap: () {
                      Get.find<MainNavigationController>().changeIndex(0);
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 0,
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.quiz_rounded,
                    title: 'Exams',
                    subtitle: 'Practice & Mock Tests',
                    onTap: () {
                      Get.find<MainNavigationController>().changeIndex(1);
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 1,
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.article_rounded,
                    title: 'News',
                    subtitle: 'Latest Updates',
                    onTap: () {
                      Get.find<MainNavigationController>().changeIndex(2);
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 2,
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    subtitle: 'Account & Settings',
                    onTap: () {
                      Navigator.of(context).pop(); // Close drawer
                      Get.to(() => ProfilePage());
                    },
                    isSelected: false,
                  ),
                  // SizedBox(height: 20),
                  // _buildSectionHeader('Payments'),
                  // _buildModernDrawerMenuItem(
                  //   icon: Icons.payment_rounded,
                  //   title: 'Payments',
                  //   subtitle: 'View your payments',
                  //   onTap: () => Get.toNamed(VIEWS.payments.path),
                  // ),
                  // SizedBox(height: 20),
                  // _buildModernDrawerMenuItem(
                  //   icon: Icons.history_rounded,
                  //   title: 'Payment History',
                  //   subtitle: 'View your payment history',
                  //   onTap: () => Get.toNamed(VIEWS.paymentHistory.path),
                  // ),

                  SizedBox(height: 20),

                  _buildSectionHeader('Study Materials'),
                  _buildModernDrawerMenuItem(
                    icon: Icons.book_rounded,
                    title: 'Subjects',
                    subtitle: 'Browse all subjects',
                    onTap: () => Get.toNamed(VIEWS.subjects.path),
                  ),

                  SizedBox(height: 20),

                  _buildSectionHeader('Tools & Features'),

                  _buildModernDrawerMenuItem(
                    icon: Icons.download_rounded,
                    title: 'Downloads',
                    subtitle: 'Offline content',
                    onTap: () => Get.toNamed(VIEWS.downloads.path),
                  ),

                  SizedBox(height: 20),

                  _buildSectionHeader('Support'),
                  _buildModernDrawerMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQ',
                    subtitle: 'Frequently asked questions',
                    onTap: () => Get.toNamed(VIEWS.faq.path),
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.headset_mic_rounded,
                    title: 'Support',
                    subtitle: 'Get help & support',
                    onTap: () => Get.toNamed(VIEWS.support.path),
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'App information',
                    onTap: () => Get.toNamed(VIEWS.about.path),
                  ),

                  SizedBox(height: 20),

                  if (isAuthenticated)
                    _buildModernDrawerMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      onTap: () {
                        Get.find<NavigationDrawerController>().logout();
                      },
                      isDestructive: true,
                    )
                  else ...[
                    _buildModernDrawerMenuItem(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Sign Up',
                      subtitle: 'Create an account',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(VIEWS.register.path);
                      },
                    ),
                    _buildModernDrawerMenuItem(
                      icon: Icons.login_rounded,
                      title: 'Login',
                      subtitle: 'Already have an account',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(VIEWS.login.path);
                      },
                    ),
                  ],

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModernDrawerMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : isSelected
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? Colors.red[600]
                : isSelected
                ? Colors.blue[600]
                : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isDestructive
                ? Colors.red[600]
                : isSelected
                ? Colors.blue[600]
                : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: isSelected
            ? Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 14,
              ),
        onTap: onTap,
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  bool get _hasIcon => subject.icon != null && subject.icon!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: onSurfaceVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _hasIcon
                  ? CachedNetworkImage(
                      imageUrl: subject.icon!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: accent.withValues(alpha: 0.08),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _thumbnailFallback(accent),
                    )
                  : _thumbnailFallback(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subject.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: card,
      ),
    );
  }

  Widget _thumbnailFallback(Color accent) {
    return Container(
      color: accent.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: accent,
          size: 28,
        ),
      ),
    );
  }
}
