import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../features/mass_plantation/repositories/mass_plantation_repository.dart';
import '../../../widgts/home_items.dart';

// ------------------- MAIN LANDING SCREEN -------------------
class MassPlantingScreen extends StatefulWidget {
  const MassPlantingScreen({super.key});

  @override
  State<MassPlantingScreen> createState() => _MassPlantingScreenState();
}

class _MassPlantingScreenState extends State<MassPlantingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimations = List.generate(2, (index) {
      return Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.1 + index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _slideAnimations = List.generate(2, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.1 + index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mass Planting Event",
          style: AppTextStyles.appBarTitle,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              "Mass Planting Event",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedButton(
                    0,
                    "Enter New Record",
                    Icons.add_circle,
                    AppColors.primaryGreen,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MassPlantingFormScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildAnimatedButton(
                    1,
                    "View Records",
                    Icons.list_alt,
                    AppColors.secondaryGreen,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MassPlantingViewRecordsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    int index,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimations[index],
        _slideAnimations[index],
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: SlideTransition(
            position: _slideAnimations[index],
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: onPressed,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------- VIEW RECORDS SCREEN -------------------
class MassPlantingViewRecordsScreen extends StatelessWidget {
  MassPlantingViewRecordsScreen({super.key});

  final List<Map<String, dynamic>> _records = [
    {
      'fullName': 'John Smith',
      'division': 'Northern Division',
      'location': 'City Park',
      'chiefGuest': 'Dr. Jane Wilson',
      'date': '2023-03-15',
      'season': 'Spring',
      'plantsDistributed': '500',
      'plantsPlanted': '450',
      'majorSpecies': 'Pine, Oak',
      'institute': 'Green Earth Foundation',
      'attachedFile': 'planting_report.pdf',
    },
    {
      'fullName': 'Alice Johnson',
      'division': 'Southern Division',
      'location': 'Community Garden',
      'chiefGuest': 'Mr. Robert Brown',
      'date': '2023-07-20',
      'season': 'Monsoon',
      'plantsDistributed': '300',
      'plantsPlanted': '280',
      'majorSpecies': 'Mango, Neem',
      'institute': 'Nature Conservation Society',
      'attachedFile': 'event_summary.docx',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mass Planting Records",
          style: AppTextStyles.appBarTitle,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No records found",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MassPlantingFormScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: const Text("Add New Record"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shadowColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryGreen
                                  .withValues(alpha: 0.1),
                              child: Icon(
                                Icons.nature_people,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                record['fullName'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.business,
                          "Division",
                          record['division'],
                        ),
                        _buildDetailRow(
                          Icons.location_on,
                          "Location",
                          record['location'],
                        ),
                        _buildDetailRow(
                          Icons.person,
                          "Chief Guest",
                          record['chiefGuest'],
                        ),
                        _buildDetailRow(
                          Icons.calendar_today,
                          "Date",
                          "${record['date']} (${record['season']})",
                        ),
                        _buildDetailRow(
                          Icons.format_list_numbered,
                          "Plants Planted",
                          "${record['plantsPlanted']}/${record['plantsDistributed']}",
                        ),
                        if (record['attachedFile'] != null)
                          _buildDetailRow(
                            Icons.attach_file,
                            "Attached File",
                            record['attachedFile'],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ------------------- FORM SCREEN -------------------
class MassPlantingFormScreen extends ConsumerStatefulWidget {
  const MassPlantingFormScreen({super.key});

  @override
  ConsumerState<MassPlantingFormScreen> createState() =>
      _MassPlantingFormScreenState();
}

class _MassPlantingFormScreenState extends ConsumerState<MassPlantingFormScreen>
    with ImagePickerMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  DateTime? _selectedDate;
  String? _selectedFileName;
  File? _selectedFile;
  String? selectedRegion;

  final List<String> regions = ['Region I', 'Region II', 'Region III'];
  final List<Map<String, String>> _plantDetails = [];
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _plantsController = TextEditingController();

  final Map<String, TextEditingController> _controllers = {};

  final List<String> _fields = [
    'Employee Name',
    'Name of Forest Region',
    'Name of Forest Circle',
    'Name of Division',
    'Name of Sub-Division / Range',
    'Name of Project',
    'Name of Institution / Organization',
    'Location | Venue',
    'Chief Guest',
    'Total Number of Plants',
  ];

  @override
  void initState() {
    super.initState();
    for (var field in _fields) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _speciesController.dispose();
    _plantsController.dispose();
    super.dispose();
  }

  void _removePlantDetail(int index) {
    setState(() {
      _plantDetails.removeAt(index);
    });
  }

  void _addPlantDetail() {
    if (_speciesController.text.isNotEmpty &&
        _plantsController.text.isNotEmpty) {
      setState(() {
        _plantDetails.add({
          'name': _speciesController.text,
          'number': _plantsController.text,
        });
        _speciesController.clear();
        _plantsController.clear();
      });
    }
  }

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Plant Detail"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: "Plant Name / Species",
                hintText: "Enter plant name",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _plantsController,
              decoration: const InputDecoration(
                labelText: "Number of Plants",
                hintText: "Enter number of plants",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addPlantDetail();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          // Documents
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
          // Images
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
          // Archives
          'zip', 'rar', '7z',
          // Text files
          'txt', 'csv',
          // Other common formats
          'mp4', 'avi', 'mov', 'mp3', 'wav',
        ],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _selectedFile = File(result.files.single.path!);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File selected: $_selectedFileName"),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking file: $e"),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFileName = null;
    });
  }

  void _showEditOptions() {
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
            const Text(
              "Edit Options",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: AppColors.primaryGreen),
              ),
              title: const Text("Edit Form Data"),
              subtitle: const Text("Modify existing form entries"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Edit mode activated"),
                    backgroundColor: AppColors.primaryGreen,
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
                _showDeleteConfirmation();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Record deleted successfully"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a date"),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String value(String field) => _controllers[field]?.text.trim() ?? '';

    final fields = <String, dynamic>{
      'employee_name': value('Employee Name'),
      'forest_region': selectedRegion ?? value('Name of Forest Region'),
      'forest_circle_name': value('Name of Forest Circle'),
      'division_name': value('Name of Division'),
      'sub_division_range': value('Name of Sub-Division / Range'),
      'project_name': value('Name of Project'),
      'institute_org': value('Name of Institution / Organization'),
      'venue': value('Location | Venue'),
      'chief_guest': value('Chief Guest'),
      'total_plants': value('Total Number of Plants'),
      'date_of_event':
          '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      'plant_details': _plantDetails
          .map((d) => '${d['name']} (${d['number']})')
          .join(', '),
    };

    try {
      await ref
          .read(massPlantationRepositoryProvider)
          .createMultipart(fields, document: _selectedFile?.path);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      String message = "Record Saved Successfully\n";
      message += "Plants: ${_plantDetails.length} types";

      if (_selectedFileName != null) {
        message += "\nFile attached: $_selectedFileName";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submission failed: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mass Planting Record",
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditOptions(),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildImagePickerField(label: "Upload Event Image"),
              const SizedBox(height: 10),
              buildFilePickerField(
                label: "Attach Supporting Document",
                fileName: _selectedFileName,
                onPressed: _pickFile,
                onClear: _clearSelectedFile,
              ),
              ..._fields.asMap().entries.map((entry) {
                final field = entry.value;
                if (field == 'Name of Forest Region') {
                  return FormHelpers.buildDropdownField(
                    label: field,
                    options: regions,
                    value: selectedRegion,
                    validator: (value) => value == null ? 'Required' : null,
                    onChanged: (value) =>
                        setState(() => selectedRegion = value),
                  );
                }
                return FormHelpers.buildTextField(
                  label: field,
                  controller: _controllers[field]!,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  prefixIcon: _getIconForField(field),
                );
              }),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Plant Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddPlantDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Plant"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (_plantDetails.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._plantDetails.asMap().entries.map((entry) {
                  final index = entry.key;
                  final plant = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.eco,
                        color: AppColors.primaryGreen,
                      ),
                      title: Text(plant['name'] ?? ''),
                      subtitle: Text("Plants: ${plant['number'] ?? ''}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removePlantDetail(index),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 25),
              FormHelpers.buildSubmitButton(
                onPressed: _submitForm,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: _selectDate,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Date of Event",
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: AppColors.secondaryGreen,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.secondaryGreen),
            ),
            filled: true,
            fillColor: AppColors.surfaceColor,
          ),
          child: Text(
            _selectedDate != null
                ? "${_selectedDate!.toLocal()}".split(' ')[0]
                : 'Select Date',
            style: TextStyle(
              color: _selectedDate != null ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Mass planting event same as to
  IconData _getIconForField(String field) {
    switch (field) {
      case 'Employee Name':
        return Icons.person;
      case 'Name of Forest Region':
        return Icons.map;
      case 'Name of Forest Circle':
        return Icons.business;
      case 'Name of Division':
        return Icons.business;
      case 'Name of Sub-Division / Range':
        return Icons.business;
      case 'Name of Project':
        return Icons.folder;
      case 'Name of Institution / Organization':
        return Icons.account_balance;
      case 'Location | Venue':
        return Icons.location_on;
      case 'Chief Guest':
        return Icons.person_pin;
      case 'Number of Plant Distributed':
      case 'Name of Species':
      case 'No of plant planted':
      case 'Total Number of Plants':
        return Icons.format_list_numbered;
      default:
        return Icons.label;
    }
  }
}
