import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cdegad_kp/constants/constants.dart';
import 'package:cdegad_kp/features/awareness/models/awareness_model.dart';
import 'package:cdegad_kp/features/awareness/providers/awareness_provider.dart';

class AwarenessFormScreen extends ConsumerStatefulWidget {
  final AwarenessModel? existing;

  const AwarenessFormScreen({super.key, this.existing});

  @override
  ConsumerState<AwarenessFormScreen> createState() =>
      _AwarenessFormScreenState();
}

class _AwarenessFormScreenState extends ConsumerState<AwarenessFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _topicCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _divisionCtrl;
  late final TextEditingController _tehsilCtrl;
  late final TextEditingController _participantsCtrl;
  late final TextEditingController _descriptionCtrl;

  DateTime? _sessionDate;
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
    _titleCtrl = TextEditingController(text: m?.title ?? '');
    _topicCtrl = TextEditingController(text: m?.topic ?? '');
    _districtCtrl = TextEditingController(text: m?.district ?? '');
    _divisionCtrl = TextEditingController(text: m?.division ?? '');
    _tehsilCtrl = TextEditingController(text: m?.tehsil ?? '');
    _participantsCtrl = TextEditingController(text: m?.participantsCount ?? '');
    _descriptionCtrl = TextEditingController(text: m?.description ?? '');
    _existingImageUrl = m?.imageUrl;
    _existingDocumentUrl = m?.documentUrl;
    if (m?.sessionDate != null) {
      _sessionDate = DateTime.tryParse(m!.sessionDate!);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _topicCtrl.dispose();
    _districtCtrl.dispose();
    _divisionCtrl.dispose();
    _tehsilCtrl.dispose();
    _participantsCtrl.dispose();
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
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentFile = File(result.files.single.path!);
        _pickedDocName = result.files.single.name;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _sessionDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(awarenessListProvider.notifier);
      final fields = {
        'title': _titleCtrl.text.trim(),
        'topic': _topicCtrl.text.trim(),
        'district': _districtCtrl.text.trim(),
        'division': _divisionCtrl.text.trim(),
        'tehsil': _tehsilCtrl.text.trim(),
        'participantsCount': _participantsCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        if (_sessionDate != null)
          'sessionDate': _sessionDate!.toIso8601String().split('T')[0],
      };

      if (_isEditing) {
        final model = widget.existing!.copyWith(
          title: fields['title']!,
          topic: fields['topic']!,
          district: fields['district']!,
          division: fields['division']!,
          tehsil: fields['tehsil']!,
          participantsCount: fields['participantsCount']!,
          description: fields['description']!,
          sessionDate: fields['sessionDate'],
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
          final model = AwarenessModel.fromJson(fields);
          await notifier.create(model);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Record updated successfully' : 'Record created successfully'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorColor),
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
        title: Text(_isEditing ? 'Edit Session' : 'New Session'),
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
                _buildSectionHeader('Session Details'),
                const SizedBox(height: 12),
                _buildField('Title', _titleCtrl, Icons.title),
                _buildField('Topic', _topicCtrl, Icons.topic),
                _buildField('District', _districtCtrl, Icons.location_city),
                _buildField('Division', _divisionCtrl, Icons.business),
                _buildField('Tehsil', _tehsilCtrl, Icons.map),
                _buildField('Participants Count', _participantsCtrl, Icons.people, keyboardType: TextInputType.number),
                _buildField('Description', _descriptionCtrl, Icons.description, maxLines: 3),
                const SizedBox(height: 20),
                _buildSectionHeader('Session Date'),
                const SizedBox(height: 12),
                _buildDateField(),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isEditing ? 'Update Record' : 'Save Record',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Session Date',
          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.secondaryGreen),
          filled: true,
          fillColor: AppColors.surfaceColor,
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
        ),
        child: Text(
          _sessionDate != null
              ? '${_sessionDate!.toLocal()}'.split(' ')[0]
              : 'Select date',
          style: TextStyle(
            color: _sessionDate != null ? AppColors.textPrimary : AppColors.textSecondary,
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
          _pickedImageName ?? (_existingImageUrl != null ? 'Image attached' : 'Pick Image'),
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
          _pickedDocName ?? (_existingDocumentUrl != null ? 'Document attached' : 'Pick Document'),
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
