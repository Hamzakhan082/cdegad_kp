import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/mass_plantation/models/mass_plantation_model.dart';
import 'package:cdegad_kp/features/mass_plantation/providers/mass_plantation_provider.dart';

class MassPlantationFormScreen extends ConsumerStatefulWidget {
  final MassPlantationModel? existing;

  const MassPlantationFormScreen({super.key, this.existing});

  @override
  ConsumerState<MassPlantationFormScreen> createState() =>
      _MassPlantationFormScreenState();
}

class _MassPlantationFormScreenState
    extends ConsumerState<MassPlantationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final TextEditingController _plantationNameCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _divisionCtrl;
  late final TextEditingController _tehsilCtrl;
  late final TextEditingController _provinceCtrl;
  late final TextEditingController _totalPlantsCtrl;
  late final TextEditingController _speciesCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _descriptionCtrl;

  File? _imageFile;
  File? _documentFile;
  String? _existingImageUrl;
  String? _existingDocumentUrl;
  String? _pickedImageName;
  String? _pickedDocName;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _plantationNameCtrl = TextEditingController(text: m?.plantationName ?? '');
    _districtCtrl = TextEditingController(text: m?.district ?? '');
    _divisionCtrl = TextEditingController(text: m?.division ?? '');
    _tehsilCtrl = TextEditingController(text: m?.tehsil ?? '');
    _provinceCtrl = TextEditingController(text: m?.province ?? '');
    _totalPlantsCtrl = TextEditingController(text: m?.totalPlants ?? '');
    _speciesCtrl = TextEditingController(text: m?.species ?? '');
    _areaCtrl = TextEditingController(text: m?.area ?? '');
    _descriptionCtrl = TextEditingController(text: m?.description ?? '');
    _existingImageUrl = m?.imageUrl;
    _existingDocumentUrl = m?.documentUrl;
  }

  @override
  void dispose() {
    _plantationNameCtrl.dispose();
    _districtCtrl.dispose();
    _divisionCtrl.dispose();
    _tehsilCtrl.dispose();
    _provinceCtrl.dispose();
    _totalPlantsCtrl.dispose();
    _speciesCtrl.dispose();
    _areaCtrl.dispose();
    _descriptionCtrl.dispose();
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
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _pickedImageName = picked.name;
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
      ],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentFile = File(result.files.single.path!);
        _pickedDocName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(massPlantationListProvider.notifier);
      final fields = {
        'plantationName': _plantationNameCtrl.text.trim(),
        'district': _districtCtrl.text.trim(),
        'division': _divisionCtrl.text.trim(),
        'tehsil': _tehsilCtrl.text.trim(),
        'province': _provinceCtrl.text.trim(),
        'totalPlants': _totalPlantsCtrl.text.trim(),
        'species': _speciesCtrl.text.trim(),
        'area': _areaCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
      };

      if (_isEditing) {
        final model = widget.existing!.copyWith(
          plantationName: fields['plantationName']!,
          district: fields['district']!,
          division: fields['division']!,
          tehsil: fields['tehsil']!,
          province: fields['province']!,
          totalPlants: fields['totalPlants']!,
          species: fields['species']!,
          area: fields['area']!,
          description: fields['description']!,
        );
        await notifier.update(model.id.toString(), model);
      } else {
        if (_imageFile != null || _documentFile != null) {
          await notifier.createMultipart(
            fields,
            image: _imageFile?.path,
            document: _documentFile?.path,
          );
        } else {
          final model = MassPlantationModel.fromJson(fields);
          await notifier.create(model);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Record updated successfully'
                : 'Record created successfully',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Plantation' : 'New Plantation'),
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
      body: RepaintBoundary(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('Plantation Details'),
                const SizedBox(height: 12),
                _buildField(
                  'Plantation Name',
                  _plantationNameCtrl,
                  Icons.forest,
                ),
                _buildField('District', _districtCtrl, Icons.location_city),
                _buildField('Division', _divisionCtrl, Icons.business),
                _buildField('Tehsil', _tehsilCtrl, Icons.map),
                _buildField('Province', _provinceCtrl, Icons.public),
                const SizedBox(height: 20),
                _buildSectionHeader('Planting Information'),
                const SizedBox(height: 12),
                _buildField(
                  'Total Plants',
                  _totalPlantsCtrl,
                  Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                ),
                _buildField('Species', _speciesCtrl, Icons.eco),
                _buildField('Area', _areaCtrl, Icons.square_foot),
                _buildField(
                  'Description',
                  _descriptionCtrl,
                  Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Attachments'),
                const SizedBox(height: 12),
                _buildImagePicker(),
                const SizedBox(height: 12),
                _buildDocumentPicker(),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
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
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Update Record' : 'Save Record',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryGreen),
          filled: true,
          fillColor: AppColors.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.dividerColor.withAlpha(128),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.dividerColor.withAlpha(128),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen.withAlpha(26),
          child: const Icon(Icons.image, color: AppColors.primaryGreen),
        ),
        title: Text(
          _pickedImageName ??
              (_existingImageUrl != null ? 'Image attached' : 'Pick Image'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text('Camera or Gallery'),
        trailing: IconButton(
          icon: const Icon(Icons.add_a_photo, color: AppColors.secondaryGreen),
          onPressed: _pickImage,
        ),
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondaryGreen.withAlpha(26),
          child: const Icon(Icons.attach_file, color: AppColors.secondaryGreen),
        ),
        title: Text(
          _pickedDocName ??
              (_existingDocumentUrl != null
                  ? 'Document attached'
                  : 'Pick Document'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text('PDF, DOC, XLS, etc.'),
        trailing: IconButton(
          icon: const Icon(Icons.upload_file, color: AppColors.secondaryGreen),
          onPressed: _pickDocument,
        ),
      ),
    );
  }
}
