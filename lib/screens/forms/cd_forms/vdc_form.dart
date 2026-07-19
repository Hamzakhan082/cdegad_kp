import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../constants/constants.dart';
import '../../../widgts/home_items.dart'; // Assuming this has FormHelpers and ImagePickerMixin

class VDCForm extends StatefulWidget {
  const VDCForm({super.key});

  @override
  State<VDCForm> createState() => _VDCFormState();
}

class _VDCFormState extends State<VDCForm> with ImagePickerMixin {
  final _formKey = GlobalKey<FormState>();
  final _employeeNameController = TextEditingController();
  final _divisionController = TextEditingController();
  final _subDivisionController = TextEditingController();
  final _villageController = TextEditingController();
  final _vdcController = TextEditingController();
  final _presidentNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _vdcMembersController = TextEditingController();
  final _secretaryNameController = TextEditingController();

  DateTime? selectedDate;
  String? selectedActivity;
  String? selectedRegion;
  bool _isSubmitting = false;

  // File and document storage
  File? _supportingDocument;
  String? _selectedDocumentName;

  final List<String> regions = ['Region I', 'Region II', 'Region III'];
  final List<String> activities = ['Nursery', 'Village Development Plan (VDP)', 'Other Activities'];
  final List<Map<String, String>> addedInterventions = [];

  final TextEditingController _interventionNameController = TextEditingController();

  // Method to pick supporting documents
  Future<void> _pickDocument() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
          'zip', 'rar', '7z', 'txt', 'csv',
          'mp4', 'avi', 'mov', 'mp3', 'wav'
        ],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _supportingDocument = File(result.files.single.path!);
          _selectedDocumentName = result.files.single.name;
        });

        messenger.showSnackBar(
          SnackBar(
            content: Text("Document selected: $_selectedDocumentName"),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Error picking document: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedActivity != null) {
        final route = '/activity_${selectedActivity!.toLowerCase().replaceAll(' ', '_').replaceAll('(', '').replaceAll(')', '')}';
        Navigator.pushNamed(context, route);
        return;
      }

      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("VDC Data Submitted Successfully!"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    }
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        content: const Text("Are you sure you want to delete this record? This action cannot be undone."),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  void dispose() {
    _employeeNameController.dispose();
    _divisionController.dispose();
    _subDivisionController.dispose();
    _villageController.dispose();
    _vdcController.dispose();
    _presidentNameController.dispose();
    _contactController.dispose();
    _vdcMembersController.dispose();
    _secretaryNameController.dispose();
    _interventionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VDC Form", style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditOptions,
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
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildImagePickerField(label: "Upload VDC Image"),
              const SizedBox(height: 16),
              _buildDocumentPicker(),
              const SizedBox(height: 16),
              FormHelpers.buildTextField(
                label: "Employee Name",
                controller: _employeeNameController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
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
                controller: _employeeNameController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.person,
              ),
              FormHelpers.buildTextField(
                label: "Forest Division",
                controller: _divisionController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.business,
              ),
              FormHelpers.buildTextField(
                label: "Sub Division/Region",
                controller: _subDivisionController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.map,
              ),
              FormHelpers.buildTextField(
                label: "Village/PU",
                controller: _villageController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.home,
              ),
              FormHelpers.buildTextField(
                label: "Refrence Coordinates Of Village / PU",
                controller: _villageController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.home,
              ),
              FormHelpers.buildTextField(
                label: "VDC Name",
                controller: _vdcController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.location_city,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Date of Registration",
                      prefixIcon: const Icon(Icons.calendar_today, color: AppColors.secondaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: AppColors.secondaryGreen),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceColor,
                    ),
                    // add name of project under which established.
                    child: Text(
                      selectedDate != null ? "${selectedDate!.toLocal()}".split(' ')[0] : 'Select Date',
                      style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey),
                    ),
                  ),
                ),
              ),
              FormHelpers.buildTextField(
                label: "Name Of Project Under Which Established",
                controller: _presidentNameController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.person_pin,
              ),
              FormHelpers.buildTextField(
                label: "Chairman Name",
                controller: _presidentNameController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.person_pin,
              ),
              FormHelpers.buildTextField(
                label: "Secretary/Treasurer Name",
                controller: _secretaryNameController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.person_pin,
              ),
              FormHelpers.buildTextField(
                label: "Number of VDC Members",
                controller: _vdcMembersController,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  final num = int.tryParse(value);
                  if (num == null || num > 15) return "Maximum 15 members";
                  return null;
                },
                prefixIcon: Icons.person_pin,
                keyboardType: TextInputType.number,
              ),

              // Add date of expiry where the user is notified through the notifaction. after 35 months it has ben notified.
             // add edit option to all form.
              FormHelpers.buildTextField(
                // contact number must be 11. not less nor max.
                label: "Contact Number",
                controller: _contactController,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (!RegExp(r'^\d{10,15}$').hasMatch(value)) return "Enter a valid number";
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
                              Icon(Icons.info_outline, size: 18, color: Colors.grey.shade500),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "No interventions added yet. Tap 'Add More' to add.",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    intervention["name"] ?? "",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => addedInterventions.removeAt(index));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.red, size: 16),
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
                            side: const BorderSide(color: AppColors.primaryGreen),
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
              FormHelpers.buildSubmitButton(onPressed: _submitForm, isLoading: _isSubmitting),
            ],
          ),
        ),
      ),
    );
  }

  // New widget for document picker
  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload Supporting Document",
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
                  "PDF, DOC, XLS, Images, and more",
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