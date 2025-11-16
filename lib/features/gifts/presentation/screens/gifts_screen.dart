import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/gift_providers.dart';

class GiftsScreen extends ConsumerWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientsAsync = ref.watch(recipientsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Planning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: recipientsAsync.when(
        data: (recipients) {
          if (recipients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.card_giftcard, size: 64, color: AppTheme.lightGrey),
                  const SizedBox(height: 16),
                  const Text('No recipients yet'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddRecipientDialog(context, ref),
                    child: const Text('Add Recipient'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipients.length,
            itemBuilder: (context, index) {
              final recipient = recipients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.christmasRed,
                    child: Text(
                      recipient.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(recipient.name),
                  subtitle: Text('Budget: \$${recipient.budgetLimit.toStringAsFixed(2)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.push('/gifts/recipient/${recipient.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipientDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecipientDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement add recipient dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add recipient dialog - to be implemented')),
    );
  }
}
