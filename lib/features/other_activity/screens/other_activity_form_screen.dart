import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/other_activity/models/other_activity_model.dart';
import 'package:cdegad_kp/features/other_activity/providers/other_activity_provider.dart';

class OtherActivityFormScreen extends ConsumerStatefulWidget {
  final OtherActivityModel? existingActivity;

  const OtherActivityFormScreen({super.key, this.existingActivity});

  @override
  ConsumerState<OtherActivityFormScreen> createState() =>
      _OtherActivityFormScreenState();
}

class _OtherActivityFormScreenState
    extends ConsumerState<OtherActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _districtController = TextEditingController();
  final _divisionController = TextEditingController();
  final _tehsilController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile;
  File? _documentFile;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingActivity?.id != null;

  @override
  void initState() {
    super.initState();
    final activity = widget.existingActivity;
    if (activity != null) {
      _nameController.text = activity.activityName;
      _typeController.text = activity.activityType;
      _districtController.text = activity.district;
      _divisionController.text = activity.division;
      _tehsilController.text = activity.tehsil;
      _descriptionController.text = activity.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _districtController.dispose();
    _divisionController.dispose();
    _tehsilController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryGreen,
              ),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryGreen,
              ),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
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
        'txt',
        'csv',
      ],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _documentFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final fields = {
        'activityName': _nameController.text.trim(),
        'activityType': _typeController.text.trim(),
        'district': _districtController.text.trim(),
        'division': _divisionController.text.trim(),
        'tehsil': _tehsilController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      final notifier = ref.read(otherActivityListProvider.notifier);
      if (_isEditing) {
        await notifier.updateMultipart(
          widget.existingActivity!.id!,
          fields,
          image: _imageFile?.path,
          document: _documentFile?.path,
        );
      } else {
        await notifier.createMultipart(
          fields,
          image: _imageFile?.path,
          document: _documentFile?.path,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Activity updated successfully'
                  : 'Activity created successfully',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Activity' : 'New Activity'),
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
      body: RepaintBoundary(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 16),
                _buildDocumentPicker(),
                const SizedBox(height: 20),
                _buildField(
                  controller: _nameController,
                  label: 'Activity Name',
                  icon: Icons.label,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _typeController,
                  label: 'Activity Type',
                  icon: Icons.category,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _districtController,
                  label: 'District',
                  icon: Icons.location_city,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _divisionController,
                  label: 'Division',
                  icon: Icons.map,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _tehsilController,
                  label: 'Tehsil',
                  icon: Icons.place,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Save Changes' : 'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Image', style: AppTextStyles.formLabel),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _imageFile != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageFile = null),
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
                        Icons.add_a_photo,
                        size: 36,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add image',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Supporting Document', style: AppTextStyles.formLabel),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDocument,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _documentFile != null
                ? Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _documentFile!.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _documentFile = null),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to attach document',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryGreen),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
