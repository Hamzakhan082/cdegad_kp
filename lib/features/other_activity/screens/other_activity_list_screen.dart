import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/other_activity/models/other_activity_model.dart';
import 'package:cdegad_kp/features/other_activity/providers/other_activity_provider.dart';
import 'package:cdegad_kp/features/other_activity/screens/other_activity_form_screen.dart';

class OtherActivityListScreen extends ConsumerStatefulWidget {
  const OtherActivityListScreen({super.key});

  @override
  ConsumerState<OtherActivityListScreen> createState() =>
      _OtherActivityListScreenState();
}

class _OtherActivityListScreenState
    extends ConsumerState<OtherActivityListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OtherActivityModel> _filter(List<OtherActivityModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((e) =>
            e.activityName.toLowerCase().contains(q) ||
            e.activityType.toLowerCase().contains(q) ||
            e.district.toLowerCase().contains(q) ||
            e.division.toLowerCase().contains(q) ||
            e.tehsil.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(otherActivityListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Activities'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search activities...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.secondaryGreen),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorColor, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load data', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => ref.read(otherActivityListProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (list) {
                final filtered = _filter(list);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No activities found'
                              : 'No results for "$_searchQuery"',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return RepaintBoundary(
                  child: RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: () => ref.read(otherActivityListProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return RepaintBoundary(
                          child: Dismissible(
                            key: ValueKey(item.id ?? 'item_$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Activity'),
                                  content: Text(
                                    'Delete "${item.activityName}"? This cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.errorColor,
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) async {
                              if (item.id != null) {
                                try {
                                  await ref
                                      .read(otherActivityListProvider.notifier)
                                      .remove(item.id!);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${item.activityName} deleted'),
                                        backgroundColor: AppColors.errorColor,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Delete failed: $e'),
                                        backgroundColor: AppColors.errorColor,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: _ActivityCard(item: item),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OtherActivityFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final OtherActivityModel item;

  const _ActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.otherActivity.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.extension, color: AppColors.otherActivity),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.activityName,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _infoChip(Icons.category, item.activityType),
                _infoChip(Icons.location_on, item.district),
                _infoChip(Icons.map, item.division),
                _infoChip(Icons.place, item.tehsil),
              ],
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondaryGreen),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
