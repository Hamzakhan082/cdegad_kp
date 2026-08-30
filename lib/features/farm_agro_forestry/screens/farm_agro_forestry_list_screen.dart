import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/constants/constants.dart';

import 'package:cdegad_kp/features/farm_agro_forestry/models/farm_agro_forestry_model.dart';
import 'package:cdegad_kp/features/farm_agro_forestry/providers/farm_agro_forestry_provider.dart';
import 'package:cdegad_kp/features/farm_agro_forestry/screens/farm_agro_forestry_form_screen.dart';

class FarmAgroForestryListScreen extends ConsumerStatefulWidget {
  const FarmAgroForestryListScreen({super.key});

  @override
  ConsumerState<FarmAgroForestryListScreen> createState() =>
      _FarmAgroForestryListScreenState();
}

class _FarmAgroForestryListScreenState
    extends ConsumerState<FarmAgroForestryListScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmAgroForestryModel> _filteredList(List<FarmAgroForestryModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where(
          (e) =>
              e.farmName.toLowerCase().contains(q) ||
              e.ownerName.toLowerCase().contains(q) ||
              e.district.toLowerCase().contains(q) ||
              e.crops.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _confirmDelete(FarmAgroForestryModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Farm'),
        content: Text('Delete "${model.farmName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await ref
            .read(farmAgroForestryNotifierProvider.notifier)
            .delete(model.id.toString());
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Farm deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void _navigateToForm({FarmAgroForestryModel? model}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FarmAgroForestryFormScreen(existingModel: model),
      ),
    );
    if (result == true) {
      ref.read(farmAgroForestryNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(farmAgroForestryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Agro Forestry'),
        backgroundColor: AppColors.farmForestry,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(farmAgroForestryNotifierProvider.notifier).refresh(),
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
                  hintText: 'Search farms...',
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
                          : 'No farms yet',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  );
                }
                return RepaintBoundary(
                  child: RefreshIndicator(
                    onRefresh: () => ref
                        .read(farmAgroForestryNotifierProvider.notifier)
                        .refresh(),
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
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
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
                                  backgroundColor: AppColors.farmForestry,
                                  child: const Icon(
                                    Icons.agriculture,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  item.farmName,
                                  style: AppTextStyles.cardTitle,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.ownerName} | ${item.district}',
                                      style: AppTextStyles.cardSubtitle,
                                    ),
                                    Text(
                                      'Crops: ${item.crops} | Area: ${item.totalArea}',
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
                    Text(
                      e.toString(),
                      style: const TextStyle(color: AppColors.errorColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(farmAgroForestryNotifierProvider.notifier)
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
        backgroundColor: AppColors.farmForestry,
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
