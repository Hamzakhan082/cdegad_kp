import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/women_organization/models/women_organization_model.dart';
import 'package:cdegad_kp/features/women_organization/providers/women_organization_provider.dart';
import 'package:cdegad_kp/features/women_organization/screens/women_organization_form_screen.dart';

class WomenOrganizationListScreen extends ConsumerStatefulWidget {
  const WomenOrganizationListScreen({super.key});

  @override
  ConsumerState<WomenOrganizationListScreen> createState() =>
      _WomenOrganizationListScreenState();
}

class _WomenOrganizationListScreenState
    extends ConsumerState<WomenOrganizationListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WomenOrganizationModel> _filter(List<WomenOrganizationModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((e) =>
            e.organizationName.toLowerCase().contains(q) ||
            e.district.toLowerCase().contains(q) ||
            e.division.toLowerCase().contains(q) ||
            e.tehsil.toLowerCase().contains(q) ||
            e.province.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(womenOrganizationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Women Organizations'),
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
                  hintText: 'Search organizations...',
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
                      onPressed: () => ref.read(womenOrganizationListProvider.notifier).refresh(),
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
                        Icon(Icons.group_off, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No organizations found'
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
                    onRefresh: () => ref.read(womenOrganizationListProvider.notifier).refresh(),
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
                                  title: const Text('Delete Organization'),
                                  content: Text(
                                    'Delete "${item.organizationName}"? This cannot be undone.',
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
                                await ref
                                    .read(womenOrganizationListProvider.notifier)
                                    .remove(item.id!);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.organizationName} deleted'),
                                      backgroundColor: AppColors.errorColor,
                                    ),
                                  );
                                }
                              }
                            },
                            child: _OrganizationCard(
                              item: item,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WomenOrganizationFormScreen(editItem: item),
                                ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WomenOrganizationFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Organization'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final WomenOrganizationModel item;
  final VoidCallback onTap;

  const _OrganizationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      color: AppColors.womenOrganization.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.groups, color: AppColors.womenOrganization),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.organizationName,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _infoChip(Icons.location_on, item.district),
                  const SizedBox(width: 8),
                  _infoChip(Icons.map, item.division),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _infoChip(Icons.account_balance, item.province),
                  const SizedBox(width: 8),
                  _infoChip(Icons.people, '${item.membersCount} members'),
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
