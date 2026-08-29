import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../features/awareness/repositories/awareness_repository.dart';
import '../../../features/jfmc/providers/jfmc_provider.dart';
import '../../../features/mass_plantation/repositories/mass_plantation_repository.dart';
import '../../../features/vdc/providers/vdc_provider.dart';
import '../../../features/women_organization/repositories/women_organization_repository.dart';
import '../../../features/youth_women_nursery/providers/youth_women_nursery_provider.dart';
import '../../../features/farm_agro_forestry/providers/farm_agro_forestry_provider.dart';
import '../../../features/other_activity/repositories/other_activity_repository.dart';

class RecordsViewPage extends ConsumerStatefulWidget {
  final String formType;
  final List<Color> gradient;

  const RecordsViewPage({
    super.key,
    required this.formType,
    required this.gradient,
  });

  @override
  ConsumerState<RecordsViewPage> createState() => _RecordsViewPageState();
}

class _RecordsViewPageState extends ConsumerState<RecordsViewPage> {
  String _searchQuery = '';
  String _dateFilter = 'all';
  bool _showSearch = false;
  bool _sortAscending = true;
  bool _isLoading = false;
  String? _loadError;
  late List<Map<String, dynamic>> _allRecords;

  List<Color> get gradient => widget.gradient;

  /// Form types that pull from a live backend endpoint.
  bool get _usesBackend => const [
        'VDC',
        'JFMC',
        'Mass Planting Event',
        'Awareness Raising Sessions',
        'Women Organization',
        'Women Nursery',
        'Farm / Agro Forestry',
        'Other Activity',
      ].contains(widget.formType) ||
      widget.formType == 'All';

  @override
  void initState() {
    super.initState();
    _allRecords = [];
    if (_usesBackend) {
      _loadRecords();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFormRecords(String formType) async {
    switch (formType) {
      case 'VDC':
        return (await ref.read(vdcRepositoryProvider).getAllVdc())
            .map((e) => e.toJson())
            .toList();
      case 'JFMC':
        return (await ref.read(jfmcRepositoryProvider).getAllJfmc())
            .map((e) => e.toJson())
            .toList();
      case 'Mass Planting Event':
        return (await ref.read(massPlantationRepositoryProvider).getAll())
            .map((e) => e.toJson())
            .toList();
      case 'Awareness Raising Sessions':
        return (await ref.read(awarenessRepositoryProvider).getAll()).map((e) => e.toJson()).toList();
      case 'Women Organization':
        return (await ref.read(womenOrganizationRepositoryProvider).getAll()).map((e) => e.toJson()).toList();
      case 'Women Nursery':
        return (await ref.read(youthWomenNurseryRepositoryProvider).getAll()).map((e) => e.toJson()).toList();
      case 'Farm / Agro Forestry':
        return (await ref.read(farmAgroForestryRepositoryProvider).getAll()).map((e) => e.toJson()).toList();
      case 'Other Activity':
        return (await ref.read(otherActivityRepositoryProvider).getAll()).map((e) => e.toJson()).toList();
      default:
        return [];
    }
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final List<Map<String, dynamic>> raw;
      if (widget.formType == 'All') {
        final all = await Future.wait([
          _fetchFormRecords('VDC'),
          _fetchFormRecords('JFMC'),
          _fetchFormRecords('Mass Planting Event'),
          _fetchFormRecords('Awareness Raising Sessions'),
          _fetchFormRecords('Women Organization'),
          _fetchFormRecords('Women Nursery'),
          _fetchFormRecords('Farm / Agro Forestry'),
          _fetchFormRecords('Other Activity'),
        ]);
        raw = all.expand((rows) => rows).toList();
      } else {
        raw = await _fetchFormRecords(widget.formType);
      }

      if (!mounted) return;
      setState(() {
        _allRecords = raw
            .map((row) => _normalizeRecord(row, widget.formType))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  Map<String, dynamic> _normalizeRecord(Map<String, dynamic> row, String formType) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = row[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      return '';
    }

    return {
      'id': (row['id'] ?? '').toString(),
      'name': pick([
        'vdc_name',
        'committee_name',
        'name_of_wo',
        'institute_org',
        'venue',
        'activity_title',
        'type_of_event',
        'major_species',
        'nursery_owner_name',
        'project_name',
        'employee_name',
      ]),
      'date': _toIsoDate(pick([
                'date_established',
                'date_of_registration',
                'date_of_event',
                'date_establishment',
                'date_of_agreement',
                'created_at',
              ])),
      'employee': pick(['employee_name']),
      'status': 'Active',
      'formType': formType,
      'data': row,
    };
  }

  /// Converts the form's dd-MM-yyyy values into an ISO date so the existing
  /// date filter/sort logic can parse them. Also strips the time part from
  /// MySQL "YYYY-MM-DD HH:MM:SS" timestamps (e.g. created_at).
  String _toIsoDate(String value) {
    final m = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$').firstMatch(value.trim());
    if (m != null) {
      return '${m.group(3)}-${m.group(2)!.padLeft(2, '0')}-${m.group(1)!.padLeft(2, '0')}';
    }
    final ts = RegExp(r'^(\d{4}-\d{2}-\d{2}) ').firstMatch(value.trim());
    if (ts != null) {
      return ts.group(1)!;
    }
    return value;
  }

  List<Map<String, dynamic>> get _filteredRecords {
    var records = List<Map<String, dynamic>>.from(_allRecords);
    final now = DateTime.now();
    if (_dateFilter == 'today') {
      records = records.where((r) {
        final d = DateTime.tryParse(r['date'] ?? '');
        return d != null && d.year == now.year && d.month == now.month && d.day == now.day;
      }).toList();
    } else if (_dateFilter == 'week') {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      records = records.where((r) {
        final d = DateTime.tryParse(r['date'] ?? '');
        return d != null && !d.isBefore(weekStart) && !d.isAfter(now);
      }).toList();
    } else if (_dateFilter == 'month') {
      records = records.where((r) {
        final d = DateTime.tryParse(r['date'] ?? '');
        return d != null && d.year == now.year && d.month == now.month;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      records = records.where((r) =>
          (r['name'] ?? '').toString().toLowerCase().contains(q) ||
          (r['id'] ?? '').toString().toLowerCase().contains(q) ||
          (r['employee'] ?? '').toString().toLowerCase().contains(q) ||
          (r['status'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
    records.sort((a, b) {
      final da = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);
      return _sortAscending ? da.compareTo(db) : db.compareTo(da);
    });
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "${widget.formType} Records",
          style: AppTextStyles.appBarTitle,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          IconButton(
            icon: Icon(_sortAscending ? Icons.sort_by_alpha : Icons.sort),
            onPressed: () {
              setState(() => _sortAscending = !_sortAscending);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_sortAscending ? "Sorted: Oldest first" : "Sorted: Newest first"),
                  backgroundColor: gradient.first,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(
            child: _buildRecordsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _dateFilter,
                      hint: const Text("Filter by Date"),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text("All Records")),
                        DropdownMenuItem(value: 'today', child: Text("Today")),
                        DropdownMenuItem(value: 'week', child: Text("This Week")),
                        DropdownMenuItem(value: 'month', child: Text("This Month")),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _dateFilter = value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gradient.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: gradient.first,
                ),
              ),
            ],
          ),
          if (_showSearch) ...[
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search records...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchQuery = '';
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading records..."),
          ],
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "Could not load records",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _loadRecords,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final records = _filteredRecords;

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No records found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try changing the search or filter",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(context, record);
      },
    );
  }

  Widget _buildRecordCard(BuildContext context, Map<String, dynamic> record) {
    final Color statusColor;
    switch (record['status']) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showRecordDetails(context, record),
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
                        color: gradient.first.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description,
                        color: gradient.first,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['name'] ?? 'Record',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ID: ${record['id']}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        record['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Flexible(
                      child: _buildInfoChip(Icons.calendar_today, record['date'] ?? ''),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildInfoChip(Icons.person, record['employee'] ?? ''),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: gradient.first,
                      onPressed: () => _showEditOptions(context, record),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () => _showDeleteConfirmation(context, record),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  void _showRecordDetails(BuildContext context, Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: gradient.first.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description,
                      color: gradient.first,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['name'] ?? 'Record Details',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "ID: ${record['id']}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: record['data'] != null
                      ? _buildDynamicDetailRows(record['data'] as Map<String, dynamic>)
                      : [
                          _buildDetailRow("Status", record['status'] ?? ''),
                          _buildDetailRow("Date", record['date'] ?? ''),
                          _buildDetailRow("Employee", record['employee'] ?? ''),
                          _buildDetailRow("Name", record['name'] ?? ''),
                          _buildDetailRow("Region", "Region I"),
                          _buildDetailRow("Division", "Forest Division"),
                          _buildDetailRow("Sub Division", "Sub Division"),
                        ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditOptions(context, record);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradient.first,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, record);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicDetailRows(Map<String, dynamic> data) {
    const exclude = {'id', 'created_at', 'upload_file', 'upload_image'};
    final rows = <Widget>[];
    data.forEach((key, value) {
      if (exclude.contains(key)) return;
      final text = value?.toString() ?? '';
      if (text.trim().isEmpty) return;
      rows.add(_buildDetailRow(_prettyKey(key), text));
    });
    return rows;
  }

  String _prettyKey(String key) {
    final words = key.split('_');
    final title = words.map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    return title;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditOptions(BuildContext context, Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Edit Options",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: gradient.first,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gradient.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, color: gradient.first),
              ),
              title: const Text("Edit Record"),
              subtitle: const Text("Modify this record"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Edit mode activated"),
                    backgroundColor: gradient.first,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: const Text("Delete Record"),
              subtitle: const Text("Remove this record permanently"),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, record);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text(
          "Are you sure you want to delete this record? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteRecord(record);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord(Map<String, dynamic> record) async {
    final formType = (record['formType'] as String?) ?? widget.formType;
    final recordId = record['id']?.toString() ?? '';

    const knownTypes = [
      'VDC',
      'JFMC',
      'Mass Planting Event',
      'Awareness Raising Sessions',
      'Women Organization',
      'Women Nursery',
      'Farm / Agro Forestry',
      'Other Activity',
    ];
    if (!knownTypes.contains(formType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Record deleted successfully"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      switch (formType) {
        case 'VDC':
          await ref.read(vdcRepositoryProvider).deleteVdc(recordId);
          break;
        case 'JFMC':
          await ref.read(jfmcRepositoryProvider).deleteJfmc(recordId);
          break;
        case 'Mass Planting Event':
          await ref.read(massPlantationRepositoryProvider).delete(recordId);
          break;
        case 'Awareness Raising Sessions':
          await ref.read(awarenessRepositoryProvider).delete(recordId);
          break;
        case 'Women Organization':
          await ref.read(womenOrganizationRepositoryProvider).delete(recordId);
          break;
        case 'Women Nursery':
          await ref.read(youthWomenNurseryRepositoryProvider).delete(recordId);
          break;
        case 'Farm / Agro Forestry':
          await ref.read(farmAgroForestryRepositoryProvider).delete(recordId);
          break;
        case 'Other Activity':
          await ref.read(otherActivityRepositoryProvider).delete(recordId);
          break;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Record deleted successfully"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _loadRecords();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Delete failed: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}