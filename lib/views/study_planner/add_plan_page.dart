import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/controllers.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/navigation_utils.dart';

class AddPlanPage extends StatelessWidget {
  const AddPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPlanController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            controller.plan == null ? 'Create Study Plan' : 'Edit Study Plan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blue[600],
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => safePop(context: context),
          ),
        ),
        body: _AddPlanForm(),
      ),
    );
  }
}

class _AddPlanForm extends StatelessWidget {
  const _AddPlanForm();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPlanController>(
      builder: (controller) => SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Field
                TextFormField(
                  controller: controller.titleController,
                  enabled: !controller.isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g., Review Math Chapter 5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  autofocus: controller.plan == null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 20),

                // Description Field
                TextFormField(
                  controller: controller.descriptionController,
                  enabled: !controller.isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add notes or details...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 20),

                // Courses Dropdown
                _CoursesDropdown(controller: controller),
                SizedBox(height: 30),

                // Date and Time Section
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: controller.isSubmitting
                      ? null
                      : () => controller.selectDate(context),
                  child: Opacity(
                    opacity: controller.isSubmitting ? 0.6 : 1.0,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.blue[600],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date (Optional)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  controller.selectedDate != null
                                      ? '${controller.getDayOfWeek(controller.selectedDate!)}, ${controller.selectedDate!.day}/${controller.selectedDate!.month}/${controller.selectedDate!.year}'
                                      : 'No date set',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: controller.selectedDate != null
                                        ? Colors.grey[800]
                                        : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (controller.selectedDate != null)
                            IconButton(
                              icon: Icon(Icons.close, size: 20),
                              color: Colors.grey[400],
                              onPressed: controller.isSubmitting
                                  ? null
                                  : controller.clearDate,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Local / Foreign time toggle
                Text(
                  'Time format',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeModeChip(
                          label: 'Local time',
                          subtitle: 'Ethiopian',
                          selected: controller.useLocalTime,
                          enabled: !controller.isSubmitting,
                          onTap: () => controller.setUseLocalTime(true),
                        ),
                      ),
                      Expanded(
                        child: _TimeModeChip(
                          label: 'Foreign time',
                          subtitle: 'Western',
                          selected: !controller.useLocalTime,
                          enabled: !controller.isSubmitting,
                          onTap: () => controller.setUseLocalTime(false),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                // Start Time Picker
                InkWell(
                  onTap: controller.isSubmitting
                      ? null
                      : () => controller.selectStartTime(context),
                  child: Opacity(
                    opacity: controller.isSubmitting ? 0.6 : 1.0,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.green[600],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Time (${controller.timeModeLabel}) *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  controller.formatStartTimeDisplay(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: controller.startTime != null
                                        ? Colors.grey[800]
                                        : controller.selectedDate != null
                                        ? Colors.red[400]
                                        : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // End Time Picker
                InkWell(
                  onTap: controller.isSubmitting
                      ? null
                      : () => controller.selectEndTime(context),
                  child: Opacity(
                    opacity: controller.isSubmitting ? 0.6 : 1.0,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.stop_rounded,
                              color: Colors.red[600],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Time (${controller.timeModeLabel}) *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  controller.formatEndTimeDisplay(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: controller.endTime != null
                                        ? Colors.grey[800]
                                        : controller.selectedDate != null
                                        ? Colors.red[400]
                                        : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Repeat Days Section
                Text(
                  'Repeat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Select days of the week to repeat this plan',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      final day = index + 1; // 1=Monday, 7=Sunday
                      final isSelected = controller.selectedDays.contains(day);
                      return GestureDetector(
                        onTap: controller.isSubmitting
                            ? null
                            : () => controller.toggleDay(day),
                        child: Opacity(
                          opacity: controller.isSubmitting ? 0.6 : 1.0,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[600]
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[600]!
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                controller.dayNames[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (controller.selectedDays.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.repeat_rounded,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Repeats on: ${controller.selectedDays.map((d) => controller.dayNames[d - 1]).join(', ')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 40),

                // Save Button
                ElevatedButton(
                  onPressed: controller.isSubmitting
                      ? null
                      : controller.savePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: Colors.grey[400],
                    disabledForegroundColor: Colors.white,
                  ),
                  child: controller.isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          controller.plan == null
                              ? 'Create Plan'
                              : 'Update Plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoursesDropdown extends StatelessWidget {
  final AddPlanController controller;

  const _CoursesDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingCourses && controller.courses.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Courses',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.book_rounded),
        ),
        child: SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    final items = <DropdownMenuItem<Subject>>[
      ...controller.courses.map(
        (course) => DropdownMenuItem<Subject>(
          value: course,
          child: Text(course.name, overflow: TextOverflow.ellipsis),
        ),
      ),
    ];

    // Legacy free-text subject that isn't in the courses list
    final hasLegacy =
        controller.legacySubjectName != null &&
        controller.legacySubjectName!.isNotEmpty &&
        controller.selectedCourse == null;

    return DropdownButtonFormField<Subject>(
      value: controller.selectedCourseForDropdown,
      items: items,
      onChanged: controller.isSubmitting || controller.courses.isEmpty
          ? null
          : controller.selectCourse,
      decoration: InputDecoration(
        labelText: 'Courses',
        hintText: controller.courses.isEmpty
            ? 'No courses available'
            : hasLegacy
            ? controller.legacySubjectName
            : 'Select a course',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.book_rounded),
      ),
      isExpanded: true,
    );
  }
}

class _TimeModeChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeModeChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: Colors.blue[600]!, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.blue[700] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.blue[600] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
