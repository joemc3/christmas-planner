import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/shopping_list_model.dart';
import '../../data/repositories/shopping_repository.dart';

// Providers
final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository();
});

final shoppingListsProvider = StreamProvider<List<ShoppingListModel>>((ref) {
  final repository = ref.watch(shoppingRepositoryProvider);
  return repository.watchShoppingLists();
});

final selectedListIdProvider = StateProvider<String?>((ref) => null);

final shoppingItemsProvider = StreamProvider.family<List<ShoppingListItemModel>, String>((ref, listId) {
  final repository = ref.watch(shoppingRepositoryProvider);
  return repository.watchShoppingListItems(listId);
});

final shoppingListStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, listId) async {
  final repository = ref.watch(shoppingRepositoryProvider);
  return repository.getShoppingListStats(listId);
});

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final selectedListId = ref.watch(selectedListIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddListDialog(context, ref),
          ),
        ],
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'No shopping lists yet',
              subtitle: 'Create a list to start tracking your purchases',
              actionText: 'Create List',
              onAction: () => _showAddListDialog(context, ref),
            );
          }

          if (selectedListId == null && lists.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedListIdProvider.notifier).state = lists.first.id;
            });
          }

          return Column(
            children: [
              Container(
                height: 48,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    final isSelected = list.id == selectedListId;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedListIdProvider.notifier).state = list.id;
                        },
                        child: AnimatedContainer(
                          duration: FrostedHearthTiming.quick,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FrostedHearthColors.spruce
                                : FrostedHearthColors.snow,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? FrostedHearthColors.spruce
                                  : FrostedHearthColors.parchmentWarm,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              list.name,
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected
                                    ? FrostedHearthColors.frostGold
                                    : FrostedHearthColors.inkMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (selectedListId != null)
                Expanded(child: _ShoppingListContent(listId: selectedListId)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load shopping lists')),
      ),
      floatingActionButton: selectedListId != null
          ? FloatingActionButton(
              onPressed: () => _showAddItemDialog(context, ref, selectedListId),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Shopping List', style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'List Name', hintText: 'e.g., Christmas Gifts'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a list name')),
                );
                return;
              }

              final list = ShoppingListModel(
                id: '',
                userId: '',
                name: nameController.text,
                isDefault: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              try {
                final repository = ref.read(shoppingRepositoryProvider);
                final created = await repository.createShoppingList(list);
                ref.read(selectedListIdProvider.notifier).state = created.id;
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shopping list created')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create list: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, String listId) {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item', style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name', prefixIcon: Icon(Icons.shopping_bag)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Estimated Cost', prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an item name')),
                );
                return;
              }

              final item = ShoppingListItemModel(
                id: '',
                shoppingListId: listId,
                itemName: nameController.text,
                estimatedCost: double.tryParse(costController.text),
                category: categoryController.text.isNotEmpty ? categoryController.text : null,
                purchased: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              try {
                final repository = ref.read(shoppingRepositoryProvider);
                await repository.createShoppingListItem(item);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ShoppingListContent extends ConsumerWidget {
  final String listId;

  const _ShoppingListContent({required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoppingItemsProvider(listId));
    final statsAsync = ref.watch(shoppingListStatsProvider(listId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(shoppingItemsProvider(listId));
        ref.invalidate(shoppingListStatsProvider(listId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statsAsync.when(
              data: (stats) => _StatsCard(stats: stats),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: FrostedHearthColors.inkLight),
                          const SizedBox(height: 16),
                          Text('No items yet', style: GoogleFonts.sourceSerif4(color: FrostedHearthColors.inkLight)),
                        ],
                      ),
                    ),
                  );
                }

                final groupedItems = <String, List<ShoppingListItemModel>>{};
                for (final item in items) {
                  final category = item.category ?? 'Uncategorized';
                  groupedItems.putIfAbsent(category, () => []).add(item);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groupedItems.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: FrostedHearthColors.spruce.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  entry.key,
                                  style: GoogleFonts.fraunces(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: FrostedHearthColors.spruce,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.value.length} items',
                                style: GoogleFonts.dmMono(fontSize: 12, color: FrostedHearthColors.inkLight),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: EnchantedShoppingItem(
                            name: item.itemName,
                            isChecked: item.purchased,
                            price: item.estimatedCost != null ? AppDateUtils.formatCurrency(item.estimatedCost!) : null,
                            onToggle: () async {
                              final repository = ref.read(shoppingRepositoryProvider);
                              await repository.toggleItemPurchased(item.id, !item.purchased);
                            },
                          ),
                        )),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load items')),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalItems = (stats['totalItems'] as int?) ?? 0;
    final purchasedItems = (stats['purchasedItems'] as int?) ?? 0;
    final remainingItems = (stats['remainingItems'] as int?) ?? 0;
    final completionPercentage = (stats['completionPercentage'] as double?) ?? 0.0;
    final estimatedTotal = (stats['estimatedTotal'] as double?) ?? 0.0;
    final actualTotal = (stats['actualTotal'] as double?) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: FrostedHearthGradients.winterNight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRESS',
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: FrostedHearthColors.iceAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$purchasedItems of $totalItems',
                      style: GoogleFonts.dmMono(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: FrostedHearthColors.frostGold,
                      ),
                    ),
                    Text(
                      'items purchased',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 13,
                        color: FrostedHearthColors.frostGold.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              EmberArcProgress(
                value: completionPercentage / 100,
                size: 70,
                centerText: '${completionPercentage.toInt()}%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FrostedHearthColors.spruceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated', style: GoogleFonts.sourceSerif4(fontSize: 11, color: FrostedHearthColors.frostGold.withOpacity(0.7))),
                    Text(AppDateUtils.formatCurrency(estimatedTotal), style: GoogleFonts.dmMono(fontSize: 14, fontWeight: FontWeight.w600, color: FrostedHearthColors.frostGold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Spent', style: GoogleFonts.sourceSerif4(fontSize: 11, color: FrostedHearthColors.frostGold.withOpacity(0.7))),
                    Text(AppDateUtils.formatCurrency(actualTotal), style: GoogleFonts.dmMono(fontSize: 14, fontWeight: FontWeight.w600, color: FrostedHearthColors.success)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Left', style: GoogleFonts.sourceSerif4(fontSize: 11, color: FrostedHearthColors.frostGold.withOpacity(0.7))),
                    Text('$remainingItems', style: GoogleFonts.dmMono(fontSize: 14, fontWeight: FontWeight.w600, color: FrostedHearthColors.frostGold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
