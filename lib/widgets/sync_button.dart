import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SyncButton extends StatefulWidget {
  final VoidCallback onSyncComplete;

  const SyncButton({super.key, required this.onSyncComplete});

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleSync() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.performMorningSync();
      widget.onSyncComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.sync),
      tooltip: 'Morning Sync',
      onPressed: _handleSync,
    );
  }
}
