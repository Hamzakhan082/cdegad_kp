import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/women_organization/models/women_organization_model.dart';
import 'package:cdegad_kp/features/women_organization/providers/women_organization_provider.dart';

class WomenOrganizationFormScreen extends ConsumerStatefulWidget {
  final WomenOrganizationModel? editItem;

  const WomenOrganizationFormScreen({super.key, this.editItem});

  bool get isEditing => editItem != null;

  @override
  ConsumerState<WomenOrganizationFormScreen> createState() =>
      _WomenOrganizationFormScreenState();
}

class _WomenOrganizationFormScreenState
    extends ConsumerState<WomenOrganizationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _districtController;
  late final TextEditingController _divisionController;
  late final TextEditingController _tehsilController;
  late final TextEditingController _provinceController;
  late final TextEditingController _membersController;
  late final TextEditingController _descriptionController;

  File? _imageFile;
  File? _documentFile;
  String? _existingImageUrl;
  String? _existingDocumentUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;
    _nameController = TextEditingController(text: item?.organizationName ?? '');
    _districtController = TextEditingController(text: item?.district ?? '');
    _divisionController = TextEditingController(text: item?.division ?? '');
    _tehsilController = TextEditingController(text: item?.tehsil ?? '');
    _provinceController = TextEditingController(text: item?.province ?? '');
    _membersController =
        TextEditingController(text: item?.membersCount != null ? '${item!.membersCount}' : '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _existingImageUrl = item?.imageUrl;
    _existingDocumentUrl = item?.documentUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _divisionController.dispose();
    _tehsilController.dispose();
    _provinceController.dispose();
    _membersController.dispose();
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
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
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
      setState(() {
        _imageFile = File(picked.path);
        _existingImageUrl = null;
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
        'jpg', 'jpeg', 'png', 'txt', 'csv',
      ],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentFile = File(result.files.single.path!);
        _existingDocumentUrl = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _existingImageUrl = null;
    });
  }

  void _removeDocument() {
    setState(() {
      _documentFile = null;
      _existingDocumentUrl = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final fields = {
        'organizationName': _nameController.text.trim(),
        'district': _districtController.text.trim(),
        'division': _divisionController.text.trim(),
        'tehsil': _tehsilController.text.trim(),
        'province': _provinceController.text.trim(),
        'membersCount': int.tryParse(_membersController.text.trim()) ?? 0,
        'description': _descriptionController.text.trim(),
      };

      if (widget.isEditing) {
        final updated = widget.editItem!.copyWith(
          organizationName: fields['organizationName'] as String,
          district: fields['district'] as String,
          division: fields['division'] as String,
          tehsil: fields['tehsil'] as String,
          province: fields['province'] as String,
          membersCount: fields['membersCount'] as int,
          description: fields['description'] as String,
        );
        await ref
            .read(womenOrganizationListProvider.notifier)
            .updateItem(widget.editItem!.id!, updated);
      } else {
        await ref.read(womenOrganizationListProvider.notifier).create(
              WomenOrganizationModel.fromJson(fields),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Updated successfully' : 'Created successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorColor),
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
        title: Text(widget.isEditing ? 'Edit Organization' : 'New Organization'),
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
                  label: 'Organization Name',
                  icon: Icons.business,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _districtController,
                  label: 'District',
                  icon: Icons.location_city,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _divisionController,
                  label: 'Division',
                  icon: Icons.map,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _tehsilController,
                  label: 'Tehsil',
                  icon: Icons.place,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _provinceController,
                  label: 'Province',
                  icon: Icons.account_balance,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _buildField(
                  controller: _membersController,
                  label: 'Members Count',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (int.tryParse(v.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                _buildField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            widget.isEditing ? 'Update' : 'Submit',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        Text('Organization Image', style: AppTextStyles.formLabel),
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
                        child: Image.file(_imageFile!,
                            width: double.infinity, height: 160, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Tap to add image',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
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
                      const Icon(Icons.description, color: AppColors.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _documentFile!.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _removeDocument,
                        child: const Icon(Icons.close, color: Colors.red, size: 20),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Text('Tap to attach document',
                          style: TextStyle(color: Colors.grey.shade500)),
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
