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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
              ? _SignedOutParent(
                  onCreateAccount: openParentRegistration,
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

class _SignedOutParent extends StatelessWidget {
  const _SignedOutParent({
    required this.onCreateAccount,
    required this.onUseAsStudent,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onUseAsStudent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Image.asset(FlavorConfig.logoAsset, height: 88),
        const SizedBox(height: 24),
        Text(
          'Create your parent account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register with your own phone number. After that, enter your child\'s number and wait for them to accept. You can then see their exams and buy courses, exams, and plans for them.',
          style: TextStyle(fontSize: 15, height: 1.4, color: Colors.grey[700]),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onCreateAccount,
          child: const Text('Create account or log in'),
        ),
        TextButton(
          onPressed: onUseAsStudent,
          child: const Text('Use the app as a student'),
        ),
      ],
    );
  }
}
