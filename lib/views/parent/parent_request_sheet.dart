import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/parent/parent_mode_controller.dart';
import 'package:vector_academy/flavors/flavor_config.dart';
import 'package:vector_academy/models/parent_link.dart';
import 'package:vector_academy/services/api/exceptions.dart';
import 'package:vector_academy/utils/snackbar_utils.dart';

bool _promptedParentRequests = false;

Future<void> maybePromptParentRequests({bool force = false}) async {
  if ((!force && _promptedParentRequests) || !FlavorConfig.supportsParentMode) {
    return;
  }
  _promptedParentRequests = true;
  if (!Get.isRegistered<ParentModeController>()) return;
  try {
    final incoming = await Get.find<ParentModeController>().loadIncoming();
    if (incoming.isEmpty) return;
    final context = Get.overlayContext ?? Get.context;
    if (context == null || !context.mounted) return;
    await showParentRequestSheet(context, incoming);
  } catch (_) {
    // A failed prompt should not block the home screen.
  }
}

Future<void> openParentLinkRequests(BuildContext context) async {
  if (!FlavorConfig.supportsParentMode) return;
  if (!Get.isRegistered<ParentModeController>()) {
    Get.put(ParentModeController());
  }
  try {
    final incoming = await Get.find<ParentModeController>().loadIncoming();
    if (!context.mounted) return;
    if (incoming.isEmpty) {
      AppSnackbar.showInfo(
        'Parent Mode',
        'There are no pending parent requests.',
      );
      return;
    }
    await showParentRequestSheet(context, incoming);
  } catch (error) {
    AppSnackbar.showError('Parent Mode', ApiErrorMessage.from(error));
  }
}

Future<void> showParentRequestSheet(
  BuildContext context,
  List<ParentLink> requests,
) async {
  var remaining = List<ParentLink>.from(requests);
  while (remaining.isNotEmpty && context.mounted) {
    final request = remaining.removeAt(0);
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ParentRequestSheet(request: request),
    );
    if (accepted == null) return;
    if (!context.mounted) return;
  }
}

class _ParentRequestSheet extends StatefulWidget {
  const _ParentRequestSheet({required this.request});

  final ParentLink request;

  @override
  State<_ParentRequestSheet> createState() => _ParentRequestSheetState();
}

class _ParentRequestSheetState extends State<_ParentRequestSheet> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    setState(() => _busy = true);
    try {
      await Get.find<ParentModeController>().respondToRequest(
        widget.request.id,
        accept: accept,
      );
      if (!mounted) return;
      Navigator.pop(context, accept);
      AppSnackbar.showSuccess(
        'Parent Mode',
        accept
            ? 'You accepted the parent request.'
            : 'You declined the parent request.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnackbar.showError('Parent Mode', ApiErrorMessage.from(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              'Parent Mode request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${request.parentName} (${request.parentPhone}) wants to view your learning status, study program, exam results, and activity.',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _respond(false),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy ? null : () => _respond(true),
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
