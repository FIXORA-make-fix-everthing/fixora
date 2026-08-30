import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isSosActive = context.watch<AppState>().isSosActive;

    return FloatingActionButton.extended(
      onPressed: isSosActive ? () => context.read<AppState>().cancelSos() : () => _showSosConfirmationDialog(context),
      backgroundColor: isSosActive ? Colors.grey : Colors.redAccent,
      icon: Icon(isSosActive ? Icons.cancel : Icons.sos, color: Colors.white),
      label: Text(
        isSosActive ? 'Cancel SOS' : 'Emergency SOS',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showSosConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm SOS', style: TextStyle(color: Colors.red)),
        content: const Text(
          'Are you sure you want to trigger an Emergency SOS? This will alert dispatch services immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AppState>().triggerSos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS Alert triggered!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('TRIGGER SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
