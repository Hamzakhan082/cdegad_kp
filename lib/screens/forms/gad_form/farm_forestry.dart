import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../constants/constants.dart';
import '../../../widgts/home_items.dart';

class FarmAgroForm extends StatefulWidget {
  const FarmAgroForm({super.key});

  @override
  State<FarmAgroForm> createState() => _FarmAgroFormState();
}

class _FarmAgroFormState extends State<FarmAgroForm> with ImagePickerMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _areaController = TextEditingController();
  final _totalPlantsController = TextEditingController();

  // File and image storage
  File? _supportingDocument;
  String? _selectedDocumentName;

  // Plant types list
  final List<String> _plantTypes = [
    'Acacia Albida', 'Farnesiana', 'Quercus', 'Acasia Glavca', 'Orange', 'Rambil', 'Habiscus', 'Bogan belia',
    'Acacia Perconsonia', 'Gander', 'Reen', 'Acer', 'Pasta', 'Rat ki Rani', 'Hair Pom', 'Bottle Bursh',
    'Acacia Victoria', 'Gledcia', 'Reetha', 'Alistonia', 'Peach', 'Rose', 'Jasmine', 'Cassia Gluaka',
    'Ailanthus', 'Horsechestnut', 'Retha', 'Amaltas', 'Pecon', 'Rose Merry', 'Jeranaim', 'Chambali',
    'Albeeda', 'Imli', 'Robinia', 'Antara', 'Pear', 'Safora', 'Jocoranda', 'Conocarpus',
    'Bakian', 'Ipple Ipple', 'Robinia Kikar', 'Arjun', 'Persimen', 'Sanatha', 'Juranda', 'Darontha',
    'Batkaral', 'Jand', 'Sarikh', 'Artonia', 'Plum', 'Sarro', 'Kachnar', 'Daruna',
    'Ber', 'Kail', 'Sharol', 'Astarkolya', 'Pomegranate', 'Shanai', 'Kangi Palm', 'Din Ka Raja',
    'Bheens', 'Kanghar', 'Shesham', 'Bambarina', 'Russian Olive', 'Silver', 'Kasra', 'Dodonai',
    'Black Palm', 'Kikar', 'Shinus Moli', 'Oalendier', 'Shahtoot', 'Silver Oak', 'Lagerstromia', 'Euphobia',
    'Candle Beri', 'Korasia', 'Simal', 'Victoria Singa', 'Toot', 'Sohajna', 'Lal Pati', 'Facansonia',
    'Casia Fastola', 'Marfa', 'Sirin', 'Walnut', 'Sepium', 'Logistum', 'Ficus',
    'Casurina', 'Mazari', 'Siris', 'Zarcha', 'Stercolia', 'Maria', 'Ficus Black',
    'Charbi', 'Millia', 'Siyal Kikar', 'Amlok', 'Olive', 'Subzdranti', 'Marwa', 'Ficus Golden',
    'Chinar', 'Mud grass', 'Sum', 'Amrood', 'Alobukhara', 'Suk Chan', 'Moranga', 'Ficus Lake',
    'Chir', 'Oak', 'Ulcia', 'Anardana', 'Alocha', 'Sukchai', 'Morphank', 'Ficus Novie',
    'Chir Pine', 'Perciqqna', 'Willow', 'Apple', 'Almond', 'Synofila', 'Motia', 'Ficus White',
    'Deodar', 'Persion Pine', 'Palm', 'Apricot', 'Mulberry', 'Sypres', 'Mruch', 'Gandery',
    'Dhaman', 'Phullai', 'Panda Ficus', 'Banana', 'Narang', 'Table Palm', 'Nim', 'Gandula',
    'Eucalyptus', 'Poplar', 'Parkinsonia', 'Chalghoza', 'Guava', 'Tarminilia', 'Oleander', 'Garanta',
    'Praso', 'Gul Kaneer', 'Falsa', 'Injeer', 'Tocoma', 'Loqat', 'Gardenia',
    'Grabelia', 'Lemon', 'Grapes', 'Jaman', 'Gul Toot', 'Gren Duranta', 'Gazinia'
  ];

  // Controllers for plant counts
  final Map<String, TextEditingController> _plantCountControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each plant type
    for (var plantType in _plantTypes) {
      _plantCountControllers[plantType] = TextEditingController(text: '0');
    }
  }

  Future<void> _pickDocument() async {
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

      if (!context.mounted) return;
      if (result != null && result.files.single.path != null) {
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking document: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Collect plant distribution data
      Map<String, int> plantsDistributed = {};
      int totalDistributed = 0;

      for (var plantType in _plantTypes) {
        int count = int.tryParse(_plantCountControllers[plantType]!.text) ?? 0;
        if (count > 0) {
          plantsDistributed[plantType] = count;
          totalDistributed += count;
        }
      }

      // Update the total plants field
      _totalPlantsController.text = totalDistributed.toString();

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Farm Forestry Data Submitted Successfully!"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _locationController.dispose();
    _cropTypeController.dispose();
    _areaController.dispose();
    _totalPlantsController.dispose();

    // Dispose plant count controllers
    for (var controller in _plantCountControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farm Forestry Form", style: AppTextStyles.appBarTitle),
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildImagePickerField(label: "Upload Farm Image"),
              const SizedBox(height: 16),
              _buildDocumentPicker(),
              const SizedBox(height: 16),
              FormHelpers.buildTextField(
                label: "Employee Name",
                controller: _farmNameController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.agriculture,
              ),
              FormHelpers.buildTextField(
                label: "Forest Division",
                controller: _locationController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.location_on,
              ),
              FormHelpers.buildTextField(
                label: "Name of Sub Division",
                controller: _cropTypeController,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
                prefixIcon: Icons.grass,
              ),
              _buildPlantDistributionTable(),
              _buildTotalPlantsField(),
              const SizedBox(height: 24),
              FormHelpers.buildSubmitButton(onPressed: _submitForm, isLoading: _isSubmitting),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPlantsField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _totalPlantsController,
        enabled: false, // This field is disabled and auto-calculated
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: " Plants Distributed Today",
          prefixIcon: Icon(Icons.straighten, color: AppColors.primaryGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade100, // Lighter background to indicate it's disabled
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantDistributionTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "No Of Plants Distributed",
              style: AppTextStyles.formLabel,
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                for (var controller in _plantCountControllers.values) {
                  controller.text = '0';
                }
                _totalPlantsController.text = '0';
              },
              child: Text(
                "Reset All",
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Type",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Number",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Table content
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _plantTypes.length,
                  itemBuilder: (context, index) {
                    final plantType = _plantTypes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              plantType,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _plantCountControllers[plantType],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                // Auto-calculate total
                                int total = 0;
                                for (var controller in _plantCountControllers.values) {
                                  total += int.tryParse(controller.text) ?? 0;
                                }
                                _totalPlantsController.text = total.toString();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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


// REMOVE this form.