import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/constants/constants.dart';

import 'package:cdegad_kp/features/youth_women_nursery/models/youth_women_nursery_model.dart';
import 'package:cdegad_kp/features/youth_women_nursery/providers/youth_women_nursery_provider.dart';
import 'package:cdegad_kp/features/youth_women_nursery/screens/youth_women_nursery_form_screen.dart';

class YouthWomenNurseryListScreen extends ConsumerStatefulWidget {
  const YouthWomenNurseryListScreen({super.key});

  @override
  ConsumerState<YouthWomenNurseryListScreen> createState() =>
      _YouthWomenNurseryListScreenState();
}

class _YouthWomenNurseryListScreenState
    extends ConsumerState<YouthWomenNurseryListScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<YouthWomenNurseryModel> _filteredList(
      List<YouthWomenNurseryModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where(
          (e) =>
              e.nurseryName.toLowerCase().contains(q) ||
              e.district.toLowerCase().contains(q) ||
              e.species.toLowerCase().contains(q) ||
              e.division.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _confirmDelete(YouthWomenNurseryModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Nursery'),
        content: Text('Delete "${model.nurseryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await ref
            .read(youthWomenNurseryNotifierProvider.notifier)
            .delete(model.id.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nursery deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  void _navigateToForm({YouthWomenNurseryModel? model}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => YouthWomenNurseryFormScreen(existingModel: model),
      ),
    );
    if (result == true) {
      ref.read(youthWomenNurseryNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(youthWomenNurseryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Youth Women Nurseries'),
        backgroundColor: AppColors.womenNursery,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(youthWomenNurseryNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search nurseries...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          Expanded(
            child: asyncList.when(
              data: (list) {
                final filtered = _filteredList(list);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No results found'
                          : 'No nurseries yet',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  );
                }
                return RepaintBoundary(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(youthWomenNurseryNotifierProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return RepaintBoundary(
                          child: Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: AppColors.errorColor,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              _confirmDelete(item);
                              return false;
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(14),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.womenNursery,
                                  child: const Icon(Icons.park, color: Colors.white),
                                ),
                                title: Text(
                                  item.nurseryName,
                                  style: AppTextStyles.cardTitle,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.district} | ${item.division}',
                                      style: AppTextStyles.cardSubtitle,
                                    ),
                                    Text(
                                      'Species: ${item.species} | Plants: ${item.totalPlants}',
                                      style: AppTextStyles.cardSubtitle,
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _navigateToForm(model: item),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.toString(),
                        style: const TextStyle(color: AppColors.errorColor)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(youthWomenNurseryNotifierProvider.notifier)
                          .refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.womenNursery,
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
