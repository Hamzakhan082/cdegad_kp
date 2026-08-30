import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../constants/constants.dart';
import '../../../features/awareness/repositories/awareness_repository.dart';
import '../../../widgts/home_items.dart';

class ExtensionMaterialScreen extends ConsumerStatefulWidget {
  const ExtensionMaterialScreen({super.key});

  @override
  ConsumerState<ExtensionMaterialScreen> createState() =>
      _ExtensionMaterialScreenState();
}

class _ExtensionMaterialScreenState
    extends ConsumerState<ExtensionMaterialScreen>
    with ImagePickerMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  String? selectedRegion;

  final List<String> regions = ['Region I', 'Region II', 'Region III'];

  final Map<String, TextEditingController> _controllers = {};

  final List<String> _fields = [
    "Employee Name",
    "Name of Forest Region",
    "Name of Forest Circle",
    "Name of Division",
    "Name of Sub-Division / Range",
    "Name of Project",
    "Type of Event",
    "Name of Institution / Organization",
    "Venue",
    "Chief Guest",
    "Description",
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
    super.dispose();
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
          _selectedFile = result.files.single;
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
      _selectedFile = null;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        await ref
            .read(awarenessRepositoryProvider)
            .createMultipart(
              {
                'employee_name': _controllers["Employee Name"]!.text.trim(),
                'forest_region': selectedRegion ?? '',
                'forest_circle_name': _controllers["Name of Forest Circle"]!
                    .text
                    .trim(),
                'division_name': _controllers["Name of Division"]!.text.trim(),
                'sub_division_range':
                    _controllers["Name of Sub-Division / Range"]!.text.trim(),
                'project_name': _controllers["Name of Project"]!.text.trim(),
                'type_of_event': _controllers["Type of Event"]!.text.trim(),
                'institution_name':
                    _controllers["Name of Institution / Organization"]!.text
                        .trim(),
                'venue': _controllers["Venue"]!.text.trim(),
                'chief_guest': _controllers["Chief Guest"]!.text.trim(),
                'description': _controllers["Description"]!.text.trim(),
              },
              image: selectedImage?.path,
              document: _selectedFile?.path,
            );
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        String message2 = "Form submitted successfully!";
        if (_selectedFileName != null) {
          message2 += "\nFile attached: $_selectedFileName";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message2),
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
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Awareness Raising Sessions",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditOptions,
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Using the ImagePickerMixin widget
              buildImagePickerField(label: "Upload Image / Take Pic"),
              const SizedBox(height: 10),
              // File picker field
              buildFilePickerField(
                label: "Attach Supporting Document",
                fileName: _selectedFileName,
                onPressed: _pickFile,
                onClear: _clearSelectedFile,
              ),
              ..._fields.asMap().entries.map((entry) {
                final field = entry.value;
                if (field == "Name of Forest Region") {
                  return FormHelpers.buildDropdownField(
                    label: field,
                    options: regions,
                    value: selectedRegion,
                    validator: (value) => value == null ? 'Required' : null,
                    onChanged: (value) {
                      setState(() {
                        selectedRegion = value;
                      });
                    },
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Activity Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Using the FormHelpers submit button
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

  // Helper to get relevant icons for each field
  IconData _getIconForField(String field) {
    switch (field) {
      case "Employee Name":
        return Icons.person;
      case "Name of Forest Region":
        return Icons.location_city;
      case "Name of Project":
        return Icons.folder;
      case "Name of Forest Circle":
        return Icons.circle;
      case "Name of Division":
        return Icons.business;
      case "Name of Sub-Division / Range":
        return Icons.map;
      case "Type of Event":
        return Icons.event_note;
      case "Name of Institution / Organization":
        return Icons.account_balance;
      case "Venue":
        return Icons.flag;
      case "Chief Guest":
        return Icons.person_pin;
      case "Activity Description":
        return Icons.description;
      default:
        return Icons.extension;
    }
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit, color: AppColors.primaryGreen),
              ),
              title: const Text("Edit Form Data"),
              subtitle: const Text("Modify existing record"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Edit mode - modify form data"),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Record deleted successfully"),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
