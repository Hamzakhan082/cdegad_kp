import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cdegad_kp/constants/constants.dart';

import 'package:cdegad_kp/features/youth_women_nursery/models/youth_women_nursery_model.dart';
import 'package:cdegad_kp/features/youth_women_nursery/providers/youth_women_nursery_provider.dart';

class YouthWomenNurseryFormScreen extends ConsumerStatefulWidget {
  final YouthWomenNurseryModel? existingModel;

  const YouthWomenNurseryFormScreen({super.key, this.existingModel});

  @override
  ConsumerState<YouthWomenNurseryFormScreen> createState() =>
      _YouthWomenNurseryFormScreenState();
}

class _YouthWomenNurseryFormScreenState
    extends ConsumerState<YouthWomenNurseryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nurseryNameController;
  late final TextEditingController _districtController;
  late final TextEditingController _divisionController;
  late final TextEditingController _tehsilController;
  late final TextEditingController _provinceController;
  late final TextEditingController _totalPlantsController;
  late final TextEditingController _speciesController;
  late final TextEditingController _descriptionController;

  File? _imageFile;
  File? _documentFile;
  bool _isSubmitting = false;
  final _picker = ImagePicker();

  bool get _isEditing => widget.existingModel != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existingModel;
    _nurseryNameController = TextEditingController(text: m?.nurseryName ?? '');
    _districtController = TextEditingController(text: m?.district ?? '');
    _divisionController = TextEditingController(text: m?.division ?? '');
    _tehsilController = TextEditingController(text: m?.tehsil ?? '');
    _provinceController = TextEditingController(text: m?.province ?? '');
    _totalPlantsController = TextEditingController(text: m?.totalPlants ?? '');
    _speciesController = TextEditingController(text: m?.species ?? '');
    _descriptionController = TextEditingController(text: m?.description ?? '');
  }

  @override
  void dispose() {
    _nurseryNameController.dispose();
    _districtController.dispose();
    _divisionController.dispose();
    _tehsilController.dispose();
    _provinceController.dispose();
    _totalPlantsController.dispose();
    _speciesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickDocument() async {
    final picked = await _picker.pickMedia();
    if (picked != null) setState(() => _documentFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(youthWomenNurseryNotifierProvider.notifier);

      final fields = {
        'nurseryName': _nurseryNameController.text.trim(),
        'district': _districtController.text.trim(),
        'division': _divisionController.text.trim(),
        'tehsil': _tehsilController.text.trim(),
        'province': _provinceController.text.trim(),
        'totalPlants': _totalPlantsController.text.trim(),
        'species': _speciesController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      if (_isEditing) {
        await notifier.update(
          widget.existingModel!.id.toString(),
          YouthWomenNurseryModel.fromJson(fields),
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
              _isEditing ? 'Nursery updated' : 'Nursery created',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
        title: Text(_isEditing ? 'Edit Nursery' : 'New Nursery'),
        backgroundColor: AppColors.womenNursery,
      ),
      body: RepaintBoundary(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nurseryNameController,
                  decoration: const InputDecoration(labelText: 'Nursery Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _districtController,
                  decoration: const InputDecoration(labelText: 'District'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _divisionController,
                  decoration: const InputDecoration(labelText: 'Division'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tehsilController,
                  decoration: const InputDecoration(labelText: 'Tehsil'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _provinceController,
                  decoration: const InputDecoration(labelText: 'Province'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _totalPlantsController,
                  decoration: const InputDecoration(labelText: 'Total Plants'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(labelText: 'Species'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                _buildFileSection(
                  label: 'Image',
                  file: _imageFile,
                  existingUrl: widget.existingModel?.imageUrl,
                  onPick: _pickImage,
                  onClear: () => setState(() => _imageFile = null),
                ),
                const SizedBox(height: 12),
                _buildFileSection(
                  label: 'Document',
                  file: _documentFile,
                  existingUrl: widget.existingModel?.documentUrl,
                  onPick: _pickDocument,
                  onClear: () => setState(() => _documentFile = null),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.womenNursery,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Update' : 'Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileSection({
    required String label,
    required File? file,
    required String? existingUrl,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    final hasFile = file != null;
    final hasExisting = existingUrl != null && existingUrl.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.formLabel),
            const SizedBox(height: 8),
            if (hasFile)
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(file.path.split('/').last)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClear,
                  ),
                ],
              )
            else if (hasExisting)
              Row(
                children: [
                  const Icon(Icons.link, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      existingUrl.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file),
                label: Text('Pick $label'),
              ),
            if (!hasFile && hasExisting)
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.change_circle),
                label: Text('Change $label'),
              ),
          ],
        ),
      ),
    );
  }
}
