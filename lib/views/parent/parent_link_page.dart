import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/parent/parent_mode_controller.dart';
import 'package:vector_academy/utils/navigation_utils.dart';
import 'package:vector_academy/utils/snackbar_utils.dart';

class ParentLinkPage extends StatefulWidget {
  const ParentLinkPage({super.key});

  @override
  State<ParentLinkPage> createState() => _ParentLinkPageState();
}

class _ParentLinkPageState extends State<ParentLinkPage> {
  final TextEditingController _phoneController = TextEditingController();

  ParentModeController get _controller {
    if (!Get.isRegistered<ParentModeController>()) {
      Get.put(ParentModeController());
    }
    return Get.find<ParentModeController>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.bootstrap();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await _controller.requestLink(_phoneController.text);
    if (!mounted) return;
    if (ok) {
      _phoneController.clear();
      final link = _controller.link;
      AppSnackbar.showSuccess(
        'Request sent',
        link?.isAccepted == true
            ? '${link!.childName} is already linked to your account.'
            : 'Waiting for your child to accept on their phone.',
      );
    } else if (_controller.error != null) {
      AppSnackbar.showError('Parent Mode', _controller.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParentModeController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          title: const Text(
            'Parent Mode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => safePop(context: context),
          ),
        ),
        body: controller.loading && controller.link == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
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
                    'Enter the phone number they used to register. They must accept the request before you can see their account.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (controller.link?.isPending == true)
                    ParentPendingCard(controller: controller)
                  else if (controller.link?.isAccepted == true)
                    _AcceptedCard(controller: controller)
                  else
                    ParentPhoneRequestForm(
                      controller: controller,
                      phoneController: _phoneController,
                      onSubmit: _submit,
                    ),
                  if (controller.link?.isRejected == true) ...[
                    const SizedBox(height: 16),
                    Text(
                      'The last request was declined. You can send a new one.',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class ParentPhoneRequestForm extends StatelessWidget {
  const ParentPhoneRequestForm({
    super.key,
    required this.controller,
    required this.phoneController,
    required this.onSubmit,
  });

  final ParentModeController controller;
  final TextEditingController phoneController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Child\'s phone number',
            hintText: '9xxxxxxxx',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.submitting ? null : onSubmit,
            child: controller.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send confirmation request'),
          ),
        ),
      ],
    );
  }
}

class ParentPendingCard extends StatelessWidget {
  const ParentPendingCard({super.key, required this.controller});

  final ParentModeController controller;

  @override
  Widget build(BuildContext context) {
    final link = controller.link!;
    return _StatusCard(
      icon: Icons.hourglass_top,
      title: 'Waiting for ${link.childName}',
      body:
          'A confirmation request was sent to ${link.childPhone}. Parent Mode opens after they accept.',
      actionLabel: 'Cancel request',
      busy: controller.submitting,
      onPressed: () async {
        await controller.cancelOrUnlink();
        if (controller.error != null) {
          AppSnackbar.showError('Parent Mode', controller.error!);
        }
      },
    );
  }
}

class _AcceptedCard extends StatelessWidget {
  const _AcceptedCard({required this.controller});

  final ParentModeController controller;

  @override
  Widget build(BuildContext context) {
    final link = controller.link!;
    return _StatusCard(
      icon: Icons.family_restroom,
      title: '${link.childName} accepted',
      body:
          'Open Parent Mode to see their learning status, study program, exam results, and activity. You can leave it anytime and keep using your own account.',
      actionLabel: 'Open Parent Mode',
      busy: controller.submitting || controller.loading,
      onPressed: controller.openDashboard,
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
    required this.busy,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6366F1)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(height: 1.4, color: Colors.grey[700])),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: busy ? null : onPressed,
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
