import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/awareness/models/awareness_model.dart';
import 'package:cdegad_kp/features/awareness/providers/awareness_provider.dart';
import 'package:cdegad_kp/features/awareness/screens/awareness_form_screen.dart';

class AwarenessListScreen extends ConsumerStatefulWidget {
  const AwarenessListScreen({super.key});

  @override
  ConsumerState<AwarenessListScreen> createState() =>
      _AwarenessListScreenState();
}

class _AwarenessListScreenState extends ConsumerState<AwarenessListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(awarenessListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Awareness Sessions'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(awarenessListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search sessions...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: asyncList.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.errorColor),
                    const SizedBox(height: 12),
                    Text('Failed to load records', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(awarenessListProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (list) {
                final filtered = _searchQuery.isEmpty
                    ? list
                    : list.where((m) =>
                        m.title.toLowerCase().contains(_searchQuery) ||
                        m.topic.toLowerCase().contains(_searchQuery) ||
                        m.district.toLowerCase().contains(_searchQuery) ||
                        m.division.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign, size: 64, color: AppColors.primaryGreen.withAlpha(77)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No records yet' : 'No results found',
                          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RepaintBoundary(
                  child: RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: () => ref.read(awarenessListProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final model = filtered[index];
                        return RepaintBoundary(
                          child: _buildCard(model),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AwarenessFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(AwarenessModel model) {
    return Dismissible(
      key: ValueKey(model.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 24),
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
            title: const Text('Delete Record'),
            content: const Text('Are you sure you want to delete this awareness record?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(awarenessListProvider.notifier).delete(model.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: AppColors.primaryGreen.withAlpha(26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AwarenessFormScreen(existing: model),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.campaign, color: AppColors.secondaryGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        model.title.isEmpty ? 'Untitled Session' : model.title,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (model.topic.isNotEmpty) _infoRow(Icons.topic, 'Topic', model.topic),
                _infoRow(Icons.location_on, model.district, model.division),
                if (model.participantsCount.isNotEmpty)
                  _infoRow(Icons.people, 'Participants', model.participantsCount),
                if (model.sessionDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        model.sessionDate!,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryGreen),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
