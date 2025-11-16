import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/gift_providers.dart';

class RecipientDetailScreen extends ConsumerWidget {
  final String recipientId;

  const RecipientDetailScreen({super.key, required this.recipientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(recipientByIdProvider(recipientId));
    final giftsAsync = ref.watch(giftsByRecipientProvider(recipientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: recipientAsync.when(
        data: (recipient) {
          if (recipient == null) {
            return const Center(child: Text('Recipient not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.christmasRed,
                    child: Text(
                      recipient.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    recipient.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                if (recipient.relationship != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      recipient.relationship!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget: \$${recipient.budgetLimit.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gifts',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add Gift'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                giftsAsync.when(
                  data: (gifts) {
                    if (gifts.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No gifts added yet'),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gifts.length,
                      itemBuilder: (context, index) {
                        final gift = gifts[index];
                        return Card(
                          child: ListTile(
                            title: Text(gift.name),
                            subtitle: Text('\$${gift.price.toStringAsFixed(2)}'),
                            trailing: Chip(
                              label: Text(gift.status.value),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
