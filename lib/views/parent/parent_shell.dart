import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/parent/parent_mode_controller.dart';
import 'package:vector_academy/flavors/flavor_config.dart';
import 'package:vector_academy/services/auth.dart';
import 'package:vector_academy/utils/auth_guard.dart';
import 'package:vector_academy/utils/snackbar_utils.dart';
import 'package:vector_academy/utils/storages/config.dart';
import 'package:vector_academy/views/parent/parent_link_page.dart';

/// Home for a parent who has not yet opened the accepted-child dashboard.
class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentPhoneController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  var _guestStep = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _studentPhoneController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submitGuest(ParentModeController controller) async {
    final ok = await controller.requestGuestLink(
      childPhone: _studentPhoneController.text,
      parentName: _parentNameController.text,
      parentPhone: _parentPhoneController.text,
    );
    if (!mounted) return;
    if (ok) {
      final link = controller.link;
      AppSnackbar.showSuccess(
        'Request sent',
        link?.isAccepted == true
            ? '${link!.childName} is already linked.'
            : 'Waiting for your child to accept on their phone.',
      );
    } else if (controller.error != null) {
      AppSnackbar.showError('Parent Mode', controller.error!);
    }
  }

  Future<void> _submit(ParentModeController controller) async {
    final ok = await controller.requestLink(_phoneController.text);
    if (!mounted) return;
    if (ok) {
      _phoneController.clear();
      final link = controller.link;
      AppSnackbar.showSuccess(
        'Request sent',
        link?.isAccepted == true
            ? '${link!.childName} is already linked to your account.'
            : 'Waiting for your child to accept on their phone.',
      );
    } else if (controller.error != null) {
      AppSnackbar.showError('Parent Mode', controller.error!);
    }
  }

  Future<void> _useAsStudent(ParentModeController controller) async {
    await controller.chooseAudience(AppAudience.student);
    goToStartupRoute();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParentModeController>(
      builder: (controller) {
        final signedIn =
            Get.isRegistered<AuthService>() &&
            Get.find<AuthService>().isAuthenticated;
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black87,
            title: const Text(
              'Parent Mode',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (signedIn)
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: controller.loading
                      ? null
                      : controller.refreshOverview,
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          body: !signedIn
              ? _GuestParentForm(
                  step: _guestStep,
                  studentPhoneController: _studentPhoneController,
                  parentNameController: _parentNameController,
                  parentPhoneController: _parentPhoneController,
                  submitting: controller.submitting,
                  error: controller.error,
                  onContinue: () {
                    setState(() => _guestStep = 1);
                  },
                  onBack: () {
                    setState(() => _guestStep = 0);
                  },
                  onSubmit: () => _submitGuest(controller),
                  onUseAsStudent: () => _useAsStudent(controller),
                )
              : RefreshIndicator(
                  onRefresh: controller.refreshOverview,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'See your child\'s learning progress',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the phone number they used to register. They must accept the request before you can see their exams and buy courses for them.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (controller.loading && controller.link == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (controller.link?.isPending == true)
                        ParentPendingCard(controller: controller)
                      else
                        ParentPhoneRequestForm(
                          controller: controller,
                          phoneController: _phoneController,
                          onSubmit: () => _submit(controller),
                        ),
                      if (controller.link?.isRejected == true) ...[
                        const SizedBox(height: 16),
                        Text(
                          'The last request was declined. You can send a new one.',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ],
                      if (controller.error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          controller.error!,
                          style: const TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ],
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: controller.submitting
                            ? null
                            : () => _useAsStudent(controller),
                        child: const Text('Use the app as a student'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _GuestParentForm extends StatelessWidget {
  const _GuestParentForm({
    required this.step,
    required this.studentPhoneController,
    required this.parentNameController,
    required this.parentPhoneController,
    required this.submitting,
    required this.error,
    required this.onContinue,
    required this.onBack,
    required this.onSubmit,
    required this.onUseAsStudent,
  });

  final int step;
  final TextEditingController studentPhoneController;
  final TextEditingController parentNameController;
  final TextEditingController parentPhoneController;
  final bool submitting;
  final String? error;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onUseAsStudent;

  @override
  Widget build(BuildContext context) {
    final askingForStudent = step == 0;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Image.asset(FlavorConfig.logoAsset, height: 88),
        const SizedBox(height: 24),
        Text(
          askingForStudent ? 'Your child\'s phone' : 'Your name and phone',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          askingForStudent
              ? 'Enter the phone number your child used to register. You do not need to create an account.'
              : 'Enter your name and phone number. We will ask your child to accept before you can see their exams.',
          style: TextStyle(fontSize: 15, height: 1.4, color: Colors.grey[700]),
        ),
        const SizedBox(height: 24),
        if (askingForStudent)
          TextField(
            controller: studentPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Child\'s phone number',
              hintText: '9xxxxxxxx',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          )
        else ...[
          TextField(
            controller: parentNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Your name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: parentPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Your phone number',
              hintText: '9xxxxxxxx',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(error!, style: const TextStyle(color: Color(0xFFEF4444))),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: submitting
              ? null
              : askingForStudent
              ? onContinue
              : onSubmit,
          child: submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(askingForStudent ? 'Continue' : 'Send confirmation request'),
        ),
        if (!askingForStudent)
          TextButton(onPressed: submitting ? null : onBack, child: const Text('Back')),
        TextButton(
          onPressed: submitting ? null : onUseAsStudent,
          child: const Text('Use the app as a student'),
        ),
      ],
    );
  }
}
