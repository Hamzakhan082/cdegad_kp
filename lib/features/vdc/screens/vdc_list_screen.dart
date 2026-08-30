import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/vdc/models/vdc_model.dart';
import 'package:cdegad_kp/features/vdc/providers/vdc_provider.dart';
import 'package:cdegad_kp/features/vdc/screens/vdc_form_screen.dart';

class VdcListScreen extends ConsumerStatefulWidget {
  const VdcListScreen({super.key});

  @override
  ConsumerState<VdcListScreen> createState() => _VdcListScreenState();
}

class _VdcListScreenState extends ConsumerState<VdcListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VdcModel> _filterList(List<VdcModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((v) {
      return v.villageName.toLowerCase().contains(q) ||
          v.district.toLowerCase().contains(q) ||
          v.division.toLowerCase().contains(q) ||
          v.tehsil.toLowerCase().contains(q) ||
          v.province.toLowerCase().contains(q);
    }).toList();
  }

  void _showDeleteDialog(VdcModel vdc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete VDC Record'),
        content: Text('Are you sure you want to delete "${vdc.villageName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(vdcListProvider.notifier)
                  .delete(vdc.id.toString());
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('VDC record deleted')),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vdcAsync = ref.watch(vdcListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VDC Records'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by village, district, division...',
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
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),
          Expanded(
            child: vdcAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.errorColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load VDC records',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(vdcListProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (list) {
                final filtered = _filterList(list);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.forest,
                          size: 80,
                          color: AppColors.secondaryGreen.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          list.isEmpty
                              ? 'No VDC records yet'
                              : 'No matching records',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          list.isEmpty
                              ? 'Tap + to add a new VDC record'
                              : 'Try a different search term',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RepaintBoundary(
                  child: RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: () =>
                        ref.read(vdcListProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final vdc = filtered[index];
                        return RepaintBoundary(
                          child: Dismissible(
                            key: ValueKey(vdc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              _showDeleteDialog(vdc);
                              return false;
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.secondaryGreen
                                      .withAlpha(40),
                                  child: const Icon(
                                    Icons.forest,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                title: Text(
                                  vdc.villageName.isNotEmpty
                                      ? vdc.villageName
                                      : 'Unnamed Village',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    [
                                      vdc.district,
                                      vdc.division,
                                      vdc.tehsil,
                                    ].where((s) => s.isNotEmpty).join(', '),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VdcFormScreen(existingVdc: vdc),
                                    ),
                                  );
                                },
                              ),
                            ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VdcFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
