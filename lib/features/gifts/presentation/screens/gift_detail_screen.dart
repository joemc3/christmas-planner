import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GiftDetailScreen extends ConsumerWidget {
  final String giftId;

  const GiftDetailScreen({super.key, required this.giftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
      ),
      body: const Center(
        child: Text('Gift detail view'),
      ),
    );
  }
}
