import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/controllers.dart';
import 'package:vector_academy/models/models.dart';

class StudyPlannerPage extends StatelessWidget {
  const StudyPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudyPlannerController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Study Planner',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blue[600],
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (controller.isShowingOfflineData) _buildOfflineNotice(),
              Expanded(
                child: controller.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => controller.loadStudyPlans(),
                        child: CustomScrollView(
                          slivers: [
                            // Day Filter
                            SliverToBoxAdapter(
                              child: _buildDayFilter(context, controller),
                            ),

                            // Filtered Plans
                            if (controller.filteredPlans.isNotEmpty)
                              SliverToBoxAdapter(
                                child: _buildSectionHeader(
                                  context,
                                  _getFilterTitle(controller.selectedFilterDate),
                                  Icons.calendar_today_rounded,
                                ),
                              ),
                            if (controller.filteredPlans.isNotEmpty)
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildPlanCard(
                                    context,
                                    controller.filteredPlans[index],
                                    controller,
                                  ),
                                  childCount: controller.filteredPlans.length,
                                ),
                              ),

                            // Empty State
                            if (controller.filteredPlans.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(context, controller),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => controller.showAddPlanDialog(),
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Plan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blue[600],
        ),
      ),
    );
  }

  Widget _buildDayFilter(
    BuildContext context,
    StudyPlannerController controller,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = controller.selectedFilterDate ?? today;

    // Generate 7 days starting from today
    final days = List.generate(7, (index) {
      return today.add(Duration(days: index));
    });

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: days.map((date) {
            final isSelected =
                selectedDate.year == date.year &&
                selectedDate.month == date.month &&
                selectedDate.day == date.day;
            final isToday =
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            return GestureDetector(
              onTap: () => controller.setFilterDate(date),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[600] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: Colors.blue[600]!, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getDayAbbreviation(date.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? Colors.blue[600]
                            : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? Colors.blue[600]
                            : Colors.grey[800],
                      ),
                    ),
                    if (isToday && !isSelected)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOfflineNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD89C)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFF8A5A00)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline – showing saved data",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A5A00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayAbbreviation(int weekday) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getFilterTitle(DateTime? date) {
    if (date == null) return 'Today\'s Schedule';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final filterDate = DateTime(date.year, date.month, date.day);

    if (filterDate.year == today.year &&
        filterDate.month == today.month &&
        filterDate.day == today.day) {
      return 'Today\'s Schedule';
    } else if (filterDate.year == tomorrow.year &&
        filterDate.month == tomorrow.month &&
        filterDate.day == tomorrow.day) {
      return 'Tomorrow\'s Schedule';
    } else {
      final daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final dayName = daysOfWeek[date.weekday - 1];
      return '$dayName\'s Schedule';
    }
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    StudyPlan plan,
    StudyPlannerController controller,
  ) {
    // Check completion for the selected filter date
    final filterDate = controller.selectedFilterDate;
    final targetDate = filterDate ?? DateTime.now();
    final targetDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCompleted = plan.isCompletedForDate(targetDateOnly);

    // Check if task is overdue (past date or past end time on selected day)
    bool isOverdue = false;
    // Use endDate if available, otherwise fall back to dueDate
    final endDateTime = plan.endDate ?? plan.dueDate;
    if (!isCompleted && endDateTime != null) {
      // Check if the selected date is in the past
      if (targetDateOnly.isBefore(today)) {
        isOverdue = true;
      }
      // Check if it's today and the end time has passed
      else if (targetDateOnly.year == today.year &&
          targetDateOnly.month == today.month &&
          targetDateOnly.day == today.day) {
        // For repeating plans, check if it repeats on today
        // For non-repeating plans, check if the plan's date matches today
        final effectiveDate = plan.effectiveDate;
        final isRepeatingOnToday =
            plan.isRepeating &&
            plan.repeatDays.contains(targetDateOnly.weekday);
        final isNonRepeatingOnToday =
            !plan.isRepeating &&
            effectiveDate != null &&
            effectiveDate.year == today.year &&
            effectiveDate.month == today.month &&
            effectiveDate.day == today.day;

        if (isRepeatingOnToday || isNonRepeatingOnToday) {
          // Create a DateTime for today with the plan's end time
          final planEndDateTime = DateTime(
            today.year,
            today.month,
            today.day,
            endDateTime.hour,
            endDateTime.minute,
          );
          // Mark as overdue if the end time has passed
          if (planEndDateTime.isBefore(now)) {
            isOverdue = true;
          }
        }
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? Colors.red[400]!
              : isCompleted
              ? Colors.green[200]!
              : Colors.grey[200]!,
          width: isOverdue ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showPlanDetails(plan),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox - separate tap handler to prevent InkWell interference
                GestureDetector(
                  onTap: () {
                    final filterDate = controller.selectedFilterDate;
                    controller.togglePlanCompletion(plan, filterDate);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green[600]!
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isCompleted
                            ? Colors.green[600]
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? Colors.grey[500]
                              : Colors.grey[800],
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (plan.description.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          plan.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            flex: 2,
                            child: Text(
                              _formatTimeRange(plan),
                              style: TextStyle(
                                fontSize: 12,
                                color: plan.effectiveDate != null
                                    ? (isOverdue
                                          ? Colors.red[600]
                                          : Colors.grey[600])
                                    : Colors.grey[400],
                                fontWeight: isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (plan.subject.isNotEmpty) ...[
                            SizedBox(width: 12),
                            Icon(
                              Icons.book_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              flex: 3,
                              child: Text(
                                plan.subject,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (plan.isRepeating) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 14,
                              color: Colors.blue[600],
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _formatRepeatDays(plan.repeatDays),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    StudyPlannerController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'No Study Plans Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first study plan to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => controller.showAddPlanDialog(),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Create Plan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRange(StudyPlan plan) {
    if (plan.startDate == null &&
        plan.endDate == null &&
        plan.dueDate == null) {
      return 'No date set';
    }

    // Use startDate/endDate if available, otherwise fall back to dueDate
    final startDate = plan.startDate;
    final endDate = plan.endDate;
    final dueDate = plan.dueDate;

    if (startDate != null && endDate != null) {
      // Show time range: "09:00 - 10:00" or "Today, 09:00 - 10:00"
      final startTime =
          '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';
      final endTime =
          '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDateOnly = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      if (startDateOnly == today) {
        return 'Today, $startTime - $endTime';
      } else if (startDateOnly == today.add(Duration(days: 1))) {
        return 'Tomorrow, $startTime - $endTime';
      } else {
        final daysOfWeek = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        final dayOfWeek = daysOfWeek[startDate.weekday - 1];
        return '$dayOfWeek, ${startDate.day}/${startDate.month}/${startDate.year} $startTime - $endTime';
      }
    } else if (startDate != null) {
      // Only start time
      return _formatDateTime(startDate);
    } else if (endDate != null) {
      // Only end time
      return _formatDateTime(endDate);
    } else if (dueDate != null) {
      // Fall back to dueDate
      return _formatDateTime(dueDate);
    }

    return 'No date set';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayOfWeek = daysOfWeek[dateTime.weekday - 1];

    if (date == today) {
      return 'Today, $dayOfWeek ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (date == today.add(Duration(days: 1))) {
      return 'Tomorrow, $dayOfWeek ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '$dayOfWeek, ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatRepeatDays(List<int> days) {
    if (days.isEmpty) return '';

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(days)..sort();

    if (sortedDays.length == 7) {
      return 'Every day';
    } else if (sortedDays.length == 5 &&
        sortedDays.contains(1) &&
        sortedDays.contains(2) &&
        sortedDays.contains(3) &&
        sortedDays.contains(4) &&
        sortedDays.contains(5)) {
      return 'Weekdays';
    } else if (sortedDays.length == 2 &&
        sortedDays.contains(6) &&
        sortedDays.contains(7)) {
      return 'Weekends';
    } else {
      return 'Repeats: ${sortedDays.map((d) => dayNames[d - 1]).join(', ')}';
    }
  }
}
