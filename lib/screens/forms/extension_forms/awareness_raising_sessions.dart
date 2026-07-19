import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/constants.dart';
import '../../../widgts/home_items.dart';

class ExtensionMaterialScreen extends StatefulWidget {
  const ExtensionMaterialScreen({super.key});

  @override
  State<ExtensionMaterialScreen> createState() => _ExtensionMaterialScreenState();
}

class _ExtensionMaterialScreenState extends State<ExtensionMaterialScreen> with ImagePickerMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _selectedFileName;
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
          'mp4', 'avi', 'mov', 'mp3', 'wav'
        ],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File selected: $_selectedFileName"),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      if (!context.mounted) return;
      if (mounted) {
        setState(() => _isSubmitting = false);

        String message = "Form Submitted Successfully";
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Awareness Raising Sessions", style: AppTextStyles.appBarTitle),
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
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  prefixIcon: _getIconForField(field),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Activity Description",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
      case "Type Of Event":
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
        content: const Text("Are you sure you want to delete this record? This action cannot be undone."),
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

// Add this mixin to your ImagePickerMixin if it doesn't already have the buildFilePickerField method
mixin ImagePickerMixin<T extends StatefulWidget> on State<T> {
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking image: $e"),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void clearImage() {
    setState(() {
      _pickedImage = null;
    });
  }

  Widget buildImagePickerField({required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _pickedImage != null
                  ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _pickedImage!.path as dynamic,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                              const SizedBox(height: 8),
                              Text(
                                "Error loading image",
                                style: TextStyle(color: Colors.grey[500], fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: clearImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to upload image",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilePickerField({
    required String label,
    required String? fileName,
    required VoidCallback onPressed,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 24,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName ?? "Tap to select file",
                      style: TextStyle(
                        color: fileName != null ? Colors.black87 : Colors.grey[600],
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fileName != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: onClear,
                    ),
                ],
              ),
            ),
          ),
          if (fileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "File selected: $fileName",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}