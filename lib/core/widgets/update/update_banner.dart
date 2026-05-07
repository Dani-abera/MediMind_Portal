import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/app_update_service.dart';

class UpdateBanner extends StatelessWidget {
  final AppVersionInfo info;

  const UpdateBanner({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    if (info.status == UpdateStatus.upToDate) return const SizedBox.shrink();

    final isForce = info.status == UpdateStatus.forceUpdate;
    final color = isForce ? const Color(0xFFDC2626) : const Color(0xFF2563EB);

    return Material(
      color: Colors.transparent,
      child: Container(
        color: color,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.system_update, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isForce
                    ? 'A required update (v${info.latest}) is available. Please update to continue.'
                    : 'Update available: v${info.latest}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (info.downloadUrl != null)
              TextButton(
                onPressed: () => launchUrl(Uri.parse(info.downloadUrl!)),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Download'),
              ),
          ],
        ),
      ),
    );
  }
}

class ForceUpdateScreen extends StatelessWidget {
  final AppVersionInfo info;

  const ForceUpdateScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.system_update, size: 64, color: Color(0xFFDC2626)),
                  const SizedBox(height: 24),
                  const Text(
                    'Update Required',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This version of MediMind Portal is no longer supported. '
                    'Please download version ${info.latest} to continue.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 32),
                  if (info.downloadUrl != null)
                    FilledButton.icon(
                      onPressed: () => launchUrl(Uri.parse(info.downloadUrl!)),
                      icon: const Icon(Icons.download),
                      label: const Text('Download Latest Version'),
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
