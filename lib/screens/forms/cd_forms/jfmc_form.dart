import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../features/jfmc/providers/jfmc_provider.dart';
import '../../../widgts/home_items.dart';

class JFMCForm extends ConsumerStatefulWidget {
  const JFMCForm({super.key});

  @override
  ConsumerState<JFMCForm> createState() => _JFMCFormState();
}

class _JFMCFormState extends ConsumerState<JFMCForm> with ImagePickerMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _employeeNameController = TextEditingController();
  final _divisionController = TextEditingController();
  final _subDivisionController = TextEditingController();
  final _villageController = TextEditingController();
  final _forestCompartmentController = TextEditingController();
  final _jfmcNameController = TextEditingController();
  final _presidentNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _circleController = TextEditingController();

  DateTime? selectedDate;
  String? selectedRegion;
  File? _supportingDocument;
  String? _selectedDocumentName;
  final TextEditingController _interventionNameController =
      TextEditingController();
  final List<Map<String, String>> addedInterventions = [];

  final List<String> regions = ['Region I', 'Region II', 'Region III'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      if (!context.mounted) return;
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'webp',
          'zip',
          'rar',
          '7z',
          'txt',
          'csv',
        ],
      );

      if (!mounted) return;

      if (result != null && result.files.single.path != null) {
        final fileSize = result.files.single.size;
        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File size must be less than 5MB"),
              backgroundColor: Colors.red.shade700,
            ),
          );
          return;
        }
        setState(() {
          _supportingDocument = File(result.files.single.path!);
          _selectedDocumentName = result.files.single.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Document selected: $_selectedDocumentName"),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking document: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _divisionController.dispose();
    _subDivisionController.dispose();
    _villageController.dispose();
    _forestCompartmentController.dispose();
    _jfmcNameController.dispose();
    _presidentNameController.dispose();
    _contactController.dispose();
    _circleController.dispose();
    _interventionNameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _showAddInterventionDialog() {
    _interventionNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Intervention"),
        content: TextField(
          controller: _interventionNameController,
          decoration: InputDecoration(
            labelText: "Intervention Name",
            hintText: "e.g. Enclosure Form, Training, etc.",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.add_circle),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_interventionNameController.text.isNotEmpty) {
                setState(() {
                  addedInterventions.add({
                    "name": _interventionNameController.text.trim(),
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    String d(TextEditingController c) => c.text.trim();

    final fields = <String, dynamic>{
      'employee_name': d(_employeeNameController),
      'forest_region': selectedRegion ?? '',
      'forest_circle_name': d(_circleController),
      'forest_division': d(_divisionController),
      'sub_division_range': d(_subDivisionController),
      'village_pu': d(_villageController),
      'forest_compartment': d(_forestCompartmentController),
      'jfmc_name': d(_jfmcNameController),
      'date_of_registration': selectedDate != null
          ? '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
          : '',
      'president_name': d(_presidentNameController),
      'contact_number': d(_contactController),
      'interventions': addedInterventions
          .map((i) => i['name'] ?? '')
          .join(', '),
      'description': addedInterventions.map((i) => i['name'] ?? '').join(', '),
    };

    try {
      await ref
          .read(jfmcRepositoryProvider)
          .createJfmcMultipart(fields, document: _supportingDocument?.path);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("JFMC Data Submitted Successfully!"),
          backgroundColor: AppColors.primaryGreen,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JFMC Form", style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditOptions),
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
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildImagePickerField(label: "Upload Image / Take Pic"),
              const SizedBox(height: 16),
              _buildDocumentPicker(),
              const SizedBox(height: 16),
              FormHelpers.buildTextField(
                label: "Employee Name",
                controller: _employeeNameController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.person,
              ),
              FormHelpers.buildDropdownField(
                label: "Forest Region",
                options: regions,
                value: selectedRegion,
                validator: (value) => value == null ? "Required" : null,
                onChanged: (value) {
                  setState(() {
                    selectedRegion = value;
                  });
                },
              ),
              FormHelpers.buildTextField(
                label: "Forest Circle",
                controller: _circleController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.business,
              ),
              FormHelpers.buildTextField(
                label: "Forest Division",
                controller: _divisionController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.business,
              ),
              FormHelpers.buildTextField(
                label: "Sub Division | Range",
                controller: _subDivisionController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.map,
              ),
              FormHelpers.buildTextField(
                label: "Village / VDC",
                controller: _villageController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.home,
              ),
              FormHelpers.buildTextField(
                label: "Forest Type",
                controller: _forestCompartmentController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.pin,
              ),
              FormHelpers.buildTextField(
                label: "JFMC Name",
                controller: _jfmcNameController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.groups,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Date of Registration (DD/MM/YYYY)",
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.secondaryGreen,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: AppColors.secondaryGreen,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceColor,
                    ),
                    child: Text(
                      selectedDate != null
                          ? _formatDate(selectedDate!)
                          : 'Select Date',
                      style: TextStyle(
                        color: selectedDate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              FormHelpers.buildTextField(
                label: "Chairman Name",
                controller: _presidentNameController,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.person_pin,
              ),
              FormHelpers.buildTextField(
                label: "Contact Number",
                controller: _contactController,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                    return "Enter exactly 11 digits";
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
              ),
              // Main Interventions - Add More Button
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Main Interventions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (addedInterventions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "No interventions added yet. Tap 'Add More' to add.",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...addedInterventions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final intervention = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    intervention["name"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(
                                      () => addedInterventions.removeAt(index),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showAddInterventionDialog,
                          icon: const Icon(Icons.add_circle),
                          label: const Text("Add More"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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

  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload Supporting Document (Max 5MB)",
          style: AppTextStyles.formLabel,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDocument,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _supportingDocument != null
                ? Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description,
                              size: 32,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedDocumentName ?? "Document selected",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${(_supportingDocument?.lengthSync() ?? 0) / 1024} KB",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _supportingDocument = null;
                            _selectedDocumentName = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to upload document",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "PDF, DOC, XLS, Images (Max 5MB)",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
