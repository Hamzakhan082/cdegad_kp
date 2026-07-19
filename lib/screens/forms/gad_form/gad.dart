import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../screens/records/records_view_page.dart';

void main() {
  runApp(const GADApp());
}

class GADApp extends StatelessWidget {
  const GADApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Department GAD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GADPage(),
    );
  }
}

class GADPage extends StatefulWidget {
  const GADPage({super.key});

  @override
  State<GADPage> createState() => _GADPageState();
}

class _GADPageState extends State<GADPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> options = [
    {
      "title": "Women Organization",// only woman organization.
      "icon": Icons.diversity_3,
      "color": const Color(0xFFE91E63),
      "gradient": const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFAD1457)]),
      "description": "Empowering women through community organization"
    },
    {
      "title": "Women Nursery",
      "icon": Icons.nature_people,
      "color": const Color(0xFF9C27B0),
      "gradient": const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)]),
      "description": "Nurturing young minds in environmental care"
    },
    {
      "title": "Mass Planting Event",
      "icon": Icons.park,
      "color": const Color(0xFF009688),
      "gradient": const LinearGradient(colors: [Color(0xFF009688), Color(0xFF00695C)]),
      "description": "Community-driven plantation initiatives"
    },
    {
      "title": "Farm / Agro Forestry",
      "icon": Icons.agriculture,
      "color": const Color(0xFF4CAF50),
      "gradient": const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
      "description": "Sustainable farming and forestry practices"
    },
    {
      "title": "Other Activity",
      "icon": Icons.extension,
      "color": const Color(0xFF2196F3),
      "gradient": const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1565C0)]),
      "description": "Various community development activities"
    },
  ];

  late AnimationController _headerController;
  late AnimationController _cardController;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _cardAnimations = List.generate(
      options.length,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            0.1 + (index * 0.15),
            0.7 + (index * 0.05),
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _headerController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE8F5E9),
                const Color(0xFFF1F8E9),
                const Color(0xFFF9FBE7),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildOptionsGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(_headerAnimation),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.diversity_1,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Gender & Development",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Empowering Communities",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Select an activity to manage and track community development initiatives",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.70,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final item = options[index];
          return AnimatedBuilder(
            animation: _cardAnimations[index],
            builder: (context, child) {
              return FadeTransition(
                opacity: _cardAnimations[index],
                child: Transform.scale(
                  scale: 0.9 + (0.1 * _cardAnimations[index].value),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_cardAnimations[index]),
                    child: _buildModernCard(item),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildModernCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OptionPage(activity: item["title"], gradient: item["gradient"]),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: item["gradient"],
          boxShadow: [
            BoxShadow(
              color: item["color"].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: item["color"].withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item["icon"],
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  // Title
                  Text(
                    item["title"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    item["description"] ?? "",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Arrow indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen with two options: Enter new data or view records
class OptionPage extends StatelessWidget {
  final String activity;
  final Gradient gradient;
  const OptionPage({super.key, required this.activity, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradient.colors.first.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(child: _buildOptions(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Choose an option",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildOptionCard(
            context: context,
            icon: Icons.add_circle_outline,
            label: "Enter New Data",
            description: "Create a new record for $activity",
            color: gradient.colors.first,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      GADFormPage(activity: activity, gradient: gradient),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildOptionCard(
            context: context,
            icon: Icons.folder_outlined,
            label: "View Records",
            description: "Browse existing records for $activity",
            color: Colors.blueGrey.shade700,
            onTap: () {
              final List<Color> recordGradient = gradient.colors.cast<Color>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecordsViewPage(
                    formType: activity,
                    gradient: recordGradient,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'option_card_$label',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic form page with document upload
class GADFormPage extends StatefulWidget {
  final String activity;
  final Gradient gradient;
  const GADFormPage({super.key, required this.activity, required this.gradient});

  @override
  State<GADFormPage> createState() => _GADFormPageState();
}

class _GADFormPageState extends State<GADFormPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final DateFormat _fmt = DateFormat('dd-MM-yyyy');
  File? pickedImage;
  PlatformFile? selectedDocument;
  bool _isSubmitting = false;

  String? selectedRegion;
  String? selectedNurseryType;
  final List<String> regions = ['Region I', 'Region II', 'Region III'];
  final List<String> nurseryTypes = ['Bare Rooted', 'Tube'];
  final List<Map<String, String>> addedInterventions = [];
  final List<Map<String, String>> plantDistributionList = [];
  final TextEditingController _plantTypeController = TextEditingController();
  final TextEditingController _plantNumberController = TextEditingController();

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(_fabController);
    _fabController.forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _fabController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    // Initialize controllers based on activity type
    switch (widget.activity) {
      case "Women Organization":
        _controllers.addAll({
          "Employee Name": TextEditingController(),
          "Name of Forest Circle": TextEditingController(),
          "Name of Forest Division": TextEditingController(),
          "Name of Sub-Division / Range": TextEditingController(),
          "Name of Village / PU": TextEditingController(),
          "Name of WO": TextEditingController(),
          "Date of Registration": TextEditingController(),
          "Project under Which Established": TextEditingController(),
          "Name of Chairperson": TextEditingController(),
          "Name of Sectary/Treasurer": TextEditingController(),
          "Contact Number of Chairman": TextEditingController(),
          "NContact Number of Chairperson": TextEditingController(),
          "Number of WO Members": TextEditingController(),
        });
        break;
      case "Women Nursery":
        _controllers.addAll({
          "Employee Name": TextEditingController(),
          "Name of Forest Circle": TextEditingController(),
          "Name of Project Under Which Established": TextEditingController(),
          "Name of Division": TextEditingController(),
          "Name of Sub-division | Range": TextEditingController(),
          "WO": TextEditingController(),
          "Name of Nursery Grower": TextEditingController(),
          "Contact Number": TextEditingController(),
          "CNIC of Nursery Grower": TextEditingController(),
          "Date Of Agreement": TextEditingController(),
          "Refrence Coordinates": TextEditingController(),
          "Location | Village | Site Name": TextEditingController(),
          "No of Unit/No of Plants": TextEditingController(),
          "Date of Establishment": TextEditingController(),
        });
        break;
      case "Mass Planting Event":
        _controllers.addAll({
          "Employee Name": TextEditingController(),
          "Name of Forest Circle": TextEditingController(),
          "Name of Division": TextEditingController(),
          "Chief Guest's Name of Event": TextEditingController(),
          "Date of Event": TextEditingController(),
          "Location": TextEditingController(),
          "Name of Institute": TextEditingController(),
          "Number of Plants Planted": TextEditingController(),
          "Major Species": TextEditingController(),
          "Detail Of Plants": TextEditingController(),
          "Number of Plants Utilized": TextEditingController(),
        });
        break;
      case "Farm / Agro Forestry":
        _controllers.addAll({
          "Employee Name": TextEditingController(),
          "Forest Division": TextEditingController(),
          "Name of Sub-Division / Range": TextEditingController(),
          "Plants Distributed Today": TextEditingController(),
          "Major Species": TextEditingController(),
          "Total No Of Plants Distributed": TextEditingController(),
        });
        break;
      case "Other Activity":
        _controllers.addAll({
          "Employee Name": TextEditingController(),
          "Activity Title": TextEditingController(),
          "Name of Forest Division": TextEditingController(),
          "Name of WO": TextEditingController(),
          "Name of Village": TextEditingController(),
          "Description": TextEditingController(),
        });
        break;
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
          selectedDocument = result.files.single;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Document selected: ${selectedDocument?.name}"),
            backgroundColor: widget.gradient.colors.first,
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

  Widget _buildMediaSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Attachments",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.gradient.colors.first,
            ),
          ),
          const SizedBox(height: 16),
          _buildImagePicker(),
          const SizedBox(height: 16),
          _buildDocumentPicker(),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: pickedImage != null
          ? Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              pickedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => pickedImage = null),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
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
            Icons.image_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            "Tap to add image",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return GestureDetector(
      onTap: () => _pickDocument(),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: selectedDocument != null
            ? Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description,
                    size: 32,
                    color: widget.gradient.colors.first,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedDocument?.name ?? "Document selected",
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
                    "${(selectedDocument?.size ?? 0) / 1024} KB",
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
                onTap: () => setState(() => selectedDocument = null),
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
              Icons.description,
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
          ],
        ),
      ),
    );
  }

  Widget _buildText(String label, {TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _controllers[label],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(
            color: widget.gradient.colors.first,
            fontWeight: FontWeight.w500,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.gradient.colors.first, width: 2),
          ),
        ),
        keyboardType: type,
        validator: (v) => v == null || v.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDate(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _controllers[label],
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today, color: widget.gradient.colors.first),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(
            color: widget.gradient.colors.first,
            fontWeight: FontWeight.w500,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.gradient.colors.first, width: 2),
          ),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(1980),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );
          if (!context.mounted) return;
          if (picked != null) _controllers[label]?.text = _fmt.format(picked);
        },
        validator: (v) => v == null || v.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(
            color: widget.gradient.colors.first,
            fontWeight: FontWeight.w500,
          ),
        ),
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildInterventionSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Main Interventions",
                  style: TextStyle(
                    color: widget.gradient.colors.first,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddInterventionDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.gradient.colors.first,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (addedInterventions.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addedInterventions.length,
              itemBuilder: (context, index) {
                final intervention = addedInterventions[index];
                return ListTile(
                  leading: Icon(Icons.eco, color: widget.gradient.colors.first),
                  title: Text(intervention['name'] ?? ''),
                  subtitle: Text("Number: ${intervention['number'] ?? ''}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        addedInterventions.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAddInterventionDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Intervention"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Intervention Name",
                hintText: "Enter intervention name",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: "Number",
                hintText: "Enter number",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  addedInterventions.add({
                    'name': nameController.text,
                    'number': numberController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddPlantDistributionDialog() {
    _plantTypeController.clear();
    _plantNumberController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Detail of Plants"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _plantTypeController,
              decoration: const InputDecoration(
                labelText: "Plant Type / Species",
                hintText: "Enter plant type",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _plantNumberController,
              decoration: const InputDecoration(
                labelText: "Number of Plants",
                hintText: "Enter number",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_plantTypeController.text.isNotEmpty && _plantNumberController.text.isNotEmpty) {
                setState(() {
                  plantDistributionList.add({
                    'type': _plantTypeController.text,
                    'number': _plantNumberController.text,
                    'date': DateTime.now().toString().split(' ')[0],
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantDistributionSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Detail Of Plants",
                  style: TextStyle(
                    color: widget.gradient.colors.first,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddPlantDistributionDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.gradient.colors.first,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (plantDistributionList.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plantDistributionList.length,
              itemBuilder: (context, index) {
                final plant = plantDistributionList[index];
                return ListTile(
                  leading: Icon(Icons.eco, color: widget.gradient.colors.first),
                  title: Text(plant['type'] ?? ''),
                  subtitle: Text("Number: ${plant['number'] ?? ''} | Date: ${plant['date'] ?? ''}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        plantDistributionList.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    switch (widget.activity) {
      case "Women Organization":
        return [
          _buildMediaSection(),
          _buildText("Employee Name"),
          _buildDropdown("Forest Region", regions, selectedRegion, (value) => setState(() => selectedRegion = value)),
          _buildText("Name Of Forest Circle"),
          _buildText("Name of Forest Division"),
          _buildText("Name of Sub Division / Range "),
          _buildText("Name of Village / PU"),
          _buildText("Refrence Coordinates of Village / PU"),
          _buildText("Name of WO"),
          _buildText("Name of Project Under Which Established"),
          _buildDate("Date / Year of Establishment"),
          _buildText("Name of Chairperson"),
          _buildText("Sectary / Treasurer "),
          _buildText("Contact Number"),
          _buildInterventionSection(),
        ];
      case "Women Nursery":// new remove ka
        return [
          _buildMediaSection(),
          _buildText("Employee Name"),
          _buildDropdown("Forest Region", regions, selectedRegion, (value) => setState(() => selectedRegion = value)),
          _buildText("Name of Forest Circle"),
          _buildText("Name of Division"),
          _buildText("Name of Sub-division | Range"),
          _buildText("Name Of WO"),
          _buildText("Name of Project Under Which Established"),
          _buildDropdown("Type Of Nursery", nurseryTypes, selectedNurseryType, (value) => setState(() => selectedNurseryType = value)),
          _buildText("Name of Nursery Grower"),
          _buildText("Contact Number", type: TextInputType.phone),
          _buildText("CNIC of Nursery Grower"),
          _buildDate("Date Of Agreement"),
          _buildText("Refrence Coordinates"),
          _buildText("Location | Village | Site Name"),
          _buildText("No of Unit/No of Plants", type: TextInputType.number),
          _buildDate("Date of Establishment"),
        ];
      case "Mass Planting Event":
        return [
          _buildMediaSection(),
          _buildText("Employee Name"),
          _buildDropdown("Name Of Forest Region", regions, selectedRegion, (value) => setState(() => selectedRegion = value)),
          _buildText("Name of Forest Circle"),
          _buildText("Name of Division"),
          _buildText("Name Of Project"),
          _buildText("Name of Sub-Division / Range"),
          _buildText("Name of Institute / Organization"),
          _buildText("Location / Venue"),
          _buildText("Chief Guest"),
          _buildDate("Date of Event"),// instad of plant distribution writ detail of plants.
          _buildPlantDistributionSection(),
        ];
      case "Farm / Agro Forestry":
        return [
          _buildMediaSection(),
          _buildText("Employee Name"),
          _buildText("Forest Division"),
          _buildText("Name of Sub Division"),
          _buildText("Plants Distributed Today", type: TextInputType.number),
          _buildText("Major Species"),
          _buildText("Total No Of Plants Distributed", type: TextInputType.number),
        ];
      case "Other Activity":
        return [
          _buildMediaSection(),
          _buildText("Employee Name"),
          _buildDropdown("Name Of Forest Region", regions, selectedRegion, (value) => setState(() => selectedRegion = value)),
          _buildText("Name of Forest Circle"),
          _buildText("Name of Division"),
          _buildText("Name of Sub-Division / Range"),
          _buildText("Name Of Project"),
          _buildText("Name of WO"),
          _buildText("Name of Village"),
          _buildText("Activity Title"),
          _buildText("Activity Description"),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.gradient.colors.first.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFormHeader(),
              Expanded(child: _buildForm()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  " ${widget.activity}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Fill in the required information",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEditOptions(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
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
            Text(
              "Edit Options",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.gradient.colors.first,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.gradient.colors.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, color: widget.gradient.colors.first),
              ),
              title: const Text("Edit Form Data"),
              subtitle: const Text("Modify existing form entries"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Edit mode activated"),
                    backgroundColor: widget.gradient.colors.first,
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ..._buildFormFields(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _isSubmitting ? null : _submitForm,
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Submit Form",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Add help functionality
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Help - ${widget.activity}'),
            content: const Text('Fill in all the required fields and attach an image and document to submit the form.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      backgroundColor: widget.gradient.colors.first,
      child: const Icon(Icons.help_outline, color: Colors.white),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (pickedImage == null && selectedDocument == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please add an image and document"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Form submitted successfully!"),
            backgroundColor: widget.gradient.colors.first,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}