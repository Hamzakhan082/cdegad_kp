import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/jfmc/models/jfmc_model.dart';
import 'package:cdegad_kp/features/jfmc/providers/jfmc_provider.dart';
import 'package:cdegad_kp/features/jfmc/screens/jfmc_form_screen.dart';

class JfmcListScreen extends ConsumerStatefulWidget {
  const JfmcListScreen({super.key});

  @override
  ConsumerState<JfmcListScreen> createState() => _JfmcListScreenState();
}

class _JfmcListScreenState extends ConsumerState<JfmcListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JfmcModel> _filterList(List<JfmcModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((j) {
      return j.committeeName.toLowerCase().contains(q) ||
          j.district.toLowerCase().contains(q) ||
          j.division.toLowerCase().contains(q) ||
          j.tehsil.toLowerCase().contains(q) ||
          j.province.toLowerCase().contains(q);
    }).toList();
  }

  void _showDeleteDialog(JfmcModel jfmc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete JFMC Record'),
        content: Text(
            'Are you sure you want to delete "${jfmc.committeeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(jfmcListProvider.notifier)
                  .delete(jfmc.id.toString());
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JFMC record deleted')),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jfmcAsync = ref.watch(jfmcListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('JFMC Records'),
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
                  hintText: 'Search by committee, district, division...',
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
            child: jfmcAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryGreen)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.errorColor),
                    const SizedBox(height: 16),
                    const Text('Failed to load JFMC records',
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(jfmcListProvider.notifier).refresh(),
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
                        Icon(Icons.groups,
                            size: 80,
                            color: AppColors.secondaryGreen.withAlpha(100)),
                        const SizedBox(height: 16),
                        Text(
                          list.isEmpty
                              ? 'No JFMC records yet'
                              : 'No matching records',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          list.isEmpty
                              ? 'Tap + to add a new JFMC record'
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
                        ref.read(jfmcListProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final jfmc = filtered[index];
                        return RepaintBoundary(
                          child: Dismissible(
                            key: ValueKey(jfmc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white, size: 28),
                            ),
                            confirmDismiss: (_) async {
                              _showDeleteDialog(jfmc);
                              return false;
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.secondaryGreen.withAlpha(40),
                                  child: const Icon(Icons.groups,
                                      color: AppColors.primaryGreen),
                                ),
                                title: Text(
                                  jfmc.committeeName.isNotEmpty
                                      ? jfmc.committeeName
                                      : 'Unnamed Committee',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          [jfmc.district, jfmc.division, jfmc.tehsil]
                                              .where((s) => s.isNotEmpty)
                                              .join(', '),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      if (jfmc.membersCount != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen.withAlpha(20),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${jfmc.membersCount} members',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primaryGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right,
                                    color: AppColors.textSecondary),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          JfmcFormScreen(existingJfmc: jfmc),
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
            MaterialPageRoute(builder: (_) => const JfmcFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
