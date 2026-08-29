import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/vdc/models/vdc_model.dart';
import 'package:cdegad_kp/features/vdc/providers/vdc_provider.dart';

class VdcFormScreen extends ConsumerStatefulWidget {
  final VdcModel? existingVdc;

  const VdcFormScreen({super.key, this.existingVdc});

  bool get isEditing => existingVdc != null;

  @override
  ConsumerState<VdcFormScreen> createState() => _VdcFormScreenState();
}

class _VdcFormScreenState extends ConsumerState<VdcFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _villageNameController;
  late final TextEditingController _districtController;
  late final TextEditingController _divisionController;
  late final TextEditingController _tehsilController;
  late final TextEditingController _provinceController;
  late final TextEditingController _descriptionController;

  File? _selectedImage;
  File? _selectedDocument;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final vdc = widget.existingVdc;
    _villageNameController = TextEditingController(text: vdc?.villageName ?? '');
    _districtController = TextEditingController(text: vdc?.district ?? '');
    _divisionController = TextEditingController(text: vdc?.division ?? '');
    _tehsilController = TextEditingController(text: vdc?.tehsil ?? '');
    _provinceController = TextEditingController(text: vdc?.province ?? '');
    _descriptionController = TextEditingController(text: vdc?.description ?? '');
  }

  @override
  void dispose() {
    _villageNameController.dispose();
    _districtController.dispose();
    _divisionController.dispose();
    _tehsilController.dispose();
    _provinceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.first.path != null) {
      setState(() => _selectedDocument = File(result.files.first.path!));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.isEditing) {
        final updatedVdc = VdcModel(
          id: widget.existingVdc!.id,
          villageName: _villageNameController.text.trim(),
          district: _districtController.text.trim(),
          division: _divisionController.text.trim(),
          tehsil: _tehsilController.text.trim(),
          province: _provinceController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: widget.existingVdc!.imageUrl,
          documentUrl: widget.existingVdc!.documentUrl,
        );
        await ref
            .read(vdcListProvider.notifier)
            .update(widget.existingVdc!.id.toString(), updatedVdc);
      } else {
        final fields = <String, dynamic>{
          'villageName': _villageNameController.text.trim(),
          'district': _districtController.text.trim(),
          'division': _divisionController.text.trim(),
          'tehsil': _tehsilController.text.trim(),
          'province': _provinceController.text.trim(),
          'description': _descriptionController.text.trim(),
        };
        await ref.read(vdcListProvider.notifier).createMultipart(
              fields,
              image: _selectedImage?.path,
              document: _selectedDocument?.path,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'VDC updated successfully' : 'VDC created successfully',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
        title: Text(widget.isEditing ? 'Edit VDC Record' : 'New VDC Record'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: RepaintBoundary(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildField(
                  controller: _villageNameController,
                  label: 'Village Name',
                  icon: Icons.house,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Village name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _districtController,
                  label: 'District',
                  icon: Icons.map,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'District is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _divisionController,
                  label: 'Division',
                  icon: Icons.category,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Division is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _tehsilController,
                  label: 'Tehsil',
                  icon: Icons.location_on,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Tehsil is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _provinceController,
                  label: 'Province',
                  icon: Icons.public,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Province is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _pickImage,
                        icon: Icon(
                          _selectedImage != null ? Icons.check_circle : Icons.image,
                          color: _selectedImage != null
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary,
                        ),
                        label: Text(
                          _selectedImage != null ? 'Image Selected' : 'Pick Image',
                          style: TextStyle(
                            color: _selectedImage != null
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _pickDocument,
                        icon: Icon(
                          _selectedDocument != null ? Icons.check_circle : Icons.attach_file,
                          color: _selectedDocument != null
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary,
                        ),
                        label: Text(
                          _selectedDocument != null ? 'Doc Selected' : 'Pick Document',
                          style: TextStyle(
                            color: _selectedDocument != null
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.secondaryGreen.withAlpha(100),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            widget.isEditing ? 'Update Record' : 'Create Record',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerColor.withAlpha(128)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerColor.withAlpha(128)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
      ),
    );
  }
}
